// CUSF crypto service

// Code generated by protoc-gen-go. DO NOT EDIT.
// versions:
// 	protoc-gen-go v1.36.5
// 	protoc        (unknown)
// source: cusf/crypto/v1/crypto.proto

package cryptov1

import (
	v1 "github.com/LayerTwo-Labs/sidesail/servers/bitwindow/gen/cusf/common/v1"
	protoreflect "google.golang.org/protobuf/reflect/protoreflect"
	protoimpl "google.golang.org/protobuf/runtime/protoimpl"
	reflect "reflect"
	sync "sync"
	unsafe "unsafe"
)

const (
	// Verify that this generated code is sufficiently up-to-date.
	_ = protoimpl.EnforceVersion(20 - protoimpl.MinVersion)
	// Verify that runtime/protoimpl is sufficiently up-to-date.
	_ = protoimpl.EnforceVersion(protoimpl.MaxVersion - 20)
)

type HmacSha512Request struct {
	state         protoimpl.MessageState `protogen:"open.v1"`
	Key           *v1.Hex                `protobuf:"bytes,1,opt,name=key,proto3" json:"key,omitempty"`
	Msg           *v1.Hex                `protobuf:"bytes,2,opt,name=msg,proto3" json:"msg,omitempty"`
	unknownFields protoimpl.UnknownFields
	sizeCache     protoimpl.SizeCache
}

func (x *HmacSha512Request) Reset() {
	*x = HmacSha512Request{}
	mi := &file_cusf_crypto_v1_crypto_proto_msgTypes[0]
	ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
	ms.StoreMessageInfo(mi)
}

func (x *HmacSha512Request) String() string {
	return protoimpl.X.MessageStringOf(x)
}

func (*HmacSha512Request) ProtoMessage() {}

func (x *HmacSha512Request) ProtoReflect() protoreflect.Message {
	mi := &file_cusf_crypto_v1_crypto_proto_msgTypes[0]
	if x != nil {
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		if ms.LoadMessageInfo() == nil {
			ms.StoreMessageInfo(mi)
		}
		return ms
	}
	return mi.MessageOf(x)
}

// Deprecated: Use HmacSha512Request.ProtoReflect.Descriptor instead.
func (*HmacSha512Request) Descriptor() ([]byte, []int) {
	return file_cusf_crypto_v1_crypto_proto_rawDescGZIP(), []int{0}
}

func (x *HmacSha512Request) GetKey() *v1.Hex {
	if x != nil {
		return x.Key
	}
	return nil
}

func (x *HmacSha512Request) GetMsg() *v1.Hex {
	if x != nil {
		return x.Msg
	}
	return nil
}

type HmacSha512Response struct {
	state         protoimpl.MessageState `protogen:"open.v1"`
	Hmac          *v1.Hex                `protobuf:"bytes,1,opt,name=hmac,proto3" json:"hmac,omitempty"`
	unknownFields protoimpl.UnknownFields
	sizeCache     protoimpl.SizeCache
}

func (x *HmacSha512Response) Reset() {
	*x = HmacSha512Response{}
	mi := &file_cusf_crypto_v1_crypto_proto_msgTypes[1]
	ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
	ms.StoreMessageInfo(mi)
}

func (x *HmacSha512Response) String() string {
	return protoimpl.X.MessageStringOf(x)
}

func (*HmacSha512Response) ProtoMessage() {}

func (x *HmacSha512Response) ProtoReflect() protoreflect.Message {
	mi := &file_cusf_crypto_v1_crypto_proto_msgTypes[1]
	if x != nil {
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		if ms.LoadMessageInfo() == nil {
			ms.StoreMessageInfo(mi)
		}
		return ms
	}
	return mi.MessageOf(x)
}

// Deprecated: Use HmacSha512Response.ProtoReflect.Descriptor instead.
func (*HmacSha512Response) Descriptor() ([]byte, []int) {
	return file_cusf_crypto_v1_crypto_proto_rawDescGZIP(), []int{1}
}

func (x *HmacSha512Response) GetHmac() *v1.Hex {
	if x != nil {
		return x.Hmac
	}
	return nil
}

type Ripemd160Request struct {
	state         protoimpl.MessageState `protogen:"open.v1"`
	Msg           *v1.Hex                `protobuf:"bytes,1,opt,name=msg,proto3" json:"msg,omitempty"`
	unknownFields protoimpl.UnknownFields
	sizeCache     protoimpl.SizeCache
}

func (x *Ripemd160Request) Reset() {
	*x = Ripemd160Request{}
	mi := &file_cusf_crypto_v1_crypto_proto_msgTypes[2]
	ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
	ms.StoreMessageInfo(mi)
}

func (x *Ripemd160Request) String() string {
	return protoimpl.X.MessageStringOf(x)
}

func (*Ripemd160Request) ProtoMessage() {}

func (x *Ripemd160Request) ProtoReflect() protoreflect.Message {
	mi := &file_cusf_crypto_v1_crypto_proto_msgTypes[2]
	if x != nil {
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		if ms.LoadMessageInfo() == nil {
			ms.StoreMessageInfo(mi)
		}
		return ms
	}
	return mi.MessageOf(x)
}

// Deprecated: Use Ripemd160Request.ProtoReflect.Descriptor instead.
func (*Ripemd160Request) Descriptor() ([]byte, []int) {
	return file_cusf_crypto_v1_crypto_proto_rawDescGZIP(), []int{2}
}

func (x *Ripemd160Request) GetMsg() *v1.Hex {
	if x != nil {
		return x.Msg
	}
	return nil
}

type Ripemd160Response struct {
	state         protoimpl.MessageState `protogen:"open.v1"`
	Digest        *v1.Hex                `protobuf:"bytes,1,opt,name=digest,proto3" json:"digest,omitempty"`
	unknownFields protoimpl.UnknownFields
	sizeCache     protoimpl.SizeCache
}

func (x *Ripemd160Response) Reset() {
	*x = Ripemd160Response{}
	mi := &file_cusf_crypto_v1_crypto_proto_msgTypes[3]
	ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
	ms.StoreMessageInfo(mi)
}

