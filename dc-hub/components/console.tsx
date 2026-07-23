"use client";

import { type DescField, type DescMessage, ScalarType, toJson } from "@bufbuild/protobuf";
import { type AnyClient, createClient } from "@connectrpc/connect";
import type React from "react";
import { useCallback, useMemo, useState } from "react";
import { Button } from "@/components/ui/button";
import { Select } from "@/components/ui/select";
import { Textarea } from "@/components/ui/textarea";
import { ValidatorService } from "@/gen/cusf/mainchain/v1/validator_pb";
import { clientTransport } from "@/lib/client-api";

function highlightJson(json: string): React.ReactNode[] {
  return json.split("\n").map((line, i) => {
    const highlighted = line
      .replace(
        /("(?:\\.|[^"\\])*")\s*:/g,
        '<span class="text-blue-600 dark:text-blue-400">$1</span>:'
      )
      .replace(
        /:\s*("(?:\\.|[^"\\])*")/g,
        ': <span class="text-green-600 dark:text-green-400">$1</span>'
      )
      .replace(/:\s*(\d+)/g, ': <span class="text-orange-600 dark:text-orange-400">$1</span>')
      .replace(
        /:\s*(true|false|null)\b/g,
        ': <span class="text-purple-600 dark:text-purple-400">$1</span>'
      );

    return (
      // biome-ignore lint/suspicious/noArrayIndexKey: stable line order
      // biome-ignore lint/security/noDangerouslySetInnerHtml: controlled JSON output
      <span key={i} dangerouslySetInnerHTML={{ __html: `${highlighted}\n` }} />
    );
  });
}

// Well-known wrapper types use their unwrapped value in JSON
const WRAPPER_TYPES = new Set([
  "google.protobuf.UInt32Value",
  "google.protobuf.UInt64Value",
  "google.protobuf.Int32Value",
  "google.protobuf.Int64Value",
  "google.protobuf.FloatValue",
  "google.protobuf.DoubleValue",
  "google.protobuf.BoolValue",
  "google.protobuf.StringValue",
  "google.protobuf.BytesValue",
]);

function scalarDefault(type: ScalarType): unknown {
  switch (type) {
    case ScalarType.STRING:
      return "";
    case ScalarType.BOOL:
      return false;
    case ScalarType.BYTES:
      return "";
    default:
      return 0;
  }
}

function wrapperDefault(typeName: string): unknown {
  if (typeName === "google.protobuf.StringValue" || typeName === "google.protobuf.BytesValue") {
    return "";
  }
  if (typeName === "google.protobuf.BoolValue") {
    return false;
  }
  return 0;
}

function messageTemplate(schema: DescMessage): Record<string, unknown> {
  const obj: Record<string, unknown> = {};
  for (const field of schema.fields) {
    // Skip proto3 optional fields — they're not required and sending empty defaults causes errors
    if (field.proto.proto3Optional) continue;
    obj[field.jsonName] = fieldDefault(field);
  }
  return obj;
}

function fieldDefault(field: DescField): unknown {
  if (field.fieldKind === "list") {
    // List of scalars
    if (field.scalar !== undefined) return [];
    // List of messages
    if (field.message) {
      if (WRAPPER_TYPES.has(field.message.typeName))
        return [wrapperDefault(field.message.typeName)];
      return [messageTemplate(field.message)];
    }
    return [];
  }
  if (field.fieldKind === "scalar") {
    return scalarDefault(field.scalar);
  }
  if (field.fieldKind === "enum") {
    return 0;
  }
  if (field.fieldKind === "map") {
    return {};
  }
  // singular message
  if (field.fieldKind === "message" && field.message) {
    if (WRAPPER_TYPES.has(field.message.typeName)) {
      return wrapperDefault(field.message.typeName);
    }
    return messageTemplate(field.message);
  }
  return null;
}

function defaultArgsJson(method: (typeof ValidatorService.methods)[number]): string {
  const schema = method.input;
  if (schema.fields.length === 0) return "{}";
  return JSON.stringify(messageTemplate(schema), null, 2);
}

