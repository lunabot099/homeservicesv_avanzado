-- Configuracion necesaria para que las fotos de solicitudes funcionen.
-- Ejecutar en Supabase SQL Editor antes de probar el flujo real.

alter table public.solicitudes_servicio
  add column if not exists imagenes_urls text[] not null default '{}';

-- Bucket esperado por la app: solicitudes-imagenes
-- Crealo desde Storage si no existe. Recomendado: publico solo si quieres usar URLs publicas.
-- Si prefieres bucket privado, hay que cambiar la app a signed URLs.
