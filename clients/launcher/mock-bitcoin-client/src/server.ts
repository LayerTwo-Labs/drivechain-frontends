import { WebSocket, WebSocketServer } from 'ws';

const PORT = 8382;
const DEBUG = true;

// Message type definitions
interface BaseMessage {
  type: string;
  data: Record<string, any>;
}

interface FastWithdrawRequest {
  type: 'request_fast_withdraw';
  data: {
    amount: number;
    destination: string;
  };
}

interface InvoicePaidRequest {
  type: 'invoice_paid';
  data: {
    txid: string;
    amount: number;
    destination: string;
  };
}

interface FastWithdrawInvoice {
  type: 'fast_withdraw_invoice';
  data: {
    amount: number;
    destination: string;
  };
}

interface FastWithdrawComplete {
  type: 'fast_withdraw_complete';
  data: {
    txid: string;
    amount: number;
    destination: string;
  };
}

interface ErrorMessage {
  type: 'error';
  data: {
    code: string;
    message: string;
  };
}

type Message = FastWithdrawRequest | InvoicePaidRequest | FastWithdrawInvoice | FastWithdrawComplete | ErrorMessage;

class MockBitcoinClient {
  private wss: WebSocketServer;
  private clients: Map<WebSocket, number> = new Map();
  private nextClientId = 1;

  constructor() {
    this.wss = new WebSocketServer({ port: PORT });
    this.setupServerHandlers();
    if (DEBUG) console.log(`Mock Bitcoin client running on ws://localhost:${PORT}`);
  }

  private setupServerHandlers() {
    this.wss.on('connection', (ws: WebSocket) => {
      const clientId = this.nextClientId++;
      this.clients.set(ws, clientId);

      if (DEBUG) console.log(`Client ${clientId} connected`);

      ws.on('message', (data: Buffer) => {
        try {
          const message = JSON.parse(data.toString()) as Message;
          this.handleMessage(ws, message);
        } catch (error) {
          if (DEBUG) console.error('Error parsing message:', error);
          this.sendError(ws, 'invalid_message', 'Invalid message format');
        }
      });

      ws.on('close', () => {
        if (DEBUG) console.log(`Client ${clientId} disconnected`);
        this.clients.delete(ws);
      });

      ws.on('error', (error: Error) => {
        if (DEBUG) console.error(`Client ${clientId} error:`, error);
        this.clients.delete(ws);
      });
    });
  }

  private handleMessage(ws: WebSocket, message: Message) {
    const clientId = this.clients.get(ws);
    
    if (DEBUG) {
      console.log(`Received from client ${clientId}:`, message);
    }

    switch (message.type) {
      case 'request_fast_withdraw':
        this.handleFastWithdrawRequest(ws, message.data);
        break;

      case 'invoice_paid':
        this.handleInvoicePaid(ws, message.data);
        break;

      default:
        this.sendError(ws, 'unknown_message', 'Unknown message type');
    }
  }

  private handleFastWithdrawRequest(
    ws: WebSocket,
    data: FastWithdrawRequest['data']
  ) {
    // Generate a mock L2 address for payment
    const l2Address = `L2_${Math.random().toString(36).substring(2, 15)}`;

    // Send invoice back to client
    this.sendMessage(ws, {
      type: 'fast_withdraw_invoice',
      data: {
        amount: data.amount,
        destination: l2Address
      }
    } as FastWithdrawInvoice);

    if (DEBUG) {
      console.log('Generated L2 address:', l2Address);
      console.log('For amount:', data.amount);
    }
  }

  private handleInvoicePaid(
    ws: WebSocket,
    data: InvoicePaidRequest['data']
  ) {
    // Generate a mock mainchain transaction ID
    const mainchainTxid = `TX_${Math.random().toString(36).substring(2, 15)}`;

    // Send completion message
    this.sendMessage(ws, {
      type: 'fast_withdraw_complete',
      data: {
        txid: mainchainTxid,
        amount: data.amount,
        destination: data.destination
      }
    } as FastWithdrawComplete);

    if (DEBUG) {
      console.log('Generated mainchain txid:', mainchainTxid);
      console.log('For L2 txid:', data.txid);
    }
  }

  private sendMessage(ws: WebSocket, message: Message) {
    if (DEBUG) {
      const clientId = this.clients.get(ws);
      console.log(`Sending to client ${clientId}:`, message);
    }
    ws.send(JSON.stringify(message));
  }

  private sendError(ws: WebSocket, code: string, message: string) {
    this.sendMessage(ws, {
      type: 'error',
      data: {
        code,
        message
      }
    } as ErrorMessage);
  }
}

// Start the mock Bitcoin client
new MockBitcoinClient();