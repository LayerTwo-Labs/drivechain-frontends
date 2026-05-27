import { Feed } from "@/components/feed";
import { getServerClient } from "@/lib/server-api";
import { shortHex } from "@/lib/utils";

type Params = Promise<{ xpk: string }>;

export default async function UserPage({ params }: { params: Params }) {
  const { xpk } = await params;
  const client = getServerClient();
  const res = await client.listByAuthor({ authorXpkHex: xpk, limit: 50, offset: 0 });
  return (
    <>
      <div className="page-header">
        <span className="label">Author</span>
        <h1>{shortHex(xpk, 8, 8)}</h1>
        <code>{xpk}</code>
      </div>
      <Feed items={res.items} />
    </>
  );
}
