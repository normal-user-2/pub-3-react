FROM node:10 AS builder
WORKDIR /app
ENV BUILD_PATH './build'

COPY . .

RUN \
  if [ -f yarn.lock ]; then yarn && yarn build; \
  elif [ -f package-lock.json ]; then npm ci && npm run build; \
  elif [ -f pnpm-lock.yaml ]; then yarn global add pnpm && pnpm i && pnpm run build; \
  else echo "Lockfile not found." && exit 1; \
  fi

FROM nginx:alpine AS prod
WORKDIR /usr/share/nginx/html
COPY --from=builder /app/build .
EXPOSE 80
ENTRYPOINT ["nginx", "-g", "daemon off;"]

