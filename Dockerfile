FROM nlss/base-alpine

RUN apk --update add nginx curl \
    && wget -O /usr/local/bin/attr https://gist.githubusercontent.com/xZero707/7a3fb3e12e7192c96dbc60d45b3dc91d/raw/44a755181d2677a7dd1c353af0efcc7150f15240/attr.sh \
    && chmod a+x /usr/local/bin/attr \
    && mkdir /app/data -p \
    && echo "30 2 * * * /app/cloudflare-sync-ips.sh" > /etc/crontabs/nginx

ENV CRON_ENABLED     true
ENV NGINX_CF_FILE    "/app/data/cloudflare.conf"
ENV CF_IPV4_ENDPOINT "https://www.cloudflare.com/ips-v4/"
ENV CF_IPV6_ENDPOINT "https://www.cloudflare.com/ips-v6/"

# Install gomplate
COPY --from=hairyhenderson/gomplate:v3.9.0-alpine /bin/gomplate  /usr/local/bin/gomplate

WORKDIR "/app"

COPY ["cloudflare-sync-ips.sh", "LICENSE", "/app/"]
COPY ["src", "/app/src/"]
COPY rootfs /

VOLUME ["/app/data"]