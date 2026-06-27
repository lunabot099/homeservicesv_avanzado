-- Aprueba un trabajador por correo y crea/activa su worker_profile.
-- Uso: cambia el correo de la CTE input y ejecuta todo en Supabase SQL Editor.

begin;

with input as (
  select lower('ingfernandorivera2@gmail.com') as correo
), latest_form as (
  select
    f.*,
    coalesce(f.user_id, u.id) as effective_user_id
  from public.formulario_trabajador f
  left join auth.users u on lower(u.email) = lower(f.correo)
  join input i on lower(f.correo) = i.correo
  order by f.fecha_creacion desc
  limit 1
), approved_form as (
  update public.formulario_trabajador f
  set
    user_id = lf.effective_user_id,
    estado = 'aprobado',
    fecha_actualizacion = now()
  from latest_form lf
  where f.id = lf.id
    and lf.effective_user_id is not null
  returning f.*
), upsert_perfil as (
  insert into public.perfiles (
    id,
    nombre,
    nombre_completo,
    correo,
    telefono,
    rol,
    foto_perfil_url,
    activo
  )
  select
    user_id,
    nombre_completo,
    nombre_completo,
    correo,
    celular,
    'trabajador',
    foto_perfil_url,
    true
  from approved_form
  on conflict (id) do update set
    nombre = excluded.nombre,
    nombre_completo = excluded.nombre_completo,
    correo = excluded.correo,
    telefono = excluded.telefono,
    rol = 'trabajador',
    foto_perfil_url = coalesce(excluded.foto_perfil_url, public.perfiles.foto_perfil_url),
    activo = true,
    fecha_actualizacion = now()
  returning id
), upsert_worker as (
  insert into public.worker_profiles (
    id,
    dui,
    estado_verificacion,
    disponibilidad,
    verificado,
    latitud,
    longitud,
    radio_km
  )
  select
    user_id,
    dui,
    'aprobado',
    false,
    true,
    latitud,
    longitud,
    6
  from approved_form
  on conflict (id) do update set
    dui = excluded.dui,
    estado_verificacion = 'aprobado',
    verificado = true,
    latitud = coalesce(excluded.latitud, public.worker_profiles.latitud),
    longitud = coalesce(excluded.longitud, public.worker_profiles.longitud),
    fecha_actualizacion = now()
  returning id, estado_verificacion, verificado, disponibilidad
)
select
  af.user_id,
  af.correo,
  af.nombre_completo,
  af.estado as estado_formulario,
  uw.estado_verificacion,
  uw.verificado,
  uw.disponibilidad
from approved_form af
join upsert_worker uw on uw.id = af.user_id;

commit;
