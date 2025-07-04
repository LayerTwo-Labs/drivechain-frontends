// Code generated by MockGen. DO NOT EDIT.
// Source: ../gen/cusf/mainchain/v1/mainchainv1connect/validator.connect.go
//
// Generated by this command:
//
//	mockgen -source=../gen/cusf/mainchain/v1/mainchainv1connect/validator.connect.go -destination=mocks/mock_validator.go -package=mocks
//

// Package mocks is a generated GoMock package.
package mocks

import (
	context "context"
	reflect "reflect"

	connect "connectrpc.com/connect"
	mainchainv1 "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/cusf/mainchain/v1"
	gomock "go.uber.org/mock/gomock"
)

// MockValidatorServiceClient is a mock of ValidatorServiceClient interface.
type MockValidatorServiceClient struct {
	ctrl     *gomock.Controller
	recorder *MockValidatorServiceClientMockRecorder
	isgomock struct{}
}

// MockValidatorServiceClientMockRecorder is the mock recorder for MockValidatorServiceClient.
type MockValidatorServiceClientMockRecorder struct {
	mock *MockValidatorServiceClient
}

// NewMockValidatorServiceClient creates a new mock instance.
func NewMockValidatorServiceClient(ctrl *gomock.Controller) *MockValidatorServiceClient {
	mock := &MockValidatorServiceClient{ctrl: ctrl}
	mock.recorder = &MockValidatorServiceClientMockRecorder{mock}
	return mock
}

// EXPECT returns an object that allows the caller to indicate expected use.
func (m *MockValidatorServiceClient) EXPECT() *MockValidatorServiceClientMockRecorder {
	return m.recorder
}

// GetBlockHeaderInfo mocks base method.
func (m *MockValidatorServiceClient) GetBlockHeaderInfo(arg0 context.Context, arg1 *connect.Request[mainchainv1.GetBlockHeaderInfoRequest]) (*connect.Response[mainchainv1.GetBlockHeaderInfoResponse], error) {
	m.ctrl.T.Helper()
	ret := m.ctrl.Call(m, "GetBlockHeaderInfo", arg0, arg1)
	ret0, _ := ret[0].(*connect.Response[mainchainv1.GetBlockHeaderInfoResponse])
	ret1, _ := ret[1].(error)
	return ret0, ret1
}

// GetBlockHeaderInfo indicates an expected call of GetBlockHeaderInfo.
func (mr *MockValidatorServiceClientMockRecorder) GetBlockHeaderInfo(arg0, arg1 any) *gomock.Call {
	mr.mock.ctrl.T.Helper()
	return mr.mock.ctrl.RecordCallWithMethodType(mr.mock, "GetBlockHeaderInfo", reflect.TypeOf((*MockValidatorServiceClient)(nil).GetBlockHeaderInfo), arg0, arg1)
}

// GetBlockInfo mocks base method.
func (m *MockValidatorServiceClient) GetBlockInfo(arg0 context.Context, arg1 *connect.Request[mainchainv1.GetBlockInfoRequest]) (*connect.Response[mainchainv1.GetBlockInfoResponse], error) {
	m.ctrl.T.Helper()
	ret := m.ctrl.Call(m, "GetBlockInfo", arg0, arg1)
	ret0, _ := ret[0].(*connect.Response[mainchainv1.GetBlockInfoResponse])
	ret1, _ := ret[1].(error)
	return ret0, ret1
}

// GetBlockInfo indicates an expected call of GetBlockInfo.
func (mr *MockValidatorServiceClientMockRecorder) GetBlockInfo(arg0, arg1 any) *gomock.Call {
	mr.mock.ctrl.T.Helper()
	return mr.mock.ctrl.RecordCallWithMethodType(mr.mock, "GetBlockInfo", reflect.TypeOf((*MockValidatorServiceClient)(nil).GetBlockInfo), arg0, arg1)
}

// GetBmmHStarCommitment mocks base method.
func (m *MockValidatorServiceClient) GetBmmHStarCommitment(arg0 context.Context, arg1 *connect.Request[mainchainv1.GetBmmHStarCommitmentRequest]) (*connect.Response[mainchainv1.GetBmmHStarCommitmentResponse], error) {
	m.ctrl.T.Helper()
	ret := m.ctrl.Call(m, "GetBmmHStarCommitment", arg0, arg1)
	ret0, _ := ret[0].(*connect.Response[mainchainv1.GetBmmHStarCommitmentResponse])
	ret1, _ := ret[1].(error)
	return ret0, ret1
}

