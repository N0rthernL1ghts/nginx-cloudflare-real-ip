#!/usr/bin/env sh

println() {
  if [ "${VERBOSE_MODE:-}" = "true" ]; then
    echo "${1:-}"
    return 0
  fi
  return 1
}

printlnError() {
  if [ "${VERBOSE_MODE:-}" = "true" ]; then
    echo >&2 "${1:-}"
    return 0
  fi
  return 1
}

fetchCloudFlareIPRanges() {
  ENDPOINT="${1:-}"

  if [ -z "${ENDPOINT}" ]; then
    printlnError "Argument error:  Missing endpoint"
    return 1
  fi

  CF_IP_RANGES=$(curl --fail --silent "${ENDPOINT}")

  if [ "${?}" != 0 ]; then
    printlnError "Error: Fetching IP ranges from '${ENDPOINT}' failed. Invalid response"
    printlnError "Warning: Skipping section"
    return 1
  fi

  if [ -n "${CF_IP_RANGES}" ]; then
    echo "${CF_IP_RANGES}"
    return 0
  fi

  printlnError "Error: Fetching IP ranges from '${ENDPOINT}' failed. Empty response"
  return 1
}

isDockerContainer() {
  if [ -f /.dockerenv ]; then
    return 0
  fi
  return 1
}

validateNginxConfig() {
  CONF_FILE="${1:-}"

  if [ -z "${CONF_FILE}" ]; then
    printlnError "Argument error:  Missing endpoint"
    return 1
  fi

  if [ ! -f "${CONF_FILE}" ]; then
    printlnError "validateNginxConfig: ${CONF_FILE}: No such file or directory"
    return 1
  fi

  if isDockerContainer; then

    NGINX_CF_FILE=${CONF_FILE} /usr/local/bin/gomplate -V \
      -o "${CONF_FILE}.full" \
      -f /etc/templates/nginx.conf

    nginx -t -c "$(realpath ${CONF_FILE}.full)"
    return $?
  fi

  printlnError "Warning: Not validated with nginx. Docker environment unavailable"
}
