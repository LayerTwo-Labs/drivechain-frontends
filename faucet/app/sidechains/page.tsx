import * as pb from "@bufbuild/protobuf";
import { createClient } from "@connectrpc/connect";
import {
  ExplorerService,
  type GetChainTipsResponseJson,
  GetChainTipsResponseSchema,
} from "@/gen/explorer/v1/explorer_pb";
import { getServerTransport } from "@/lib/server-api";
import { ExplorerClient } from "./explorer-client";

export default async function ExplorerPage() {
  let initialData: GetChainTipsResponseJson | undefined;

  try {
    const api = createClient(ExplorerService, await getServerTransport());
    const response = await api.getChainTips({});
    initialData = pb.toJson(GetChainTipsResponseSchema, response);
  } catch (err) {
    console.error("Failed to fetch initial chain tips on server", err);
  }

  return <ExplorerClient initialData={initialData} />;
}
