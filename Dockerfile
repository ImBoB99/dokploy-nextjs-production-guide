# syntax=docker.io/docker/dockerfile:1

# Base image, change node:22 to whatever version of node your project is using
FROM node:22-alpine AS base
WORKDIR /app
RUN apk add --no-cache libc6-compat

# --------------------
# Stage 1: Install dependencies and generate Prisma client
# --------------------
FROM base AS deps
COPY package.json package-lock.json* ./
RUN npm ci

#PRISMA Copy Prisma schema and generate client
COPY prisma ./prisma
RUN npx prisma generate

# --------------------
# Stage 2: Build Next.js
# --------------------
FROM base AS builder
WORKDIR /app

# Copy installed node_modules
COPY --from=deps /app/node_modules ./node_modules

#PRISMA Copy the generated Prisma client
COPY --from=deps /app/generated ./generated

# Copy full source code
COPY . .

# Build Next.js standalone output
RUN npm run build

# --------------------
# Stage 3: Production runtime
# --------------------
FROM base AS runner
WORKDIR /app

ENV NODE_ENV=production
ENV PORT=3000
ENV NEXT_TELEMETRY_DISABLED=1
ENV HOSTNAME="0.0.0.0"

# Create non-root user
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

# Copy public assets
COPY --from=builder /app/public ./public

# Copy standalone build output
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

# Switch to non-root user
USER nextjs

EXPOSE 3000

# Entrypoint
CMD ["node", "server.js"]