export function Console() {
  const allMethods = ValidatorService.methods.filter(
    (m) => m.name !== "Stop" && m.methodKind === "unary"
  );
  // biome-ignore lint/style/noNonNullAssertion: we control the values
  const defaultMethod = allMethods.find((m) => m.name === "GetChainTip")!;
  const [method, setMethod] = useState(defaultMethod);
  const [args, setArgs] = useState(() => defaultArgsJson(defaultMethod));
  const [output, setOutput] = useState("");
  const [loading, setLoading] = useState(false);
  const [copied, setCopied] = useState(false);

  const jsonError = useMemo(() => {
    try {
      JSON.parse(args);
      return null;
    } catch (e) {
      return e instanceof Error ? e.message : "Invalid JSON";
    }
  }, [args]);

  const handleCopy = useCallback(() => {
    navigator.clipboard.writeText(output);
    setCopied(true);
    setTimeout(() => setCopied(false), 1500);
  }, [output]);

  const handleExecute = async () => {
    setLoading(true);
    setOutput("Executing...");

    const client = createClient(ValidatorService, clientTransport) as AnyClient;
    const rpc = client[method.localName];
    if (!rpc) {
      throw new Error(`Method ${method.name} not found`);
    }

    try {
      const response = await rpc(JSON.parse(args));
      // biome-ignore lint/suspicious/noExplicitAny: method.output is a GenMessage schema
      const json = toJson(method.output as any, response, { alwaysEmitImplicit: true });
      setOutput(JSON.stringify(json, null, 2));
    } catch (err) {
      setOutput(`Error: ${err instanceof Error ? err.message : String(err)}`);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="flex flex-col gap-4">
      <div className="flex flex-col md:flex-row gap-4">
        <div className="flex-1 flex flex-col gap-2">
          <label htmlFor="method" className="text-sm font-medium">
            Method
          </label>
          <Select
            id="method"
            value={method.name}
            onChange={(e) => {
              // biome-ignore lint/style/noNonNullAssertion: we control the values
              const m = allMethods.find((m) => m.name === e.target.value)!;
              setMethod(m);
              setArgs(defaultArgsJson(m));
            }}
          >
            {allMethods.map((m) => (
              <option key={m.name} value={m.name}>
                {m.name}
              </option>
            ))}
          </Select>
        </div>
        <div className="flex-[2] flex flex-col gap-2">
          <label htmlFor="args" className="text-sm font-medium">
            Arguments (JSON)
          </label>
          <div className="relative">
            <Textarea
              id="args"
              value={args}
              onChange={(e) => setArgs(e.target.value)}
              disabled={args === "{}"}
              className={`font-mono text-xs min-h-[160px] ${jsonError ? "border-red-500 focus-visible:ring-red-500" : ""} ${jsonError ? "pb-8" : ""}`}
            />
            {jsonError && (
              <p className="absolute bottom-0 left-0 right-0 px-3 py-1.5 text-xs text-red-500 bg-red-50 border-t border-red-200 rounded-b-md pointer-events-none">
                {jsonError}
              </p>
            )}
          </div>
        </div>
      </div>

      <Button
        onClick={handleExecute}
        loading={loading}
        disabled={!!jsonError}
        className="self-start"
      >
        Execute
      </Button>

      <div className="flex flex-col gap-2">
        <div className="flex items-center justify-between">
          <label htmlFor="output" className="text-sm font-medium">
            Output
          </label>
          <button
            type="button"
            onClick={handleCopy}
            className={`inline-flex items-center gap-1.5 px-2 py-1 text-xs font-medium rounded-md border border-border bg-background hover:bg-muted transition-all ${output && !loading ? "opacity-100" : "opacity-0 pointer-events-none"}`}
          >
            {copied ? (
              <>
                <svg
                  className="size-3.5 text-green-600"
                  fill="none"
                  viewBox="0 0 24 24"
                  strokeWidth={2}
                  stroke="currentColor"
                  role="img"
                  aria-label="Copied"
                >
                  <path strokeLinecap="round" strokeLinejoin="round" d="M4.5 12.75l6 6 9-13.5" />
                </svg>
                Copied!
              </>
            ) : (
              <>
                <svg
                  className="size-3.5"
                  fill="none"
                  viewBox="0 0 24 24"
                  strokeWidth={2}
                  stroke="currentColor"
                  role="img"
                  aria-label="Copy"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    d="M15.666 3.888A2.25 2.25 0 0013.5 2.25h-3c-1.03 0-1.9.693-2.166 1.638m7.332 0c.055.194.084.4.084.612v0a.75.75 0 01-.75.75H9.75a.75.75 0 01-.75-.75v0c0-.212.03-.418.084-.612m7.332 0c.646.049 1.288.11 1.927.184 1.1.128 1.907 1.077 1.907 2.185V19.5a2.25 2.25 0 01-2.25 2.25H6.75A2.25 2.25 0 014.5 19.5V6.257c0-1.108.806-2.057 1.907-2.185a48.208 48.208 0 011.927-.184"
                  />
                </svg>
                Copy
              </>
            )}
          </button>
        </div>
        <div className="p-4 bg-muted rounded-md font-mono text-xs whitespace-pre-wrap overflow-x-auto h-[300px] overflow-y-auto border border-border">
          <pre id="output">{output ? highlightJson(output) : "No output"}</pre>
        </div>
      </div>
    </div>
  );
}
