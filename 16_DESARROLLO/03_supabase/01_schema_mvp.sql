-- =====================================================================
-- BRUZZONE IA · MVP · Esquema de base de datos (Supabase / PostgreSQL + PostGIS)
-- Archivo: 01_schema_mvp.sql  ·  Versión: v01  ·  Fecha: 2026-05-29
-- Ejecutar en el SQL Editor de Supabase o vía psql. Idempotente.
-- Modelo mínimo del MVP: cliente · predio · sector · arbol · monitoreo · tarea · usuario
-- =====================================================================

-- ---------- Extensiones ----------
create extension if not exists postgis;
create extension if not exists "pgcrypto";  -- gen_random_uuid()

-- ---------- Tipos (enumeraciones controladas) ----------
do $$ begin
  create type zona_manejo_t as enum ('alto','medio','bajo');
exception when duplicate_object then null; end $$;

-- 7 estados operacionales oficiales definidos desde el inicio
-- (evita ALTER TYPE ADD VALUE, que no es válido dentro de bloques/transacciones).
do $$ begin
  create type estado_arbol_t as enum
    ('sin_monitoreo','sano','vigilar','recuperandose','podado','intervencion','critico');
exception when duplicate_object then null; end $$;

do $$ begin
  create type rol_t as enum ('admin','agronomo','operador','cliente');
exception when duplicate_object then null; end $$;

do $$ begin
  create type estado_tarea_t as enum ('pendiente','en_proceso','validada','cerrada');
exception when duplicate_object then null; end $$;

-- =====================================================================
-- TABLAS
-- =====================================================================

-- ---------- cliente ----------
create table if not exists cliente (
  id          uuid primary key default gen_random_uuid(),
  nombre      text not null,
  contacto    text,
  creado_en   timestamptz not null default now()
);

-- ---------- usuario ----------
create table if not exists usuario (
  id          uuid primary key default gen_random_uuid(),
  nombre      text not null,
  email       text unique,
  rol         rol_t not null default 'operador',
  id_cliente  uuid references cliente(id) on delete set null,  -- si es usuario tipo cliente
  creado_en   timestamptz not null default now()
);

-- ---------- predio ----------
create table if not exists predio (
  id          uuid primary key default gen_random_uuid(),
  id_cliente  uuid references cliente(id) on delete cascade,
  nombre      text not null,
  comuna      text,
  cultivo     text default 'Olivo',
  n_arboles   int,
  geom        geometry(Polygon, 4326),   -- perímetro predial
  creado_en   timestamptz not null default now()
);

-- ---------- sector ----------
create table if not exists sector (
  id          uuid primary key default gen_random_uuid(),
  id_predio   uuid not null references predio(id) on delete cascade,
  nombre      text not null,
  zona_manejo zona_manejo_t,
  qr_token    text unique,               -- token que codifica el QR del sector
  geom        geometry(Polygon, 4326),
  creado_en   timestamptz not null default now()
);

-- ---------- arbol ----------
-- Atributos alineados 1:1 con el GeoJSON LL_arbolado_zonas_manejo_v01
create table if not exists arbol (
  id                 uuid primary key default gen_random_uuid(),
  id_predio          uuid not null references predio(id) on delete cascade,
  id_sector          uuid references sector(id) on delete set null,
  codigo             text not null,              -- LL-OLI-0001
  id_arbol_origen    int,                        -- id numérico original del KML/dataset
  variedad           text,
  zona_manejo        zona_manejo_t,
  clase_vigor_kmeans smallint check (clase_vigor_kmeans between 1 and 4),
  ndvi               numeric(5,3),               -- NDVI medio multitemporal
  ndvi_actual        numeric(5,3),               -- NDVI más reciente
  rendimiento_2019   numeric(7,1),               -- kg/árbol
  rendimiento_2020   numeric(7,1),               -- kg/árbol
  estado             estado_arbol_t not null default 'sin_monitoreo',
  ultimo_monitoreo   timestamptz,
  geom               geometry(Point, 4326) not null,
  creado_en          timestamptz not null default now(),
  unique (id_predio, codigo)
);

-- ---------- monitoreo ----------
-- El "quintral" es un tipo de monitoreo (tipo='quintral'), no una tabla aparte.
create table if not exists monitoreo (
  id          uuid primary key default gen_random_uuid(),
  id_arbol    uuid references arbol(id) on delete cascade,
  id_sector   uuid references sector(id) on delete cascade,
  fecha       timestamptz not null default now(),
  tipo        text not null,                 -- 'quintral' | 'vigor' | 'fitosanitario' | 'riego'
  severidad   smallint check (severidad between 0 and 5),
  observacion text,
  foto_url    text,
  id_usuario  uuid references usuario(id) on delete set null,
  geom        geometry(Point, 4326),
  creado_en   timestamptz not null default now(),
  check (id_arbol is not null or id_sector is not null)
);

