import { Feed } from "@/components/feed";
import { getServerClient } from "@/lib/server-api";
import { Subtype } from "@/gen/coinnews/v1/coinnews_pb";

export default async function JobsPage() {
  const client = getServerClient();
  const res = await client.listNewFeed({ limit: 30, offset: 0, subtype: Subtype.JOB });
  return (
    <>
      <h1 className="sr-only">Jobs</h1>
      <Feed items={res.items} />
    </>
  );
}
