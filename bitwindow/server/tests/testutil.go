package tests

import (
	"fmt"

	"connectrpc.com/connect"
	"go.uber.org/mock/gomock"
	"google.golang.org/protobuf/encoding/protojson"
	"google.golang.org/protobuf/proto"
)

func Connect(msg proto.Message) gomock.Matcher {
	return connectMatcher{msg}
}

type connectMatcher struct{ proto.Message }

var (
	_ gomock.Matcher      = new(connectMatcher)
	_ gomock.GotFormatter = new(connectMatcher)
)

func (c connectMatcher) Matches(x any) bool {
	switch x := x.(type) {
	case proto.Message:
		return proto.Equal(c.Message, x)

	case connect.AnyRequest:
		return c.Matches(x.Any())

	case connect.AnyResponse:
		return c.Matches(x.Any())

	default:
		return false
	}
}

func (c connectMatcher) Got(got any) string {
	switch got := got.(type) {
	case connect.AnyRequest:
		return c.Got(got.Any())

	case connect.AnyResponse:
		return c.Got(got.Any())

	case proto.Message:
		return encodeJson(got)

	default:
		return fmt.Sprint(got)
	}
}

func (c connectMatcher) String() string {
	return encodeJson(c.Message)
}

func encodeJson(msg proto.Message) string {
	var jsonOpts = protojson.MarshalOptions{
		EmitUnpopulated: true,
	}

	return jsonOpts.Format(msg)
}
