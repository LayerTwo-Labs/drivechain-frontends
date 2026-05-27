import Link from "next/link";

export default function NotFound() {
  return (
    <div className="notfound">
      <h1>Not found</h1>
      <p>That item isn&apos;t in the index.</p>
      <Link href="/">Back to front page</Link>
    </div>
  );
}
