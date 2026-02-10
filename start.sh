#!/bin/bash

set -e # Exit immediately if a command exits with a non-zero status

# --- Configuration ---
PYTHON_SERVER_PATH="server/server.py"
CLIENT_DIR="client"
VITE_DEV_CMD="npm run dev"
VITE_READY_MESSAGE="Local:" # Look for this string in Vite's output to detect the URL
DEFAULT_VITE_URL="http://localhost:5173" # Fallback URL if detection fails

# --- Functions ---

# Function to clean up background processes on script exit
cleanup() {
    echo -e "
--- Shutting down services ---"
    if [ -n "$PYTHON_PID" ]; then
        echo "Stopping Python server (PID: $PYTHON_PID)..."
        kill $PYTHON_PID || true # `|| true` prevents script from exiting if process already dead
    fi
    if [ -n "$VITE_PID" ]; then
        echo "Stopping Vite dev server (PID: $VITE_PID)..."
        # `kill -TERM` sends a termination signal, allowing graceful shutdown
        kill -TERM $VITE_PID || true
    fi
    if [ -f "$VITE_LOG" ]; then
        rm "$VITE_LOG"
    fi
    echo "Cleanup complete."
}

# Trap CTRL+C and call the cleanup function
trap cleanup EXIT

# --- Start Python Server ---
echo "--- Starting Python backend server ---"
python3 "$PYTHON_SERVER_PATH" &
PYTHON_PID=$!
echo "Python server started with PID: $PYTHON_PID"
echo "Waiting for Python server to initialize (2 seconds)..."
sleep 2 # Give Python server a moment to start up

# --- Start Vite Development Server and capture its URL ---
echo "--- Starting Vite development server ---"
echo "Running '$VITE_DEV_CMD' in '$CLIENT_DIR'"

# Run Vite in the background and redirect its output to a temporary file
VITE_LOG=$(mktemp)
(cd "$CLIENT_DIR" && $VITE_DEV_CMD) > "$VITE_LOG" 2>&1 &
VITE_PID=$!
echo "Vite dev server started with PID: $VITE_PID, logs are in $VITE_LOG"

VITE_URL_FOUND=""
MAX_RETRIES=30 # Wait up to 30 * 1 second = 30 seconds
RETRY_COUNT=0

echo "Waiting for Vite server to report its URL..."
while [ -z "$VITE_URL_FOUND" ] && [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    # Check if Vite process is still running
    if ! kill -0 $VITE_PID 2>/dev/null; then
        echo "Vite process (PID: $VITE_PID) exited unexpectedly. Check logs for details."
        cat "$VITE_LOG" # Print Vite logs for debugging
        cleanup
        exit 1
    fi

    # Look for the "Local:" line and extract the URL
    VITE_URL_FOUND=$(grep "$VITE_READY_MESSAGE" "$VITE_LOG" | awk '{print $NF}' | head -n 1)
    if [ -n "$VITE_URL_FOUND" ] && [[ "$VITE_URL_FOUND" == http* ]]; then
        echo "Detected Vite URL: $VITE_URL_FOUND"
        break
    else
        echo -n "."
        sleep 1
        RETRY_COUNT=$((RETRY_COUNT+1))
    fi
done

if [ -z "$VITE_URL_FOUND" ]; then
    echo -e "
Error: Could not detect Vite URL after $MAX_RETRIES seconds."
    echo "Falling back to default URL: $DEFAULT_VITE_URL"
    VITE_URL_FOUND=$DEFAULT_VITE_URL
fi

# --- Launch Browser ---
echo -e "
--- Launching browser ---"
open "$VITE_URL_FOUND"

# --- Keep script running (maintains background processes) ---
echo -e "
--- Services are running ---"
echo "Press Ctrl+C to stop both backend and frontend development servers."

# Wait for Vite process to exit. If Vite is killed, the cleanup trap will fire.
wait $VITE_PID

# The temporary log file is removed by the cleanup trap
echo "Script finished."