// GetBmmHStarCommitment indicates an expected call of GetBmmHStarCommitment.
func (mr *MockValidatorServiceClientMockRecorder) GetBmmHStarCommitment(arg0, arg1 any) *gomock.Call {
	mr.mock.ctrl.T.Helper()
	return mr.mock.ctrl.RecordCallWithMethodType(mr.mock, "GetBmmHStarCommitment", reflect.TypeOf((*MockValidatorServiceClient)(nil).GetBmmHStarCommitment), arg0, arg1)
}

// GetChainInfo mocks base method.
func (m *MockValidatorServiceClient) GetChainInfo(arg0 context.Context, arg1 *connect.Request[mainchainv1.GetChainInfoRequest]) (*connect.Response[mainchainv1.GetChainInfoResponse], error) {
	m.ctrl.T.Helper()
	ret := m.ctrl.Call(m, "GetChainInfo", arg0, arg1)
	ret0, _ := ret[0].(*connect.Response[mainchainv1.GetChainInfoResponse])
	ret1, _ := ret[1].(error)
	return ret0, ret1
}

// GetChainInfo indicates an expected call of GetChainInfo.
func (mr *MockValidatorServiceClientMockRecorder) GetChainInfo(arg0, arg1 any) *gomock.Call {
	mr.mock.ctrl.T.Helper()
	return mr.mock.ctrl.RecordCallWithMethodType(mr.mock, "GetChainInfo", reflect.TypeOf((*MockValidatorServiceClient)(nil).GetChainInfo), arg0, arg1)
}

// GetChainTip mocks base method.
func (m *MockValidatorServiceClient) GetChainTip(arg0 context.Context, arg1 *connect.Request[mainchainv1.GetChainTipRequest]) (*connect.Response[mainchainv1.GetChainTipResponse], error) {
	m.ctrl.T.Helper()
	ret := m.ctrl.Call(m, "GetChainTip", arg0, arg1)
	ret0, _ := ret[0].(*connect.Response[mainchainv1.GetChainTipResponse])
	ret1, _ := ret[1].(error)
	return ret0, ret1
}

// GetChainTip indicates an expected call of GetChainTip.
func (mr *MockValidatorServiceClientMockRecorder) GetChainTip(arg0, arg1 any) *gomock.Call {
	mr.mock.ctrl.T.Helper()
	return mr.mock.ctrl.RecordCallWithMethodType(mr.mock, "GetChainTip", reflect.TypeOf((*MockValidatorServiceClient)(nil).GetChainTip), arg0, arg1)
}

// GetCoinbasePSBT mocks base method.
func (m *MockValidatorServiceClient) GetCoinbasePSBT(arg0 context.Context, arg1 *connect.Request[mainchainv1.GetCoinbasePSBTRequest]) (*connect.Response[mainchainv1.GetCoinbasePSBTResponse], error) {
	m.ctrl.T.Helper()
	ret := m.ctrl.Call(m, "GetCoinbasePSBT", arg0, arg1)
	ret0, _ := ret[0].(*connect.Response[mainchainv1.GetCoinbasePSBTResponse])
	ret1, _ := ret[1].(error)
	return ret0, ret1
}

// GetCoinbasePSBT indicates an expected call of GetCoinbasePSBT.
func (mr *MockValidatorServiceClientMockRecorder) GetCoinbasePSBT(arg0, arg1 any) *gomock.Call {
	mr.mock.ctrl.T.Helper()
	return mr.mock.ctrl.RecordCallWithMethodType(mr.mock, "GetCoinbasePSBT", reflect.TypeOf((*MockValidatorServiceClient)(nil).GetCoinbasePSBT), arg0, arg1)
}

// GetCtip mocks base method.
func (m *MockValidatorServiceClient) GetCtip(arg0 context.Context, arg1 *connect.Request[mainchainv1.GetCtipRequest]) (*connect.Response[mainchainv1.GetCtipResponse], error) {
	m.ctrl.T.Helper()
	ret := m.ctrl.Call(m, "GetCtip", arg0, arg1)
	ret0, _ := ret[0].(*connect.Response[mainchainv1.GetCtipResponse])
	ret1, _ := ret[1].(error)
	return ret0, ret1
}

