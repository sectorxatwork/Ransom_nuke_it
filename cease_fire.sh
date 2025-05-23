#!/usr/bin/env bash
# decrypt-folder.sh
# Decrypts a previously encrypted .enc file and restores the original folder

set -euo pipefail

usage() {
    echo "Usage: $0 <encrypted_file.enc>"
    exit 1
}

# ---- 1. Input Validation -----------------------------------------------------
[[ $# -eq 1 ]] || usage

ENC_FILE="$(realpath "$1")"
[[ -f "$ENC_FILE" ]] || {
    echo "  Error: File '$ENC_FILE' does not exist."
    exit 1
}

DIR="$(dirname "$ENC_FILE")"
BASENAME="$(basename "$ENC_FILE" .enc)"
DECRYPTED_ARCHIVE="${DIR}/${BASENAME}.tar.gz"
RESTORE_DIR="${DIR}/${BASENAME}"

# ---- 2. Get password ---------------------------------------------------------
PASSWORD="${PASSWORD:-}"
if [[ -z "$PASSWORD" ]]; then
    read -rsp "Enter decryption password: " PASSWORD
    echo
fi

# ---- 3. Decrypt the archive --------------------------------------------------
echo "  Decrypting '$ENC_FILE' → '$DECRYPTED_ARCHIVE' ..."
openssl enc -d -aes-256-cbc -in "$ENC_FILE" -out "$DECRYPTED_ARCHIVE" -pass pass:"$PASSWORD"

# ---- 4. Extract the archive --------------------------------------------------
echo "  Extracting archive → '$RESTORE_DIR' ..."
tar -xzf "$DECRYPTED_ARCHIVE" -C "$DIR"

# ---- 5. Cleanup --------------------------------------------------------------
echo "  Cleaning up temporary files ..."
rm "$DECRYPTED_ARCHIVE"
rm /tmp/Hacked.jpg
echo "Done. Folder restored to: $RESTORE_DIR"
