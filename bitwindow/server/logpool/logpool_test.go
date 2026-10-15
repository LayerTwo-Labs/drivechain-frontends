package logpool_test

import (
	"context"
	"errors"
	"fmt"
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/logpool"
)

func TestResultPoolSubmissionOrder(t *testing.T) {
	t.Run("results come back in submission order", func(t *testing.T) {
		const jobs = 8

		p := logpool.NewWithResults[int](t.Context(), "submission-order").
			WithJobCount(jobs)

		// Later jobs finish first.
		for i := range jobs {
			p.Go(fmt.Sprintf("job-%d", i), func(ctx context.Context) (int, error) {
				time.Sleep(time.Duration(jobs-i) * 20 * time.Millisecond)
				return i, nil
			})
		}

		out, err := p.Wait(t.Context())
		require.NoError(t, err)
		assert.Equal(t, []int{0, 1, 2, 3, 4, 5, 6, 7}, out)
	})

	t.Run("a failed job drops out and keeps the order", func(t *testing.T) {
		p := logpool.NewWithResults[int](t.Context(), "submission-order-error").
			WithJobCount(3)

		errBoom := errors.New("boom")

		p.Go("first", func(ctx context.Context) (int, error) {
			time.Sleep(40 * time.Millisecond)
			return 1, nil
		})
		p.Go("second", func(ctx context.Context) (int, error) {
			return 0, errBoom
		})
		p.Go("third", func(ctx context.Context) (int, error) {
			return 3, nil
		})

		out, err := p.Wait(t.Context())
		require.ErrorIs(t, err, errBoom)
		assert.Equal(t, []int{1, 3}, out)
	})
}
