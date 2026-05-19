// Copyright (c) 2014-2017 The btcsuite developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

package rpcclient

import (
	"bytes"
	"container/list"
	"context"
	"crypto/tls"
	"crypto/x509"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"os"
	"sync"
	"sync/atomic"
	"time"

	"github.com/btcsuite/btcd/chaincfg"
	"github.com/rs/zerolog"

	"github.com/barebitcoin/btc-buf/rpcclient/btcjson"
)

var (
	// ErrInvalidAuth is an error to describe the condition where the client
	// is either unable to authenticate or the specified endpoint is
	// incorrect.
	ErrInvalidAuth = errors.New("authentication failure")

	// ErrClientDisconnect is an error to describe the condition where the
	// client has been disconnected from the RPC server.  When the
	// DisableAutoReconnect option is not set, any outstanding futures
	// when a client disconnect occurs will return this error as will
	// any new requests.
	ErrClientDisconnect = errors.New("the client has been disconnected")

	// ErrClientShutdown is an error to describe the condition where the
	// client is either already shutdown, or in the process of shutting
	// down.  Any outstanding futures when a client shutdown occurs will
	// return this error as will any new requests.
	ErrClientShutdown = errors.New("the client has been shutdown")
)

const (
	sendBufferSize = 50

	sendPostBufferSize = 100
)

// jsonRequest holds information about a json request that is used to properly
// detect, interpret, and deliver a reply to it.
type jsonRequest struct {
	ctx            context.Context // bad, but no way around due to the spaghetti...
	id             uint64
	method         string
	cmd            interface{}
	marshalledJSON []byte
	responseChan   chan *Response
}

// Client represents a Bitcoin RPC client which allows easy access to the
// various RPC methods available on a Bitcoin RPC server.  Each of the wrapper
// functions handle the details of converting the passed and return types to and
// from the underlying JSON types which are required for the JSON-RPC
// invocations
//
// The client provides each RPC in both synchronous (blocking) and asynchronous
// (non-blocking) forms.  The asynchronous forms are based on the concept of
// futures where they return an instance of a type that promises to deliver the
// result of the invocation at some future time.  Invoking the Receive method on
// the returned future will block until the result is available if it's not
// already.
type Client struct {
	id uint64 // atomic, so must stay 64-bit aligned

	// config holds the connection configuration associated with this client.
	config *ConnConfig

	// chainParams holds the params for the chain that this client is using,
	// and is used for many wallet methods.
	chainParams *chaincfg.Params

	// httpClient is the underlying HTTP client to use when running in HTTP
	// POST mode.
	httpClient *http.Client

	// backendVersion is the version of the backend the client is currently
	// connected to. This should be retrieved through GetVersion.
	backendVersionMu sync.Mutex
	backendVersion   BackendVersion

	// whether or not to batch requests, false unless changed by Batch()
	batch     bool
	batchList *list.List

	// Track command and their response channels by ID.
	requestLock sync.Mutex
	requestMap  map[uint64]*list.Element
	requestList *list.List

	// Networking infrastructure.
	sendChan     chan []byte
	sendPostChan chan *jsonRequest
	disconnect   chan struct{}
	shutdown     chan struct{}
	wg           sync.WaitGroup
}

// NextID returns the next id to be used when sending a JSON-RPC message.  This
// ID allows responses to be associated with particular requests per the
// JSON-RPC specification.  Typically the consumer of the client does not need
// to call this function, however, if a custom request is being created and used
// this function should be used to ensure the ID is unique amongst all requests
// being made.
func (c *Client) NextID() uint64 {
	return atomic.AddUint64(&c.id, 1)
}

