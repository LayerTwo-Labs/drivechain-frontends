"use client";

import { useRouter, useSearchParams, usePathname } from "next/navigation";
import { useTransition } from "react";
import type { Topic } from "@/gen/coinnews/v1/coinnews_pb";
import { topicLabel } from "@/lib/utils";

export function TopicFilter({
  topics,
  currentTopicHex,
}: {
  topics: Topic[];
  currentTopicHex?: string;
}) {
  const router = useRouter();
  const pathname = usePathname() ?? "/";
  const params = useSearchParams();
  const [pending, startTransition] = useTransition();

  const value = currentTopicHex ?? "";

  const onChange = (next: string) => {
    const sp = new URLSearchParams(params?.toString() ?? "");
    if (next) sp.set("topic", next);
    else sp.delete("topic");
    const qs = sp.toString();
    startTransition(() => {
      router.push(qs ? `${pathname}?${qs}` : pathname);
    });
  };

  return (
    <div className="topic-filter">
      <span className="label">Topic</span>
      <div className="topic-filter__select-wrap">
        <select
          value={value}
          onChange={(e) => onChange(e.target.value)}
          disabled={pending}
          className="topic-filter__select"
        >
          <option value="">All</option>
          {topics.map((t) => (
            <option key={t.topicHex} value={t.topicHex}>
              #{topicLabel(t.topicHex, t.name)}
            </option>
          ))}
        </select>
        <span className="topic-filter__caret">▾</span>
      </div>
      {currentTopicHex && (
        <button type="button" onClick={() => onChange("")} className="topic-filter__clear">
          × Clear
        </button>
      )}
    </div>
  );
}
