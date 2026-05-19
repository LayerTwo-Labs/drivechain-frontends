package connectserver

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"strings"

	"connectrpc.com/connect"
	"github.com/rs/zerolog"
	"google.golang.org/protobuf/encoding/protojson"
	"google.golang.org/protobuf/proto"
)

// This is cribbed from upstream Connect, but with a few changes:
//
// Unmarshalling:
//  1. We're NOT allowing unknown enum values
//  2. We make sure to not leak internal details on unmarshalling errors
//
// Marshalling:
//  1. Emit default values
type protoJsonCodec struct{}

func (p protoJsonCodec) Name() string {
	return "json"
}

func (p protoJsonCodec) Marshal(message any) ([]byte, error) {
	protoMessage, ok := message.(proto.Message)
	if !ok {
		return nil, fmt.Errorf("%T doesn't implement proto.Message", message)
	}
	return protojson.MarshalOptions{
		EmitDefaultValues: true,
	}.Marshal(protoMessage)
}

func (p protoJsonCodec) Unmarshal(binary []byte, message any) error {
	protoMessage, ok := message.(proto.Message)
	if !ok {
		return fmt.Errorf("%T doesn't implement proto.Message", message)
	}
	if len(binary) == 0 {
		return errors.New("zero-length payload is not a valid JSON object")
	}

	options := protojson.UnmarshalOptions{}
	err := options.Unmarshal(binary, protoMessage)
	switch {
	case !json.Valid(binary):
		return errors.New("invalid json")

	// We want to hide internal details on unmarshalling errors, but still
	// provide a meaningful error message.
	case err != nil:
		// Check specifically for enum errors and provide a clearer message
		if strings.Contains(err.Error(), "invalid value for enum field") {
			if parts := strings.Split(err.Error(), "field "); len(parts) > 1 {
				fieldName := strings.Split(parts[1], ":")[0]
				return fmt.Errorf("invalid value for %q", strings.Trim(fieldName, `"`))
			}
		}

		if strings.Contains(err.Error(), "unknown field") {
			if parts := strings.Split(err.Error(), "field "); len(parts) > 1 {
				fieldName := strings.Split(parts[1], ":")[0]
				return fmt.Errorf("unknown field: %q", strings.Trim(fieldName, `"`))
			}
		}

		if strings.Contains(err.Error(), "invalid value for double field") {
			if parts := strings.Split(err.Error(), "field "); len(parts) > 1 {
				fieldName := strings.Split(parts[1], ":")[0]
				return fmt.Errorf("invalid number for %q", strings.Trim(fieldName, `"`))
			}
		}

		// Get it in the logs. Unfortunate that we
		// cannot correlate with the request...
		zerolog.Ctx(context.Background()).Err(err).
			Msgf("server: protojson codec: unable to unmarshal %T", message)

		// For other errors, return a generic message
		err := errors.New("unable to parse request")
		return connect.NewError(connect.CodeInvalidArgument, err)
	}

	return nil
}

var _ connect.Codec = new(protoJsonCodec)
