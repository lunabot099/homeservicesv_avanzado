-- HomeServiceSV - schema repair for the Flutter app.
-- Run this in Supabase SQL Editor for the same project used in .env.
-- It is intentionally idempotent: it creates missing objects and adds missing columns.

begin;

create extension if not exists pgcrypto;

create or replace function public.set_fecha_actualizacion()
returns trigger
language plpgsql
as $$
begin
  new.fecha_actualizacion = now();
  return new;
end;
$$;

-- perfiles
create table if not exists public.perfiles (
  id uuid primary key references auth.users(id) on delete cascade,
  fecha_creacion timestamptz not null default now(),
  fecha_actualizacion timestamptz not null default now()
);

alter table public.perfiles
  add column if not exists nombre text not null default '',
  add column if not exists nombre_completo text not null default '',
  add column if not exists correo text not null default '',
  add column if not exists telefono text,
  add column if not exists rol text not null default 'cliente',
  add column if not exists foto_perfil_url text,
  add column if not exists promedio_calificacion numeric(3,2) not null default 0,
  add column if not exists cantidad_resenas integer not null default 0,
  add column if not exists activo boolean not null default true,
  add column if not exists fecha_creacion timestamptz not null default now(),
  add column if not exists fecha_actualizacion timestamptz not null default now();

create index if not exists perfiles_correo_idx on public.perfiles(correo);
create index if not exists perfiles_rol_idx on public.perfiles(rol);

drop trigger if exists perfiles_set_fecha_actualizacion on public.perfiles;
create trigger perfiles_set_fecha_actualizacion
before update on public.perfiles
for each row execute function public.set_fecha_actualizacion();

-- worker_profiles
create table if not exists public.worker_profiles (
  id uuid primary key references public.perfiles(id) on delete cascade,
  dui text,
  estado_verificacion text not null default 'pendiente',
  experiencia text,
  tarifa numeric(10,2),
  disponibilidad boolean not null default false,
  descripcion text,
  verificado boolean not null default false,
  especialidades text[] not null default '{}',
  latitud double precision,
  longitud double precision,
  radio_km integer not null default 6,
  oficio_principal text,
  zona_cobertura text,
  fecha_creacion timestamptz not null default now(),
  fecha_actualizacion timestamptz not null default now()
);

alter table public.worker_profiles
  add column if not exists dui text,
  add column if not exists estado_verificacion text not null default 'pendiente',
  add column if not exists experiencia text,
  add column if not exists tarifa numeric(10,2),
  add column if not exists disponibilidad boolean not null default false,
  add column if not exists descripcion text,
  add column if not exists verificado boolean not null default false,
  add column if not exists especialidades text[] not null default '{}',
  add column if not exists latitud double precision,
  add column if not exists longitud double precision,
  add column if not exists radio_km integer not null default 6,
  add column if not exists oficio_principal text,
  add column if not exists zona_cobertura text,
  add column if not exists fecha_creacion timestamptz not null default now(),
  add column if not exists fecha_actualizacion timestamptz not null default now();

create index if not exists worker_profiles_verificado_idx on public.worker_profiles(verificado);
create index if not exists worker_profiles_disponibilidad_idx on public.worker_profiles(disponibilidad);

drop trigger if exists worker_profiles_set_fecha_actualizacion on public.worker_profiles;
create trigger worker_profiles_set_fecha_actualizacion
before update on public.worker_profiles
for each row execute function public.set_fecha_actualizacion();

-- formulario_trabajador
create table if not exists public.formulario_trabajador (
  id uuid primary key default gen_random_uuid(),
  nombre_completo text not null default '',
  correo text not null,
  celular text not null default '',
  dui text not null,
  direccion text,
  foto_perfil_url text,
  foto_dui_url text,
  antecedentes_penales_url text,
  antecedentes_policiales_url text,
  estado text not null default 'pendiente',
  notas_admin text,
  fecha_creacion timestamptz not null default now(),
  fecha_actualizacion timestamptz not null default now()
);

