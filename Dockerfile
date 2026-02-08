FROM node:23-slim AS deps
WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci

FROM node:23-slim AS builder
WORKDIR /app

# this should preferably be done with google secrets manager
# but currently i want to keep it simple and not add more complexity to the project
ARG NEXT_PUBLIC_CLIENT_ID
ARG CLIENT_ID
ARG CLIENT_SECRET
ARG TOKEN_URL
ARG SPOTIFY_API_URL

ENV NEXT_PUBLIC_CLIENT_ID=$NEXT_PUBLIC_CLIENT_ID
ENV CLIENT_ID=$CLIENT_ID
ENV CLIENT_SECRET=$CLIENT_SECRET
ENV TOKEN_URL=$TOKEN_URL
ENV SPOTIFY_API_URL=$SPOTIFY_API_URL

COPY --from=deps /app/node_modules ./node_modules
COPY . .

RUN npm run build

FROM node:23-slim AS runner
WORKDIR /app

ENV NODE_ENV=production
ENV PORT=3000

COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json

EXPOSE 3000

CMD ["npm", "run", "start"]