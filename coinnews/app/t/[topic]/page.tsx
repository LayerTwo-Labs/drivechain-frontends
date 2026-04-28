import { Feed } from "@/components/feed";
import { getServerClient } from "@/lib/server-api";
import { topicLabel } from "@/lib/utils";

type Params = Promise<{ topic: string }>;

export default async function TopicPage({ params }: { params: Params }) {
  const { topic } = await params;
  const client = getServerClient();
  const [feed, topics] = await Promise.all([
    client.listByTopic({ topicHex: topic, limit: 50, offset: 0 }),
    client.listTopics({}),
  ]);
  const meta = topics.topics.find((t) => t.topicHex.toLowerCase() === topic.toLowerCase());
  return (
    <>
      <h1 className="text-base font-semibold mb-1">
        Topic: {topicLabel(topic, meta?.name)}
      </h1>
      <p className="text-xs text-[var(--muted-foreground)] mb-3">
        <code>{topic}</code>
        {meta?.retentionDays ? ` · ${meta.retentionDays}d retention` : ""}
        {meta?.createdHeight ? ` · created at block ${meta.createdHeight}` : ""}
      </p>
      <Feed items={feed.items} />
    </>
  );
}
