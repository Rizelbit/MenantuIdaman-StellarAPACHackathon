import cors from "cors";
import dotenv from "dotenv";
import express, { Request, Response } from "express";

dotenv.config();

const app = express();
app.use(cors());
app.use(express.json());

const PORT = process.env.PORT || 3000;

// Health check
app.get("/health", (_req: Request, res: Response) => {
  res.json({ ok: true, service: "kirimin-backend", env: process.env.NODE_ENV });
});

// Well-known files untuk passkey native (iOS & Android)
// Static serve folder public/.well-known
app.use("/.well-known", express.static("public/.well-known"));

// TODO: implement endpoint kontrak (lihat docs/Flutter-Boilerplate-README.md §8)
// GET  /passkey/register-options
// POST /wallet/create
// POST /tx/build
// POST /tx/submit
// GET  /wallet/:userId/balance

app.listen(PORT, () => {
  // eslint-disable-next-line no-console
  console.log(`Kirimin backend listening on port ${PORT}`);
});
