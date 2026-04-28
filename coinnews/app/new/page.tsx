import { Feed } from "@/components/feed";
import { getServerClient } from "@/lib/server-api";

export default async function NewPage() {
  const client = getServerClient();
  const res = await client.listNewFeed({ limit: 30, offset: 0 });
  return (
    <>
      <h1 className="sr-only">New</h1>
      <Feed items={res.items} />
    </>
  );
}
