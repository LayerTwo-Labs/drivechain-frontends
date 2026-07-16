import type { Metadata } from "next";
import { CodeBlock } from "@/components/code-block";
import { InlineCode } from "@/components/inline-code";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { type Network, serverNetwork } from "@/lib/network";

export const metadata: Metadata = {
  title: "Connect to drynet",
};

// Per-drynet connection parameters. Future drynets add an entry here (and
// this page is only linked on drynet builds — see hasConnectInfoPage()).
const CONNECT_INFO: Partial<
  Record<
    Network,
    {
      forkHeight: number;
      lastCommonBlock: number;
      node: string;
      explorer: string;
      esplora: string;
      electrum: string;
      electrumTls: string;
      // Snapshot fields are optional: a drynet without a published assumeutxo
      // snapshot omits them, and the fast-bootstrap UI is hidden accordingly.
      dataBase?: string;
      snapshotFile?: string;
    }
  >
> = {
  drynet1: {
    forkHeight: 955_584,
    lastCommonBlock: 955_583,
    node: "drynet1.drivechain.dev:8335",
    explorer: "https://explorer.drynet1.drivechain.dev",
    esplora: "https://esplora.drynet1.drivechain.dev",
    // Non-standard ports: this host also serves mainnet, which already holds
    // 50001/50002.
    electrum: "explorer.drynet1.drivechain.dev:50011",
    electrumTls: "explorer.drynet1.drivechain.dev:50012",
    dataBase: "https://data.drivechain.dev/drynet1",
    snapshotFile: "utxo-955584.dat",
  },
  drynet2: {
    forkHeight: 957_600,
    lastCommonBlock: 957_599,
    node: "drynet2.drivechain.dev:8335",
    explorer: "https://explorer.drynet2.drivechain.dev",
    esplora: "https://esplora.drynet2.drivechain.dev",
    electrum: "explorer.drynet2.drivechain.dev:50011",
    electrumTls: "explorer.drynet2.drivechain.dev:50012",
    // No assumeutxo snapshot published yet: fast-bootstrap section is hidden.
  },
};

export default function InfoPage() {
  const net = serverNetwork();
  const info = CONNECT_INFO[net];
  const hasSnapshot = Boolean(info?.snapshotFile);

  if (!info) {
    return (
      <div className="container mx-auto px-4 py-8">
        <p className="text-muted-foreground">No connection info available for network “{net}”.</p>
      </div>
    );
  }

  return (
    <div className="container mx-auto px-4 py-8 max-w-3xl space-y-6">
      <div>
        <h1 className="text-2xl font-bold">Connect to {net}</h1>
        <p className="text-muted-foreground mt-2">
          {net} is a dry-run drivechain network forked from Bitcoin mainnet at block{" "}
          {info.forkHeight.toLocaleString()}. It runs real BIP300/301 rules. PoW difficulty is set
          very low, so it is possible to mine this chain at home.
        </p>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Network endpoints</CardTitle>
        </CardHeader>
        <CardContent className="space-y-4 text-sm">
          <div className="space-y-1">
            <InlineCode>{info.node}</InlineCode>
            <p className="text-muted-foreground">A full {net} node: the peer you sync from.</p>
          </div>
          <div className="space-y-1">
            <a className="underline" href={info.explorer} target="_blank" rel="noreferrer">
              <InlineCode>{info.explorer.replace("https://", "")}</InlineCode>
            </a>
            <p className="text-muted-foreground">Block explorer (mempool.space)</p>
          </div>
          <div className="space-y-1">
            <a className="underline" href={info.esplora} target="_blank" rel="noreferrer">
              <InlineCode>{info.esplora.replace("https://", "")}</InlineCode>
            </a>
            <p className="text-muted-foreground">
              Esplora REST API, for querying {net} programmatically — e.g.{" "}
              <InlineCode>/blocks/tip/height</InlineCode> or{" "}
              <InlineCode>/address/&lt;addr&gt;/utxo</InlineCode>.
            </p>
          </div>
          <div className="space-y-1">
            <InlineCode>{info.electrum}</InlineCode> <InlineCode>{info.electrumTls}</InlineCode>
            <p className="text-muted-foreground">
              Electrum server — plaintext on <InlineCode>50011</InlineCode>, TLS on{" "}
              <InlineCode>50012</InlineCode>. Point an Electrum wallet at it to hold {net} coins
              without running a node.
            </p>
          </div>
          {hasSnapshot && (
            <div className="space-y-1">
              <InlineCode>{info.dataBase}/</InlineCode>
              <p className="text-muted-foreground">
                UTXO snapshots, to skip the historical download entirely — see below.
              </p>
            </div>
          )}
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Run a node</CardTitle>
          <CardDescription>
            Build the drivechain client from{" "}
            <a
              className="underline"
              href={`https://github.com/ecash-com/bitcoin/tree/${net}`}
              target="_blank"
              rel="noreferrer"
            >
              ecash-com/bitcoin ({net} branch)
            </a>{" "}
            . Then connect to the network:
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-4">
          <CodeBlock>{`bitcoind -datadir=./${net} -addnode=${info.node}`}</CodeBlock>
          <p className="text-sm text-muted-foreground">
            ⚠️ Always pass <InlineCode>-datadir</InlineCode>: because the fork identifies as{" "}
            <InlineCode>main</InlineCode>, running without it would write into a real{" "}
            <InlineCode>~/.bitcoin</InlineCode> directory.
          </p>
          <p className="text-sm text-muted-foreground">
            A full sync downloads and validates all of mainnet history up to the fork (~850 GB,
            several hours).
            {hasSnapshot ? " For a much faster start, use the UTXO snapshot below." : ""}
          </p>
        </CardContent>
      </Card>

      {hasSnapshot && (
        <Card>
          <CardHeader>
            <CardTitle>Fast bootstrap (UTXO snapshot)</CardTitle>
            <CardDescription>
              The client ships an <InlineCode>assumeutxo</InlineCode> commitment for the fork block,
              so you can load a ~9 GB snapshot and be validating {net} blocks at the tip within
              minutes. Historical blocks backfill in the background.
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            <CodeBlock>{`curl -O ${info.dataBase}/${info.snapshotFile}
curl -O ${info.dataBase}/SHA256SUMS
sha256sum -c SHA256SUMS`}</CodeBlock>
            <CodeBlock>{`bitcoind -daemon -datadir=./${net} -addnode=${info.node}
bitcoin-cli -datadir=./${net} -rpcclienttimeout=0 \\
  loadtxoutset ${info.snapshotFile}`}</CodeBlock>
            <p className="text-sm text-muted-foreground">
              The snapshot is verified against a hash committed in the client’s{" "}
              <InlineCode>chainparams</InlineCode>. Expect the background history sync to eventually
              use the full ~850 GB of disk.
            </p>
          </CardContent>
        </Card>
      )}

      <Card>
        <CardHeader>
          <CardTitle>Mining</CardTitle>
        </CardHeader>
        <CardContent>
          <p className="text-sm text-muted-foreground">
            {net} restarted difficulty at 1 from the fork block, so blocks are CPU-mineable: point
            any <InlineCode>getblocktemplate</InlineCode> miner at your own node with a payout
            address of yours.
          </p>
        </CardContent>
      </Card>
    </div>
  );
}
