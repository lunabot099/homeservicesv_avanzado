-- Repara la llave foranea de resenas.solicitud_id.
-- Ejecutar en Supabase SQL Editor si al calificar aparece:
-- violates foreign key constraint "resenas_solicitud_id_fkey"
-- Key is not present in table "solicitudes".

begin;

alter table public.resenas
  drop constraint if exists resenas_solicitud_id_fkey;

alter table public.resenas
  add constraint resenas_solicitud_id_fkey
  foreign key (solicitud_id)
  references public.solicitudes_servicio(id)
  on delete cascade;

notify pgrst, 'reload schema';

commit;