// addRequest associates the passed jsonRequest with its id.  This allows the
// response from the remote server to be unmarshalled to the appropriate type
// and sent to the specified channel when it is received.
//
// If the client has already begun shutting down, ErrClientShutdown is returned
// and the request is not added.
//
// This function is safe for concurrent access.
func (c *Client) addRequest(jReq *jsonRequest) error {
	c.requestLock.Lock()
	defer c.requestLock.Unlock()

	// A non-blocking read of the shutdown channel with the request lock
	// held avoids adding the request to the client's internal data
	// structures if the client is in the process of shutting down (and
	// has not yet grabbed the request lock), or has finished shutdown
	// already (responding to each outstanding request with
	// ErrClientShutdown).
	select {
	case <-c.shutdown:
		return ErrClientShutdown
	default:
	}

	if !c.batch {
		element := c.requestList.PushBack(jReq)
		c.requestMap[jReq.id] = element
	} else {
		element := c.batchList.PushBack(jReq)
		c.requestMap[jReq.id] = element
	}
	return nil
}

// removeRequest returns and removes the jsonRequest which contains the response
// channel and original method associated with the passed id or nil if there is
// no association.
//
// This function is safe for concurrent access.
func (c *Client) removeRequest(id uint64) *jsonRequest {
	c.requestLock.Lock()
	defer c.requestLock.Unlock()

	element, ok := c.requestMap[id]
	if !ok {
		return nil
	}

	delete(c.requestMap, id)

	var request *jsonRequest
	if c.batch {
		request = c.batchList.Remove(element).(*jsonRequest)
	} else {
		request = c.requestList.Remove(element).(*jsonRequest)
	}

	return request
}

// removeAllRequests removes all the jsonRequests which contain the response
// channels for outstanding requests.
//
// This function MUST be called with the request lock held.
func (c *Client) removeAllRequests() {
	c.requestMap = make(map[uint64]*list.Element)
	c.requestList.Init()
}

// FutureGetBulkResult waits for the responses promised by the future
// and returns them in a channel
type FutureGetBulkResult chan *Response

// Receive waits for the response promised by the future and returns an map
// of results by request id
func (r FutureGetBulkResult) Receive() (BulkResult, error) {
	m := make(BulkResult)
	res, err := ReceiveFuture(r)
	if err != nil {
		return nil, err
	}
	var arr []IndividualBulkResult
	err = json.Unmarshal(res, &arr)
	if err != nil {
		return nil, err
	}

	for _, results := range arr {
		m[results.Id] = results
	}

	return m, nil
}

// IndividualBulkResult represents one result
// from a bulk json rpc api
type IndividualBulkResult struct {
	Result interface{}       `json:"result"`
	Error  *btcjson.RPCError `json:"error"`
	Id     uint64            `json:"id"`
}

type BulkResult = map[uint64]IndividualBulkResult

// rawResponse is a partially-unmarshaled JSON-RPC response.  For this
// to be valid (according to JSON-RPC 1.0 spec), ID may not be nil.
type rawResponse struct {
	Result json.RawMessage   `json:"result"`
	Error  *btcjson.RPCError `json:"error"`
}

// Response is the raw bytes of a JSON-RPC result, or the error if the response
// error object was non-null.
type Response struct {
	result []byte
	err    error
}

// result checks whether the unmarshaled response contains a non-nil error,
// returning an unmarshaled btcjson.RPCError (or an unmarshalling error) if so.
// If the response is not an error, the raw bytes of the request are
// returned for further unmashaling into specific result types.
func (r rawResponse) result() (result []byte, err error) {
	if r.Error != nil {
		return nil, r.Error
	}
	return r.Result, nil
}

