package tests

import (
	"fmt"

	"connectrpc.com/connect"
	"go.uber.org/mock/gomock"
	"google.golang.org/protobuf/encoding/protojson"
	"google.golang.org/protobuf/proto"
	"google.golang.org/protobuf/reflect/protoreflect"
)

func ConnectSubset(msg proto.Message) gomock.Matcher {
	return connectSubsetMatcher{msg}
}

type connectSubsetMatcher struct{ proto.Message }

func (c connectSubsetMatcher) Got(got any) string {
	return connectMatcher(c).Got(got)
}

func (c connectSubsetMatcher) Matches(x any) bool {
	switch x := x.(type) {
	case proto.Message:
		return isSubset(c.Message, x)

	case connect.AnyRequest:
		return c.Matches(x.Any())

	case connect.AnyResponse:
		return c.Matches(x.Any())

	default:
		return false
	}
}

func (c connectSubsetMatcher) String() string {
	return connectMatcher(c).String()
}

func Connect(msg proto.Message) gomock.Matcher {
	return connectMatcher{msg}
}

type connectMatcher struct{ proto.Message }

var (
	_ gomock.Matcher      = new(connectMatcher)
	_ gomock.GotFormatter = new(connectMatcher)

	_ gomock.Matcher      = new(connectSubsetMatcher)
	_ gomock.GotFormatter = new(connectSubsetMatcher)
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

func isSubset(a, b proto.Message) bool {
	aReflect := a.ProtoReflect()
	bReflect := b.ProtoReflect()

	// Message are of different types
	if aReflect.Descriptor() != bReflect.Descriptor() {
		return false
	}

	subset := true
	aReflect.Range(func(fd protoreflect.FieldDescriptor, v protoreflect.Value) bool {
		switch {
		case !aReflect.Has(fd):
			return true

		case aReflect.Has(fd) && !bReflect.Has(fd):
			subset = false
			return false

		case fd.Kind() == protoreflect.MessageKind && fd.IsMap():
			if !subsetMaps(aReflect.Get(fd).Map(), bReflect.Get(fd).Map()) {
				subset = false
				return false
			}

		case fd.Kind() == protoreflect.MessageKind:
			subA, subB := aReflect.Get(fd).Message(), bReflect.Get(fd).Message()
			if !isSubset(subA.Interface(), subB.Interface()) {
				subset = false
				return false
			}

		case !aReflect.Get(fd).Equal(bReflect.Get(fd)):
			subset = false
			return false

		}

		return true
	})

	return subset
}

func subsetMaps(a, b protoreflect.Map) bool {
	subset := true
	a.Range(func(key protoreflect.MapKey, value protoreflect.Value) bool {
		if !b.Has(key) {
			subset = false
			return false
		}

		switch t := value.Interface().(type) {
		case uint32, uint64, int32, int64, string, bool, float64, float32:
			return a.Get(key).Equal(b.Get(key))

		default:
			panic(fmt.Sprintf("unknown type: %T: %s", t, t))
		}

	})
	return subset
}
