-- Creates the reviews table used by the client/worker rating screens.
-- Run this in Supabase SQL Editor if the app shows:
-- PGRST205: Could not find the table 'public.resenas' in the schema cache.

create extension if not exists pgcrypto;

create table if not exists public.resenas (
  id uuid primary key default gen_random_uuid(),
  solicitud_id uuid not null references public.solicitudes_servicio(id) on delete cascade,
  cliente_id uuid not null references auth.users(id) on delete cascade,
  trabajador_id uuid not null references auth.users(id) on delete cascade,
  emisor_id uuid not null references auth.users(id) on delete cascade,
  tipo text not null default 'cliente_a_trabajador',
  calificacion numeric(2,1) not null check (calificacion >= 1 and calificacion <= 5),
  comentario text,
  preguntas_rapidas text[],
  fecha_creacion timestamptz not null default now()
);

alter table public.resenas
  add column if not exists solicitud_id uuid,
  add column if not exists cliente_id uuid,
  add column if not exists trabajador_id uuid,
  add column if not exists emisor_id uuid,
  add column if not exists tipo text not null default 'cliente_a_trabajador',
  add column if not exists calificacion numeric(2,1),
  add column if not exists comentario text,
  add column if not exists preguntas_rapidas text[],
  add column if not exists fecha_creacion timestamptz not null default now();

create unique index if not exists resenas_solicitud_emisor_tipo_unique_idx
  on public.resenas(solicitud_id, emisor_id, tipo);
create index if not exists resenas_trabajador_idx on public.resenas(trabajador_id);
create index if not exists resenas_cliente_idx on public.resenas(cliente_id);

alter table public.resenas enable row level security;

drop policy if exists resenas_select_authenticated on public.resenas;
create policy resenas_select_authenticated
  on public.resenas for select
  to authenticated
  using (true);

drop policy if exists resenas_insert_emisor on public.resenas;
create policy resenas_insert_emisor
  on public.resenas for insert
  to authenticated
  with check (emisor_id = auth.uid());

grant select, insert on public.resenas to authenticated;

notify pgrst, 'reload schema';
