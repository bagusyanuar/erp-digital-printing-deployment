# ERP Digital Printing Deployment Guide

Dokumentasi untuk operasional dan maintenance backend ERP di server VPS.

## 🚀 Database Maintenance

Gunakan script shortcut agar lebih cepat:

1. **Migration:** `./migrate.sh`
2. **Seeding:** `./seed.sh`

> **Note:** Jangan lupa jalankan `chmod +x *.sh` saat pertama kali setup di VPS.

---

### Manual Commands (Jika script bermasalah)
Semua perintah dijalankan dari dalam container `erp-app`:
Gunakan command ini untuk memperbarui skema database ke versi terbaru:

```bash
docker exec -it erp-app ./migrate -path ./migrations -database "postgres://${DB_USER}:${DB_PASSWORD}@db:5432/${DB_NAME}?sslmode=disable" up
```
Contoh langsung sesuai env server:
```bash
docker exec -it erp-app ./migrate -path ./migrations -database "postgres://postgres:<DB_PASSWORD>@db:5432/db_erp_printing?sslmode=disable" up
```

> **Note:** Pastikan `sslmode=disable` (bukan `ssl_mode`) dan hostname menggunakan `db`.

### 2. Database Seeding
Gunakan command ini untuk mengisi data awal (Permissions, Roles, Admin User):

```bash
docker exec -it erp-app ./seed
```

### 3. Cek Versi Migrasi
Untuk melihat versi migrasi saat ini:

```bash
docker exec -it erp-app ./migrate -path ./migrations -database "postgres://${DB_USER}:${DB_PASSWORD}@db:5432/${DB_NAME}?sslmode=disable" version
```
Atau:
```bash
docker exec -it erp-app ./migrate -path ./migrations -database "postgres://postgres:<DB_PASSWORD>@db:5432/db_erp_printing?sslmode=disable" version
```

---

## ⚙️ Environment Configuration (`env/backend/.env`)

Template konfigurasi `.env` backend di server (isi `DB_PASSWORD` sesuai server):

```env
APP_NAME=erp-digital-printing
APP_VERSION="1.0.0"

APP_ENV=production
APP_PORT=8000
APP_DEBUG=false
APP_CORS_ALLOWED_ORIGINS=http://localhost:3000,http://localhost:5173,https://made-printing.local:5173

DB_HOST=db
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=<DB_PASSWORD>
DB_NAME=db_erp_printing
DB_SSLMODE=disable

JWT_ISSUER=erp-digital-printing-app
JWT_SECRET=a78f2c3d9e4b1a5c8d0e6f2a9b4c7d1e8f0a3b6c9d2e5f1a4b7c0d3e6f9a2b5
JWT_EXPIRATION=5
JWT_SECRET_REFRESH=f1e2d3c4b5a697887766554433221100aabbccddeeff00112233445566778899
JWT_EXPIRATION_REFRESH=30

LOG_FILE=.logs/app.log
LOG_MAX_SIZE=10
LOG_MAX_BACKUPS=3
LOG_MAX_AGE=7
LOG_COMPRESS=true
LOG_LEVEL=debug

CASBIN_MODEL_PATH=configs/rbac_model.conf
```

## 🛠 Troubleshooting

### Password Authentication Failed
Jika muncul error password, kemungkinan besar:
1. Database lama masih menggunakan password default (`password123`).
2. File `.env` belum di-load oleh service `db` di `docker-compose.yaml`.

**Solusi:**
Pastikan service `db` di `docker-compose.yaml` sudah menggunakan `env_file`:
```yaml
  db:
    ...
    env_file: env/backend/.env
```

### SSL Not Enabled
Jika muncul error SSL, pastikan di connection string menggunakan parameter `?sslmode=disable`.
