import Link from "next/link";

export default function NotFound() {
  return (
    <div className="py-10 text-center">
      <h1 className="font-bold text-lg mb-2">Not found</h1>
      <p className="text-[var(--muted-foreground)] mb-3">
        That item isn&apos;t in the index.
      </p>
      <Link href="/" className="underline">
        Back to front page
      </Link>
    </div>
  );
}