// GetCtip indicates an expected call of GetCtip.
func (mr *MockValidatorServiceClientMockRecorder) GetCtip(arg0, arg1 any) *gomock.Call {
	mr.mock.ctrl.T.Helper()
	return mr.mock.ctrl.RecordCallWithMethodType(mr.mock, "GetCtip", reflect.TypeOf((*MockValidatorServiceClient)(nil).GetCtip), arg0, arg1)
}

// GetSidechainProposals mocks base method.
func (m *MockValidatorServiceClient) GetSidechainProposals(arg0 context.Context, arg1 *connect.Request[mainchainv1.GetSidechainProposalsRequest]) (*connect.Response[mainchainv1.GetSidechainProposalsResponse], error) {
	m.ctrl.T.Helper()
	ret := m.ctrl.Call(m, "GetSidechainProposals", arg0, arg1)
	ret0, _ := ret[0].(*connect.Response[mainchainv1.GetSidechainProposalsResponse])
	ret1, _ := ret[1].(error)
	return ret0, ret1
}

// GetSidechainProposals indicates an expected call of GetSidechainProposals.
func (mr *MockValidatorServiceClientMockRecorder) GetSidechainProposals(arg0, arg1 any) *gomock.Call {
	mr.mock.ctrl.T.Helper()
	return mr.mock.ctrl.RecordCallWithMethodType(mr.mock, "GetSidechainProposals", reflect.TypeOf((*MockValidatorServiceClient)(nil).GetSidechainProposals), arg0, arg1)
}

// GetSidechains mocks base method.
func (m *MockValidatorServiceClient) GetSidechains(arg0 context.Context, arg1 *connect.Request[mainchainv1.GetSidechainsRequest]) (*connect.Response[mainchainv1.GetSidechainsResponse], error) {
	m.ctrl.T.Helper()
	ret := m.ctrl.Call(m, "GetSidechains", arg0, arg1)
	ret0, _ := ret[0].(*connect.Response[mainchainv1.GetSidechainsResponse])
	ret1, _ := ret[1].(error)
	return ret0, ret1
}

// GetSidechains indicates an expected call of GetSidechains.
func (mr *MockValidatorServiceClientMockRecorder) GetSidechains(arg0, arg1 any) *gomock.Call {
	mr.mock.ctrl.T.Helper()
	return mr.mock.ctrl.RecordCallWithMethodType(mr.mock, "GetSidechains", reflect.TypeOf((*MockValidatorServiceClient)(nil).GetSidechains), arg0, arg1)
}

// GetTwoWayPegData mocks base method.
func (m *MockValidatorServiceClient) GetTwoWayPegData(arg0 context.Context, arg1 *connect.Request[mainchainv1.GetTwoWayPegDataRequest]) (*connect.Response[mainchainv1.GetTwoWayPegDataResponse], error) {
	m.ctrl.T.Helper()
	ret := m.ctrl.Call(m, "GetTwoWayPegData", arg0, arg1)
	ret0, _ := ret[0].(*connect.Response[mainchainv1.GetTwoWayPegDataResponse])
	ret1, _ := ret[1].(error)
	return ret0, ret1
}

// GetTwoWayPegData indicates an expected call of GetTwoWayPegData.
func (mr *MockValidatorServiceClientMockRecorder) GetTwoWayPegData(arg0, arg1 any) *gomock.Call {
	mr.mock.ctrl.T.Helper()
	return mr.mock.ctrl.RecordCallWithMethodType(mr.mock, "GetTwoWayPegData", reflect.TypeOf((*MockValidatorServiceClient)(nil).GetTwoWayPegData), arg0, arg1)
}

// Stop mocks base method.
func (m *MockValidatorServiceClient) Stop(arg0 context.Context, arg1 *connect.Request[mainchainv1.StopRequest]) (*connect.Response[mainchainv1.StopResponse], error) {
	m.ctrl.T.Helper()
	ret := m.ctrl.Call(m, "Stop", arg0, arg1)
	ret0, _ := ret[0].(*connect.Response[mainchainv1.StopResponse])
	ret1, _ := ret[1].(error)
	return ret0, ret1
}

// Stop indicates an expected call of Stop.
func (mr *MockValidatorServiceClientMockRecorder) Stop(arg0, arg1 any) *gomock.Call {
	mr.mock.ctrl.T.Helper()
	return mr.mock.ctrl.RecordCallWithMethodType(mr.mock, "Stop", reflect.TypeOf((*MockValidatorServiceClient)(nil).Stop), arg0, arg1)
}