func (x *Ripemd160Response) String() string {
	return protoimpl.X.MessageStringOf(x)
}

func (*Ripemd160Response) ProtoMessage() {}

func (x *Ripemd160Response) ProtoReflect() protoreflect.Message {
	mi := &file_cusf_crypto_v1_crypto_proto_msgTypes[3]
	if x != nil {
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		if ms.LoadMessageInfo() == nil {
			ms.StoreMessageInfo(mi)
		}
		return ms
	}
	return mi.MessageOf(x)
}

// Deprecated: Use Ripemd160Response.ProtoReflect.Descriptor instead.
func (*Ripemd160Response) Descriptor() ([]byte, []int) {
	return file_cusf_crypto_v1_crypto_proto_rawDescGZIP(), []int{3}
}

func (x *Ripemd160Response) GetDigest() *v1.Hex {
	if x != nil {
		return x.Digest
	}
	return nil
}

type Secp256K1SecretKeyToPublicKeyRequest struct {
	state         protoimpl.MessageState `protogen:"open.v1"`
	SecretKey     *v1.ConsensusHex       `protobuf:"bytes,1,opt,name=secret_key,json=secretKey,proto3" json:"secret_key,omitempty"`
	unknownFields protoimpl.UnknownFields
	sizeCache     protoimpl.SizeCache
}

func (x *Secp256K1SecretKeyToPublicKeyRequest) Reset() {
	*x = Secp256K1SecretKeyToPublicKeyRequest{}
	mi := &file_cusf_crypto_v1_crypto_proto_msgTypes[4]
	ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
	ms.StoreMessageInfo(mi)
}

func (x *Secp256K1SecretKeyToPublicKeyRequest) String() string {
	return protoimpl.X.MessageStringOf(x)
}

func (*Secp256K1SecretKeyToPublicKeyRequest) ProtoMessage() {}

func (x *Secp256K1SecretKeyToPublicKeyRequest) ProtoReflect() protoreflect.Message {
	mi := &file_cusf_crypto_v1_crypto_proto_msgTypes[4]
	if x != nil {
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		if ms.LoadMessageInfo() == nil {
			ms.StoreMessageInfo(mi)
		}
		return ms
	}
	return mi.MessageOf(x)
}

// Deprecated: Use Secp256K1SecretKeyToPublicKeyRequest.ProtoReflect.Descriptor instead.
func (*Secp256K1SecretKeyToPublicKeyRequest) Descriptor() ([]byte, []int) {
	return file_cusf_crypto_v1_crypto_proto_rawDescGZIP(), []int{4}
}

func (x *Secp256K1SecretKeyToPublicKeyRequest) GetSecretKey() *v1.ConsensusHex {
	if x != nil {
		return x.SecretKey
	}
	return nil
}

type Secp256K1SecretKeyToPublicKeyResponse struct {
	state         protoimpl.MessageState `protogen:"open.v1"`
	PublicKey     *v1.ConsensusHex       `protobuf:"bytes,1,opt,name=public_key,json=publicKey,proto3" json:"public_key,omitempty"`
	unknownFields protoimpl.UnknownFields
	sizeCache     protoimpl.SizeCache
}

func (x *Secp256K1SecretKeyToPublicKeyResponse) Reset() {
	*x = Secp256K1SecretKeyToPublicKeyResponse{}
	mi := &file_cusf_crypto_v1_crypto_proto_msgTypes[5]
	ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
	ms.StoreMessageInfo(mi)
}

func (x *Secp256K1SecretKeyToPublicKeyResponse) String() string {
	return protoimpl.X.MessageStringOf(x)
}

func (*Secp256K1SecretKeyToPublicKeyResponse) ProtoMessage() {}

func (x *Secp256K1SecretKeyToPublicKeyResponse) ProtoReflect() protoreflect.Message {
	mi := &file_cusf_crypto_v1_crypto_proto_msgTypes[5]
	if x != nil {
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		if ms.LoadMessageInfo() == nil {
			ms.StoreMessageInfo(mi)
		}
		return ms
	}
	return mi.MessageOf(x)
}

// Deprecated: Use Secp256K1SecretKeyToPublicKeyResponse.ProtoReflect.Descriptor instead.
func (*Secp256K1SecretKeyToPublicKeyResponse) Descriptor() ([]byte, []int) {
	return file_cusf_crypto_v1_crypto_proto_rawDescGZIP(), []int{5}
}

func (x *Secp256K1SecretKeyToPublicKeyResponse) GetPublicKey() *v1.ConsensusHex {
	if x != nil {
		return x.PublicKey
	}
	return nil
}

type Secp256K1SignRequest struct {
	state         protoimpl.MessageState `protogen:"open.v1"`
	Message       *v1.Hex                `protobuf:"bytes,1,opt,name=message,proto3" json:"message,omitempty"`
	SecretKey     *v1.ConsensusHex       `protobuf:"bytes,2,opt,name=secret_key,json=secretKey,proto3" json:"secret_key,omitempty"`
	unknownFields protoimpl.UnknownFields
	sizeCache     protoimpl.SizeCache
}

func (x *Secp256K1SignRequest) Reset() {
	*x = Secp256K1SignRequest{}
	mi := &file_cusf_crypto_v1_crypto_proto_msgTypes[6]
	ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
	ms.StoreMessageInfo(mi)
}

func (x *Secp256K1SignRequest) String() string {
	return protoimpl.X.MessageStringOf(x)
}

func (*Secp256K1SignRequest) ProtoMessage() {}

func (x *Secp256K1SignRequest) ProtoReflect() protoreflect.Message {
	mi := &file_cusf_crypto_v1_crypto_proto_msgTypes[6]
	if x != nil {
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		if ms.LoadMessageInfo() == nil {
			ms.StoreMessageInfo(mi)
		}
		return ms
	}
	return mi.MessageOf(x)
}

// Deprecated: Use Secp256K1SignRequest.ProtoReflect.Descriptor instead.
func (*Secp256K1SignRequest) Descriptor() ([]byte, []int) {
	return file_cusf_crypto_v1_crypto_proto_rawDescGZIP(), []int{6}
}

