#!/bin/sh

# Certificate parameters
DOMAIN="umbrel.local"
CERT_DIR="/umbrel_certs"
CERT_FILE="$CERT_DIR/$DOMAIN.crt"
KEY_FILE="$CERT_DIR/$DOMAIN.key"
DAYS_VALID=825  # Maximum certificate validity period

# Check if the certificate exists
if [ ! -f "$CERT_FILE" ]; then
  echo "Certificate not found, creating a new one..."
  mkdir -p "$CERT_DIR"
  openssl req -new -newkey rsa:2048 -days $DAYS_VALID -nodes -x509 \
    -keyout "$KEY_FILE" -out "$CERT_FILE" \
    -subj "/CN=$DOMAIN"
  echo "Certificate successfully created."
  exit 0
fi

# Check the certificate's expiration date
EXPIRY_DATE=$(openssl x509 -enddate -noout -in "$CERT_FILE" | cut -d= -f2)
EXPIRY_TIMESTAMP=$(date -d "$EXPIRY_DATE" +%s)
CURRENT_TIMESTAMP=$(date +%s)
THREE_MONTHS=$(($CURRENT_TIMESTAMP + 90*24*3600))

if [ "$EXPIRY_TIMESTAMP" -lt "$THREE_MONTHS" ]; then
  echo "Certificate will expire in less than 3 months. Issuing a new certificate..."
  openssl req -new -newkey rsa:2048 -days $DAYS_VALID -nodes -x509 \
    -keyout "$KEY_FILE" -out "$CERT_FILE" \
    -subj "/CN=$DOMAIN"
  echo "Certificate successfully updated."
else
  echo "Certificate is valid until $EXPIRY_DATE. No update required."
fi
