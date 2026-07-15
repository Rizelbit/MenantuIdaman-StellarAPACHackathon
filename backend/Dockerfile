FROM node:20-alpine AS base

WORKDIR /app

# Install pnpm (project switched from npm to pnpm — see package.json's
# pnpm.overrides for @stellar/stellar-sdk/@stellar/js-xdr version pins).
# Pinned to v9 to match pnpm-lock.yaml's lockfileVersion 9.0 — pnpm v10+
# moved the "pnpm.overrides" package.json field elsewhere and rejects this
# lockfile under --frozen-lockfile.
RUN corepack enable && corepack prepare pnpm@9 --activate

# Install dependencies
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile

# Copy source & build
COPY . .
RUN pnpm run build

# Runtime
ENV NODE_ENV=production
EXPOSE 3000

CMD ["node", "dist/index.js"]