func (x *Secp256K1SignRequest) GetMessage() *v1.Hex {
	if x != nil {
		return x.Message
	}
	return nil
}

func (x *Secp256K1SignRequest) GetSecretKey() *v1.ConsensusHex {
	if x != nil {
		return x.SecretKey
	}
	return nil
}

type Secp256K1SignResponse struct {
	state         protoimpl.MessageState `protogen:"open.v1"`
	Signature     *v1.Hex                `protobuf:"bytes,1,opt,name=signature,proto3" json:"signature,omitempty"`
	unknownFields protoimpl.UnknownFields
	sizeCache     protoimpl.SizeCache
}

func (x *Secp256K1SignResponse) Reset() {
	*x = Secp256K1SignResponse{}
	mi := &file_cusf_crypto_v1_crypto_proto_msgTypes[7]
	ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
	ms.StoreMessageInfo(mi)
}

func (x *Secp256K1SignResponse) String() string {
	return protoimpl.X.MessageStringOf(x)
}

func (*Secp256K1SignResponse) ProtoMessage() {}

func (x *Secp256K1SignResponse) ProtoReflect() protoreflect.Message {
	mi := &file_cusf_crypto_v1_crypto_proto_msgTypes[7]
	if x != nil {
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		if ms.LoadMessageInfo() == nil {
			ms.StoreMessageInfo(mi)
		}
		return ms
	}
	return mi.MessageOf(x)
}

// Deprecated: Use Secp256K1SignResponse.ProtoReflect.Descriptor instead.
func (*Secp256K1SignResponse) Descriptor() ([]byte, []int) {
	return file_cusf_crypto_v1_crypto_proto_rawDescGZIP(), []int{7}
}

func (x *Secp256K1SignResponse) GetSignature() *v1.Hex {
	if x != nil {
		return x.Signature
	}
	return nil
}

type Secp256K1VerifyRequest struct {
	state         protoimpl.MessageState `protogen:"open.v1"`
	Message       *v1.Hex                `protobuf:"bytes,1,opt,name=message,proto3" json:"message,omitempty"`
	Signature     *v1.Hex                `protobuf:"bytes,2,opt,name=signature,proto3" json:"signature,omitempty"`
	PublicKey     *v1.ConsensusHex       `protobuf:"bytes,3,opt,name=public_key,json=publicKey,proto3" json:"public_key,omitempty"`
	unknownFields protoimpl.UnknownFields
	sizeCache     protoimpl.SizeCache
}

func (x *Secp256K1VerifyRequest) Reset() {
	*x = Secp256K1VerifyRequest{}
	mi := &file_cusf_crypto_v1_crypto_proto_msgTypes[8]
	ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
	ms.StoreMessageInfo(mi)
}

func (x *Secp256K1VerifyRequest) String() string {
	return protoimpl.X.MessageStringOf(x)
}

func (*Secp256K1VerifyRequest) ProtoMessage() {}

func (x *Secp256K1VerifyRequest) ProtoReflect() protoreflect.Message {
	mi := &file_cusf_crypto_v1_crypto_proto_msgTypes[8]
	if x != nil {
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		if ms.LoadMessageInfo() == nil {
			ms.StoreMessageInfo(mi)
		}
		return ms
	}
	return mi.MessageOf(x)
}

// Deprecated: Use Secp256K1VerifyRequest.ProtoReflect.Descriptor instead.
func (*Secp256K1VerifyRequest) Descriptor() ([]byte, []int) {
	return file_cusf_crypto_v1_crypto_proto_rawDescGZIP(), []int{8}
}

func (x *Secp256K1VerifyRequest) GetMessage() *v1.Hex {
	if x != nil {
		return x.Message
	}
	return nil
}

func (x *Secp256K1VerifyRequest) GetSignature() *v1.Hex {
	if x != nil {
		return x.Signature
	}
	return nil
}

func (x *Secp256K1VerifyRequest) GetPublicKey() *v1.ConsensusHex {
	if x != nil {
		return x.PublicKey
	}
	return nil
}

type Secp256K1VerifyResponse struct {
	state         protoimpl.MessageState `protogen:"open.v1"`
	Valid         bool                   `protobuf:"varint,1,opt,name=valid,proto3" json:"valid,omitempty"`
	unknownFields protoimpl.UnknownFields
	sizeCache     protoimpl.SizeCache
}

func (x *Secp256K1VerifyResponse) Reset() {
	*x = Secp256K1VerifyResponse{}
	mi := &file_cusf_crypto_v1_crypto_proto_msgTypes[9]
	ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
	ms.StoreMessageInfo(mi)
}

func (x *Secp256K1VerifyResponse) String() string {
	return protoimpl.X.MessageStringOf(x)
}

func (*Secp256K1VerifyResponse) ProtoMessage() {}

func (x *Secp256K1VerifyResponse) ProtoReflect() protoreflect.Message {
	mi := &file_cusf_crypto_v1_crypto_proto_msgTypes[9]
	if x != nil {
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		if ms.LoadMessageInfo() == nil {
			ms.StoreMessageInfo(mi)
		}
		return ms
	}
	return mi.MessageOf(x)
}

// Deprecated: Use Secp256K1VerifyResponse.ProtoReflect.Descriptor instead.
func (*Secp256K1VerifyResponse) Descriptor() ([]byte, []int) {
	return file_cusf_crypto_v1_crypto_proto_rawDescGZIP(), []int{9}
}

func (x *Secp256K1VerifyResponse) GetValid() bool {
	if x != nil {
		return x.Valid
	}
	return false
}

var File_cusf_crypto_v1_crypto_proto protoreflect.FileDescriptor

