/**
 * PasskeyKit server setup + WebAuthn bridge.
 *
 * Menggunakan dynamic import karena passkey-kit adalah ESM-only.
 * tsx handle ESM/CJS interop secara otomatis untuk development.
 */

// Types untuk bridge
type RegistrationResponseJSON = {
  id: string;
  rawId: string;
  response: { clientDataJSON: string; attestationObject: string };
  type: string;
};

type AuthenticationResponseJSON = {
  id: string;
  rawId: string;
  response: { clientDataJSON: string; authenticatorData: string; signature: string };
  type: string;
};

type WebAuthnCreationOptions = {
  challenge: string;
  rp: { id: string; name: string };
  user: { id: string; name: string; displayName: string };
  pubKeyCredParams: Array<{ type: string; alg: number }>;
  timeout?: number;
};

type WebAuthnRequestOptions = {
  challenge: string;
  rpId: string;
  timeout?: number;
  allowCredentials?: Array<{ type: string; id: string }>;
  userVerification?: string;
};

// ---------------------------------------------------------------------------
// WebAuthn Bridge
// ---------------------------------------------------------------------------

class WebAuthnBridge {
  private pendingReg: {
    options: WebAuthnCreationOptions;
    resolve: (attestation: RegistrationResponseJSON) => void;
  } | null = null;

  private pendingAuth: {
    options: WebAuthnRequestOptions;
    resolve: (assertion: AuthenticationResponseJSON) => void;
  } | null = null;

  async startRegistration({ optionsJSON }: { optionsJSON: WebAuthnCreationOptions }): Promise<RegistrationResponseJSON> {
    return new Promise<RegistrationResponseJSON>((resolve) => {
      this.pendingReg = { options: optionsJSON, resolve };
    });
  }

  async startAuthentication({ optionsJSON }: { optionsJSON: WebAuthnRequestOptions }): Promise<AuthenticationResponseJSON> {
    return new Promise<AuthenticationResponseJSON>((resolve) => {
      this.pendingAuth = { options: optionsJSON, resolve };
    });
  }

  hasPendingRegistration() { return this.pendingReg !== null; }
  getRegistrationOptions() { return this.pendingReg?.options ?? null; }
  completeRegistration(attestation: RegistrationResponseJSON) {
    if (this.pendingReg) {
      this.pendingReg.resolve(attestation);
      this.pendingReg = null;
    }
  }

  hasPendingAuthentication() { return this.pendingAuth !== null; }
  getAuthenticationOptions() { return this.pendingAuth?.options ?? null; }
  completeAuthentication(assertion: AuthenticationResponseJSON) {
    if (this.pendingAuth) {
      this.pendingAuth.resolve(assertion);
      this.pendingAuth = null;
    }
  }
}

// ---------------------------------------------------------------------------
// Singleton instances — initialized lazily via dynamic import
// ---------------------------------------------------------------------------

export const bridge = new WebAuthnBridge();

const NETWORK_PASSPHRASE = "Test SDF Network ; September 2015";
const WALLET_WASM_HASH = "fdefad64b96837147e1c333e51f537b696eab925e9f147e63d597c04e3c903f0";
const RPC_URL = process.env.SOROBAN_RPC_URL || "https://soroban-testnet.stellar.org";

let _kit: any = null;
let _server: any = null;

export async function getKit() {
  if (!_kit) {
    const { PasskeyKit } = await import("passkey-kit");
    _kit = new PasskeyKit({
      rpcUrl: RPC_URL,
      networkPassphrase: NETWORK_PASSPHRASE,
      walletWasmHash: WALLET_WASM_HASH,
      rpId: process.env.RP_ID || "localhost",
      WebAuthn: bridge as any,
      ...(process.env.SIGNER_SECRET_KEY ? { deploySource: process.env.SIGNER_SECRET_KEY } : {}),
    });
  }
  return _kit;
}

export async function getServer() {
  if (!_server) {
    const { PasskeyServer } = await import("passkey-kit/server");
    const relayerConfig = process.env.RELAYER_BASE_URL
      ? { baseUrl: process.env.RELAYER_BASE_URL, apiKey: process.env.RELAYER_API_KEY || "" }
      : undefined;
    _server = new PasskeyServer({
      networkPassphrase: NETWORK_PASSPHRASE,
      rpcUrl: RPC_URL,
      relayer: relayerConfig,
    });
  }
  return _server;
}

export const USDC_ISSUER = process.env.USDC_ISSUER || "GBBD47IF6LWK7P7MDEVSCWR7DPUWV3NY3DTQEVFL4NAT4AQH3ZLLFLA5";

/**
 * Helper: tunggu sampai bridge punya pending data, dengan timeout.
 */
export async function waitForBridge(check: () => boolean, timeoutMs = 15000): Promise<void> {
  const start = Date.now();
  while (!check()) {
    if (Date.now() - start > timeoutMs) {
      throw new Error("Bridge timeout — WebAuthn ceremony tidak dimulai");
    }
    await new Promise((r) => setTimeout(r, 20));
  }
}
