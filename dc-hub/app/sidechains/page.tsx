import * as pb from "@bufbuild/protobuf";
import { createClient } from "@connectrpc/connect";
import {
  ExplorerService,
  type GetChainTipsResponseJson,
  GetChainTipsResponseSchema,
  type ListSidechainsResponseJson,
  ListSidechainsResponseSchema,
} from "@/gen/explorer/v1/explorer_pb";
import { getServerTransport } from "@/lib/server-api";
import { ExplorerClient } from "./explorer-client";

export default async function ExplorerPage() {
  let initialData: GetChainTipsResponseJson | undefined;
  let initialSidechains: ListSidechainsResponseJson | undefined;

  const api = createClient(ExplorerService, await getServerTransport());

  try {
    initialData = pb.toJson(GetChainTipsResponseSchema, await api.getChainTips({}));
  } catch (err) {
    console.error("Failed to fetch initial chain tips on server", err);
  }

  // Fetched independently so a sidechain-list failure never blanks the tips.
  try {
    initialSidechains = pb.toJson(ListSidechainsResponseSchema, await api.listSidechains({}));
  } catch (err) {
    console.error("Failed to fetch initial sidechains on server", err);
  }

  return <ExplorerClient initialData={initialData} initialSidechains={initialSidechains} />;
}
