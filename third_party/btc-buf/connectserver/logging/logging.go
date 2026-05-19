package logging

import (
	"context"
	"fmt"
	"strings"
	"time"

	"connectrpc.com/connect"
	"github.com/rs/zerolog"
)

type InterceptorConf struct {
	GetLogLevel func(ctx context.Context, info connect.Spec) zerolog.Level
}

// Interceptor is a unary server Connect interceptor that logs all
// incoming requests and responses
func Interceptor(conf InterceptorConf) connect.UnaryInterceptorFunc {
	return func(next connect.UnaryFunc) connect.UnaryFunc {
		return func(ctx context.Context, req connect.AnyRequest) (connect.AnyResponse, error) {
			start := time.Now()

			var code connect.Code

			log := zerolog.Ctx(ctx)

			// We want /all/ log lines to include this, including panics.
			log.UpdateContext(func(c zerolog.Context) zerolog.Context {
				return c.Str("endpoint", req.Spec().Procedure)
			})

			// Forward the request to the actual request handler. Prior to this
			// line we haven't executed any handler code, after this line we're
			// done.
			resp, handlerErr := next(ctx, req)

			// Important: We don't mutate err, only create a textual representation
			// of it. What's sent back to the user is the responsibility of other
			// interceptors/handlers.
			if handlerErr != nil {
				if cCode := connect.CodeOf(handlerErr); cCode != 0 {
					code = cCode
				} else {
					code = connect.CodeInternal
				}
			}

			// Internal and unknown errors are bad! In theory, these are bugs. We
			// should always make sure to return something meaningful.
			isBadErr := code == connect.CodeInternal || code == connect.CodeUnknown

			level := zerolog.DebugLevel
			if conf.GetLogLevel != nil {
				level = conf.GetLogLevel(ctx, req.Spec())
			}

			switch {
			case isBadErr:
				level = zerolog.ErrorLevel

			case code == connect.CodeCanceled:
				level = zerolog.InfoLevel

			case code == connect.CodeDeadlineExceeded:
				level = zerolog.WarnLevel
			}

			fields := log.WithLevel(level).
				Stringer("duration", time.Since(start)).
				Str("status", describeCode(code)).
				Err(handlerErr)

			message := fmt.Sprintf("%s: %s", req.Spec().Procedure, describeCode(code))

			if handlerErr != nil {
				handlerErrMessage := handlerErr.Error()

				cutset := fmt.Sprintf("%s: ", describeCode(code))
				if _, trimmed, ok := strings.Cut(handlerErrMessage, cutset); ok {
					handlerErrMessage = trimmed
				}
				message = fmt.Sprintf("%s: %s", message, handlerErrMessage)
			}

			// Send the actual log
			fields.Msg(message)

			return resp, handlerErr
		}
	}
}

func describeCode(code connect.Code) string {
	if code == 0 {
		return "ok"
	}

	return code.String()
}
