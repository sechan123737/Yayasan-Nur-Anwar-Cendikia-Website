# Yayasan Nur Anwar Cendikia — Website

Website yayasan dengan Vue 3 + Vite + Tailwind CSS, terhubung ke Supabase untuk sistem member dan CRUD program/artikel.

## Struktur Proyek

```
src/
  components/        -> Section halaman utama (Hero, About, Programs, dst) - reusable
  views/              -> Halaman per-route (Home, Login, Register, ProgramDetail, Admin)
  composables/        -> useAuth.js - state login & role (member/admin), dipakai di banyak komponen
  lib/supabase.js     -> Koneksi ke Supabase
  router/index.js     -> Routing + proteksi halaman (harus login / harus admin)
supabase/schema.sql    -> Skema database: tabel, RLS policy, trigger, data contoh
```

Bagian dari halaman lama (index4.html) sudah dipecah jadi komponen terpisah supaya mudah dikembangkan:
`Hero.vue`, `ImpactStats.vue`, `About.vue`, `Programs.vue`, `Donate.vue`, `MemberCta.vue` (dulunya "Relawan"),
`NavBar.vue`, `SiteFooter.vue`.

## 1. Setup Supabase

1. Buat project baru di [supabase.com](https://supabase.com).
2. Buka **SQL Editor**, tempel isi file `supabase/schema.sql`, lalu jalankan (Run).
   Ini akan membuat:
   - Tabel `profiles` (data member: nama, no hp, role)
   - Tabel `programs` (program/artikel yayasan)
   - View `programs_preview` (versi publik tanpa konten lengkap)
   - Row Level Security (RLS) + trigger otomatis buat profil saat user daftar
   - 4 contoh data program (Beasiswa, Pusat Komunitas, dll — sama seperti desain awal)
3. Buka **Project Settings -> API**, salin `Project URL` dan `anon public key`.

## 2. Setup Environment

```bash
cp .env.example .env
```

Isi `.env`:
```
VITE_SUPABASE_URL=https://xxxxxxxxxxxx.supabase.co
VITE_SUPABASE_ANON_KEY=isi-dengan-anon-public-key
```

## 3. Install & Jalankan

```bash
npm install
npm run dev
```

Buka `http://localhost:5173`.

## 4. Cara Kerja Sistem Member & Admin

- **Pengunjung biasa (belum login):** hanya bisa lihat ringkasan program (judul + summary) di halaman utama, lewat view `programs_preview` yang publik.
- **Member (sudah daftar & login):** bisa membuka halaman detail penuh tiap program (`/program/:slug`), karena RLS tabel `programs` mensyaratkan `auth.role() = 'authenticated'`.
- **Admin:** bisa mengakses halaman `/admin` untuk CRUD (tambah/edit/hapus) program. Menu "Panel Admin" di navbar hanya muncul untuk akun dengan `role = 'admin'`.

### Menjadikan sebuah akun sebagai admin

1. Daftar akun biasa dulu lewat halaman `/daftar`.
2. Di Supabase SQL Editor, jalankan:
   ```sql
   update public.profiles
   set role = 'admin'
   where id = (select id from auth.users where email = 'email-akun-kamu@contoh.com');
   ```
3. Logout & login ulang di website — menu "Panel Admin" akan muncul di navbar.

### Konfirmasi Email

Secara default Supabase mewajibkan user mengonfirmasi email sebelum bisa login. Kalau untuk keperluan tugas/demo kamu ingin skip ini:
Dashboard Supabase -> **Authentication -> Providers -> Email** -> matikan "Confirm email".

## 5. Build untuk Deploy

```bash
npm run build
```

Hasil build ada di folder `dist/`, bisa di-deploy ke Netlify, Vercel, atau hosting statis lain.
Jangan lupa set environment variable `VITE_SUPABASE_URL` dan `VITE_SUPABASE_ANON_KEY` di dashboard hosting-nya juga.

## Catatan

- Bagian **Donasi** masih simulasi (belum terhubung payment gateway) — kalau nanti butuh pembayaran sungguhan, perlu integrasi seperti Midtrans/Xendit.
- Kolom `content` di tabel `programs` sengaja dipisah dari `programs_preview` (view publik) supaya isi lengkap program benar-benar hanya bisa diakses lewat query ke tabel `programs`, yang dibatasi RLS untuk user yang login saja.
