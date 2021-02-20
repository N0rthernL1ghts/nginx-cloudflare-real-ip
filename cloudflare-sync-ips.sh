#!/usr/bin/env sh

NGINX_CF_FILE="${NGINX_CF_FILE:-/etc/nginx/cloudflare}"
VERBOSE_MODE=${VERBOSE_MODE:-true}

# Data endpoints
CF_IPV4_ENDPOINT="${CF_IPV4_ENDPOINT:-https://www.cloudflare.com/ips-v4/}"
CF_IPV6_ENDPOINT="${CF_IPV6_ENDPOINT:-https://www.cloudflare.com/ips-v6/}"

SCRIPTPATH="$(
  cd "$(dirname "$0")" >/dev/null 2>&1
  pwd -P
)"

. ${SCRIPTPATH}/src/functions.sh

trap 'rm -f "${TMP_FILE}"' EXIT
TMP_FILE="$(mktemp)"

if [ -z "${TMP_FILE}" ]; then
  echo "Error creating temporary file"
  exit 1
fi

echo "#Cloudflare" >"${TMP_FILE}"
echo "" >>"${TMP_FILE}"

echo "# - IPv4" >>"${TMP_FILE}"

CF_IPV4_RANGES=$(fetchCloudFlareIPRanges "${CF_IPV4_ENDPOINT}")
if [ -n "${CF_IPV4_RANGES}" ]; then
  for IP_RANGE in ${CF_IPV4_RANGES}; do
    echo "set_real_ip_from ${IP_RANGE};" >>"${TMP_FILE}"
  done
fi

echo "" >>"${TMP_FILE}"
echo "# - IPv6" >>"${TMP_FILE}"

CF_IPV6_RANGES=$(fetchCloudFlareIPRanges "${CF_IPV6_ENDPOINT}")
if [ -n "${CF_IPV6_RANGES}" ]; then
  for IP_RANGE in ${CF_IPV6_RANGES}; do
    echo "set_real_ip_from ${IP_RANGE};" >>"${TMP_FILE}"
  done
fi

echo "" >>"${TMP_FILE}"
echo "real_ip_header CF-Connecting-IP;" >>"${TMP_FILE}"

if validateNginxConfig "${TMP_FILE}"; then
  echo "Flushing file"
  cat "${TMP_FILE}" >"${NGINX_CF_FILE}"
fi
