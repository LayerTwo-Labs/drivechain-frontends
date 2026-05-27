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
      <div className="page-header">
        <span className="label">Topic</span>
        <h1>#{topicLabel(topic, meta?.name)}</h1>
        <code>{topic}</code>
        {(meta?.retentionDays || meta?.createdHeight) && (
          <p className="label" style={{ marginTop: "0.35rem" }}>
            {meta?.retentionDays ? `${meta.retentionDays}d retention` : ""}
            {meta?.retentionDays && meta?.createdHeight ? " · " : ""}
            {meta?.createdHeight ? `created at block ${meta.createdHeight}` : ""}
          </p>
        )}
      </div>
      <Feed items={feed.items} />
    </>
  );
}
