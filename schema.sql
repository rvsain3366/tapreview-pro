-- TAPREVIEW PRO database schema for Supabase PostgreSQL
-- Run this entire file in Supabase Dashboard > SQL Editor as project owner.
create extension if not exists pgcrypto;

create table if not exists public.admin_users (
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);

create or replace function public.is_admin()
returns boolean language sql stable security definer set search_path = public
as $$ select exists (select 1 from public.admin_users where user_id = auth.uid()); $$;
revoke all on function public.is_admin() from public;
grant execute on function public.is_admin() to authenticated;

create table if not exists public.shops (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  slug text not null unique,
  owner_name text not null default '',
  mobile text not null default '',
  logo_url text not null default '',
  address text not null default '',
  google_review_url text not null default '',
  whatsapp_url text not null default '',
  instagram_url text not null default '',
  facebook_url text not null default '',
  youtube_url text not null default '',
  website_url text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint shops_slug_format check (slug ~ '^[a-z0-9]+(-[a-z0-9]+)*$')
);
create index if not exists shops_created_at_idx on public.shops(created_at desc);
create index if not exists shops_name_idx on public.shops using gin (to_tsvector('simple', name));

create table if not exists public.shop_links (
  id uuid primary key default gen_random_uuid(),
  shop_id uuid not null references public.shops(id) on delete cascade,
  title text not null,
  url text not null,
  icon text not null default '🔗',
  sort_order integer not null default 0,
  created_at timestamptz not null default now()
);
create index if not exists shop_links_shop_order_idx on public.shop_links(shop_id, sort_order);

create table if not exists public.customers (
  id uuid primary key default gen_random_uuid(),
  shop_id uuid references public.shops(id) on delete set null,
  name text not null,
  mobile text not null default '',
  notes text not null default '',
  created_at timestamptz not null default now()
);
create index if not exists customers_created_at_idx on public.customers(created_at desc);

create or replace function public.set_updated_at()
returns trigger language plpgsql as $$ begin new.updated_at = now(); return new; end; $$;
drop trigger if exists shops_updated_at on public.shops;
create trigger shops_updated_at before update on public.shops for each row execute function public.set_updated_at();

alter table public.admin_users enable row level security;
alter table public.shops enable row level security;
alter table public.shop_links enable row level security;
alter table public.customers enable row level security;

-- Public visitors can read only the public shop profile and public links.
-- Admins can manage shops and links after being allow-listed in admin_users.
drop policy if exists "public can read shops" on public.shops;
create policy "public can read shops" on public.shops for select to anon, authenticated using (true);
drop policy if exists "admins insert shops" on public.shops;
create policy "admins insert shops" on public.shops for insert to authenticated with check (public.is_admin());
drop policy if exists "admins update shops" on public.shops;
create policy "admins update shops" on public.shops for update to authenticated using (public.is_admin()) with check (public.is_admin());
drop policy if exists "admins delete shops" on public.shops;
create policy "admins delete shops" on public.shops for delete to authenticated using (public.is_admin());

drop policy if exists "public can read shop links" on public.shop_links;
create policy "public can read shop links" on public.shop_links for select to anon, authenticated using (true);
drop policy if exists "admins insert shop links" on public.shop_links;
create policy "admins insert shop links" on public.shop_links for insert to authenticated with check (public.is_admin());
drop policy if exists "admins update shop links" on public.shop_links;
create policy "admins update shop links" on public.shop_links for update to authenticated using (public.is_admin()) with check (public.is_admin());
drop policy if exists "admins delete shop links" on public.shop_links;
create policy "admins delete shop links" on public.shop_links for delete to authenticated using (public.is_admin());

-- Customer records are private to allow-listed admins only.
drop policy if exists "admins manage customers" on public.customers;
create policy "admins manage customers" on public.customers for all to authenticated using (public.is_admin()) with check (public.is_admin());

-- Admin allow-list is not publicly readable or writable. Add admins from SQL Editor.
drop policy if exists "admins read own allowlist row" on public.admin_users;
create policy "admins read own allowlist row" on public.admin_users for select to authenticated using (user_id = auth.uid());


-- Column-level grants prevent anonymous visitors from reading owner names or phone numbers.
revoke select on public.shops from anon;
grant select (id, name, slug, logo_url, address, google_review_url, whatsapp_url, instagram_url, facebook_url, youtube_url, website_url, created_at, updated_at) on public.shops to anon;
grant select on public.shops to authenticated;
grant select on public.shop_links to anon, authenticated;
grant select, insert, update, delete on public.shops, public.shop_links, public.customers to authenticated;

-- Optional public logo bucket. Upload logos through Supabase Storage after adding policies.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('shop-logos','shop-logos',true,2097152,array['image/png','image/jpeg','image/webp','image/svg+xml'])
on conflict (id) do nothing;
drop policy if exists "public can view shop logos" on storage.objects;
create policy "public can view shop logos" on storage.objects for select to anon, authenticated using (bucket_id = 'shop-logos');
drop policy if exists "admins upload shop logos" on storage.objects;
create policy "admins upload shop logos" on storage.objects for insert to authenticated with check (bucket_id = 'shop-logos' and public.is_admin());
drop policy if exists "admins update shop logos" on storage.objects;
create policy "admins update shop logos" on storage.objects for update to authenticated using (bucket_id = 'shop-logos' and public.is_admin()) with check (bucket_id = 'shop-logos' and public.is_admin());
drop policy if exists "admins delete shop logos" on storage.objects;
create policy "admins delete shop logos" on storage.objects for delete to authenticated using (bucket_id = 'shop-logos' and public.is_admin());

-- After creating the admin user in Authentication > Users, run this once with that user's UUID:
-- insert into public.admin_users (user_id) values ('PASTE-AUTH-USER-UUID-HERE');
