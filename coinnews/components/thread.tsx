import Link from "next/link";
import type { Comment } from "@/gen/coinnews/v1/coinnews_pb";
import { timestampToDate, timeAgo } from "@/lib/api";
import { shortHex } from "@/lib/utils";

export function Thread({ rootIdHex, comments }: { rootIdHex: string; comments: Comment[] }) {
  const tree = buildTree(rootIdHex, comments);
  if (tree.length === 0) {
    return <p className="label" style={{ padding: "0.5rem 0" }}>No replies yet.</p>;
  }
  return (
    <ul className="thread">
      {tree.map((node) => (
        <ThreadNode key={node.c.itemIdHex} node={node} depth={0} />
      ))}
    </ul>
  );
}

type Node = { c: Comment; children: Node[] };

function buildTree(rootIdHex: string, comments: Comment[]): Node[] {
  const byId: Record<string, Node> = {};
  for (const c of comments) {
    byId[c.itemIdHex] = { c, children: [] };
  }
  const roots: Node[] = [];
  for (const c of comments) {
    const parent = c.parentIdHex && byId[c.parentIdHex] ? byId[c.parentIdHex] : null;
    if (parent && c.parentIdHex !== rootIdHex) {
      parent.children.push(byId[c.itemIdHex]);
    } else {
      roots.push(byId[c.itemIdHex]);
    }
  }
  return roots;
}

function ThreadNode({ node, depth }: { node: Node; depth: number }) {
  const c = node.c;
  const when = timeAgo(timestampToDate(c.blockTime));
  return (
    <li className={`thread__node${depth > 0 ? " thread__node--child" : ""}`}>
      <div className="thread__meta">
        <Link href={`/u/${c.authorXpkHex}`}>{shortHex(c.authorXpkHex)}</Link>
        <span className="sep">·</span>
        <span>
          {c.points} {c.points === 1 ? "PT" : "PTS"}
        </span>
        <span className="sep">·</span>
        <span>{when}</span>
        <span className="sep">·</span>
        <span>BLK {c.blockHeight}</span>
      </div>
      {c.replyQuote && (
        <blockquote className="thread__quote">&gt; {c.replyQuote}</blockquote>
      )}
      <div className="thread__body">
        {c.body}
        {c.url && (
          <>
            {" "}
            <a href={c.url} target="_blank" rel="noreferrer">
              {c.url}
            </a>
          </>
        )}
      </div>
      {node.children.length > 0 && (
        <ul className="thread">
          {node.children.map((child) => (
            <ThreadNode key={child.c.itemIdHex} node={child} depth={depth + 1} />
          ))}
        </ul>
      )}
    </li>
  );
}
