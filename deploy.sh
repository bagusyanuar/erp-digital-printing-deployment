#!/bin/bash

# --- CONFIGURATION ---
# Ganti sesuai info server ente, bosku!
SERVER_USER="root"
SERVER_IP="1.2.3.4"
SERVER_PATH="/opt/erp-digital-printing"
# ---------------------

echo "🚀 Memulai Deployment ke $SERVER_IP..."

# 1. Transfer Secrets & Certs (Manual Sync)
echo "🔑 Mengirim .env dan certificates..."
ssh $SERVER_USER@$SERVER_IP "mkdir -p $SERVER_PATH/nginx/cert"
scp .env $SERVER_USER@$SERVER_IP:$SERVER_PATH/
scp -r nginx/cert/* $SERVER_USER@$SERVER_IP:$SERVER_PATH/nginx/cert/

# 2. Sync Code (Tanpa sampah .git dan file yang di-ignore)
echo "📦 Sinkronisasi source code via rsync..."
rsync -avz --delete \
    --exclude-from='.gitignore' \
    --exclude='.git' \
    ./ $SERVER_USER@$SERVER_IP:$SERVER_PATH/

# 3. Eksekusi Docker di Server
echo "🔄 Restarting Docker containers..."
ssh $SERVER_USER@$SERVER_IP "cd $SERVER_PATH && docker compose pull && docker compose up -d"

echo "✅ Selesai! ERP Digital Printing sudah Up di $SERVER_IP."
