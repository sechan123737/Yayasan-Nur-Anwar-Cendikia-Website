-- ============================================================
-- Schema untuk Yayasan Nur Anwar Cendikia
-- Jalankan file ini di Supabase Dashboard -> SQL Editor
-- ============================================================

-- 1. Tabel profiles: data tambahan member (nama, no hp, role)
-- id sama dengan auth.users.id (relasi 1-1 dengan akun auth)
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text,
  phone text,
  role text not null default 'member' check (role in ('member', 'admin')),
  created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;

-- Member boleh baca profil sendiri
create policy "profiles: user bisa baca profil sendiri"
  on public.profiles for select
  using (auth.uid() = id);

-- Member boleh update profil sendiri (tidak termasuk kolom role)
create policy "profiles: user bisa update profil sendiri"
  on public.profiles for update
  using (auth.uid() = id);

-- Insert profil dilakukan oleh user yang baru daftar (id harus sama dengan auth.uid())
create policy "profiles: user bisa insert profil sendiri"
  on public.profiles for insert
  with check (auth.uid() = id);


-- 2. Trigger: otomatis buat baris di profiles saat ada user baru daftar
-- (jaring pengaman selain upsert yang dilakukan dari sisi aplikasi)
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, full_name, phone, role)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'full_name', ''),
    coalesce(new.raw_user_meta_data->>'phone', ''),
    'member'
  )
  on conflict (id) do nothing;
  return new;
end;
$$ language plpgsql security definer;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();


-- 3. Tabel programs: program/artikel yayasan
create table if not exists public.programs (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  slug text not null unique,
  category text,
  summary text not null,
  content text not null,
  image_url text,
  created_by uuid references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.programs enable row level security;

-- Hanya member yang login (siapa saja yang sudah auth) yang boleh baca isi lengkap
create policy "programs: member login bisa baca semua kolom"
  on public.programs for select
  using (auth.role() = 'authenticated');

-- Hanya admin yang boleh tambah/ubah/hapus program
create policy "programs: hanya admin bisa insert"
  on public.programs for insert
  with check (
    exists (select 1 from public.profiles where id = auth.uid() and role = 'admin')
  );

create policy "programs: hanya admin bisa update"
  on public.programs for update
  using (
    exists (select 1 from public.profiles where id = auth.uid() and role = 'admin')
  );

create policy "programs: hanya admin bisa delete"
  on public.programs for delete
  using (
    exists (select 1 from public.profiles where id = auth.uid() and role = 'admin')
  );


-- 4. View publik: ringkasan program TANPA kolom 'content' lengkap,
-- supaya halaman utama (belum login) tetap bisa menampilkan daftar program,
-- tapi detail lengkapnya hanya lewat tabel 'programs' yang RLS-nya
-- mengharuskan login.
create or replace view public.programs_preview as
  select id, title, slug, category, summary, image_url, created_at
  from public.programs;

-- Izinkan siapa saja (termasuk pengunjung belum login / role anon) membaca view ini
grant select on public.programs_preview to anon, authenticated;


-- ============================================================
-- CARA MENJADIKAN SEORANG USER SEBAGAI ADMIN:
-- 1. Daftar akun seperti biasa lewat halaman /daftar di website.
-- 2. Jalankan query berikut di SQL Editor (ganti email-nya):
--
--    update public.profiles
--    set role = 'admin'
--    where id = (select id from auth.users where email = 'admin@contoh.com');
--
-- ============================================================


-- ============================================================
-- CONTOH DATA AWAL (opsional, sesuai program di desain awal)
-- Jalankan setelah kamu punya minimal 1 admin, atau jalankan
-- sebagai service role / lewat SQL editor (RLS tidak berlaku di SQL editor).
-- ============================================================
insert into public.programs (title, slug, category, summary, content, image_url)
values
  (
    'Program Beasiswa',
    'program-beasiswa',
    'Pendidikan',
    'Beasiswa akademis penuh untuk siswa yang kurang mampu dari tingkat sekolah dasar hingga universitas.',
    'Program Beasiswa Yayasan Nur Anwar Cendikia memberikan dukungan pendidikan penuh mulai dari biaya sekolah, buku, hingga seragam bagi siswa berprestasi dari keluarga kurang mampu. Sejak diluncurkan, program ini telah membantu ribuan siswa menyelesaikan pendidikan mereka tanpa terbebani biaya.',
    null
  ),
  (
    'Pusat Komunitas',
    'pusat-komunitas',
    'Fasilitas',
    'Membangun pusat pembelajaran yang dilengkapi dengan perpustakaan, lab komputer, dan layanan bimbingan belajar.',
    'Pusat Komunitas menjadi ruang belajar bersama bagi anak-anak dan remaja di berbagai daerah. Setiap pusat dilengkapi perpustakaan, laboratorium komputer sederhana, dan tenaga pendamping belajar yang siap membantu siswa di luar jam sekolah.',
    null
  ),
  (
    'Pelatihan Guru',
    'pelatihan-guru',
    'Pengembangan SDM',
    'Lokakarya pengembangan profesional yang memberdayakan pendidik lokal dengan metodologi pengajaran modern.',
    'Program Pelatihan Guru dirancang untuk meningkatkan kualitas pengajaran di daerah dengan akses terbatas terhadap pelatihan formal. Melalui lokakarya rutin, guru-guru lokal dibekali metode pengajaran modern, manajemen kelas, dan pemanfaatan teknologi sederhana dalam pembelajaran.',
    null
  ),
  (
    'Literasi Digital',
    'literasi-digital',
    'Teknologi',
    'Mengatasi kesenjangan digital dengan menyediakan akses teknologi dan pendidikan coding di daerah terpencil.',
    'Program Literasi Digital membawa perangkat komputer dan koneksi internet ke sekolah-sekolah di daerah terpencil, disertai kurikulum dasar coding dan literasi digital agar siswa siap menghadapi dunia kerja masa depan.',
    null
  )
on conflict (slug) do nothing;
