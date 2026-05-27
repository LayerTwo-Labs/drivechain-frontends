import { Feed } from "@/components/feed";
import { TopicFilter } from "@/components/topic-filter";
import { getServerClient } from "@/lib/server-api";

type Search = Promise<{ topic?: string }>;

export default async function NewPage({ searchParams }: { searchParams: Search }) {
  const { topic } = await searchParams;
  const client = getServerClient();
  const [feed, topics] = await Promise.all([
    client.listNewFeed({ limit: 30, offset: 0, topicHex: topic }),
    client.listTopics({}),
  ]);
  return (
    <>
      <h1 className="sr-only">New</h1>
      <TopicFilter topics={topics.topics} currentTopicHex={topic} />
      <Feed items={feed.items} />
    </>
  );
}
