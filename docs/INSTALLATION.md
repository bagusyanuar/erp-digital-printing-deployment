# 🚀 Server Installation Guide - ERP Digital Printing

### 1. Persiapan Server (Ubuntu/Debian)
* **Update System**: `sudo apt update && sudo apt upgrade -y`
* **Install Docker**:
    * `curl -fsSL https://get.docker.com -o get-docker.sh`
    * `sudo sh get-docker.sh`
* **Install Docker Compose**:
    * `sudo apt install docker-compose-v2 -y` (Docker Compose V2)
* **User Permission**:
    * `sudo usermod -aG docker $USER`
    * *Relog SSH agar efeknya terasa.*

### 2. Persiapan Lokal (Mac Ente)
* **Konfigurasi Environment**:
    * Copy file: `cp env/backend/.env.example .env`
    * Edit `.env`:
        * `DB_HOST=db` (Wajib pake nama service docker).
        * `DB_PASSWORD`: Sesuaikan sama yang ada di `docker-compose.yaml`.
        * `JWT_SECRET`: Ganti pake string random yang panjang & rahasia.
        * `APP_ENV=production`
* **Persiapan SSL**:
    * Taruh certificate SSL di `nginx/cert/` sesuai nama di `default.conf`.
* **Update Script**:
    * Edit `deploy.sh`, sesuaikan `SERVER_IP` dan `SERVER_PATH`.
* **SSH Key**:
    * Pastikan SSH key ente sudah terdaftar di server (`ssh-copy-id root@ip-server`) biar ga capek ngetik password pas deploy.

### 3. First Time Deployment
* **Gas Command**: `./deploy.sh`
* **Run Database Migration**:
    * Setelah deploy berhasil, jalankan migrasi database di server:
      ```bash
      ./migrate.sh
      ```
    * Jika muncul error password authentication (misal password di `.env` sudah diganti tapi DB container terlanjur dibikin pake password lama):
      ```bash
      docker exec -it erp-app ./migrate -path ./migrations -database "postgres://postgres:password123@db:5432/db_erp_printing?sslmode=disable" up
      ```
* **Verifikasi**:
    * SSH ke server.
    * Cek container: `docker ps`
    * Cek logs: `docker compose logs -f app`

### 4. Troubleshooting
* **Database Ga Konek**: Cek `.env`, pastikan `DB_HOST` di backend pake nama service `db`.
* **Database Auth Failed**: Jika password `.env` baru tidak match dengan db volume lama, gunakan perintah `docker exec` di atas dengan password default `password123`, atau ganti password user di postgres container:
  ```bash
  docker exec -it erp-db psql -U postgres -d db_erp_printing -c "ALTER USER postgres WITH PASSWORD 'password_baru_ente';"
  ```
* **Nginx Error**: Cek path certificate di `nginx/default.conf` sudah sesuai dengan folder `/etc/nginx/cert/` di container.
* **Port Bentrok**: Pastikan port 80/443 di server kaga ada yang pake (misal Apache bawaan).