// handleSendPostMessage handles performing the passed HTTP request, reading the
// result, unmarshalling it, and delivering the unmarshalled result to the
// provided response channel.
func (c *Client) handleSendPostMessage(jReq *jsonRequest) {
	protocol := "http"
	if !c.config.DisableTLS {
		protocol = "https"
	}

	url := protocol + "://" + c.config.Host

	var httpReq *http.Request

	bodyReader := bytes.NewReader(jReq.marshalledJSON)
	httpReq, err := http.NewRequestWithContext(jReq.ctx, "POST", url, bodyReader)
	if err != nil {
		jReq.responseChan <- &Response{result: nil, err: err}
		return
	}
	httpReq.Close = true
	httpReq.Header.Set("Content-Type", "application/json")
	for key, value := range c.config.ExtraHeaders {
		httpReq.Header.Set(key, value)
	}

	// Configure basic access authorization.
	user, pass, err := c.config.getAuth()
	if err != nil {
		jReq.responseChan <- &Response{result: nil, err: err}
		return
	}
	httpReq.SetBasicAuth(user, pass)

	httpResponse, err := c.httpClient.Do(httpReq)
	// Immediately handle the result, no retry
	if err != nil {
		jReq.responseChan <- &Response{err: err}
		return
	}

	// We still want to return an error if for any reason the response
	// remains empty.
	if httpResponse == nil {
		jReq.responseChan <- &Response{
			err: fmt.Errorf("invalid http POST response (nil), "+
				"method: %s, id: %d",
				jReq.method, jReq.id),
		}
		return
	}

	// Read the raw bytes and close the response.
	respBytes, err := io.ReadAll(httpResponse.Body)
	_ = httpResponse.Body.Close()
	if err != nil {
		err = fmt.Errorf("error reading json reply: %v", err)
		jReq.responseChan <- &Response{err: err}
		return
	}

	// Try to unmarshal the response as a regular JSON-RPC response.
	var resp rawResponse
	var batchResponse json.RawMessage
	if c.batch {
		err = json.Unmarshal(respBytes, &batchResponse)
	} else {
		err = json.Unmarshal(respBytes, &resp)
	}
	if err != nil {
		// When the response itself isn't a valid JSON-RPC response
		// return an error which includes the HTTP status code and raw
		// response bytes.
		err = fmt.Errorf("status code: %d, response: %q",
			httpResponse.StatusCode, string(respBytes))
		jReq.responseChan <- &Response{err: err}
		return
	}
	var res []byte
	if c.batch {
		// errors must be dealt with downstream since a whole request cannot
		// "error out" other than through the status code error handled above
		res, err = batchResponse, nil
	} else {
		res, err = resp.result()
	}
	jReq.responseChan <- &Response{result: res, err: err}
}

// sendPostHandler handles all outgoing messages when the client is running
// in HTTP POST mode.  It uses a buffered channel to serialize output messages
// while allowing the sender to continue running asynchronously.  It must be run
// as a goroutine.
func (c *Client) sendPostHandler(ctx context.Context) {
out:
	for {
		// Send any messages ready for send until the shutdown channel
		// is closed.
		select {
		case jReq := <-c.sendPostChan:
			c.handleSendPostMessage(jReq)

		case <-c.shutdown:
			break out
		}
	}

	// Drain any wait channels before exiting so nothing is left waiting
	// around to send.
cleanup:
	for {
		select {
		case jReq := <-c.sendPostChan:
			jReq.responseChan <- &Response{
				result: nil,
				err:    ErrClientShutdown,
			}

		default:
			break cleanup
		}
	}
	c.wg.Done()
	zerolog.Ctx(ctx).Trace().Msgf("RPC client send handler done for %s", c.config.Host)
}

// sendPostRequest sends the passed HTTP request to the RPC server using the
// HTTP client associated with the client.  It is backed by a buffered channel,
// so it will not block until the send channel is full.
func (c *Client) sendPostRequest(jReq *jsonRequest) {
	// Don't send the message if shutting down.
	select {
	case <-c.shutdown:
		jReq.responseChan <- &Response{result: nil, err: ErrClientShutdown}
	default:
	}

	select {
	case c.sendPostChan <- jReq:
		zerolog.Ctx(jReq.ctx).Trace().Msgf("Sent command [%s] with id %d", jReq.method, jReq.id)

	case <-c.shutdown:
		return
	}
}

// newFutureError returns a new future result channel that already has the
// passed error waitin on the channel with the reply set to nil.  This is useful
// to easily return errors from the various Async functions.
func newFutureError(err error) chan *Response {
	responseChan := make(chan *Response, 1)
	responseChan <- &Response{err: err}
	return responseChan
}