alter table public.formulario_trabajador
  add column if not exists nombre_completo text not null default '',
  add column if not exists correo text not null default '',
  add column if not exists celular text not null default '',
  add column if not exists dui text not null default '',
  add column if not exists direccion text,
  add column if not exists foto_perfil_url text,
  add column if not exists foto_dui_url text,
  add column if not exists antecedentes_penales_url text,
  add column if not exists antecedentes_policiales_url text,
  add column if not exists estado text not null default 'pendiente',
  add column if not exists notas_admin text,
  add column if not exists fecha_creacion timestamptz not null default now(),
  add column if not exists fecha_actualizacion timestamptz not null default now();

create index if not exists formulario_trabajador_correo_idx on public.formulario_trabajador(correo);

drop trigger if exists formulario_trabajador_set_fecha_actualizacion on public.formulario_trabajador;
create trigger formulario_trabajador_set_fecha_actualizacion
before update on public.formulario_trabajador
for each row execute function public.set_fecha_actualizacion();

-- solicitudes_servicio
create table if not exists public.solicitudes_servicio (
  id uuid primary key default gen_random_uuid(),
  cliente_id uuid not null references auth.users(id) on delete cascade,
  trabajador_seleccionado_id uuid references auth.users(id) on delete set null,
  categoria text not null,
  subcategoria text,
  descripcion text not null default '',
  imagenes_urls text[] not null default '{}',
  urgencia text not null default 'flexible',
  tipo_pago text not null default 'a_convenir',
  presupuesto_estimado numeric(10,2),
  horario_preferido text,
  departamento text,
  municipio text,
  colonia text,
  calle text,
  casa text,
  punto_referencia text,
  latitud double precision,
  longitud double precision,
  estado text not null default 'en_busqueda',
  monto_acordado numeric(10,2),
  fecha_servicio timestamptz,
  fecha_creacion timestamptz not null default now(),
  fecha_actualizacion timestamptz not null default now()
);

alter table public.solicitudes_servicio
  add column if not exists cliente_id uuid,
  add column if not exists trabajador_seleccionado_id uuid,
  add column if not exists categoria text,
  add column if not exists subcategoria text,
  add column if not exists descripcion text not null default '',
  add column if not exists imagenes_urls text[] not null default '{}',
  add column if not exists urgencia text not null default 'flexible',
  add column if not exists tipo_pago text not null default 'a_convenir',
  add column if not exists presupuesto_estimado numeric(10,2),
  add column if not exists horario_preferido text,
  add column if not exists departamento text,
  add column if not exists municipio text,
  add column if not exists colonia text,
  add column if not exists calle text,
  add column if not exists casa text,
  add column if not exists punto_referencia text,
  add column if not exists latitud double precision,
  add column if not exists longitud double precision,
  add column if not exists estado text not null default 'en_busqueda',
  add column if not exists monto_acordado numeric(10,2),
  add column if not exists fecha_servicio timestamptz,
  add column if not exists fecha_creacion timestamptz not null default now(),
  add column if not exists fecha_actualizacion timestamptz not null default now();

create index if not exists solicitudes_servicio_cliente_idx on public.solicitudes_servicio(cliente_id);
create index if not exists solicitudes_servicio_trabajador_idx on public.solicitudes_servicio(trabajador_seleccionado_id);
create index if not exists solicitudes_servicio_estado_idx on public.solicitudes_servicio(estado);

drop trigger if exists solicitudes_servicio_set_fecha_actualizacion on public.solicitudes_servicio;
create trigger solicitudes_servicio_set_fecha_actualizacion
before update on public.solicitudes_servicio
for each row execute function public.set_fecha_actualizacion();

-- postulaciones_solicitud
create table if not exists public.postulaciones_solicitud (
  id uuid primary key default gen_random_uuid(),
  solicitud_id uuid not null references public.solicitudes_servicio(id) on delete cascade,
  trabajador_id uuid not null references auth.users(id) on delete cascade,
  precio_estimado numeric(10,2),
  mensaje_inicial text,
  estado text not null default 'pendiente',
  fecha_creacion timestamptz not null default now(),
  fecha_actualizacion timestamptz not null default now()
);

alter table public.postulaciones_solicitud
  add column if not exists solicitud_id uuid,
  add column if not exists trabajador_id uuid,
  add column if not exists precio_estimado numeric(10,2),
  add column if not exists mensaje_inicial text,
  add column if not exists estado text not null default 'pendiente',
  add column if not exists fecha_creacion timestamptz not null default now(),
  add column if not exists fecha_actualizacion timestamptz not null default now();

