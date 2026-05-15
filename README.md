# ERP Digital Printing Deployment Guide

Dokumentasi untuk operasional dan maintenance backend ERP di server VPS.

## 🚀 Database Maintenance

Semua perintah dijalankan dari dalam container `erp-app` agar tidak perlu instalasi tool tambahan di host VPS.

### 1. Database Migration (Up)
Gunakan command ini untuk memperbarui skema database ke versi terbaru:

```bash
docker exec -it erp-app ./migrate -path ./migrations -database "postgres://${DB_USER}:${DB_PASSWORD}@db:5432/${DB_NAME}?sslmode=disable" up
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
