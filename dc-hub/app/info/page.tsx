import type { Metadata } from "next";
import { CodeBlock } from "@/components/code-block";
import { InlineCode } from "@/components/inline-code";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { getNetworkConfig } from "@/lib/config";
import { blockExplorerBase, findBackend } from "@/lib/network";

export async function generateMetadata(): Promise<Metadata> {
  const net = await getNetworkConfig();
  return { title: `Connect to ${net.display_name}` };
}

// Everything on this page comes from drivechain.dev/config: sections render
// only when the deployment actually has the service in question.
export default async function InfoPage() {
  const net = await getNetworkConfig();

  const esplora = findBackend(net, "esplora");
  const electrum = findBackend(net, "electrum");
  const p2p = net.p2p;
  const explorer = blockExplorerBase(net);
  const snapshot = net.assumeutxo;
  const snapshotFile = snapshot?.url.split("/").pop();
  const { blockbook, fast_withdrawal } = net.services;
  const isForknet = net.family === "ecash";

  return (
    <div className="container mx-auto px-4 py-8 max-w-3xl space-y-6">
      <div>
        <h1 className="text-2xl font-bold">Connect to {net.display_name}</h1>
        <p className="text-muted-foreground mt-2">
          {net.description}. The native currency is {net.currency.name} ({net.currency.ticker}).
          {isForknet &&
            " It runs real BIP300/301 rules, and PoW difficulty is set very low, so it is possible to mine this chain at home."}
        </p>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Network endpoints</CardTitle>
        </CardHeader>
        <CardContent className="space-y-4 text-sm">
          {p2p && (
            <div className="space-y-1">
              <InlineCode>{p2p.address}</InlineCode>
              <p className="text-muted-foreground">
                A full {net.display_name} node: the peer you sync from.
              </p>
            </div>
          )}
          {explorer && (
            <div className="space-y-1">
              <a className="underline" href={explorer} target="_blank" rel="noreferrer">
                <InlineCode>{explorer.replace("https://", "")}</InlineCode>
              </a>
              <p className="text-muted-foreground">Block explorer (mempool.space)</p>
            </div>
          )}
          {esplora && (
            <div className="space-y-1">
              <a className="underline" href={esplora.url} target="_blank" rel="noreferrer">
                <InlineCode>{esplora.url.replace("https://", "")}</InlineCode>
              </a>
              <p className="text-muted-foreground">
                Esplora REST API, for querying {net.display_name} programmatically — e.g.{" "}
                <InlineCode>/blocks/tip/height</InlineCode> or{" "}
                <InlineCode>/address/&lt;addr&gt;/utxo</InlineCode>.
              </p>
            </div>
          )}
          {electrum && (
            <div className="space-y-1">
              <InlineCode>{electrum.url}</InlineCode>
              <p className="text-muted-foreground">
                Electrum server{electrum.tls ? " (TLS)" : ""}. Point an Electrum wallet at it to
                hold {net.currency.ticker} without running a node.
              </p>
            </div>
          )}
          {blockbook.url && (
            <div className="space-y-1">
              <a className="underline" href={blockbook.url} target="_blank" rel="noreferrer">
                <InlineCode>{blockbook.url.replace("https://", "")}</InlineCode>
              </a>
              <p className="text-muted-foreground">Blockbook indexer API.</p>
            </div>
          )}
          {fast_withdrawal.map((fw) => (
            <div key={fw.url} className="space-y-1">
              <InlineCode>{fw.url.replace("https://", "")}</InlineCode>
              <p className="text-muted-foreground">
                Fast withdrawal server, for skipping the withdrawal waiting period.
              </p>
            </div>
          ))}
          {snapshot && (
            <div className="space-y-1">
              <InlineCode>{snapshot.url}</InlineCode>
              <p className="text-muted-foreground">
                UTXO snapshot, to skip the historical download entirely — see below.
              </p>
            </div>
          )}
        </CardContent>
      </Card>

      {isForknet && (
        <Card>
          <CardHeader>
            <CardTitle>Run a node</CardTitle>
            <CardDescription>
              Build the drivechain client from{" "}
              <a
                className="underline"
                href={`https://github.com/ecash-com/bitcoin/tree/${net.id}`}
                target="_blank"
                rel="noreferrer"
              >
                ecash-com/bitcoin ({net.id} branch)
              </a>{" "}
              . Then connect to the network:
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            <CodeBlock>{`bitcoind -datadir=./${net.id}${p2p ? ` -addnode=${p2p.address}` : ""}`}</CodeBlock>
            <p className="text-sm text-muted-foreground">
              ⚠️ Always pass <InlineCode>-datadir</InlineCode>: because the fork identifies as{" "}
              <InlineCode>main</InlineCode>, running without it would write into a real{" "}
              <InlineCode>~/.bitcoin</InlineCode> directory.
            </p>
            <p className="text-sm text-muted-foreground">
              A full sync downloads and validates all of mainnet history up to the fork (~850 GB,
              several hours).
              {snapshot ? " For a much faster start, use the UTXO snapshot below." : ""}
            </p>
          </CardContent>
        </Card>
      )}

      {isForknet && snapshot && (
        <Card>
          <CardHeader>
            <CardTitle>Fast bootstrap (UTXO snapshot)</CardTitle>
            <CardDescription>
              The client ships an <InlineCode>assumeutxo</InlineCode> commitment for block{" "}
              {snapshot.height.toLocaleString()}, so you can load a ~
              {Math.round(snapshot.size_bytes / 1e9)} GB snapshot and be validating{" "}
              {net.display_name} blocks at the tip within minutes. Historical blocks backfill in the
              background.
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            <CodeBlock>{`curl -O ${snapshot.url}
echo "${snapshot.sha256}  ${snapshotFile}" | shasum -a 256 --check`}</CodeBlock>
            <CodeBlock>{`bitcoind -daemon -datadir=./${net.id}${p2p ? ` -addnode=${p2p.address}` : ""}
bitcoin-cli -datadir=./${net.id} -rpcclienttimeout=0 \\
  loadtxoutset ${snapshotFile}`}</CodeBlock>
            <p className="text-sm text-muted-foreground">
              The snapshot is verified against a hash committed in the client’s{" "}
              <InlineCode>chainparams</InlineCode>. Expect the background history sync to eventually
              use the full ~850 GB of disk.
            </p>
          </CardContent>
        </Card>
      )}

      {isForknet && (
        <Card>
          <CardHeader>
            <CardTitle>Mining</CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-sm text-muted-foreground">
              {net.display_name} restarted difficulty at 1 from the fork block, so blocks are
              CPU-mineable: point any <InlineCode>getblocktemplate</InlineCode> miner at your own
              node with a payout address of yours.
            </p>
          </CardContent>
        </Card>
      )}
    </div>
  );
}