-- ---------- tarea ----------
create table if not exists tarea (
  id           uuid primary key default gen_random_uuid(),
  id_predio    uuid not null references predio(id) on delete cascade,
  id_sector    uuid references sector(id) on delete set null,
  id_arbol     uuid references arbol(id) on delete set null,
  descripcion  text not null,
  estado       estado_tarea_t not null default 'pendiente',
  asignado_a   uuid references usuario(id) on delete set null,
  fecha_limite date,
  creado_en    timestamptz not null default now()
);

-- =====================================================================
-- ÍNDICES (espaciales y de consulta frecuente)
-- =====================================================================
create index if not exists idx_predio_geom    on predio   using gist (geom);
create index if not exists idx_sector_geom    on sector   using gist (geom);
create index if not exists idx_arbol_geom      on arbol    using gist (geom);
create index if not exists idx_monitoreo_geom  on monitoreo using gist (geom);

create index if not exists idx_arbol_predio    on arbol(id_predio);
create index if not exists idx_arbol_sector    on arbol(id_sector);
create index if not exists idx_arbol_zona      on arbol(zona_manejo);
create index if not exists idx_monitoreo_arbol on monitoreo(id_arbol);
create index if not exists idx_monitoreo_fecha on monitoreo(fecha);
create index if not exists idx_tarea_predio    on tarea(id_predio);
create index if not exists idx_tarea_estado    on tarea(estado);

-- =====================================================================
-- VISTAS PARA EL DASHBOARD MVP
-- =====================================================================

-- KPIs por predio
create or replace view v_kpi_predio as
select
  p.id                                   as id_predio,
  p.nombre                               as predio,
  count(a.*)                             as n_arboles,
  round(avg(a.ndvi)::numeric, 3)         as ndvi_medio,
  round(avg(a.rendimiento_2020)::numeric, 1) as rend_2020_medio,
  round(avg(a.rendimiento_2019)::numeric, 1) as rend_2019_medio,
  count(*) filter (where a.estado in ('vigilar','intervencion')) as arboles_en_alerta
from predio p
left join arbol a on a.id_predio = p.id
group by p.id, p.nombre;

-- Resumen por zona de manejo
create or replace view v_zona_manejo as
select
  a.id_predio,
  a.zona_manejo,
  count(*)                                   as n_arboles,
  round(avg(a.ndvi)::numeric, 3)             as ndvi_medio,
  round(avg(a.rendimiento_2020)::numeric, 1) as rend_2020_medio,
  round(avg(a.rendimiento_2019)::numeric, 1) as rend_2019_medio
from arbol a
group by a.id_predio, a.zona_manejo;

-- Árboles como GeoJSON listo para el mapa (una fila = FeatureCollection del predio)
create or replace view v_arbol_geojson as
select
  a.id_predio,
  json_build_object(
    'type','FeatureCollection',
    'features', json_agg(
      json_build_object(
        'type','Feature',
        'geometry', st_asgeojson(a.geom)::json,
        'properties', json_build_object(
          'codigo', a.codigo,
          'zona_manejo', a.zona_manejo,
          'clase_vigor_kmeans', a.clase_vigor_kmeans,
          'ndvi', a.ndvi,
          'ndvi_actual', a.ndvi_actual,
          'rendimiento_2019', a.rendimiento_2019,
          'rendimiento_2020', a.rendimiento_2020,
          'estado', a.estado,
          'ultimo_monitoreo', a.ultimo_monitoreo
        )
      )
    )
  ) as geojson
from arbol a
group by a.id_predio;

-- =====================================================================
-- ROW LEVEL SECURITY (base — ajustar a la política definitiva)
-- =====================================================================
-- Activar RLS. Para el MVP: lectura pública de árboles (necesario para QR sin login)
-- y escritura solo para usuarios autenticados. Refinar por cliente al escalar.
alter table arbol     enable row level security;
alter table sector    enable row level security;
alter table monitoreo enable row level security;
alter table tarea     enable row level security;

drop policy if exists arbol_lectura_publica on arbol;
create policy arbol_lectura_publica on arbol
  for select using (true);                       -- el QR abre la ficha sin login

drop policy if exists sector_lectura_publica on sector;
create policy sector_lectura_publica on sector
  for select using (true);

drop policy if exists monitoreo_escritura_auth on monitoreo;
create policy monitoreo_escritura_auth on monitoreo
  for insert to authenticated with check (true); -- operadores autenticados registran

drop policy if exists monitoreo_lectura_auth on monitoreo;
create policy monitoreo_lectura_auth on monitoreo
  for select to authenticated using (true);

-- NOTA: cliente, predio y usuario quedan sin políticas públicas (acceso solo vía service_role
-- o políticas por cliente que se definirán al incorporar autenticación multicliente).

-- =====================================================================
-- FIN DEL ESQUEMA
-- =====================================================================
