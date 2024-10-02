package dial

import (
	"context"
	"errors"
	"fmt"
	"time"

	enforcer "github.com/LayerTwo-Labs/sidesail/drivechain-server/gen/enforcer"
	"github.com/btcsuite/btcd/chaincfg/chainhash"
	"github.com/rs/zerolog"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
)

func BIPEnforcer(ctx context.Context, url string) (enforcer.ValidatorServiceClient, error) {
	start := time.Now()

	if url == "" {
		return nil, errors.New("empty validator url")
	}

	// Use the provided context directly with grpc.NewClient
	conn, err := grpc.NewClient(url, grpc.WithTransportCredentials(insecure.NewCredentials()))
	if err != nil {
		return nil, err
	}

	client := enforcer.NewValidatorServiceClient(conn)

	tip, err := client.GetMainChainTip(ctx, &enforcer.GetMainChainTipRequest{})
	if err != nil {
		return nil, fmt.Errorf("get mainchain tip: %w", err)
	}

	blockHash, err := chainhash.NewHash(tip.BlockHash)
	if err != nil {
		return nil, fmt.Errorf("parse blockhash: %w", err)
	}

	zerolog.Ctx(ctx).Debug().
		Dur("duration", time.Since(start)).
		Str("url", url).
		Str("tip", blockHash.String()).
		Msg("connected to enforcer")

	return client, nil
}