// Expose newFutureError for developer usage when creating custom commands.
func NewFutureError(err error) chan *Response {
	return newFutureError(err)
}

// ReceiveFuture receives from the passed futureResult channel to extract a
// reply or any errors.  The examined errors include an error in the
// futureResult and the error in the reply from the server.  This will block
// until the result is available on the passed channel.
func ReceiveFuture(f chan *Response) ([]byte, error) {
	// Wait for a response on the returned channel.
	r := <-f
	return r.result, r.err
}

// sendRequest sends the passed json request to the associated server using the
// provided response channel for the reply.  It handles both websocket and HTTP
// POST mode depending on the configuration of the client.
func (c *Client) sendRequest(jReq *jsonRequest) {
	if c.batch {
		if err := c.addRequest(jReq); err != nil {
			zerolog.Ctx(jReq.ctx).Warn().Msg(err.Error())
		}
	} else {
		c.sendPostRequest(jReq)
	}
}

// SendCmd sends the passed command to the associated server and returns a
// response channel on which the reply will be delivered at some point in the
// future.  It handles both websocket and HTTP POST mode depending on the
// configuration of the client.
func (c *Client) SendCmd(ctx context.Context, cmd interface{}) chan *Response {
	rpcVersion := btcjson.RpcVersion1
	if c.batch {
		rpcVersion = btcjson.RpcVersion2
	}
	// Get the method associated with the command.
	method, err := btcjson.CmdMethod(cmd)
	if err != nil {
		return newFutureError(err)
	}

	// Marshal the command.
	id := c.NextID()
	marshalledJSON, err := btcjson.MarshalCmd(rpcVersion, id, cmd)
	if err != nil {
		return newFutureError(err)
	}

	zerolog.Ctx(ctx).Debug().Msgf("%s/%d: sending marshalled JSON: %s",
		method, id, string(marshalledJSON))

	// Generate the request and send it along with a channel to respond on.
	responseChan := make(chan *Response, 1)
	jReq := &jsonRequest{
		ctx:            ctx,
		id:             id,
		method:         method,
		cmd:            cmd,
		marshalledJSON: marshalledJSON,
		responseChan:   responseChan,
	}

	c.sendRequest(jReq)

	return responseChan
}

// sendCmdAndWait sends the passed command to the associated server, waits
// for the reply, and returns the result from it.  It will return the error
// field in the reply if there is one.
func (c *Client) sendCmdAndWait(ctx context.Context, cmd interface{}) (interface{}, error) {
	// Marshal the command to JSON-RPC, send it to the connected server, and
	// wait for a response on the returned channel.
	return ReceiveFuture(c.SendCmd(ctx, cmd))
}

// doShutdown closes the shutdown channel and logs the shutdown unless shutdown
// is already in progress.  It will return false if the shutdown is not needed.
//
// This function is safe for concurrent access.
func (c *Client) doShutdown(ctx context.Context) bool {
	// Ignore the shutdown request if the client is already in the process
	// of shutting down or already shutdown.
	select {
	case <-c.shutdown:
		return false
	default:
	}

	zerolog.Ctx(ctx).Trace().Msgf("Shutting down RPC client %s", c.config.Host)
	close(c.shutdown)
	return true
}

// Shutdown shuts down the client by disconnecting any connections associated
// with the client and, when automatic reconnect is enabled, preventing future
// attempts to reconnect.  It also stops all goroutines.
func (c *Client) Shutdown(ctx context.Context) {
	// Do the shutdown under the request lock to prevent clients from
	// adding new requests while the client shutdown process is initiated.
	c.requestLock.Lock()
	defer c.requestLock.Unlock()

	// Ignore the shutdown request if the client is already in the process
	// of shutting down or already shutdown.
	if !c.doShutdown(ctx) {
		return
	}

	// Send the ErrClientShutdown error to any pending requests.
	for e := c.requestList.Front(); e != nil; e = e.Next() {
		req := e.Value.(*jsonRequest)
		req.responseChan <- &Response{
			result: nil,
			err:    ErrClientShutdown,
		}
	}
	c.removeAllRequests()
}

