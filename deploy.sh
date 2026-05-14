#!/bin/bash

# --- CONFIGURATION ---
SSH_ALIAS="dystopia-vps"
SERVER_PATH="/home/dystopia/erp-digital-printing-deployment"
# ---------------------

echo "🚀 Memulai Deployment ke $SSH_ALIAS..."

# 0. Safety Check
if [ ! -f env/backend/.env ]; then
    echo "❌ Error: .env file tidak ditemukan di env/backend/!"
    echo "⚠️  Silakan buat .env di env/backend/ dulu bosku!"
    exit 1
fi

# 1. Transfer Secrets & Certs (Manual Sync)
echo "🔑 Mengirim .env dan certificates..."
ssh $SSH_ALIAS "mkdir -p $SERVER_PATH/env/backend $SERVER_PATH/nginx/cert"
scp env/backend/.env $SSH_ALIAS:$SERVER_PATH/env/backend/
scp -r nginx/cert/* $SSH_ALIAS:$SERVER_PATH/nginx/cert/

# 2. Sync Code (Tanpa sampah .git dan file yang di-ignore)
echo "📦 Sinkronisasi source code via rsync..."
rsync -avz --delete \
    --exclude-from='.gitignore' \
    --exclude='.git' \
    ./ $SSH_ALIAS:$SERVER_PATH/

# 3. Eksekusi Docker di Server
echo "🔄 Restarting Docker containers..."
ssh $SSH_ALIAS "cd $SERVER_PATH && docker compose pull && docker compose up -d"

echo "✅ Selesai! ERP Digital Printing sudah Up di $SSH_ALIAS."