// SubscribeEvents mocks base method.
func (m *MockValidatorServiceClient) SubscribeEvents(arg0 context.Context, arg1 *connect.Request[mainchainv1.SubscribeEventsRequest]) (*connect.ServerStreamForClient[mainchainv1.SubscribeEventsResponse], error) {
	m.ctrl.T.Helper()
	ret := m.ctrl.Call(m, "SubscribeEvents", arg0, arg1)
	ret0, _ := ret[0].(*connect.ServerStreamForClient[mainchainv1.SubscribeEventsResponse])
	ret1, _ := ret[1].(error)
	return ret0, ret1
}

// SubscribeEvents indicates an expected call of SubscribeEvents.
func (mr *MockValidatorServiceClientMockRecorder) SubscribeEvents(arg0, arg1 any) *gomock.Call {
	mr.mock.ctrl.T.Helper()
	return mr.mock.ctrl.RecordCallWithMethodType(mr.mock, "SubscribeEvents", reflect.TypeOf((*MockValidatorServiceClient)(nil).SubscribeEvents), arg0, arg1)
}

// SubscribeHeaderSyncProgress mocks base method.
func (m *MockValidatorServiceClient) SubscribeHeaderSyncProgress(arg0 context.Context, arg1 *connect.Request[mainchainv1.SubscribeHeaderSyncProgressRequest]) (*connect.ServerStreamForClient[mainchainv1.SubscribeHeaderSyncProgressResponse], error) {
	m.ctrl.T.Helper()
	ret := m.ctrl.Call(m, "SubscribeHeaderSyncProgress", arg0, arg1)
	ret0, _ := ret[0].(*connect.ServerStreamForClient[mainchainv1.SubscribeHeaderSyncProgressResponse])
	ret1, _ := ret[1].(error)
	return ret0, ret1
}

// SubscribeHeaderSyncProgress indicates an expected call of SubscribeHeaderSyncProgress.
func (mr *MockValidatorServiceClientMockRecorder) SubscribeHeaderSyncProgress(arg0, arg1 any) *gomock.Call {
	mr.mock.ctrl.T.Helper()
	return mr.mock.ctrl.RecordCallWithMethodType(mr.mock, "SubscribeHeaderSyncProgress", reflect.TypeOf((*MockValidatorServiceClient)(nil).SubscribeHeaderSyncProgress), arg0, arg1)
}

// MockValidatorServiceHandler is a mock of ValidatorServiceHandler interface.
type MockValidatorServiceHandler struct {
	ctrl     *gomock.Controller
	recorder *MockValidatorServiceHandlerMockRecorder
	isgomock struct{}
}

// MockValidatorServiceHandlerMockRecorder is the mock recorder for MockValidatorServiceHandler.
type MockValidatorServiceHandlerMockRecorder struct {
	mock *MockValidatorServiceHandler
}

// NewMockValidatorServiceHandler creates a new mock instance.
func NewMockValidatorServiceHandler(ctrl *gomock.Controller) *MockValidatorServiceHandler {
	mock := &MockValidatorServiceHandler{ctrl: ctrl}
	mock.recorder = &MockValidatorServiceHandlerMockRecorder{mock}
	return mock
}

// EXPECT returns an object that allows the caller to indicate expected use.
func (m *MockValidatorServiceHandler) EXPECT() *MockValidatorServiceHandlerMockRecorder {
	return m.recorder
}

// GetBlockHeaderInfo mocks base method.
func (m *MockValidatorServiceHandler) GetBlockHeaderInfo(arg0 context.Context, arg1 *connect.Request[mainchainv1.GetBlockHeaderInfoRequest]) (*connect.Response[mainchainv1.GetBlockHeaderInfoResponse], error) {
	m.ctrl.T.Helper()
	ret := m.ctrl.Call(m, "GetBlockHeaderInfo", arg0, arg1)
	ret0, _ := ret[0].(*connect.Response[mainchainv1.GetBlockHeaderInfoResponse])
	ret1, _ := ret[1].(error)
	return ret0, ret1
}

