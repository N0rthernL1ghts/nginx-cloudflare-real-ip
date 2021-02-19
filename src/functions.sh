#!/usr/bin/env sh

fetchCloudFlareIPRanges() {
  ENDPOINT="${1:-}"

  if [ -z "${ENDPOINT}" ]; then
    echo >&2 "Argument error:  Missing endpoint"
    return 1
  fi

  CF_IP_RANGES=$(curl --silent "${ENDPOINT}")

  if [ -n "${CF_IP_RANGES}" ]; then
    echo "${CF_IP_RANGES}"
    return 0
  fi

  echo >&2 "Error occurred fetching IP ranges from ${ENDPOINT}"
  return 1
}