var file_cusf_crypto_v1_crypto_proto_rawDesc = string([]byte{
	0x0a, 0x1b, 0x63, 0x75, 0x73, 0x66, 0x2f, 0x63, 0x72, 0x79, 0x70, 0x74, 0x6f, 0x2f, 0x76, 0x31,
	0x2f, 0x63, 0x72, 0x79, 0x70, 0x74, 0x6f, 0x2e, 0x70, 0x72, 0x6f, 0x74, 0x6f, 0x12, 0x0e, 0x63,
	0x75, 0x73, 0x66, 0x2e, 0x63, 0x72, 0x79, 0x70, 0x74, 0x6f, 0x2e, 0x76, 0x31, 0x1a, 0x1b, 0x63,
	0x75, 0x73, 0x66, 0x2f, 0x63, 0x6f, 0x6d, 0x6d, 0x6f, 0x6e, 0x2f, 0x76, 0x31, 0x2f, 0x63, 0x6f,
	0x6d, 0x6d, 0x6f, 0x6e, 0x2e, 0x70, 0x72, 0x6f, 0x74, 0x6f, 0x22, 0x61, 0x0a, 0x11, 0x48, 0x6d,
	0x61, 0x63, 0x53, 0x68, 0x61, 0x35, 0x31, 0x32, 0x52, 0x65, 0x71, 0x75, 0x65, 0x73, 0x74, 0x12,
	0x25, 0x0a, 0x03, 0x6b, 0x65, 0x79, 0x18, 0x01, 0x20, 0x01, 0x28, 0x0b, 0x32, 0x13, 0x2e, 0x63,
	0x75, 0x73, 0x66, 0x2e, 0x63, 0x6f, 0x6d, 0x6d, 0x6f, 0x6e, 0x2e, 0x76, 0x31, 0x2e, 0x48, 0x65,
	0x78, 0x52, 0x03, 0x6b, 0x65, 0x79, 0x12, 0x25, 0x0a, 0x03, 0x6d, 0x73, 0x67, 0x18, 0x02, 0x20,
	0x01, 0x28, 0x0b, 0x32, 0x13, 0x2e, 0x63, 0x75, 0x73, 0x66, 0x2e, 0x63, 0x6f, 0x6d, 0x6d, 0x6f,
	0x6e, 0x2e, 0x76, 0x31, 0x2e, 0x48, 0x65, 0x78, 0x52, 0x03, 0x6d, 0x73, 0x67, 0x22, 0x3d, 0x0a,
	0x12, 0x48, 0x6d, 0x61, 0x63, 0x53, 0x68, 0x61, 0x35, 0x31, 0x32, 0x52, 0x65, 0x73, 0x70, 0x6f,
	0x6e, 0x73, 0x65, 0x12, 0x27, 0x0a, 0x04, 0x68, 0x6d, 0x61, 0x63, 0x18, 0x01, 0x20, 0x01, 0x28,
	0x0b, 0x32, 0x13, 0x2e, 0x63, 0x75, 0x73, 0x66, 0x2e, 0x63, 0x6f, 0x6d, 0x6d, 0x6f, 0x6e, 0x2e,
	0x76, 0x31, 0x2e, 0x48, 0x65, 0x78, 0x52, 0x04, 0x68, 0x6d, 0x61, 0x63, 0x22, 0x39, 0x0a, 0x10,
	0x52, 0x69, 0x70, 0x65, 0x6d, 0x64, 0x31, 0x36, 0x30, 0x52, 0x65, 0x71, 0x75, 0x65, 0x73, 0x74,
	0x12, 0x25, 0x0a, 0x03, 0x6d, 0x73, 0x67, 0x18, 0x01, 0x20, 0x01, 0x28, 0x0b, 0x32, 0x13, 0x2e,
	0x63, 0x75, 0x73, 0x66, 0x2e, 0x63, 0x6f, 0x6d, 0x6d, 0x6f, 0x6e, 0x2e, 0x76, 0x31, 0x2e, 0x48,
	0x65, 0x78, 0x52, 0x03, 0x6d, 0x73, 0x67, 0x22, 0x40, 0x0a, 0x11, 0x52, 0x69, 0x70, 0x65, 0x6d,
	0x64, 0x31, 0x36, 0x30, 0x52, 0x65, 0x73, 0x70, 0x6f, 0x6e, 0x73, 0x65, 0x12, 0x2b, 0x0a, 0x06,
	0x64, 0x69, 0x67, 0x65, 0x73, 0x74, 0x18, 0x01, 0x20, 0x01, 0x28, 0x0b, 0x32, 0x13, 0x2e, 0x63,
	0x75, 0x73, 0x66, 0x2e, 0x63, 0x6f, 0x6d, 0x6d, 0x6f, 0x6e, 0x2e, 0x76, 0x31, 0x2e, 0x48, 0x65,
	0x78, 0x52, 0x06, 0x64, 0x69, 0x67, 0x65, 0x73, 0x74, 0x22, 0x63, 0x0a, 0x24, 0x53, 0x65, 0x63,
	0x70, 0x32, 0x35, 0x36, 0x6b, 0x31, 0x53, 0x65, 0x63, 0x72, 0x65, 0x74, 0x4b, 0x65, 0x79, 0x54,
	0x6f, 0x50, 0x75, 0x62, 0x6c, 0x69, 0x63, 0x4b, 0x65, 0x79, 0x52, 0x65, 0x71, 0x75, 0x65, 0x73,
	0x74, 0x12, 0x3b, 0x0a, 0x0a, 0x73, 0x65, 0x63, 0x72, 0x65, 0x74, 0x5f, 0x6b, 0x65, 0x79, 0x18,
	0x01, 0x20, 0x01, 0x28, 0x0b, 0x32, 0x1c, 0x2e, 0x63, 0x75, 0x73, 0x66, 0x2e, 0x63, 0x6f, 0x6d,
	0x6d, 0x6f, 0x6e, 0x2e, 0x76, 0x31, 0x2e, 0x43, 0x6f, 0x6e, 0x73, 0x65, 0x6e, 0x73, 0x75, 0x73,
	0x48, 0x65, 0x78, 0x52, 0x09, 0x73, 0x65, 0x63, 0x72, 0x65, 0x74, 0x4b, 0x65, 0x79, 0x22, 0x64,
	0x0a, 0x25, 0x53, 0x65, 0x63, 0x70, 0x32, 0x35, 0x36, 0x6b, 0x31, 0x53, 0x65, 0x63, 0x72, 0x65,
	0x74, 0x4b, 0x65, 0x79, 0x54, 0x6f, 0x50, 0x75, 0x62, 0x6c, 0x69, 0x63, 0x4b, 0x65, 0x79, 0x52,
	0x65, 0x73, 0x70, 0x6f, 0x6e, 0x73, 0x65, 0x12, 0x3b, 0x0a, 0x0a, 0x70, 0x75, 0x62, 0x6c, 0x69,
	0x63, 0x5f, 0x6b, 0x65, 0x79, 0x18, 0x01, 0x20, 0x01, 0x28, 0x0b, 0x32, 0x1c, 0x2e, 0x63, 0x75,
	0x73, 0x66, 0x2e, 0x63, 0x6f, 0x6d, 0x6d, 0x6f, 0x6e, 0x2e, 0x76, 0x31, 0x2e, 0x43, 0x6f, 0x6e,
	0x73, 0x65, 0x6e, 0x73, 0x75, 0x73, 0x48, 0x65, 0x78, 0x52, 0x09, 0x70, 0x75, 0x62, 0x6c, 0x69,
	0x63, 0x4b, 0x65, 0x79, 0x22, 0x82, 0x01, 0x0a, 0x14, 0x53, 0x65, 0x63, 0x70, 0x32, 0x35, 0x36,
	0x6b, 0x31, 0x53, 0x69, 0x67, 0x6e, 0x52, 0x65, 0x71, 0x75, 0x65, 0x73, 0x74, 0x12, 0x2d, 0x0a,
	0x07, 0x6d, 0x65, 0x73, 0x73, 0x61, 0x67, 0x65, 0x18, 0x01, 0x20, 0x01, 0x28, 0x0b, 0x32, 0x13,
	0x2e, 0x63, 0x75, 0x73, 0x66, 0x2e, 0x63, 0x6f, 0x6d, 0x6d, 0x6f, 0x6e, 0x2e, 0x76, 0x31, 0x2e,
	0x48, 0x65, 0x78, 0x52, 0x07, 0x6d, 0x65, 0x73, 0x73, 0x61, 0x67, 0x65, 0x12, 0x3b, 0x0a, 0x0a,
	0x73, 0x65, 0x63, 0x72, 0x65, 0x74, 0x5f, 0x6b, 0x65, 0x79, 0x18, 0x02, 0x20, 0x01, 0x28, 0x0b,
	0x32, 0x1c, 0x2e, 0x63, 0x75, 0x73, 0x66, 0x2e, 0x63, 0x6f, 0x6d, 0x6d, 0x6f, 0x6e, 0x2e, 0x76,
	0x31, 0x2e, 0x43, 0x6f, 0x6e, 0x73, 0x65, 0x6e, 0x73, 0x75, 0x73, 0x48, 0x65, 0x78, 0x52, 0x09,
	0x73, 0x65, 0x63, 0x72, 0x65, 0x74, 0x4b, 0x65, 0x79, 0x22, 0x4a, 0x0a, 0x15, 0x53, 0x65, 0x63,
	0x70, 0x32, 0x35, 0x36, 0x6b, 0x31, 0x53, 0x69, 0x67, 0x6e, 0x52, 0x65, 0x73, 0x70, 0x6f, 0x6e,
	0x73, 0x65, 0x12, 0x31, 0x0a, 0x09, 0x73, 0x69, 0x67, 0x6e, 0x61, 0x74, 0x75, 0x72, 0x65, 0x18,
	0x01, 0x20, 0x01, 0x28, 0x0b, 0x32, 0x13, 0x2e, 0x63, 0x75, 0x73, 0x66, 0x2e, 0x63, 0x6f, 0x6d,
	0x6d, 0x6f, 0x6e, 0x2e, 0x76, 0x31, 0x2e, 0x48, 0x65, 0x78, 0x52, 0x09, 0x73, 0x69, 0x67, 0x6e,
	0x61, 0x74, 0x75, 0x72, 0x65, 0x22, 0xb7, 0x01, 0x0a, 0x16, 0x53, 0x65, 0x63, 0x70, 0x32, 0x35,
	0x36, 0x6b, 0x31, 0x56, 0x65, 0x72, 0x69, 0x66, 0x79, 0x52, 0x65, 0x71, 0x75, 0x65, 0x73, 0x74,
	0x12, 0x2d, 0x0a, 0x07, 0x6d, 0x65, 0x73, 0x73, 0x61, 0x67, 0x65, 0x18, 0x01, 0x20, 0x01, 0x28,
	0x0b, 0x32, 0x13, 0x2e, 0x63, 0x75, 0x73, 0x66, 0x2e, 0x63, 0x6f, 0x6d, 0x6d, 0x6f, 0x6e, 0x2e,
	0x76, 0x31, 0x2e, 0x48, 0x65, 0x78, 0x52, 0x07, 0x6d, 0x65, 0x73, 0x73, 0x61, 0x67, 0x65, 0x12,
	0x31, 0x0a, 0x09, 0x73, 0x69, 0x67, 0x6e, 0x61, 0x74, 0x75, 0x72, 0x65, 0x18, 0x02, 0x20, 0x01,
	0x28, 0x0b, 0x32, 0x13, 0x2e, 0x63, 0x75, 0x73, 0x66, 0x2e, 0x63, 0x6f, 0x6d, 0x6d, 0x6f, 0x6e,
	0x2e, 0x76, 0x31, 0x2e, 0x48, 0x65, 0x78, 0x52, 0x09, 0x73, 0x69, 0x67, 0x6e, 0x61, 0x74, 0x75,
	0x72, 0x65, 0x12, 0x3b, 0x0a, 0x0a, 0x70, 0x75, 0x62, 0x6c, 0x69, 0x63, 0x5f, 0x6b, 0x65, 0x79,
	0x18, 0x03, 0x20, 0x01, 0x28, 0x0b, 0x32, 0x1c, 0x2e, 0x63, 0x75, 0x73, 0x66, 0x2e, 0x63, 0x6f,
	0x6d, 0x6d, 0x6f, 0x6e, 0x2e, 0x76, 0x31, 0x2e, 0x43, 0x6f, 0x6e, 0x73, 0x65, 0x6e, 0x73, 0x75,
	0x73, 0x48, 0x65, 0x78, 0x52, 0x09, 0x70, 0x75, 0x62, 0x6c, 0x69, 0x63, 0x4b, 0x65, 0x79, 0x22,
	0x2f, 0x0a, 0x17, 0x53, 0x65, 0x63, 0x70, 0x32, 0x35, 0x36, 0x6b, 0x31, 0x56, 0x65, 0x72, 0x69,
	0x66, 0x79, 0x52, 0x65, 0x73, 0x70, 0x6f, 0x6e, 0x73, 0x65, 0x12, 0x14, 0x0a, 0x05, 0x76, 0x61,
	0x6c, 0x69, 0x64, 0x18, 0x01, 0x20, 0x01, 0x28, 0x08, 0x52, 0x05, 0x76, 0x61, 0x6c, 0x69, 0x64,
	0x32, 0x87, 0x04, 0x0a, 0x0d, 0x43, 0x72, 0x79, 0x70, 0x74, 0x6f, 0x53, 0x65, 0x72, 0x76, 0x69,
	0x63, 0x65, 0x12, 0x53, 0x0a, 0x0a, 0x48, 0x6d, 0x61, 0x63, 0x53, 0x68, 0x61, 0x35, 0x31, 0x32,
	0x12, 0x21, 0x2e, 0x63, 0x75, 0x73, 0x66, 0x2e, 0x63, 0x72, 0x79, 0x70, 0x74, 0x6f, 0x2e, 0x76,
	0x31, 0x2e, 0x48, 0x6d, 0x61, 0x63, 0x53, 0x68, 0x61, 0x35, 0x31, 0x32, 0x52, 0x65, 0x71, 0x75,
	0x65, 0x73, 0x74, 0x1a, 0x22, 0x2e, 0x63, 0x75, 0x73, 0x66, 0x2e, 0x63, 0x72, 0x79, 0x70, 0x74,
	0x6f, 0x2e, 0x76, 0x31, 0x2e, 0x48, 0x6d, 0x61, 0x63, 0x53, 0x68, 0x61, 0x35, 0x31, 0x32, 0x52,
	0x65, 0x73, 0x70, 0x6f, 0x6e, 0x73, 0x65, 0x12, 0x50, 0x0a, 0x09, 0x52, 0x69, 0x70, 0x65, 0x6d,
	0x64, 0x31, 0x36, 0x30, 0x12, 0x20, 0x2e, 0x63, 0x75, 0x73, 0x66, 0x2e, 0x63, 0x72, 0x79, 0x70,
	0x74, 0x6f, 0x2e, 0x76, 0x31, 0x2e, 0x52, 0x69, 0x70, 0x65, 0x6d, 0x64, 0x31, 0x36, 0x30, 0x52,
	0x65, 0x71, 0x75, 0x65, 0x73, 0x74, 0x1a, 0x21, 0x2e, 0x63, 0x75, 0x73, 0x66, 0x2e, 0x63, 0x72,
	0x79, 0x70, 0x74, 0x6f, 0x2e, 0x76, 0x31, 0x2e, 0x52, 0x69, 0x70, 0x65, 0x6d, 0x64, 0x31, 0x36,
	0x30, 0x52, 0x65, 0x73, 0x70, 0x6f, 0x6e, 0x73, 0x65, 0x12, 0x8c, 0x01, 0x0a, 0x1d, 0x53, 0x65,
	0x63, 0x70, 0x32, 0x35, 0x36, 0x6b, 0x31, 0x53, 0x65, 0x63, 0x72, 0x65, 0x74, 0x4b, 0x65, 0x79,
	0x54, 0x6f, 0x50, 0x75, 0x62, 0x6c, 0x69, 0x63, 0x4b, 0x65, 0x79, 0x12, 0x34, 0x2e, 0x63, 0x75,
	0x73, 0x66, 0x2e, 0x63, 0x72, 0x79, 0x70, 0x74, 0x6f, 0x2e, 0x76, 0x31, 0x2e, 0x53, 0x65, 0x63,
	0x70, 0x32, 0x35, 0x36, 0x6b, 0x31, 0x53, 0x65, 0x63, 0x72, 0x65, 0x74, 0x4b, 0x65, 0x79, 0x54,
	0x6f, 0x50, 0x75, 0x62, 0x6c, 0x69, 0x63, 0x4b, 0x65, 0x79, 0x52, 0x65, 0x71, 0x75, 0x65, 0x73,
	0x74, 0x1a, 0x35, 0x2e, 0x63, 0x75, 0x73, 0x66, 0x2e, 0x63, 0x72, 0x79, 0x70, 0x74, 0x6f, 0x2e,
	0x76, 0x31, 0x2e, 0x53, 0x65, 0x63, 0x70, 0x32, 0x35, 0x36, 0x6b, 0x31, 0x53, 0x65, 0x63, 0x72,
	0x65, 0x74, 0x4b, 0x65, 0x79, 0x54, 0x6f, 0x50, 0x75, 0x62, 0x6c, 0x69, 0x63, 0x4b, 0x65, 0x79,
	0x52, 0x65, 0x73, 0x70, 0x6f, 0x6e, 0x73, 0x65, 0x12, 0x5c, 0x0a, 0x0d, 0x53, 0x65, 0x63, 0x70,
	0x32, 0x35, 0x36, 0x6b, 0x31, 0x53, 0x69, 0x67, 0x6e, 0x12, 0x24, 0x2e, 0x63, 0x75, 0x73, 0x66,
	0x2e, 0x63, 0x72, 0x79, 0x70, 0x74, 0x6f, 0x2e, 0x76, 0x31, 0x2e, 0x53, 0x65, 0x63, 0x70, 0x32,
	0x35, 0x36, 0x6b, 0x31, 0x53, 0x69, 0x67, 0x6e, 0x52, 0x65, 0x71, 0x75, 0x65, 0x73, 0x74, 0x1a,
	0x25, 0x2e, 0x63, 0x75, 0x73, 0x66, 0x2e, 0x63, 0x72, 0x79, 0x70, 0x74, 0x6f, 0x2e, 0x76, 0x31,
	0x2e, 0x53, 0x65, 0x63, 0x70, 0x32, 0x35, 0x36, 0x6b, 0x31, 0x53, 0x69, 0x67, 0x6e, 0x52, 0x65,
	0x73, 0x70, 0x6f, 0x6e, 0x73, 0x65, 0x12, 0x62, 0x0a, 0x0f, 0x53, 0x65, 0x63, 0x70, 0x32, 0x35,
	0x36, 0x6b, 0x31, 0x56, 0x65, 0x72, 0x69, 0x66, 0x79, 0x12, 0x26, 0x2e, 0x63, 0x75, 0x73, 0x66,
	0x2e, 0x63, 0x72, 0x79, 0x70, 0x74, 0x6f, 0x2e, 0x76, 0x31, 0x2e, 0x53, 0x65, 0x63, 0x70, 0x32,
	0x35, 0x36, 0x6b, 0x31, 0x56, 0x65, 0x72, 0x69, 0x66, 0x79, 0x52, 0x65, 0x71, 0x75, 0x65, 0x73,
	0x74, 0x1a, 0x27, 0x2e, 0x63, 0x75, 0x73, 0x66, 0x2e, 0x63, 0x72, 0x79, 0x70, 0x74, 0x6f, 0x2e,
	0x76, 0x31, 0x2e, 0x53, 0x65, 0x63, 0x70, 0x32, 0x35, 0x36, 0x6b, 0x31, 0x56, 0x65, 0x72, 0x69,
	0x66, 0x79, 0x52, 0x65, 0x73, 0x70, 0x6f, 0x6e, 0x73, 0x65, 0x42, 0xcc, 0x01, 0x0a, 0x12, 0x63,
	0x6f, 0x6d, 0x2e, 0x63, 0x75, 0x73, 0x66, 0x2e, 0x63, 0x72, 0x79, 0x70, 0x74, 0x6f, 0x2e, 0x76,
	0x31, 0x42, 0x0b, 0x43, 0x72, 0x79, 0x70, 0x74, 0x6f, 0x50, 0x72, 0x6f, 0x74, 0x6f, 0x50, 0x01,
	0x5a, 0x4f, 0x67, 0x69, 0x74, 0x68, 0x75, 0x62, 0x2e, 0x63, 0x6f, 0x6d, 0x2f, 0x4c, 0x61, 0x79,
	0x65, 0x72, 0x54, 0x77, 0x6f, 0x2d, 0x4c, 0x61, 0x62, 0x73, 0x2f, 0x73, 0x69, 0x64, 0x65, 0x73,
	0x61, 0x69, 0x6c, 0x2f, 0x73, 0x65, 0x72, 0x76, 0x65, 0x72, 0x73, 0x2f, 0x62, 0x69, 0x74, 0x77,
	0x69, 0x6e, 0x64, 0x6f, 0x77, 0x2f, 0x67, 0x65, 0x6e, 0x2f, 0x63, 0x75, 0x73, 0x66, 0x2f, 0x63,
	0x72, 0x79, 0x70, 0x74, 0x6f, 0x2f, 0x76, 0x31, 0x3b, 0x63, 0x72, 0x79, 0x70, 0x74, 0x6f, 0x76,
	0x31, 0xa2, 0x02, 0x03, 0x43, 0x43, 0x58, 0xaa, 0x02, 0x0e, 0x43, 0x75, 0x73, 0x66, 0x2e, 0x43,
	0x72, 0x79, 0x70, 0x74, 0x6f, 0x2e, 0x56, 0x31, 0xca, 0x02, 0x0e, 0x43, 0x75, 0x73, 0x66, 0x5c,
	0x43, 0x72, 0x79, 0x70, 0x74, 0x6f, 0x5c, 0x56, 0x31, 0xe2, 0x02, 0x1a, 0x43, 0x75, 0x73, 0x66,
	0x5c, 0x43, 0x72, 0x79, 0x70, 0x74, 0x6f, 0x5c, 0x56, 0x31, 0x5c, 0x47, 0x50, 0x42, 0x4d, 0x65,
	0x74, 0x61, 0x64, 0x61, 0x74, 0x61, 0xea, 0x02, 0x10, 0x43, 0x75, 0x73, 0x66, 0x3a, 0x3a, 0x43,
	0x72, 0x79, 0x70, 0x74, 0x6f, 0x3a, 0x3a, 0x56, 0x31, 0x62, 0x06, 0x70, 0x72, 0x6f, 0x74, 0x6f,
	0x33,
})

