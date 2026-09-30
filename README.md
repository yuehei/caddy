# Caddy 插件

| 插件 | 模块 | 固定提交 |
| --- | --- | --- |
| [Tencent Cloud DNS](https://github.com/caddy-dns/tencentcloud) | `dns.providers.tencentcloud` | `723aebc4c1b0f910657c85e33b0bee052eaafe59` |
| [Caddy Layer 4](https://github.com/mholt/caddy-l4) | `layer4`、`layer4.handlers.tls`、`layer4.handlers.proxy` 等 | `42db5690dea199f930a6f08005fe2e4aab10dcc9` |

## 拉取镜像

支持 `linux/amd64` 和 `linux/arm64`，Docker 会自动选择对应架构。

```bash
docker pull ghcr.io/yuehei/caddy:2.11.4
```

也可使用 `ghcr.io/yuehei/caddy:latest`。建议部署时固定版本；更新版本前先检查变更。

## 验证版本与插件

```bash
docker run --rm ghcr.io/yuehei/caddy:2.11.4 caddy version
docker run --rm ghcr.io/yuehei/caddy:2.11.4 caddy list-modules
```

## Docker 快速使用

使用镜像内置的默认配置启动静态文件服务，仅通过宿主机回环地址访问：

```bash
docker run -d --name caddy \
  --restart unless-stopped \
  -p 127.0.0.1:8080:80 \
  -v caddy_data:/data \
  -v caddy_config:/config \
  ghcr.io/yuehei/caddy:2.11.4
```

打开 `http://127.0.0.1:8080`。默认配置的监听行为沿用官方镜像；宿主机只映射回环地址。
如需自定义配置，使用下方 Compose 方式。

## Docker Compose

在同一目录创建 `compose.yaml`、`Caddyfile` 和用于静态文件的 `site/` 目录。

```yaml
services:
  caddy:
    image: ghcr.io/yuehei/caddy:2.11.4
    restart: unless-stopped
    ports:
      - "127.0.0.1:8080:80"
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile:ro
      - ./site:/srv:ro
      - caddy_data:/data
      - caddy_config:/config

volumes:
  caddy_data:
  caddy_config:
```

`Caddyfile` 示例：

```caddyfile
:80 {
    root * /srv
    file_server
}
```

将静态文件放入 `site/`，启动前校验配置：

```bash
mkdir -p site
docker compose run --rm --no-deps caddy caddy validate --config /etc/caddy/Caddyfile --adapter caddyfile
docker compose up -d
docker compose logs --tail=100 caddy
```

修改配置后校验并重载，无需重新构建镜像：

```bash
docker compose exec caddy caddy validate --config /etc/caddy/Caddyfile --adapter caddyfile
docker compose exec caddy caddy reload --config /etc/caddy/Caddyfile --adapter caddyfile
```

此示例仅提供本机 HTTP 服务。HTTPS、DNS 验证和 Layer 4 需要自行配置；镜像只提供对应模块。
凭证通过环境变量或密钥文件传入，不要写入镜像或提交到仓库。
`/data` 保存证书等持久化数据，升级时应保留。

## 更新镜像

```bash
docker compose pull
docker compose up -d
```

使用固定版本时，先修改 Compose 中的镜像标签；上述命令不会自动跳到其他版本。
