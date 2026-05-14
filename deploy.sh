#!/bin/bash

# --- CONFIGURATION ---
# Ganti sesuai info server ente, bosku!
SERVER_USER="dystopia"
SERVER_IP="103.127.134.41"
SERVER_PATH="/home/dystopia/erp-digital-printing-deployment"
# ---------------------

echo "🚀 Memulai Deployment ke $SERVER_IP..."

# 0. Safety Check
if [ ! -f .env ]; then
    echo "❌ Error: .env file tidak ditemukan di root!"
    echo "💡 Copying from env/backend/.env.example..."
    cp env/backend/.env.example .env
    echo "⚠️  Silakan edit .env dulu, baru jalanin lagi deploy.sh nya bosku!"
    exit 1
fi

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
