import type { Item } from "@/gen/coinnews/v1/coinnews_pb";
import { ItemRow } from "./item-row";

export function Feed({ items, startRank = 1 }: { items: Item[]; startRank?: number }) {
  if (items.length === 0) {
    return <div className="text-[var(--muted-foreground)] py-8 text-center">Nothing here yet.</div>;
  }
  return (
    <ol className="list-none p-0 m-0">
      {items.map((it, idx) => (
        <ItemRow key={it.itemIdHex} item={it} rank={startRank + idx} />
      ))}
    </ol>
  );
}
