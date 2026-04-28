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
      <h1 className="text-base font-semibold mb-2">
        Author{" "}
        <code className="text-xs text-[var(--muted-foreground)]">{shortHex(xpk, 8, 8)}</code>
      </h1>
      <p className="text-xs text-[var(--muted-foreground)] break-all mb-3">{xpk}</p>
      <Feed items={res.items} />
    </>
  );
}
