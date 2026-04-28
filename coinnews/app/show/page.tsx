import { Feed } from "@/components/feed";
import { getServerClient } from "@/lib/server-api";
import { Subtype } from "@/gen/coinnews/v1/coinnews_pb";

export default async function ShowPage() {
  const client = getServerClient();
  const res = await client.listFrontPage({ limit: 30, offset: 0, subtype: Subtype.SHOW });
  return (
    <>
      <h1 className="sr-only">Show</h1>
      <Feed items={res.items} />
    </>
  );
}