// GetBlockHeaderInfo indicates an expected call of GetBlockHeaderInfo.
func (mr *MockValidatorServiceHandlerMockRecorder) GetBlockHeaderInfo(arg0, arg1 any) *gomock.Call {
	mr.mock.ctrl.T.Helper()
	return mr.mock.ctrl.RecordCallWithMethodType(mr.mock, "GetBlockHeaderInfo", reflect.TypeOf((*MockValidatorServiceHandler)(nil).GetBlockHeaderInfo), arg0, arg1)
}

// GetBlockInfo mocks base method.
func (m *MockValidatorServiceHandler) GetBlockInfo(arg0 context.Context, arg1 *connect.Request[mainchainv1.GetBlockInfoRequest]) (*connect.Response[mainchainv1.GetBlockInfoResponse], error) {
	m.ctrl.T.Helper()
	ret := m.ctrl.Call(m, "GetBlockInfo", arg0, arg1)
	ret0, _ := ret[0].(*connect.Response[mainchainv1.GetBlockInfoResponse])
	ret1, _ := ret[1].(error)
	return ret0, ret1
}

// GetBlockInfo indicates an expected call of GetBlockInfo.
func (mr *MockValidatorServiceHandlerMockRecorder) GetBlockInfo(arg0, arg1 any) *gomock.Call {
	mr.mock.ctrl.T.Helper()
	return mr.mock.ctrl.RecordCallWithMethodType(mr.mock, "GetBlockInfo", reflect.TypeOf((*MockValidatorServiceHandler)(nil).GetBlockInfo), arg0, arg1)
}

// GetBmmHStarCommitment mocks base method.
func (m *MockValidatorServiceHandler) GetBmmHStarCommitment(arg0 context.Context, arg1 *connect.Request[mainchainv1.GetBmmHStarCommitmentRequest]) (*connect.Response[mainchainv1.GetBmmHStarCommitmentResponse], error) {
	m.ctrl.T.Helper()
	ret := m.ctrl.Call(m, "GetBmmHStarCommitment", arg0, arg1)
	ret0, _ := ret[0].(*connect.Response[mainchainv1.GetBmmHStarCommitmentResponse])
	ret1, _ := ret[1].(error)
	return ret0, ret1
}

// GetBmmHStarCommitment indicates an expected call of GetBmmHStarCommitment.
func (mr *MockValidatorServiceHandlerMockRecorder) GetBmmHStarCommitment(arg0, arg1 any) *gomock.Call {
	mr.mock.ctrl.T.Helper()
	return mr.mock.ctrl.RecordCallWithMethodType(mr.mock, "GetBmmHStarCommitment", reflect.TypeOf((*MockValidatorServiceHandler)(nil).GetBmmHStarCommitment), arg0, arg1)
}

// GetChainInfo mocks base method.
func (m *MockValidatorServiceHandler) GetChainInfo(arg0 context.Context, arg1 *connect.Request[mainchainv1.GetChainInfoRequest]) (*connect.Response[mainchainv1.GetChainInfoResponse], error) {
	m.ctrl.T.Helper()
	ret := m.ctrl.Call(m, "GetChainInfo", arg0, arg1)
	ret0, _ := ret[0].(*connect.Response[mainchainv1.GetChainInfoResponse])
	ret1, _ := ret[1].(error)
	return ret0, ret1
}

// GetChainInfo indicates an expected call of GetChainInfo.
func (mr *MockValidatorServiceHandlerMockRecorder) GetChainInfo(arg0, arg1 any) *gomock.Call {
	mr.mock.ctrl.T.Helper()
	return mr.mock.ctrl.RecordCallWithMethodType(mr.mock, "GetChainInfo", reflect.TypeOf((*MockValidatorServiceHandler)(nil).GetChainInfo), arg0, arg1)
}

// GetChainTip mocks base method.
func (m *MockValidatorServiceHandler) GetChainTip(arg0 context.Context, arg1 *connect.Request[mainchainv1.GetChainTipRequest]) (*connect.Response[mainchainv1.GetChainTipResponse], error) {
	m.ctrl.T.Helper()
	ret := m.ctrl.Call(m, "GetChainTip", arg0, arg1)
	ret0, _ := ret[0].(*connect.Response[mainchainv1.GetChainTipResponse])
	ret1, _ := ret[1].(error)
	return ret0, ret1
}