var (
	file_cusf_crypto_v1_crypto_proto_rawDescOnce sync.Once
	file_cusf_crypto_v1_crypto_proto_rawDescData []byte
)

func file_cusf_crypto_v1_crypto_proto_rawDescGZIP() []byte {
	file_cusf_crypto_v1_crypto_proto_rawDescOnce.Do(func() {
		file_cusf_crypto_v1_crypto_proto_rawDescData = protoimpl.X.CompressGZIP(unsafe.Slice(unsafe.StringData(file_cusf_crypto_v1_crypto_proto_rawDesc), len(file_cusf_crypto_v1_crypto_proto_rawDesc)))
	})
	return file_cusf_crypto_v1_crypto_proto_rawDescData
}

var file_cusf_crypto_v1_crypto_proto_msgTypes = make([]protoimpl.MessageInfo, 10)
var file_cusf_crypto_v1_crypto_proto_goTypes = []any{
	(*HmacSha512Request)(nil),                     // 0: cusf.crypto.v1.HmacSha512Request
	(*HmacSha512Response)(nil),                    // 1: cusf.crypto.v1.HmacSha512Response
	(*Ripemd160Request)(nil),                      // 2: cusf.crypto.v1.Ripemd160Request
	(*Ripemd160Response)(nil),                     // 3: cusf.crypto.v1.Ripemd160Response
	(*Secp256K1SecretKeyToPublicKeyRequest)(nil),  // 4: cusf.crypto.v1.Secp256k1SecretKeyToPublicKeyRequest
	(*Secp256K1SecretKeyToPublicKeyResponse)(nil), // 5: cusf.crypto.v1.Secp256k1SecretKeyToPublicKeyResponse
	(*Secp256K1SignRequest)(nil),                  // 6: cusf.crypto.v1.Secp256k1SignRequest
	(*Secp256K1SignResponse)(nil),                 // 7: cusf.crypto.v1.Secp256k1SignResponse
	(*Secp256K1VerifyRequest)(nil),                // 8: cusf.crypto.v1.Secp256k1VerifyRequest
	(*Secp256K1VerifyResponse)(nil),               // 9: cusf.crypto.v1.Secp256k1VerifyResponse
	(*v1.Hex)(nil),                                // 10: cusf.common.v1.Hex
	(*v1.ConsensusHex)(nil),                       // 11: cusf.common.v1.ConsensusHex
}
var file_cusf_crypto_v1_crypto_proto_depIdxs = []int32{
	10, // 0: cusf.crypto.v1.HmacSha512Request.key:type_name -> cusf.common.v1.Hex
	10, // 1: cusf.crypto.v1.HmacSha512Request.msg:type_name -> cusf.common.v1.Hex
	10, // 2: cusf.crypto.v1.HmacSha512Response.hmac:type_name -> cusf.common.v1.Hex
	10, // 3: cusf.crypto.v1.Ripemd160Request.msg:type_name -> cusf.common.v1.Hex
	10, // 4: cusf.crypto.v1.Ripemd160Response.digest:type_name -> cusf.common.v1.Hex
	11, // 5: cusf.crypto.v1.Secp256k1SecretKeyToPublicKeyRequest.secret_key:type_name -> cusf.common.v1.ConsensusHex
	11, // 6: cusf.crypto.v1.Secp256k1SecretKeyToPublicKeyResponse.public_key:type_name -> cusf.common.v1.ConsensusHex
	10, // 7: cusf.crypto.v1.Secp256k1SignRequest.message:type_name -> cusf.common.v1.Hex
	11, // 8: cusf.crypto.v1.Secp256k1SignRequest.secret_key:type_name -> cusf.common.v1.ConsensusHex
	10, // 9: cusf.crypto.v1.Secp256k1SignResponse.signature:type_name -> cusf.common.v1.Hex
	10, // 10: cusf.crypto.v1.Secp256k1VerifyRequest.message:type_name -> cusf.common.v1.Hex
	10, // 11: cusf.crypto.v1.Secp256k1VerifyRequest.signature:type_name -> cusf.common.v1.Hex
	11, // 12: cusf.crypto.v1.Secp256k1VerifyRequest.public_key:type_name -> cusf.common.v1.ConsensusHex
	0,  // 13: cusf.crypto.v1.CryptoService.HmacSha512:input_type -> cusf.crypto.v1.HmacSha512Request
	2,  // 14: cusf.crypto.v1.CryptoService.Ripemd160:input_type -> cusf.crypto.v1.Ripemd160Request
	4,  // 15: cusf.crypto.v1.CryptoService.Secp256k1SecretKeyToPublicKey:input_type -> cusf.crypto.v1.Secp256k1SecretKeyToPublicKeyRequest
	6,  // 16: cusf.crypto.v1.CryptoService.Secp256k1Sign:input_type -> cusf.crypto.v1.Secp256k1SignRequest
	8,  // 17: cusf.crypto.v1.CryptoService.Secp256k1Verify:input_type -> cusf.crypto.v1.Secp256k1VerifyRequest
	1,  // 18: cusf.crypto.v1.CryptoService.HmacSha512:output_type -> cusf.crypto.v1.HmacSha512Response
	3,  // 19: cusf.crypto.v1.CryptoService.Ripemd160:output_type -> cusf.crypto.v1.Ripemd160Response
	5,  // 20: cusf.crypto.v1.CryptoService.Secp256k1SecretKeyToPublicKey:output_type -> cusf.crypto.v1.Secp256k1SecretKeyToPublicKeyResponse
	7,  // 21: cusf.crypto.v1.CryptoService.Secp256k1Sign:output_type -> cusf.crypto.v1.Secp256k1SignResponse
	9,  // 22: cusf.crypto.v1.CryptoService.Secp256k1Verify:output_type -> cusf.crypto.v1.Secp256k1VerifyResponse
	18, // [18:23] is the sub-list for method output_type
	13, // [13:18] is the sub-list for method input_type
	13, // [13:13] is the sub-list for extension type_name
	13, // [13:13] is the sub-list for extension extendee
	0,  // [0:13] is the sub-list for field type_name
}

func init() { file_cusf_crypto_v1_crypto_proto_init() }
func file_cusf_crypto_v1_crypto_proto_init() {
	if File_cusf_crypto_v1_crypto_proto != nil {
		return
	}
	type x struct{}
	out := protoimpl.TypeBuilder{
		File: protoimpl.DescBuilder{
			GoPackagePath: reflect.TypeOf(x{}).PkgPath(),
			RawDescriptor: unsafe.Slice(unsafe.StringData(file_cusf_crypto_v1_crypto_proto_rawDesc), len(file_cusf_crypto_v1_crypto_proto_rawDesc)),
			NumEnums:      0,
			NumMessages:   10,
			NumExtensions: 0,
			NumServices:   1,
		},
		GoTypes:           file_cusf_crypto_v1_crypto_proto_goTypes,
		DependencyIndexes: file_cusf_crypto_v1_crypto_proto_depIdxs,
		MessageInfos:      file_cusf_crypto_v1_crypto_proto_msgTypes,
	}.Build()
	File_cusf_crypto_v1_crypto_proto = out.File
	file_cusf_crypto_v1_crypto_proto_goTypes = nil
	file_cusf_crypto_v1_crypto_proto_depIdxs = nil
}
