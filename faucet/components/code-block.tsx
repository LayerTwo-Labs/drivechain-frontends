"use client";

import { useState } from "react";

// A copyable code block for setup instructions.
export function CodeBlock({ children }: { children: string }) {
  const [copied, setCopied] = useState(false);

  const copy = async () => {
    await navigator.clipboard.writeText(children);
    setCopied(true);
    setTimeout(() => setCopied(false), 1500);
  };

  return (
    <div className="relative group">
      <pre className="bg-muted rounded-md p-4 text-sm overflow-x-auto whitespace-pre">
        <code>{children}</code>
      </pre>
      <button
        type="button"
        onClick={copy}
        className="absolute top-2 right-2 rounded-md border bg-background px-2 py-1 text-xs text-muted-foreground opacity-0 group-hover:opacity-100 transition-opacity hover:text-foreground"
      >
        {copied ? "Copied!" : "Copy"}
      </button>
    </div>
  );
}
