extends Control

# Default RPC ports for various services
# In Flutter: Store these in a configuration class
const DEFAULT_BITCOIN_RPC_PORT : int = 38332
const DEFAULT_WALLET_RPC_PORT : int = 38332
const DEFAULT_CUSF_CAT_RPC_PORT : int = -1 # TODO currently unknown
const DEFAULT_CUSF_DRIVECHAIN_RPC_PORT : int = 50051 

# Debug flag for logging request details
const DEBUG_REQUESTS : bool = true

# GRPC endpoint for drivechain tip validation
# In Flutter: Store in a configuration class or enum
const GRPC_CUSF_DRIVECHAIN_GET_TIP : String = "cusf.mainchain.v1.ValidatorService.GetChainTip"

# Status update signals
# In Flutter: Use Streams or callbacks for status updates
signal btc_new_block_count(height : int)
signal cusf_drivechain_responded(height : int)
signal thunder_new_block_count(height : int)

# Error signals
# In Flutter: Use error callbacks or error Streams
signal btc_rpc_failed()
signal cusf_drivechain_rpc_failed()
signal thunder_cli_failed()

# Authentication cookie for Bitcoin Core RPC
# TODO: Implement proper cookie-based authentication
# In Flutter: Use secure storage for credentials
var core_auth_cookie : String = "user:password"

# HTTP request nodes for RPC calls
# In Flutter: Use http package or dio for HTTP requests
@onready var http_rpc_btc_get_block_count: HTTPRequest = $BitcoinCoreRPC/HTTPRPCBTCGetBlockCount
@onready var http_rpc_btc_stop: HTTPRequest = $BitcoinCoreRPC/HTTPRPCBTCStop

# Make RPC call to get Bitcoin block count
# In Flutter: Use http package for RPC calls
func rpc_bitcoin_getblockcount() -> void:
    make_rpc_request(DEFAULT_BITCOIN_RPC_PORT, "getblockcount", [], http_rpc_btc_get_block_count)

# Make RPC call to stop Bitcoin Core
# In Flutter: Use http package for RPC calls
func rpc_bitcoin_stop() -> void:
    make_rpc_request(DEFAULT_BITCOIN_RPC_PORT, "stop", [], http_rpc_btc_stop)

# Make GRPC call to get drivechain tip
# In Flutter: Use grpc package for GRPC calls
func grpc_enforcer_gettip() -> void:
    make_grpc_request(GRPC_CUSF_DRIVECHAIN_GET_TIP) 

# Execute Thunder CLI command to get block count
# In Flutter: Use process_run package for CLI execution
func cli_thunder_getblockcount() -> void:
    var user_dir = OS.get_user_data_dir()
    var output = []
    
    # Get platform-specific binary path
    var bin_path : String = ""
    match OS.get_name():
        "Linux":
            bin_path = str(user_dir, "/downloads/l2/thunder-cli-latest-x86_64-unknown-linux-gnu")
        "Windows":
            bin_path = str(user_dir, "/downloads/l2/thunder-cli-latest-x86_64-pc-windows-gnu.exe")
        "macOS":
            bin_path = str(user_dir, "/downloads/l2/thunder-cli-latest-x86_64-apple-darwin")
    
    # Execute CLI command and handle result
    var ret : int = OS.execute(bin_path,
        ["get-blockcount"],
        output,
        true)
    
    if DEBUG_REQUESTS:
        print("ret ", ret)
        print("output ", output)
        
    if ret != 0:
        thunder_cli_failed.emit()
    else:
        thunder_new_block_count.emit(0)

