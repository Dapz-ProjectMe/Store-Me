-- DAPZ DIGITAL v2.0.3
-- Guest checkout: customers do not need Supabase Auth accounts.
-- Apply after 001_initial_schema.sql.

create table if not exists public.guest_orders (
  id uuid primary key default gen_random_uuid(),
  order_code text not null unique,
  service_id uuid not null references public.services(id) on delete restrict,
  service_name_snapshot text not null,
  unit_price_idr bigint not null check (unit_price_idr >= 0),
  total_amount_idr bigint not null check (total_amount_idr >= 0),
  customer_name text not null,
  customer_whatsapp text not null,
  customer_note text not null default '',
  payment_method public.payment_method not null default 'cash',
  payment_status public.payment_status not null default 'unpaid',
  status public.order_status not null default 'pending',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint guest_orders_name_length check (char_length(customer_name) between 1 and 100),
  constraint guest_orders_whatsapp_length check (char_length(customer_whatsapp) between 6 and 25),
  constraint guest_orders_note_length check (char_length(customer_note) <= 1000)
);

create index if not exists guest_orders_status_created_idx
  on public.guest_orders (status, created_at desc);
create index if not exists guest_orders_created_idx
  on public.guest_orders (created_at desc);

create or replace function public.prepare_guest_order()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  selected_service public.services%rowtype;
begin
  select * into selected_service
  from public.services
  where id = new.service_id and is_active = true;

  if not found then
    raise exception 'Service is unavailable';
  end if;

  if new.payment_method <> 'cash' then
    raise exception 'QRIS checkout is not enabled yet';
  end if;

  if char_length(trim(coalesce(new.customer_name, ''))) = 0 then
    raise exception 'Customer name is required';
  end if;

  if char_length(regexp_replace(coalesce(new.customer_whatsapp, ''), '[^0-9]', '', 'g')) < 9 then
    raise exception 'A valid WhatsApp number is required';
  end if;

  new.order_code := 'DPZ-' || to_char(now(), 'YYMMDD') || '-' ||
    upper(encode(gen_random_bytes(8), 'hex'));
  new.service_name_snapshot := selected_service.name;
  new.unit_price_idr := selected_service.price_idr;
  new.total_amount_idr := selected_service.price_idr;
  new.payment_status := 'unpaid';
  new.status := 'pending';
  new.created_at := now();
  new.updated_at := now();
  new.customer_name := trim(new.customer_name);
  new.customer_whatsapp := regexp_replace(trim(new.customer_whatsapp), '[^0-9+]', '', 'g');
  new.customer_note := left(trim(coalesce(new.customer_note, '')), 1000);
  return new;
end;
$$;

drop trigger if exists guest_orders_prepare_before_insert on public.guest_orders;
create trigger guest_orders_prepare_before_insert
before insert on public.guest_orders
for each row execute procedure public.prepare_guest_order();

drop trigger if exists guest_orders_set_updated_at on public.guest_orders;
create trigger guest_orders_set_updated_at
before update on public.guest_orders
for each row execute procedure public.set_updated_at();

alter table public.guest_orders enable row level security;

drop policy if exists "guest_orders_admin_read" on public.guest_orders;
create policy "guest_orders_admin_read" on public.guest_orders
for select to authenticated
using (public.is_admin());

drop policy if exists "guest_orders_admin_update" on public.guest_orders;
create policy "guest_orders_admin_update" on public.guest_orders
for update to authenticated
using (public.is_admin())
with check (public.is_admin());

grant select on public.guest_orders to authenticated;
grant update (status, payment_status) on public.guest_orders to authenticated;
revoke all on public.guest_orders from anon;
revoke insert, delete on public.guest_orders from authenticated;

comment on table public.guest_orders is
  'Guest orders without customer accounts. Creation and public tracking are handled by trusted Edge Functions; admin access is protected by RLS.';
