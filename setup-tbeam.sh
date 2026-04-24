#!/usr/bin/env bash
set -euo pipefail

VENV="/Users/ifjke/venv/bin"
DEFAULT_PORT="/dev/cu.usbserial-58741050131"

# --- Prompt for user input ---

read -rp "Serial port [$DEFAULT_PORT]: " PORT
PORT="${PORT:-$DEFAULT_PORT}"

read -rp "Owner name (long, e.g. Micromata-FutureSpace-1): " OWNER
read -rp "Owner short name (max 4 chars, e.g. MFD1): " OWNER_SHORT

read -rp "WiFi SSID: " WIFI_SSID
read -rsp "WiFi password: " WIFI_PASS
echo

MESH="$VENV/meshtastic --port $PORT"

echo ""
echo "=== Configuring T-Beam on $PORT ==="
echo ""

# --- Owner ---
echo ">> Setting owner: $OWNER ($OWNER_SHORT)"
$MESH --set-owner "$OWNER"
$MESH --set-owner-short "$OWNER_SHORT"

# --- WiFi ---
echo ">> Configuring WiFi"
$MESH --set network.wifi_enabled true
$MESH --set network.wifi_ssid "$WIFI_SSID"
$MESH --set network.wifi_psk "$WIFI_PASS"

# --- Position / GPS every 300s ---
echo ">> Configuring GPS position (300s)"
$MESH --set position.gps_enabled true
$MESH --set position.gps_update_interval 300
$MESH --set position.position_broadcast_secs 300
$MESH --set position.position_broadcast_smart_enabled false

# --- Environment telemetry every 300s (AHT20 + BMP280 auto-detected on I2C) ---
echo ">> Configuring environment telemetry (300s)"
$MESH --set telemetry.environment_measurement_enabled true
$MESH --set telemetry.environment_update_interval 300
$MESH --set telemetry.environment_screen_enabled true

# --- Reset node database ---
echo ">> Clearing node database"
$MESH --reset-nodedb
sleep 5

# --- MQTT ---
echo ">> Configuring MQTT"
$MESH --set mqtt.enabled true
$MESH --set mqtt.address mq.dg6obo.de
$MESH --set mqtt.username meshtastic
$MESH --set mqtt.password meshtastic-demo
$MESH --set mqtt.encryption_enabled true
$MESH --set mqtt.json_enabled true
$MESH --ch-set uplink_enabled true --ch-index 0

echo ""
echo "=== Configuration complete. Rebooting node... ==="
$MESH --reboot
