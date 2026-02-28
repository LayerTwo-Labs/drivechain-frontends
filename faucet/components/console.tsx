"use client";

import { type AnyClient, createClient } from "@connectrpc/connect";
import { useState } from "react";
import { Button } from "@/components/ui/button";
import { Select } from "@/components/ui/select";
import { Textarea } from "@/components/ui/textarea";
import { ValidatorService } from "@/gen/cusf/mainchain/v1/validator_pb";
import { clientTransport } from "@/lib/client-api";

export function Console() {
  const allMethods = ValidatorService.methods.filter((m) => m.name !== "Stop");
  // biome-ignore lint/style/noNonNullAssertion: we control the values
  const [method, setMethod] = useState(allMethods.find((m) => m.name === "GetChainTip")!);
  const [args, setArgs] = useState("{}");
  const [output, setOutput] = useState("");
  const [loading, setLoading] = useState(false);

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
      setOutput(
        // By default, JSON.stringify throws on BigInts, unless we provide a replacer function
        JSON.stringify(
          response,
          (_, value) => (typeof value === "bigint" ? value.toString() : value),
          2
        )
      );
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
            // biome-ignore lint/style/noNonNullAssertion: we control the values
            onChange={(e) => setMethod(allMethods.find((m) => m.name === e.target.value)!)}
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
          <Textarea
            id="args"
            value={args}
            onChange={(e) => setArgs(e.target.value)}
            className="font-mono text-xs min-h-[80px]"
          />
        </div>
      </div>

      <Button onClick={handleExecute} loading={loading} className="self-start">
        Execute
      </Button>

      <div className="flex flex-col gap-2">
        <label htmlFor="output" className="text-sm font-medium">
          Output
        </label>
        <div className="p-4 bg-muted rounded-md font-mono text-xs text-muted-foreground whitespace-pre-wrap overflow-x-auto max-h-[400px] overflow-y-auto border border-border">
          <pre id="output">{output || "No output"}</pre>
        </div>
      </div>
    </div>
  );
}