create unique index if not exists postulaciones_solicitud_unique_idx on public.postulaciones_solicitud(solicitud_id, trabajador_id);
create index if not exists postulaciones_solicitud_solicitud_idx on public.postulaciones_solicitud(solicitud_id);
create index if not exists postulaciones_solicitud_trabajador_idx on public.postulaciones_solicitud(trabajador_id);

drop trigger if exists postulaciones_solicitud_set_fecha_actualizacion on public.postulaciones_solicitud;
create trigger postulaciones_solicitud_set_fecha_actualizacion
before update on public.postulaciones_solicitud
for each row execute function public.set_fecha_actualizacion();

-- chats and mensajes_chat
create table if not exists public.chats (
  id uuid primary key default gen_random_uuid(),
  solicitud_id uuid not null references public.solicitudes_servicio(id) on delete cascade,
  cliente_id uuid not null references auth.users(id) on delete cascade,
  trabajador_id uuid not null references auth.users(id) on delete cascade,
  creado_en timestamptz not null default now(),
  eliminar_mensajes_en timestamptz
);

alter table public.chats
  add column if not exists solicitud_id uuid,
  add column if not exists cliente_id uuid,
  add column if not exists trabajador_id uuid,
  add column if not exists creado_en timestamptz not null default now(),
  add column if not exists eliminar_mensajes_en timestamptz;

create unique index if not exists chats_solicitud_unique_idx on public.chats(solicitud_id);
create index if not exists chats_cliente_idx on public.chats(cliente_id);
create index if not exists chats_trabajador_idx on public.chats(trabajador_id);

create table if not exists public.mensajes_chat (
  id uuid primary key default gen_random_uuid(),
  chat_id uuid not null references public.chats(id) on delete cascade,
  emisor_id text not null,
  tipo_mensaje text not null default 'texto',
  texto text,
  archivo_url text,
  leido boolean not null default false,
  fecha_creacion timestamptz not null default now()
);

alter table public.mensajes_chat
  add column if not exists chat_id uuid,
  add column if not exists emisor_id text,
  add column if not exists tipo_mensaje text not null default 'texto',
  add column if not exists texto text,
  add column if not exists archivo_url text,
  add column if not exists leido boolean not null default false,
  add column if not exists fecha_creacion timestamptz not null default now();

create index if not exists mensajes_chat_chat_idx on public.mensajes_chat(chat_id);
create index if not exists mensajes_chat_fecha_idx on public.mensajes_chat(fecha_creacion);

