# syntax=docker/dockerfile:1
ARG CADDY_VERSION=2.11.4
FROM caddy:${CADDY_VERSION}-builder AS builder
ARG CADDY_VERSION
ARG TENCENTCLOUD_REF=723aebc4c1b0f910657c85e33b0bee052eaafe59
ARG L4_REF=42db5690dea199f930a6f08005fe2e4aab10dcc9
# 使用官方 Go 代理；国内本地构建可通过 build-arg 覆盖。
ARG GOPROXY=https://proxy.golang.org,direct
ENV GOPROXY=${GOPROXY}
RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    xcaddy build v${CADDY_VERSION} \
      --with github.com/caddy-dns/tencentcloud@${TENCENTCLOUD_REF} \
      --with github.com/mholt/caddy-l4@${L4_REF}

FROM caddy:${CADDY_VERSION}
ARG CADDY_VERSION
LABEL org.opencontainers.image.source="https://github.com/yuehei/caddy" \
      org.opencontainers.image.description="Caddy with Tencent Cloud DNS and Layer 4 modules" \
      org.opencontainers.image.version="${CADDY_VERSION}"
COPY --from=builder /usr/bin/caddy /usr/bin/caddy
