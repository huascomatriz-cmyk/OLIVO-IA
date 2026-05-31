-- =====================================================================
-- BRUZZONE IA · MVP · Capa operacional: estados, RPC de monitoreo y RLS live
-- Archivo: 03_monitoreo_rpc_rls.sql  ·  v01  ·  2026-05-29
-- Ejecutar DESPUÉS de 01_schema_mvp.sql (y 02_seed_los_loros.sql).
-- Prepara la base para que el dashboard operacional consuma datos en vivo.
-- =====================================================================

-- ---------- 1. Estados operacionales oficiales ----------
-- El enum estado_arbol_t ya incluye los 7 estados (definido en 01_schema_mvp.sql):
--   sin_monitoreo · sano · vigilar · recuperandose · podado · intervencion · critico
-- No se usa ALTER TYPE ADD VALUE (no es válido dentro de transacciones/bloques).

-- Catálogo de estados (color/icono/prioridad) para que el front lo lea desde la BD.
create table if not exists estado_catalogo (
  estado      text primary key,
  etiqueta    text not null,
  color       text not null,
  icono       text,
  prioridad   smallint not null default 0
);
insert into estado_catalogo (estado, etiqueta, color, icono, prioridad) values
  ('sano',                'Sano',                '#2E7D32', '✓', 0),
  ('monitoreo_pendiente', 'Monitoreo pendiente', '#9E9E9E', '◷', 1),
  ('podado',              'Podado',              '#5C6BC0', '✂', 1),
  ('recuperandose',       'Recuperándose',       '#26A69A', '↑', 2),
  ('vigilar',             'Vigilar',             '#F9A825', '👁', 2),
  ('intervencion',        'Intervención',        '#EF6C00', '⚠', 3),
  ('critico',             'Crítico',             '#C62828', '✖', 4)
on conflict (estado) do update
  set etiqueta=excluded.etiqueta, color=excluded.color, icono=excluded.icono, prioridad=excluded.prioridad;

-- ---------- 2. RPC: GeoJSON de árboles de un predio (para el mapa) ----------
create or replace function arbol_geojson(p_predio uuid)
returns json language sql stable as $$
  select json_build_object(
    'type','FeatureCollection',
    'features', coalesce(json_agg(
      json_build_object(
        'type','Feature',
        'geometry', st_asgeojson(a.geom)::json,
        'properties', json_build_object(
          'codigo', a.codigo, 'zona_manejo', a.zona_manejo,
          'clase_vigor_kmeans', a.clase_vigor_kmeans,
          'ndvi', a.ndvi, 'ndvi_actual', a.ndvi_actual,
          'rendimiento_2019', a.rendimiento_2019, 'rendimiento_2020', a.rendimiento_2020,
          'estado', a.estado, 'ultimo_monitoreo', a.ultimo_monitoreo,
          'lat', st_y(a.geom), 'lon', st_x(a.geom)
        )
      )
    ), '[]'::json)
  )
  from arbol a where a.id_predio = p_predio;
$$;

-- ---------- 3. RPC: registrar monitoreo (inserta evento + actualiza estado) ----------
-- Es la operación central del flujo QR: ESCANEAR → … → MONITOREAR → GUARDAR → ACTUALIZAR.
create or replace function registrar_monitoreo(
  p_codigo     text,
  p_estado     estado_arbol_t,
  p_tipo       text,
  p_severidad  int,
  p_observacion text,
  p_foto_url   text default null
) returns uuid
language plpgsql security definer as $$
declare v_arbol uuid; v_mon uuid; v_user uuid;
begin
  select id into v_arbol from arbol where codigo = p_codigo;
  if v_arbol is null then raise exception 'Árbol % no existe', p_codigo; end if;
  v_user := auth.uid();   -- usuario autenticado (operador/agrónomo)

  insert into monitoreo (id_arbol, fecha, tipo, severidad, observacion, foto_url, id_usuario, geom)
  select v_arbol, now(), p_tipo, p_severidad, p_observacion, p_foto_url, v_user, a.geom
  from arbol a where a.id = v_arbol
  returning id into v_mon;

  update arbol
     set estado = p_estado,
         ultimo_monitoreo = now()
   where id = v_arbol;

  return v_mon;
end; $$;

-- ---------- 4. Vista de historial por árbol ----------
create or replace view v_historial_arbol as
select a.codigo, m.fecha, m.tipo, m.severidad, m.observacion, m.foto_url,
       u.nombre as tecnico, m.id_usuario
from monitoreo m
join arbol a on a.id = m.id_arbol
left join usuario u on u.id = m.id_usuario
order by a.codigo, m.fecha desc;

-- ---------- 5. RLS (modelo live) ----------
-- Lectura pública de árboles y catálogo (necesario para QR y dashboard sin login).
alter table arbol            enable row level security;
alter table estado_catalogo  enable row level security;
alter table monitoreo        enable row level security;

drop policy if exists arbol_select_public on arbol;
create policy arbol_select_public on arbol for select using (true);

drop policy if exists catalogo_select_public on estado_catalogo;
create policy catalogo_select_public on estado_catalogo for select using (true);

-- Monitoreo: lectura para autenticados; inserción solo vía RPC (security definer) o autenticado.
drop policy if exists monitoreo_select_auth on monitoreo;
create policy monitoreo_select_auth on monitoreo for select to authenticated using (true);

drop policy if exists monitoreo_insert_auth on monitoreo;
create policy monitoreo_insert_auth on monitoreo for insert to authenticated with check (true);

-- La actualización de arbol.estado se hace SOLO por la RPC registrar_monitoreo (security definer),
-- por lo que NO se abre policy de update directo sobre arbol para el rol anónimo/autenticado.

-- ---------- Verificación ----------
-- select * from estado_catalogo order by prioridad desc;
-- select arbol_geojson('22222222-2222-2222-2222-222222222222');
-- select registrar_monitoreo('LL-OLI-0001','intervencion','quintral',4,'Foco detectado');
-- =====================================================================
