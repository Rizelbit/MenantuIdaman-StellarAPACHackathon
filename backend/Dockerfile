FROM node:20-alpine AS base

WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm ci

# Copy source & build
COPY . .
RUN npm run build

# Runtime
ENV NODE_ENV=production
EXPOSE 3000

CMD ["node", "dist/index.js"]
