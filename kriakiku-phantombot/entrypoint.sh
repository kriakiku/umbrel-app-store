#!/bin/sh

# Certificate parameters
DOMAIN="umbrel.local"
CERT_DIR="/umbrel_certs"
PEM_FILE="$CERT_DIR/$DOMAIN.pem"
DAYS_VALID=825  # Maximum certificate validity period

# Check if the PEM certificate exists
if [ ! -f "$PEM_FILE" ]; then
  echo "PEM certificate not found, creating a new one..."
  mkdir -p "$CERT_DIR"
  # Generate private key and certificate in PEM format
  openssl req -new -newkey rsa:2048 -days $DAYS_VALID -nodes -x509 \
    -keyout "$PEM_FILE" -out "$PEM_FILE" \
    -subj "/CN=$DOMAIN"
  echo "PEM certificate successfully created."
  exit 0
fi

# Check the certificate's expiration date
EXPIRY_DATE=$(openssl x509 -enddate -noout -in "$PEM_FILE" | cut -d= -f2)
EXPIRY_TIMESTAMP=$(date -d "$EXPIRY_DATE" +%s)
CURRENT_TIMESTAMP=$(date +%s)
THREE_MONTHS=$(($CURRENT_TIMESTAMP + 90*24*3600))

if [ "$EXPIRY_TIMESTAMP" -lt "$THREE_MONTHS" ]; then
  echo "Certificate will expire in less than 3 months. Issuing a new PEM certificate..."
  openssl req -new -newkey rsa:2048 -days $DAYS_VALID -nodes -x509 \
    -keyout "$PEM_FILE" -out "$PEM_FILE" \
    -subj "/CN=$DOMAIN"
  echo "PEM certificate successfully updated."
else
  echo "PEM certificate is valid until $EXPIRY_DATE. No update required."
fi

# Run the PhantomBot entrypoint script
echo "Running PhantomBot entrypoint script..."
exec /opt/PhantomBot/docker-entrypoint.sh "launch-docker.sh"
