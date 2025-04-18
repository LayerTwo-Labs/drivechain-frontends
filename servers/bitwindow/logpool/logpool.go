package logpool

import (
	"context"
	"errors"
	"fmt"
	"sync"
	"sync/atomic"
	"time"

	"github.com/oklog/ulid/v2"
	"github.com/rs/zerolog"
	"github.com/samber/lo"
	"github.com/sourcegraph/conc/pool"
)

func NewInfallibleWithResults[T any](ctx context.Context, poolLabel string) *InfallibleResultPool[T] {
	return &InfallibleResultPool[T]{NewWithResults[T](ctx, poolLabel)}
}

type InfallibleResultPool[T any] struct {
	pool *ResultPool[T]
}

func (i *InfallibleResultPool[T]) Go(jobLabel string, fn func(context.Context) T) {
	i.pool.Go(jobLabel, func(ctx context.Context) (T, error) {
		return fn(ctx), nil
	})
}

func (i *InfallibleResultPool[T]) Wait(ctx context.Context) []T {
	res, err := i.pool.Wait(ctx)
	if err != nil {
		zerolog.Ctx(ctx).Panic().
			Err(err).
			Msgf("logpool: infallible result pool was in fact fallible")
	}

	return res
}

func NewWithResults[T any](ctx context.Context, poolLabel string) *ResultPool[T] {
	return &ResultPool[T]{
		pool: New(ctx, poolLabel),
	}
}

type ResultPool[T any] struct {
	pool *Pool

	mu  sync.Mutex
	out []T
}

func (p *ResultPool[T]) WithJobCount(count int) *ResultPool[T] {
	p.pool = p.pool.WithJobCount(count)
	return p
}

func (p *ResultPool[T]) WithCancelOnError() *ResultPool[T] {
	p.pool = p.pool.WithCancelOnError()
	return p
}

func (p *ResultPool[T]) WithMaxGoroutines(routines int) *ResultPool[T] {
	p.pool = p.pool.WithMaxGoroutines(routines)
	return p
}

func (p *ResultPool[T]) WithFirstError() *ResultPool[T] {
	p.pool = p.pool.WithFirstError()
	return p
}

func (p *ResultPool[T]) WithLogLevel(level zerolog.Level) *ResultPool[T] {
	p.pool = p.pool.WithLogLevel(level)
	return p
}

func (p *ResultPool[T]) Go(jobLabel string, fn func(context.Context) (T, error)) {
	p.pool.Go(jobLabel, func(ctx context.Context) error {
		res, err := fn(ctx)
		if err != nil {
			return err
		}

		p.mu.Lock()
		defer p.mu.Unlock()

		p.out = append(p.out, res)
		return nil
	})
}

func (p *ResultPool[T]) Wait(ctx context.Context) ([]T, error) {
	err := p.pool.Wait(ctx)

	p.mu.Lock()
	defer p.mu.Unlock()

	return p.out, err
}

func New(ctx context.Context, poolLabel string) *Pool {
	poolId := ulid.Make().String()
	log := zerolog.Ctx(ctx).With().
		Str("poolId", poolId).
		Str("poolName", poolLabel)

	ctx = log.Logger().WithContext(ctx)

	logLevel := zerolog.TraceLevel

	return &Pool{
		poolLabel: poolLabel,
		poolId:    poolId,
		p:         pool.New().WithContext(ctx),
		logLevel:  logLevel,
	}
}

type Pool struct {
	poolLabel, poolId string
	p                 *pool.ContextPool

	totalJobs  int
	jobCounter atomic.Int32

	cancelOnError bool

	poolStart     time.Time
	poolStartOnce sync.Once

	logLevel zerolog.Level
}

func (p *Pool) WithJobCount(count int) *Pool {
	p.totalJobs = count
	return p
}

func (p *Pool) WithCancelOnError() *Pool {
	p.p = p.p.WithCancelOnError()
	p.cancelOnError = true
	return p
}

func (p *Pool) WithFirstError() *Pool {
	p.p = p.p.WithFirstError()
	return p
}

func (p *Pool) WithMaxGoroutines(routines int) *Pool {
	p.p = p.p.WithMaxGoroutines(routines)
	return p
}

func (p *Pool) WithLogLevel(level zerolog.Level) *Pool {
	p.logLevel = level
	return p
}

func (p *Pool) Go(jobLabel string, fn func(context.Context) error) {
	job := p.jobCounter.Add(1)

	p.poolStartOnce.Do(func() {
		p.poolStart = time.Now()
	})

	p.p.Go(func(ctx context.Context) error {
		start := time.Now()
		ctx = zerolog.Ctx(ctx).With().
			Str("poolJob", jobLabel).
			Logger().
			WithContext(ctx)

		err := fn(ctx)

		switch {
		// Very noisy logs!
		case p.cancelOnError && errors.Is(err, context.Canceled):
		default:
			suffix := ""
			if p.totalJobs > 0 {
				suffix = fmt.Sprintf(" (job %d/%d)", job, p.totalJobs)
			}

			zerolog.Ctx(ctx).WithLevel(p.logLevel).Err(err).
				Str("poolId", p.poolId).
				Str("poolName", p.poolLabel).
				Msgf("%s: ran %q in %s%s",
					p.poolLabel, jobLabel, time.Since(start), suffix,
				)
		}

		if err != nil {
			return fmt.Errorf("%q: %w", jobLabel, err)
		}

		return nil
	})
}

func (p *Pool) Wait(ctx context.Context) error {
	err := p.p.Wait()

	zerolog.Ctx(ctx).WithLevel(p.logLevel).Err(err).
		Msgf("%s: pool completed in %s", p.poolLabel, time.Since(p.poolStart))

	if err != nil {
		return fmt.Errorf("%q: %w", p.poolLabel, err)
	}

	return nil
}

func UnwrapErr(err error) []error {
	if err == nil {
		return nil
	}

	// Go has this weird hangup on not having standard error interfaces
	// available. I don't understand this.
	type unwrapable interface {
		Unwrap() []error
		Error() string
	}

	if multierr, ok := lo.ErrorsAs[unwrapable](err); ok && len(multierr.Unwrap()) > 1 {
		return multierr.Unwrap()
	}

	return []error{err}
}