// GetChainTip indicates an expected call of GetChainTip.
func (mr *MockValidatorServiceHandlerMockRecorder) GetChainTip(arg0, arg1 any) *gomock.Call {
	mr.mock.ctrl.T.Helper()
	return mr.mock.ctrl.RecordCallWithMethodType(mr.mock, "GetChainTip", reflect.TypeOf((*MockValidatorServiceHandler)(nil).GetChainTip), arg0, arg1)
}

// GetCoinbasePSBT mocks base method.
func (m *MockValidatorServiceHandler) GetCoinbasePSBT(arg0 context.Context, arg1 *connect.Request[mainchainv1.GetCoinbasePSBTRequest]) (*connect.Response[mainchainv1.GetCoinbasePSBTResponse], error) {
	m.ctrl.T.Helper()
	ret := m.ctrl.Call(m, "GetCoinbasePSBT", arg0, arg1)
	ret0, _ := ret[0].(*connect.Response[mainchainv1.GetCoinbasePSBTResponse])
	ret1, _ := ret[1].(error)
	return ret0, ret1
}

// GetCoinbasePSBT indicates an expected call of GetCoinbasePSBT.
func (mr *MockValidatorServiceHandlerMockRecorder) GetCoinbasePSBT(arg0, arg1 any) *gomock.Call {
	mr.mock.ctrl.T.Helper()
	return mr.mock.ctrl.RecordCallWithMethodType(mr.mock, "GetCoinbasePSBT", reflect.TypeOf((*MockValidatorServiceHandler)(nil).GetCoinbasePSBT), arg0, arg1)
}

// GetCtip mocks base method.
func (m *MockValidatorServiceHandler) GetCtip(arg0 context.Context, arg1 *connect.Request[mainchainv1.GetCtipRequest]) (*connect.Response[mainchainv1.GetCtipResponse], error) {
	m.ctrl.T.Helper()
	ret := m.ctrl.Call(m, "GetCtip", arg0, arg1)
	ret0, _ := ret[0].(*connect.Response[mainchainv1.GetCtipResponse])
	ret1, _ := ret[1].(error)
	return ret0, ret1
}

// GetCtip indicates an expected call of GetCtip.
func (mr *MockValidatorServiceHandlerMockRecorder) GetCtip(arg0, arg1 any) *gomock.Call {
	mr.mock.ctrl.T.Helper()
	return mr.mock.ctrl.RecordCallWithMethodType(mr.mock, "GetCtip", reflect.TypeOf((*MockValidatorServiceHandler)(nil).GetCtip), arg0, arg1)
}

// GetSidechainProposals mocks base method.
func (m *MockValidatorServiceHandler) GetSidechainProposals(arg0 context.Context, arg1 *connect.Request[mainchainv1.GetSidechainProposalsRequest]) (*connect.Response[mainchainv1.GetSidechainProposalsResponse], error) {
	m.ctrl.T.Helper()
	ret := m.ctrl.Call(m, "GetSidechainProposals", arg0, arg1)
	ret0, _ := ret[0].(*connect.Response[mainchainv1.GetSidechainProposalsResponse])
	ret1, _ := ret[1].(error)
	return ret0, ret1
}

// GetSidechainProposals indicates an expected call of GetSidechainProposals.
func (mr *MockValidatorServiceHandlerMockRecorder) GetSidechainProposals(arg0, arg1 any) *gomock.Call {
	mr.mock.ctrl.T.Helper()
	return mr.mock.ctrl.RecordCallWithMethodType(mr.mock, "GetSidechainProposals", reflect.TypeOf((*MockValidatorServiceHandler)(nil).GetSidechainProposals), arg0, arg1)
}

// GetSidechains mocks base method.
func (m *MockValidatorServiceHandler) GetSidechains(arg0 context.Context, arg1 *connect.Request[mainchainv1.GetSidechainsRequest]) (*connect.Response[mainchainv1.GetSidechainsResponse], error) {
	m.ctrl.T.Helper()
	ret := m.ctrl.Call(m, "GetSidechains", arg0, arg1)
	ret0, _ := ret[0].(*connect.Response[mainchainv1.GetSidechainsResponse])
	ret1, _ := ret[1].(error)
	return ret0, ret1
}

// GetSidechains indicates an expected call of GetSidechains.
func (mr *MockValidatorServiceHandlerMockRecorder) GetSidechains(arg0, arg1 any) *gomock.Call {
	mr.mock.ctrl.T.Helper()
	return mr.mock.ctrl.RecordCallWithMethodType(mr.mock, "GetSidechains", reflect.TypeOf((*MockValidatorServiceHandler)(nil).GetSidechains), arg0, arg1)
}

