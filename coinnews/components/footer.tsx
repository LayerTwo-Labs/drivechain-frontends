import Link from "next/link";

export function Footer() {
  return (
    <footer className="border-t border-[var(--border)] py-4 mt-6">
      <div className="container mx-auto max-w-4xl px-3 text-xs text-[var(--muted-foreground)] flex flex-wrap gap-3 justify-center">
        <Link href="/" className="hover:underline">
          Home
        </Link>
        <span>|</span>
        <Link
          href="https://github.com/LayerTwo-Labs/sidesail"
          target="_blank"
          className="hover:underline"
        >
          GitHub
        </Link>
        <span>|</span>
        <span>Read-only indexer</span>
      </div>
    </footer>
  );
}