// start begins processing input and output messages.
func (c *Client) start(ctx context.Context) {
	zerolog.Ctx(ctx).Trace().Msgf("Starting RPC client %s", c.config.Host)

	// Start the I/O processing handlers depending on whether the client is
	// in HTTP POST mode or the default websocket mode.
	c.wg.Add(1)
	go c.sendPostHandler(ctx)
}

// WaitForShutdown blocks until the client goroutines are stopped and the
// connection is closed.
func (c *Client) WaitForShutdown() {
	c.wg.Wait()
}

// ConnConfig describes the connection configuration parameters for the client.
// This
type ConnConfig struct {
	// Host is the IP address and port of the RPC server you want to connect
	// to.
	Host string

	// Endpoint is the websocket endpoint on the RPC server.  This is
	// typically "ws".
	Endpoint string

	// User is the username to use to authenticate to the RPC server.
	User string

	// Pass is the passphrase to use to authenticate to the RPC server.
	Pass string

	// CookiePath is the path to a cookie file containing the username and
	// passphrase to use to authenticate to the RPC server.  It is used
	// instead of User and Pass if non-empty.
	CookiePath string

	cookieLastCheckTime time.Time
	cookieLastModTime   time.Time
	cookieLastUser      string
	cookieLastPass      string
	cookieLastErr       error

	// Params is the string representing the network that the server
	// is running. If there is no parameter set in the config, then
	// mainnet will be used by default.
	Params string

	// DisableTLS specifies whether transport layer security should be
	// disabled.  It is recommended to always use TLS if the RPC server
	// supports it as otherwise your username and password is sent across
	// the wire in cleartext.
	DisableTLS bool

	// Certificates are the bytes for a PEM-encoded certificate chain used
	// for the TLS connection.  It has no effect if the DisableTLS parameter
	// is true.
	Certificates []byte

	// Proxy specifies to connect through a SOCKS 5 proxy server.  It may
	// be an empty string if a proxy is not required.
	Proxy string

	// ProxyUser is an optional username to use for the proxy server if it
	// requires authentication.  It has no effect if the Proxy parameter
	// is not set.
	ProxyUser string

	// ProxyPass is an optional password to use for the proxy server if it
	// requires authentication.  It has no effect if the Proxy parameter
	// is not set.
	ProxyPass string

	// DisableAutoReconnect specifies the client should not automatically
	// try to reconnect to the server when it has been disconnected.
	DisableAutoReconnect bool

	// DisableConnectOnNew specifies that a websocket client connection
	// should not be tried when creating the client with New.  Instead, the
	// client is created and returned unconnected, and Connect must be
	// called manually.
	DisableConnectOnNew bool

	// ExtraHeaders specifies the extra headers when perform request. It's
	// useful when RPC provider need customized headers.
	ExtraHeaders map[string]string

	// EnableBCInfoHacks is an option provided to enable compatibility hacks
	// when connecting to blockchain.info RPC server
	EnableBCInfoHacks bool
}

// getAuth returns the username and passphrase that will actually be used for
// this connection.  This will be the result of checking the cookie if a cookie
// path is configured; if not, it will be the user-configured username and
// passphrase.
func (config *ConnConfig) getAuth() (username, passphrase string, err error) {
	// Try username+passphrase auth first.
	if config.Pass != "" {
		return config.User, config.Pass, nil
	}

	// If no username or passphrase is set, try cookie auth.
	return config.retrieveCookie()
}

// retrieveCookie returns the cookie username and passphrase.
func (config *ConnConfig) retrieveCookie() (username, passphrase string, err error) {
	if !config.cookieLastCheckTime.IsZero() && time.Now().Before(config.cookieLastCheckTime.Add(30*time.Second)) {
		return config.cookieLastUser, config.cookieLastPass, config.cookieLastErr
	}

	config.cookieLastCheckTime = time.Now()

	st, err := os.Stat(config.CookiePath)
	if err != nil {
		config.cookieLastErr = err
		return config.cookieLastUser, config.cookieLastPass, config.cookieLastErr
	}

	modTime := st.ModTime()
	if !modTime.Equal(config.cookieLastModTime) {
		config.cookieLastModTime = modTime
		config.cookieLastUser, config.cookieLastPass, config.cookieLastErr = readCookieFile(config.CookiePath)
	}

	return config.cookieLastUser, config.cookieLastPass, config.cookieLastErr
}

