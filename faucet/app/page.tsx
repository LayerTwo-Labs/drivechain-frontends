"use client";

import { createClient } from "@connectrpc/connect";
import { format } from "date-fns";
import { useState } from "react";
import { Button } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardFooter,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import type { GetTransactionResponse } from "@/gen/bitcoin/bitcoind/v1alpha/bitcoin_pb";
import { FaucetService } from "@/gen/faucet/v1/faucet_pb";
import { timestampToDate } from "@/lib/api";
import { clientTransport } from "@/lib/client-api";
import { blockExplorerUrl, exampleAddressForNetwork } from "@/lib/utils";

export default function Home() {
  const [address, setAddress] = useState("");
  const [amount, setAmount] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [txid, setTxid] = useState<string | null>(null);

  const [claims, setClaims] = useState<GetTransactionResponse[]>([]);
  const [claimsLoading, setClaimsLoading] = useState(false);
  const [claimsError, setClaimsError] = useState<string | null>(null);

  const handleDispense = async () => {
    if (!address || !amount) return;

    setLoading(true);
    setError(null);
    setTxid(null);

    try {
      const api = createClient(FaucetService, clientTransport);
      const response = await api.dispenseCoins({ amount: Number(amount), destination: address });
      setTxid(response.txid);
      fetchClaims(); // Refresh claims list
    } catch (err) {
      setError(`Failed to dispense coins: ${err}`);
    } finally {
      setLoading(false);
    }
  };

  const fetchClaims = async () => {
    setClaimsLoading(true);
    setClaimsError(null);
    try {
      const api = createClient(FaucetService, clientTransport);
      const response = await api.listClaims({});
      const sortedClaims = (response.transactions || []).sort((a, b) => {
        const timeA = a.time ? Number(a.time.seconds) : 0;
        const timeB = b.time ? Number(b.time.seconds) : 0;
        return timeB - timeA;
      });
      setClaims(sortedClaims);
    } catch (err) {
      setClaimsError(`Failed to fetch recent transactions: ${err}`);
    } finally {
      setClaimsLoading(false);
    }
  };

  // Initial fetch
  useState(() => {
    fetchClaims();
  });

  const MAX_AMOUNT = 5;

  const handleAmountChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const val = e.target.value;
    if (Number(val) > MAX_AMOUNT) {
      setAmount(MAX_AMOUNT.toString());
    } else {
      setAmount(val);
    }
  };

  return (
    <div className="flex flex-col gap-8">
      <Card>
        <CardHeader>
          <CardTitle>Dispense Drivechain Coins</CardTitle>
          <CardDescription>Send Drivechain coins to your L1-address</CardDescription>
        </CardHeader>
        <CardContent className="flex flex-col gap-4">
          <div className="flex flex-col gap-2">
            <label htmlFor="address" className="text-sm font-medium">
              Pay To
            </label>
            <div className="flex flex-col sm:flex-row gap-2">
              <Input
                id="address"
                placeholder={`Enter a L1-address (e.g. ${exampleAddressForNetwork()})`}
                value={address}
                onChange={(e) => setAddress(e.target.value)}
              />
              <Button
                variant="outline"
                onClick={async () => {
                  try {
                    const text = await navigator.clipboard.readText();
                    setAddress(text);
                  } catch (e) {
                    console.error("Failed to read clipboard", e);
                  }
                }}
              >
                Paste
              </Button>
            </div>
          </div>

          <div className="flex flex-col gap-2">
            <label htmlFor="amount" className="text-sm font-medium">
              Amount
            </label>
            <div className="flex flex-col sm:flex-row gap-2">
              <div className="relative w-full">
                <Input
                  id="amount"
                  type="number"
                  placeholder="0.00"
                  value={amount}
                  onChange={handleAmountChange}
                  min={0}
                  max={MAX_AMOUNT}
                  className="pr-16"
                />
                <Button
                  variant="link"
                  onClick={() => setAmount(MAX_AMOUNT.toString())}
                  className="absolute right-0 top-0 h-full"
                >
                  MAX
                </Button>
              </div>
            </div>
          </div>

          {error && (
            <div className="p-3 text-sm text-red-500 bg-red-50 rounded-md border border-red-200">
              {error}
            </div>
          )}

          {txid && (
            <div className="p-3 text-sm text-green-700 bg-green-50 rounded-md border border-green-200">
              Dispensed {amount} BTC!{" "}
              <a href={blockExplorerUrl(txid)} target="_blank" className="underline font-bold">
                View Transaction
              </a>
            </div>
          )}
        </CardContent>
        <CardFooter className="flex justify-between">
          <div className="flex gap-2">
            <Button
              onClick={handleDispense}
              disabled={loading || !address || !amount}
              loading={loading}
            >
              Send
            </Button>
            <Button
              variant="secondary"
              onClick={() => {
                setAddress("");
                setAmount("");
                setError(null);
                setTxid(null);
              }}
            >
              Clear All
            </Button>
          </div>
        </CardFooter>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Latest Transactions</CardTitle>
          <CardDescription>View the latest faucet dispensations</CardDescription>
        </CardHeader>
        <CardContent className="p-0 sm:p-6">
          <div className="relative overflow-x-auto">
            <table className="w-full text-xs sm:text-sm text-left">
              <thead className="text-xs text-muted-foreground uppercase bg-muted/50">
                <tr>
                  <th className="px-3 sm:px-6 py-3 w-32 sm:w-48">Time</th>
                  <th className="px-3 sm:px-6 py-3">TxID</th>
                  <th className="px-3 sm:px-6 py-3 text-right">Amount</th>
                  <th className="px-3 sm:px-6 py-3 text-right">Conf.</th>
                </tr>
              </thead>
              <tbody>
                {claimsLoading ? (
                  <tr>
                    <td colSpan={4} className="px-3 sm:px-6 py-4 text-center">
                      Loading...
                    </td>
                  </tr>
                ) : claimsError ? (
                  <tr>
                    <td colSpan={4} className="px-3 sm:px-6 py-4 text-center text-red-500">
                      {claimsError}
                    </td>
                  </tr>
                ) : claims.length === 0 ? (
                  <tr>
                    <td colSpan={4} className="px-3 sm:px-6 py-4 text-center">
                      No transactions found
                    </td>
                  </tr>
                ) : (
                  claims.map((claim) => (
                    <tr key={claim.txid} className="bg-background border-b">
                      <td className="px-3 sm:px-6 py-4 whitespace-nowrap">
                        {claim.time
                          ? format(timestampToDate(claim.time), "yyyy-MM-dd HH:mm:ss")
                          : "-"}
                      </td>
                      <td className="px-3 sm:px-6 py-4 font-mono text-xs">
                        <div className="truncate max-w-[80px] sm:max-w-[200px] md:max-w-full">
                          <a
                            href={blockExplorerUrl(claim.txid)}
                            target="_blank"
                            className="text-primary hover:underline"
                          >
                            {claim.txid}
                          </a>
                        </div>
                      </td>
                      <td className="px-3 sm:px-6 py-4 text-right font-mono whitespace-nowrap">
                        {claim.amount.toFixed(8)} BTC
                      </td>
                      <td className="px-3 sm:px-6 py-4 text-right">{claim.confirmations}</td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
