#!/usr/bin/env sh

NGINX_CF_FILE=/etc/nginx/cloudflare

# Data endpoints
CF_IPV4_ENDPOINT="${CF_IPV4_ENDPOINT:-https://www.cloudflare.com/ips-v4}"
CF_IPV6_ENDPOINT="${CF_IPV6_ENDPOINT:-https://www.cloudflare.com/ips-v6}"

. ./src/functions.sh

echo "#Cloudflare" > "${NGINX_CF_FILE}";
echo "" >> "${NGINX_CF_FILE}";

echo "# - IPv4" >> "${NGINX_CF_FILE}";

CF_IPV4_RANGES=$(fetchCloudFlareIPRanges "${CF_IPV4_ENDPOINT}")
if [ -n "${CF_IPV4_RANGES}" ]; then
  for IP_RANGE in ${CF_IPV4_RANGES}; do
    echo "set_real_ip_from ${IP_RANGE};" >> "${NGINX_CF_FILE}";
  done
fi

echo "" >> "${NGINX_CF_FILE}";
echo "# - IPv6" >> "${NGINX_CF_FILE}";

CF_IPV6_RANGES=$(fetchCloudFlareIPRanges "${CF_IPV6_ENDPOINT}")
if [ -n "${CF_IPV6_RANGES}" ]; then
  for IP_RANGE in ${CF_IPV6_RANGES}; do
    echo "set_real_ip_from ${IP_RANGE};" >> "${NGINX_CF_FILE}";
  done
fi

echo "" >> "${NGINX_CF_FILE}";
echo "real_ip_header CF-Connecting-IP;" >> "${NGINX_CF_FILE}";