-- resenas
create table if not exists public.resenas (
  id uuid primary key default gen_random_uuid(),
  solicitud_id uuid not null references public.solicitudes_servicio(id) on delete cascade,
  cliente_id uuid not null references auth.users(id) on delete cascade,
  trabajador_id uuid not null references auth.users(id) on delete cascade,
  emisor_id uuid not null references auth.users(id) on delete cascade,
  tipo text not null default 'cliente_a_trabajador',
  calificacion numeric(2,1) not null,
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

create unique index if not exists resenas_solicitud_emisor_tipo_unique_idx on public.resenas(solicitud_id, emisor_id, tipo);
create index if not exists resenas_trabajador_idx on public.resenas(trabajador_id);
create index if not exists resenas_cliente_idx on public.resenas(cliente_id);

-- RLS
alter table public.perfiles enable row level security;
alter table public.worker_profiles enable row level security;
alter table public.formulario_trabajador enable row level security;
alter table public.solicitudes_servicio enable row level security;
alter table public.postulaciones_solicitud enable row level security;
alter table public.chats enable row level security;
alter table public.mensajes_chat enable row level security;
alter table public.resenas enable row level security;

drop policy if exists perfiles_select_authenticated on public.perfiles;
create policy perfiles_select_authenticated on public.perfiles for select to authenticated using (activo = true or id = auth.uid());
drop policy if exists perfiles_insert_own on public.perfiles;
create policy perfiles_insert_own on public.perfiles for insert to authenticated with check (id = auth.uid());
drop policy if exists perfiles_update_own on public.perfiles;
create policy perfiles_update_own on public.perfiles for update to authenticated using (id = auth.uid()) with check (id = auth.uid());

drop policy if exists worker_profiles_select_authenticated on public.worker_profiles;
create policy worker_profiles_select_authenticated on public.worker_profiles for select to authenticated using (verificado = true or id = auth.uid());
drop policy if exists worker_profiles_insert_own on public.worker_profiles;
create policy worker_profiles_insert_own on public.worker_profiles for insert to authenticated with check (id = auth.uid());
drop policy if exists worker_profiles_update_own on public.worker_profiles;
create policy worker_profiles_update_own on public.worker_profiles for update to authenticated using (id = auth.uid()) with check (id = auth.uid());

drop policy if exists formulario_insert_authenticated on public.formulario_trabajador;
create policy formulario_insert_authenticated on public.formulario_trabajador for insert to authenticated with check (correo = coalesce(auth.jwt() ->> 'email', correo));
drop policy if exists formulario_select_own on public.formulario_trabajador;
create policy formulario_select_own on public.formulario_trabajador for select to authenticated using (correo = auth.jwt() ->> 'email');

drop policy if exists solicitudes_insert_own on public.solicitudes_servicio;
create policy solicitudes_insert_own on public.solicitudes_servicio for insert to authenticated with check (cliente_id = auth.uid());
drop policy if exists solicitudes_select_involved_or_available on public.solicitudes_servicio;
create policy solicitudes_select_involved_or_available on public.solicitudes_servicio for select to authenticated using (cliente_id = auth.uid() or trabajador_seleccionado_id = auth.uid() or estado in ('en_busqueda', 'postulaciones_recibidas'));
drop policy if exists solicitudes_update_involved on public.solicitudes_servicio;
create policy solicitudes_update_involved on public.solicitudes_servicio for update to authenticated using (cliente_id = auth.uid() or trabajador_seleccionado_id = auth.uid()) with check (cliente_id = auth.uid() or trabajador_seleccionado_id = auth.uid());
drop policy if exists solicitudes_delete_own on public.solicitudes_servicio;
create policy solicitudes_delete_own on public.solicitudes_servicio for delete to authenticated using (cliente_id = auth.uid());

drop policy if exists postulaciones_select_involved on public.postulaciones_solicitud;
create policy postulaciones_select_involved on public.postulaciones_solicitud for select to authenticated using (trabajador_id = auth.uid() or exists (select 1 from public.solicitudes_servicio s where s.id = solicitud_id and s.cliente_id = auth.uid()));
drop policy if exists postulaciones_insert_worker on public.postulaciones_solicitud;
create policy postulaciones_insert_worker on public.postulaciones_solicitud for insert to authenticated with check (trabajador_id = auth.uid());
drop policy if exists postulaciones_update_involved on public.postulaciones_solicitud;
create policy postulaciones_update_involved on public.postulaciones_solicitud for update to authenticated using (trabajador_id = auth.uid() or exists (select 1 from public.solicitudes_servicio s where s.id = solicitud_id and s.cliente_id = auth.uid())) with check (trabajador_id = auth.uid() or exists (select 1 from public.solicitudes_servicio s where s.id = solicitud_id and s.cliente_id = auth.uid()));

drop policy if exists chats_select_participants on public.chats;
create policy chats_select_participants on public.chats for select to authenticated using (cliente_id = auth.uid() or trabajador_id = auth.uid());
drop policy if exists chats_insert_participants on public.chats;
create policy chats_insert_participants on public.chats for insert to authenticated with check (cliente_id = auth.uid() or trabajador_id = auth.uid());
drop policy if exists chats_update_participants on public.chats;
create policy chats_update_participants on public.chats for update to authenticated using (cliente_id = auth.uid() or trabajador_id = auth.uid()) with check (cliente_id = auth.uid() or trabajador_id = auth.uid());

drop policy if exists mensajes_select_chat_participants on public.mensajes_chat;
create policy mensajes_select_chat_participants on public.mensajes_chat for select to authenticated using (exists (select 1 from public.chats c where c.id = chat_id and (c.cliente_id = auth.uid() or c.trabajador_id = auth.uid())));
drop policy if exists mensajes_insert_chat_participants on public.mensajes_chat;
create policy mensajes_insert_chat_participants on public.mensajes_chat for insert to authenticated with check ((emisor_id = auth.uid()::text or emisor_id = 'system') and exists (select 1 from public.chats c where c.id = chat_id and (c.cliente_id = auth.uid() or c.trabajador_id = auth.uid())));
drop policy if exists mensajes_update_chat_participants on public.mensajes_chat;
create policy mensajes_update_chat_participants on public.mensajes_chat for update to authenticated using (exists (select 1 from public.chats c where c.id = chat_id and (c.cliente_id = auth.uid() or c.trabajador_id = auth.uid()))) with check (exists (select 1 from public.chats c where c.id = chat_id and (c.cliente_id = auth.uid() or c.trabajador_id = auth.uid())));

drop policy if exists resenas_select_authenticated on public.resenas;
create policy resenas_select_authenticated on public.resenas for select to authenticated using (true);
drop policy if exists resenas_insert_emisor on public.resenas;
create policy resenas_insert_emisor on public.resenas for insert to authenticated with check (emisor_id = auth.uid());

-- Storage buckets. DUI and antecedentes are private because they are sensitive.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values
  ('perfil-fotos', 'perfil-fotos', true, 5242880, array['image/jpeg','image/png','image/webp']),
  ('dui-documentos', 'dui-documentos', false, 10485760, array['image/jpeg','image/png','image/webp','application/pdf']),
  ('antecedentes-documentos', 'antecedentes-documentos', false, 10485760, array['image/jpeg','image/png','image/webp','application/pdf']),
  ('solicitudes-imagenes', 'solicitudes-imagenes', true, 10485760, array['image/jpeg','image/png','image/webp']),
  ('chat-imagenes', 'chat-imagenes', true, 10485760, array['image/jpeg','image/png','image/webp'])
on conflict (id) do update set
  public = excluded.public,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists storage_public_read_app_public_buckets on storage.objects;
create policy storage_public_read_app_public_buckets on storage.objects for select to public using (bucket_id in ('perfil-fotos', 'solicitudes-imagenes', 'chat-imagenes'));
drop policy if exists storage_private_docs_read_own on storage.objects;
create policy storage_private_docs_read_own on storage.objects for select to authenticated using (bucket_id in ('dui-documentos', 'antecedentes-documentos') and (storage.foldername(name))[1] = auth.uid()::text);
drop policy if exists storage_upload_own_profile_and_docs on storage.objects;
create policy storage_upload_own_profile_and_docs on storage.objects for insert to authenticated with check (bucket_id in ('perfil-fotos', 'dui-documentos', 'antecedentes-documentos') and (storage.foldername(name))[1] = auth.uid()::text);
drop policy if exists storage_update_own_profile_and_docs on storage.objects;
create policy storage_update_own_profile_and_docs on storage.objects for update to authenticated using (bucket_id in ('perfil-fotos', 'dui-documentos', 'antecedentes-documentos') and (storage.foldername(name))[1] = auth.uid()::text) with check (bucket_id in ('perfil-fotos', 'dui-documentos', 'antecedentes-documentos') and (storage.foldername(name))[1] = auth.uid()::text);
drop policy if exists storage_delete_own_profile_and_docs on storage.objects;
create policy storage_delete_own_profile_and_docs on storage.objects for delete to authenticated using (bucket_id in ('perfil-fotos', 'dui-documentos', 'antecedentes-documentos') and (storage.foldername(name))[1] = auth.uid()::text);
drop policy if exists storage_upload_app_shared_images on storage.objects;
create policy storage_upload_app_shared_images on storage.objects for insert to authenticated with check (bucket_id in ('solicitudes-imagenes', 'chat-imagenes'));
drop policy if exists storage_update_app_shared_images on storage.objects;
create policy storage_update_app_shared_images on storage.objects for update to authenticated using (bucket_id in ('solicitudes-imagenes', 'chat-imagenes')) with check (bucket_id in ('solicitudes-imagenes', 'chat-imagenes'));
drop policy if exists storage_delete_app_shared_images on storage.objects;
create policy storage_delete_app_shared_images on storage.objects for delete to authenticated using (bucket_id in ('solicitudes-imagenes', 'chat-imagenes'));

notify pgrst, 'reload schema';

commit;
