import { Feed } from "@/components/feed";
import { getServerClient } from "@/lib/server-api";
import { Subtype } from "@/gen/coinnews/v1/coinnews_pb";

export default async function AskPage() {
  const client = getServerClient();
  const res = await client.listFrontPage({ limit: 30, offset: 0, subtype: Subtype.ASK });
  return (
    <>
      <h1 className="sr-only">Ask</h1>
      <Feed items={res.items} />
    </>
  );
}
