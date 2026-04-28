import { Feed } from "@/components/feed";
import { getServerClient } from "@/lib/server-api";

export default async function HomePage() {
  const client = getServerClient();
  const res = await client.listFrontPage({ limit: 30, offset: 0 });
  return (
    <>
      <h1 className="sr-only">CoinNews — front page</h1>
      <Feed items={res.items} />
    </>
  );
}
