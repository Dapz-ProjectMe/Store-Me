-- DAPZ DIGITAL v2.0
-- Initial Supabase/PostgreSQL schema.
-- Apply through Supabase SQL Editor or Supabase CLI after creating a project.
-- IMPORTANT: sample catalogue rows are inactive until the owner approves their prices.

create extension if not exists pgcrypto;

-- -----------------------------------------------------------------------------
-- ENUMS
-- -----------------------------------------------------------------------------
do $$ begin
  create type public.user_role as enum ('customer', 'admin');
exception when duplicate_object then null; end $$;

do $$ begin
  create type public.order_status as enum ('pending', 'confirmed', 'in_progress', 'completed', 'cancelled');
exception when duplicate_object then null; end $$;

do $$ begin
  create type public.payment_status as enum ('unpaid', 'waiting', 'paid', 'failed', 'refunded');
exception when duplicate_object then null; end $$;

do $$ begin
  create type public.payment_method as enum ('cash', 'qris');
exception when duplicate_object then null; end $$;

-- -----------------------------------------------------------------------------
-- COMMON FUNCTIONS
-- -----------------------------------------------------------------------------
create or replace function public.set_updated_at()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

-- SECURITY DEFINER avoids recursive RLS when checking the caller's role.
create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.profiles p
    where p.id = (select auth.uid())
      and p.role = 'admin'::public.user_role
  );
$$;

revoke all on function public.is_admin() from public;
grant execute on function public.is_admin() to anon, authenticated;

-- -----------------------------------------------------------------------------
-- PROFILES
-- -----------------------------------------------------------------------------
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null default '',
  whatsapp text not null default '',
  role public.user_role not null default 'customer',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint profiles_full_name_length check (char_length(full_name) <= 100),
  constraint profiles_whatsapp_length check (char_length(whatsapp) <= 25)
);

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, full_name)
  values (
    new.id,
    coalesce(left(new.raw_user_meta_data ->> 'full_name', 100), '')
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

 drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute procedure public.handle_new_user();

 drop trigger if exists profiles_set_updated_at on public.profiles;
create trigger profiles_set_updated_at
before update on public.profiles
for each row execute procedure public.set_updated_at();

-- -----------------------------------------------------------------------------
-- SERVICES
-- -----------------------------------------------------------------------------
create table if not exists public.services (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique,
  name text not null,
  category text not null,
  short_description text not null default '',
  description text not null default '',
  price_idr bigint not null check (price_idr >= 0),
  duration text not null default '',
  is_active boolean not null default false,
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint services_slug_format check (slug ~ '^[a-z0-9-]+$'),
  constraint services_name_length check (char_length(name) between 1 and 120)
);

 drop trigger if exists services_set_updated_at on public.services;
create trigger services_set_updated_at
before update on public.services
for each row execute procedure public.set_updated_at();

-- These are draft/example prices copied from the v2.0 frontend catalogue.
-- is_active=false prevents public display and order creation until owner approval.
insert into public.services (slug, name, category, short_description, description, price_idr, duration, is_active, sort_order)
values
  ('web-portfolio', 'Website Portofolio', 'Website', 'Website personal untuk menampilkan profil, kemampuan, dan karya.', 'Website portofolio sederhana dengan tampilan responsif untuk memperkenalkan profil dan hasil karyamu.', 50000, '3–5 hari kerja', false, 10),
  ('web-business', 'Website Profil Usaha', 'Website', 'Halaman informasi untuk memperkenalkan usaha atau layanan.', 'Website profil usaha untuk menampilkan informasi bisnis, layanan, lokasi, dan kontak pelanggan.', 75000, '4–7 hari kerja', false, 20),
  ('poster', 'Desain Poster', 'Desain', 'Desain poster digital untuk promosi, acara, atau informasi.', 'Desain poster digital sesuai tujuan dan informasi yang diberikan pelanggan.', 10000, '1–2 hari kerja', false, 30),
  ('presentation', 'Presentasi', 'Dokumen', 'Merapikan materi menjadi presentasi yang terstruktur.', 'Bantuan menyusun dan merapikan presentasi berdasarkan materi yang disediakan pelanggan.', 15000, 'Berdasarkan jumlah slide', false, 40),
  ('document', 'Format Dokumen', 'Dokumen', 'Merapikan tata letak dokumen agar lebih konsisten.', 'Perapian format dokumen seperti proposal, laporan, atau tugas berdasarkan materi pelanggan.', 10000, '1–3 hari kerja', false, 50)
on conflict (slug) do nothing;

-- -----------------------------------------------------------------------------
-- ORDERS
-- -----------------------------------------------------------------------------
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_code text not null unique,
  customer_id uuid not null references public.profiles(id) on delete restrict,
  service_id uuid not null references public.services(id) on delete restrict,
  service_name_snapshot text not null,
  unit_price_idr bigint not null check (unit_price_idr >= 0),
  quantity integer not null default 1 check (quantity between 1 and 20),
  total_amount_idr bigint not null check (total_amount_idr >= 0),
  customer_name text not null,
  customer_whatsapp text not null,
  customer_note text not null default '',
  payment_method public.payment_method not null default 'cash',
  payment_status public.payment_status not null default 'unpaid',
  status public.order_status not null default 'pending',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint orders_customer_name_length check (char_length(customer_name) between 1 and 100),
  constraint orders_whatsapp_length check (char_length(customer_whatsapp) between 6 and 25),
  constraint orders_note_length check (char_length(customer_note) <= 2000)
);

create index if not exists orders_customer_created_idx on public.orders (customer_id, created_at desc);
create index if not exists orders_status_created_idx on public.orders (status, created_at desc);

