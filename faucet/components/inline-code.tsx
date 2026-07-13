// Inline rendering for technical terms in prose: flags, RPC names, paths.
// Server-component friendly (no client hooks).
export function InlineCode({ children }: { children: React.ReactNode }) {
  return <code className="rounded bg-muted px-1 py-0.5 font-mono text-[0.85em]">{children}</code>;
}