// newHTTPClient returns a new http client that is configured according to the
// proxy and TLS settings in the associated connection configuration.
func newHTTPClient(config *ConnConfig) (*http.Client, error) {
	// Set proxy function if there is a proxy configured.
	var proxyFunc func(*http.Request) (*url.URL, error)
	if config.Proxy != "" {
		proxyURL, err := url.Parse(config.Proxy)
		if err != nil {
			return nil, err
		}
		proxyFunc = http.ProxyURL(proxyURL)
	}

	// Configure TLS if needed.
	var tlsConfig *tls.Config
	if !config.DisableTLS {
		if len(config.Certificates) > 0 {
			pool := x509.NewCertPool()
			pool.AppendCertsFromPEM(config.Certificates)
			tlsConfig = &tls.Config{
				RootCAs: pool,
			}
		}
	}

	client := http.Client{
		Transport: &http.Transport{
			Proxy:           proxyFunc,
			TLSClientConfig: tlsConfig,
		},
	}

	return &client, nil
}

// New creates a new RPC client based on the provided connection configuration
// details.  The notification handlers parameter may be nil if you are not
// interested in receiving notifications and will be ignored if the
// configuration is set to run in HTTP POST mode.
func New(ctx context.Context, config *ConnConfig) (*Client, error) {
	// Either open a websocket connection or create an HTTP client depending
	// on the HTTP POST mode.  Also, set the notification handlers to nil
	// when running in HTTP POST mode.
	var httpClient *http.Client
	start := true

	var err error
	httpClient, err = newHTTPClient(config)
	if err != nil {
		return nil, err
	}

	client := &Client{
		config:       config,
		httpClient:   httpClient,
		requestMap:   make(map[uint64]*list.Element),
		requestList:  list.New(),
		batch:        false,
		batchList:    list.New(),
		sendChan:     make(chan []byte, sendBufferSize),
		sendPostChan: make(chan *jsonRequest, sendPostBufferSize),
		disconnect:   make(chan struct{}),
		shutdown:     make(chan struct{}),
	}

	// Default network is mainnet, no parameters are necessary but if mainnet
	// is specified it will be the param
	switch config.Params {
	case "":
		fallthrough
	case chaincfg.MainNetParams.Name:
		client.chainParams = &chaincfg.MainNetParams
	case chaincfg.TestNet3Params.Name:
		client.chainParams = &chaincfg.TestNet3Params
	case chaincfg.RegressionNetParams.Name:
		client.chainParams = &chaincfg.RegressionNetParams
	case chaincfg.SigNetParams.Name:
		client.chainParams = &chaincfg.SigNetParams
	case chaincfg.SimNetParams.Name:
		client.chainParams = &chaincfg.SimNetParams
	default:
		return nil, fmt.Errorf("rpcclient.New: Unknown chain %s", config.Params)
	}

	if start {
		client.start(ctx)
	}

	return client, nil
}

// Batch is a factory that creates a client able to interact with the server using
// JSON-RPC 2.0. The client is capable of accepting an arbitrary number of requests
// and having the server process the all at the same time. It's compatible with both
// btcd and bitcoind
func NewBatch(ctx context.Context, config *ConnConfig) (*Client, error) {
	client, err := New(ctx, config)
	if err != nil {
		return nil, err
	}
	client.batch = true // copy the client with changed batch setting
	client.start(ctx)
	return client, nil
}