// GetTwoWayPegData mocks base method.
func (m *MockValidatorServiceHandler) GetTwoWayPegData(arg0 context.Context, arg1 *connect.Request[mainchainv1.GetTwoWayPegDataRequest]) (*connect.Response[mainchainv1.GetTwoWayPegDataResponse], error) {
	m.ctrl.T.Helper()
	ret := m.ctrl.Call(m, "GetTwoWayPegData", arg0, arg1)
	ret0, _ := ret[0].(*connect.Response[mainchainv1.GetTwoWayPegDataResponse])
	ret1, _ := ret[1].(error)
	return ret0, ret1
}

// GetTwoWayPegData indicates an expected call of GetTwoWayPegData.
func (mr *MockValidatorServiceHandlerMockRecorder) GetTwoWayPegData(arg0, arg1 any) *gomock.Call {
	mr.mock.ctrl.T.Helper()
	return mr.mock.ctrl.RecordCallWithMethodType(mr.mock, "GetTwoWayPegData", reflect.TypeOf((*MockValidatorServiceHandler)(nil).GetTwoWayPegData), arg0, arg1)
}

// Stop mocks base method.
func (m *MockValidatorServiceHandler) Stop(arg0 context.Context, arg1 *connect.Request[mainchainv1.StopRequest]) (*connect.Response[mainchainv1.StopResponse], error) {
	m.ctrl.T.Helper()
	ret := m.ctrl.Call(m, "Stop", arg0, arg1)
	ret0, _ := ret[0].(*connect.Response[mainchainv1.StopResponse])
	ret1, _ := ret[1].(error)
	return ret0, ret1
}

// Stop indicates an expected call of Stop.
func (mr *MockValidatorServiceHandlerMockRecorder) Stop(arg0, arg1 any) *gomock.Call {
	mr.mock.ctrl.T.Helper()
	return mr.mock.ctrl.RecordCallWithMethodType(mr.mock, "Stop", reflect.TypeOf((*MockValidatorServiceHandler)(nil).Stop), arg0, arg1)
}

// SubscribeEvents mocks base method.
func (m *MockValidatorServiceHandler) SubscribeEvents(arg0 context.Context, arg1 *connect.Request[mainchainv1.SubscribeEventsRequest], arg2 *connect.ServerStream[mainchainv1.SubscribeEventsResponse]) error {
	m.ctrl.T.Helper()
	ret := m.ctrl.Call(m, "SubscribeEvents", arg0, arg1, arg2)
	ret0, _ := ret[0].(error)
	return ret0
}

// SubscribeEvents indicates an expected call of SubscribeEvents.
func (mr *MockValidatorServiceHandlerMockRecorder) SubscribeEvents(arg0, arg1, arg2 any) *gomock.Call {
	mr.mock.ctrl.T.Helper()
	return mr.mock.ctrl.RecordCallWithMethodType(mr.mock, "SubscribeEvents", reflect.TypeOf((*MockValidatorServiceHandler)(nil).SubscribeEvents), arg0, arg1, arg2)
}

// SubscribeHeaderSyncProgress mocks base method.
func (m *MockValidatorServiceHandler) SubscribeHeaderSyncProgress(arg0 context.Context, arg1 *connect.Request[mainchainv1.SubscribeHeaderSyncProgressRequest], arg2 *connect.ServerStream[mainchainv1.SubscribeHeaderSyncProgressResponse]) error {
	m.ctrl.T.Helper()
	ret := m.ctrl.Call(m, "SubscribeHeaderSyncProgress", arg0, arg1, arg2)
	ret0, _ := ret[0].(error)
	return ret0
}

// SubscribeHeaderSyncProgress indicates an expected call of SubscribeHeaderSyncProgress.
func (mr *MockValidatorServiceHandlerMockRecorder) SubscribeHeaderSyncProgress(arg0, arg1, arg2 any) *gomock.Call {
	mr.mock.ctrl.T.Helper()
	return mr.mock.ctrl.RecordCallWithMethodType(mr.mock, "SubscribeHeaderSyncProgress", reflect.TypeOf((*MockValidatorServiceHandler)(nil).SubscribeHeaderSyncProgress), arg0, arg1, arg2)
}
