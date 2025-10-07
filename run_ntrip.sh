#!/bin/bash
# This script is designed to be robust and handle interruptions.

# --- Configuration ---
set -eo pipefail

echo "### Script starting. Preparing to stream... ###"

# --- Tool Verification ---
# We now look for a single 'swift' executable.
SWIFT_TOOL=$(which swift)
OUTPUT_FILE="log.rtcm.json"

# Check if the 'swift' tool actually exists.
if [ ! -x "$SWIFT_TOOL" ]; then
    echo "Error: The main 'swift' tool was not found or is not executable."
    exit 1
fi

echo "Swift tool verified at: $SWIFT_TOOL"

# --- Main Execution Logic ---
# This section starts the stream and handles retries for 2 minutes.
echo "Starting stream. This will run for a maximum of 2 minutes."

timeout 120s bash -c '
# This sub-shell will be terminated by the `timeout` command.
while true; do
    echo "Attempting to connect to NTRIP caster..."
    
    # CORRECTED COMMANDS: We call "ntripping" and "rtcm32json" as sub-commands
    # of the main $SWIFT_TOOL program.
    "$0" ntripping \
        --username "$1" \
        --password "$2" \
        --url "https://eu.l1l2.skylark.swiftnav.com:2102/SSR-integrity" \
        --resolve "eu.l1l2.skylark.swiftnav.com:2102:$5" \
        --lat "$3" \
        --lon "$4" | "$0" rtcm32json >> "$6"

    # If the stream is interrupted, this message will show before retrying.
    echo "Stream interrupted. Retrying in 5 seconds..."
    sleep 5
done
' "$SWIFT_TOOL" "$NTRIP_USERNAME" "$NTRIP_PASSWORD" "$LATITUDE" "$LONGITUDE" "$NTRIP_IP" "$OUTPUT_FILE"

echo "### Streaming finished after 2 minutes. ###"
echo "Final log file created at: $OUTPUT_FILE"