-- Never trust a price, total, owner, order status, or payment status from the browser.
create or replace function public.prepare_customer_order()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  selected_service public.services%rowtype;
begin
  if auth.uid() is null then
    raise exception 'Authentication required';
  end if;

  if new.customer_id is not null and new.customer_id <> auth.uid() then
    raise exception 'Invalid customer';
  end if;

  select * into selected_service
  from public.services
  where id = new.service_id and is_active = true;

  if not found then
    raise exception 'Service is unavailable';
  end if;

  new.customer_id := auth.uid();
  new.order_code := 'DAPZ-' || to_char(now(), 'YYMMDD') || '-' || upper(substr(encode(gen_random_bytes(4), 'hex'), 1, 8));
  new.service_name_snapshot := selected_service.name;
  new.unit_price_idr := selected_service.price_idr;
  new.quantity := greatest(1, least(coalesce(new.quantity, 1), 20));
  new.total_amount_idr := selected_service.price_idr * new.quantity;
  new.payment_status := 'unpaid';
  new.status := 'pending';
  new.payment_method := coalesce(new.payment_method, 'cash'::public.payment_method);
  new.created_at := now();
  new.updated_at := now();

  if char_length(trim(coalesce(new.customer_name, ''))) = 0 then
    raise exception 'Customer name is required';
  end if;
  if char_length(trim(coalesce(new.customer_whatsapp, ''))) < 6 then
    raise exception 'A valid WhatsApp number is required';
  end if;

  new.customer_name := trim(new.customer_name);
  new.customer_whatsapp := trim(new.customer_whatsapp);
  new.customer_note := left(trim(coalesce(new.customer_note, '')), 2000);
  return new;
end;
$$;

 drop trigger if exists orders_prepare_before_insert on public.orders;
create trigger orders_prepare_before_insert
before insert on public.orders
for each row execute procedure public.prepare_customer_order();

 drop trigger if exists orders_set_updated_at on public.orders;
create trigger orders_set_updated_at
before update on public.orders
for each row execute procedure public.set_updated_at();

-- -----------------------------------------------------------------------------
-- PAYMENTS
-- Payment rows are written only by a trusted backend/webhook using service_role.
-- The browser must never write payment success or provider reference data.
-- -----------------------------------------------------------------------------
create table if not exists public.payments (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders(id) on delete restrict,
  provider text not null,
  provider_reference text unique,
  amount_idr bigint not null check (amount_idr >= 0),
  status public.payment_status not null default 'waiting',
  paid_at timestamptz,
  raw_event jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists payments_order_created_idx on public.payments (order_id, created_at desc);

 drop trigger if exists payments_set_updated_at on public.payments;
create trigger payments_set_updated_at
before update on public.payments
for each row execute procedure public.set_updated_at();

-- -----------------------------------------------------------------------------
-- ROW LEVEL SECURITY
-- -----------------------------------------------------------------------------
alter table public.profiles enable row level security;
alter table public.services enable row level security;
alter table public.orders enable row level security;
alter table public.payments enable row level security;

-- Profiles: users can read/update their own profile; admins can manage all.
drop policy if exists "profiles_read_own_or_admin" on public.profiles;
create policy "profiles_read_own_or_admin" on public.profiles
for select to authenticated
using (id = (select auth.uid()) or public.is_admin());

drop policy if exists "profiles_update_own_or_admin" on public.profiles;
create policy "profiles_update_own_or_admin" on public.profiles
for update to authenticated
using (id = (select auth.uid()) or public.is_admin())
with check (id = (select auth.uid()) or public.is_admin());

-- Prevent customers from changing their own role.
revoke update on public.profiles from authenticated;
grant update (full_name, whatsapp) on public.profiles to authenticated;
grant select on public.profiles to authenticated;

-- Services: visitors see only active catalogue entries; admins manage all rows.
drop policy if exists "services_read_active_or_admin" on public.services;
create policy "services_read_active_or_admin" on public.services
for select to anon, authenticated
using (is_active = true or public.is_admin());

drop policy if exists "services_admin_manage" on public.services;
create policy "services_admin_manage" on public.services
for all to authenticated
using (public.is_admin())
with check (public.is_admin());

grant select on public.services to anon, authenticated;
grant insert, update, delete on public.services to authenticated;

-- Orders: customers create orders for themselves and read only their own orders.
drop policy if exists "orders_read_own_or_admin" on public.orders;
create policy "orders_read_own_or_admin" on public.orders
for select to authenticated
using (customer_id = (select auth.uid()) or public.is_admin());

drop policy if exists "orders_create_own" on public.orders;
create policy "orders_create_own" on public.orders
for insert to authenticated
with check (customer_id = (select auth.uid()));

drop policy if exists "orders_admin_manage" on public.orders;
create policy "orders_admin_manage" on public.orders
for all to authenticated
using (public.is_admin())
with check (public.is_admin());

grant select, insert on public.orders to authenticated;
grant update (status, payment_status, payment_method) on public.orders to authenticated;

-- Payments: no direct client writes or reads. Admins may inspect payment records.
drop policy if exists "payments_admin_read" on public.payments;
create policy "payments_admin_read" on public.payments
for select to authenticated
using (public.is_admin());

grant select on public.payments to authenticated;
revoke insert, update, delete on public.payments from anon, authenticated;

-- Ensure the default API roles have only the intended table access.
grant usage on schema public to anon, authenticated;

comment on table public.profiles is 'Customer profiles; role is assigned by trusted admin only.';
comment on table public.services is 'Owner-managed service catalogue. Draft seed rows are inactive.';
comment on table public.orders is 'Customer orders; server trigger snapshots trusted service price.';
comment on table public.payments is 'Trusted payment-provider records; clients cannot write payment state.';