// BackendVersion retrieves the version of the backend the client is currently
// connected to.
func (c *Client) BackendVersion(ctx context.Context) (BackendVersion, error) {
	c.backendVersionMu.Lock()
	defer c.backendVersionMu.Unlock()

	if c.backendVersion != nil {
		return c.backendVersion, nil
	}

	// We'll start by calling GetInfo. This method doesn't exist for
	// bitcoind nodes as of v0.16.0, so we'll assume the client is connected
	// to a btcd backend if it does exist.
	info, err := c.GetInfo(ctx)

	switch err := err.(type) {
	// Parse the btcd version and cache it.
	case nil:
		zerolog.Ctx(ctx).Debug().Msgf("Detected btcd version: %v", info.Version)
		version := parseBtcdVersion(info.Version)
		c.backendVersion = version
		return c.backendVersion, nil

	// Inspect the RPC error to ensure the method was not found, otherwise
	// we actually ran into an error.
	case *btcjson.RPCError:
		if err.Code != btcjson.ErrRPCMethodNotFound.Code {
			return nil, fmt.Errorf("unable to detect btcd version: "+
				"%v", err)
		}

	default:
		return nil, fmt.Errorf("unable to detect btcd version: %v", err)
	}

	// Since the GetInfo method was not found, we assume the client is
	// connected to a bitcoind backend, which exposes its version through
	// GetNetworkInfo.
	networkInfo, err := c.GetNetworkInfo(ctx)
	if err != nil {
		return nil, fmt.Errorf("unable to detect bitcoind version: %v",
			err)
	}

	// Parse the bitcoind version and cache it.
	zerolog.Ctx(ctx).Debug().Msgf("Detected bitcoind version: %v", networkInfo.SubVersion)
	version := parseBitcoindVersion(networkInfo.SubVersion)
	c.backendVersion = &version

	return c.backendVersion, nil
}

func (c *Client) sendAsync(ctx context.Context) FutureGetBulkResult {
	// convert the array of marshalled json requests to a single request we can send
	responseChan := make(chan *Response, 1)
	marshalledRequest := []byte("[")
	for iter := c.batchList.Front(); iter != nil; iter = iter.Next() {
		request := iter.Value.(*jsonRequest)
		marshalledRequest = append(marshalledRequest, request.marshalledJSON...)
		marshalledRequest = append(marshalledRequest, []byte(",")...)
	}
	if len(marshalledRequest) > 0 {
		// removes the trailing comma to process the request individually
		marshalledRequest = marshalledRequest[:len(marshalledRequest)-1]
	}
	marshalledRequest = append(marshalledRequest, []byte("]")...)
	request := jsonRequest{
		ctx:            ctx,
		id:             c.NextID(),
		method:         "",
		cmd:            nil,
		marshalledJSON: marshalledRequest,
		responseChan:   responseChan,
	}
	c.sendPostRequest(&request)
	return responseChan
}

// Marshall's bulk requests and sends to the server
// creates a response channel to receive the response
func (c *Client) Send(ctx context.Context) error {
	// if batchlist is empty, there's nothing to send
	if c.batchList.Len() == 0 {
		return nil
	}

	batchResp, err := c.sendAsync(ctx).Receive()
	if err != nil {
		// Clear batchlist in case of an error.
		//
		// TODO(yy): need to double check to make sure there's no
		// concurrent access to this batch list, otherwise we may miss
		// some batched requests.
		c.batchList = list.New()

		return err
	}

	// Iterate each response and send it to the corresponding request.
	for id, resp := range batchResp {
		// Perform a GC on batchList and requestMap before moving
		// forward.
		request := c.removeRequest(id)

		// If there's an error, we log it and continue to the next
		// request.
		fullResult, err := json.Marshal(resp.Result)
		if err != nil {
			zerolog.Ctx(ctx).Error().Msgf("Unable to marshal result: %v for req=%v",
				err, request.id)

			continue
		}

		// If there's a response error, we send it back the request.
		var requestError error
		if resp.Error != nil {
			requestError = resp.Error
		}

		result := Response{
			result: fullResult,
			err:    requestError,
		}
		request.responseChan <- &result
	}

	return nil
}