# Make GRPC request using grpcurl
# In Flutter: Use grpc package for native GRPC calls
func make_grpc_request(request : String) -> void:
    var user_dir = OS.get_user_data_dir()
    var output = []
    
    # Get platform-specific grpcurl binary path
    var bin_path : String = ""
    match OS.get_name():
        "Linux":
            bin_path = str(user_dir, "/downloads/l1/grpcurl")
        "Windows":
            bin_path = str(user_dir, "/downloads/l1/grpcurl.exe")
        "macOS":
            bin_path = str(user_dir, "/downloads/l1/grpcurl")
            
    # Execute grpcurl command
    var ret : int = OS.execute(bin_path,
        ["-plaintext",
        "localhost:50051",
        request],
        output,
        true)
    
    if DEBUG_REQUESTS:
        print("grpc ret ", ret)
        print("grpc output ", output)
        
    # Parse response for chain tip request
    var enforcer_height : int = 0
    if request == GRPC_CUSF_DRIVECHAIN_GET_TIP && output.size():
        var json = JSON.new()
        var error = json.parse(output[0])
        if error == OK:
            if DEBUG_REQUESTS:
                print("Parsed grpc json!")
            if !json.data.has("blockHeaderInfo"):
                printerr("gRPC response missing block header info!")
                cusf_drivechain_rpc_failed.emit()
                return
            enforcer_height = json.data["blockHeaderInfo"]["height"]
            
            if DEBUG_REQUESTS:
                print("Height from json? : ", enforcer_height)
        else:
            printerr("Failed to parse gRPC JSON response!")
            cusf_drivechain_rpc_failed.emit()
            return

    if ret != 0:
        cusf_drivechain_rpc_failed.emit()
    else:
        # TODO only emit the height when 
        # "cusf.mainchain.v1.ValidatorService.GetChainTip" is requested
        # But for now that's the only gRPC request being used
        cusf_drivechain_responded.emit(enforcer_height)

# Make JSON-RPC request to Bitcoin Core
# In Flutter: Use http package for RPC calls
func make_rpc_request(port : int, method: String, params: Variant, http_request: HTTPRequest) -> void:    
    # Get authentication credentials
    var auth = get_bitcoin_core_cookie()

    if DEBUG_REQUESTS:
        print("Auth Cookie: ", auth)
        
    # Prepare authentication header
    var auth_bytes = auth.to_utf8_buffer()
    var auth_encoded = Marshalls.raw_to_base64(auth_bytes)
    var headers: PackedStringArray = []
    headers.push_back("Authorization: Basic " + auth_encoded)
    headers.push_back("content-type: application/json")
    
    # Create JSON-RPC request
    var jsonrpc := JSONRPC.new()
    var req = jsonrpc.make_request(method, params, 1)
    
    # Make HTTP request
    http_request.request(str("http://", auth, "@127.0.0.1:", str(port)), headers, HTTPClient.METHOD_POST, JSON.stringify(req))

# Get Bitcoin Core authentication cookie
# In Flutter: Use secure storage for credentials
func get_bitcoin_core_cookie() -> String:
    # TODO: Implement proper cookie-based authentication
    if !core_auth_cookie.is_empty():
        return core_auth_cookie
    
    # Read cookie file if it exists
    var cookie_path : String = str("", "/regtest/.cookie")
    if !FileAccess.file_exists(cookie_path):
        return ""
        
    var file = FileAccess.open(cookie_path, FileAccess.READ)
    core_auth_cookie = file.get_as_text()
    
    return core_auth_cookie

# Parse JSON-RPC response
# In Flutter: Use dart:convert for JSON parsing
func parse_rpc_result(response_code, body) -> Dictionary:
    var res = {}
    var json = JSON.new()
    if response_code != 200:
        if body != null:
            var err = json.parse(body.get_string_from_utf8())
            if err == OK:
                printerr(json.get_data())
    else:
        var err = json.parse(body.get_string_from_utf8())
        if err == OK:
            res = json.get_data() as Dictionary
    
    return res

# Handle block count RPC response
# In Flutter: Use callback or Stream to handle response
func _on_http_rpc_btc_get_block_count_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
    var res = parse_rpc_result(response_code, body)
    var height : int = 0
    if res.has("result"):
        if DEBUG_REQUESTS:
            print_debug("Result: ", res.result)
        height = res.result
        btc_new_block_count.emit(height)
    else:
        if DEBUG_REQUESTS:
            print_debug("result error")
        btc_rpc_failed.emit()
