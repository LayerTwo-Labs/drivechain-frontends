import { createConnectTransport as createConnectClientTransport } from "@connectrpc/connect-web";

const apiBaseUrl = process.env.NEXT_PUBLIC_API_CLIENT_BASE_URL ?? "/api";

console.log("client transport base URL:", apiBaseUrl);

export const clientTransport = createConnectClientTransport({
  baseUrl: apiBaseUrl,
  // Tolerate server side updates without regenerating code.
  jsonOptions: { ignoreUnknownFields: true },
});
