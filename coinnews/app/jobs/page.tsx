import { Feed } from "@/components/feed";
import { TopicFilter } from "@/components/topic-filter";
import { getServerClient } from "@/lib/server-api";
import { Subtype } from "@/gen/coinnews/v1/coinnews_pb";

type Search = Promise<{ topic?: string }>;

export default async function JobsPage({ searchParams }: { searchParams: Search }) {
  const { topic } = await searchParams;
  const client = getServerClient();
  const [feed, topics] = await Promise.all([
    client.listNewFeed({ limit: 30, offset: 0, subtype: Subtype.JOB, topicHex: topic }),
    client.listTopics({}),
  ]);
  return (
    <>
      <h1 className="sr-only">Jobs</h1>
      <TopicFilter topics={topics.topics} currentTopicHex={topic} />
      <Feed items={feed.items} />
    </>
  );
}
