# Logging helper
log() {
  echo ">>> [$(date +'%Y-%m-%dT%H:%M:%S%z')] $*"
}

# Function to start a service and wait until it becomes active
start_and_wait_for_service() {
  local service_name="$1"
  local max_attempts="${2:-10}"  # Default to 10 attempts if not specified
  local sleep_seconds="${3:-2}"  # Default to 2 seconds between attempts

  log "Starting ${service_name} service..."
  sudo systemctl enable "${service_name}"
  sudo systemctl start "${service_name}"

  log "Waiting for ${service_name} to become active..."
  for attempt in $(seq 1 "$max_attempts"); do
    if systemctl is-active --quiet "${service_name}"; then
      log "${service_name} is active and running."
      return 0
    else
      log "${service_name} not ready yet. Retrying (${attempt}/${max_attempts})..."
      sleep "${sleep_seconds}"
    fi
  done

  log "ERROR: ${service_name} failed to start after ${max_attempts} attempts."
  exit 1
}