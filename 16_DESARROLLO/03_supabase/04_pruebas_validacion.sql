-- =====================================================================
-- BRUZZONE IA · MVP · Pruebas de validación post-carga
-- Archivo: 04_pruebas_validacion.sql  ·  v01  ·  2026-05-29
-- Ejecutar tras 01 + 02 + 03. Cada bloque imprime PASA / FALLA.
-- =====================================================================
\set PREDIO '22222222-2222-2222-2222-222222222222'

-- 1) Cantidad de árboles = 504
select case when count(*) = 504 then 'PASA' else 'FALLA' end as test_504_arboles, count(*) as n
from arbol where id_predio = :'PREDIO';

-- 2) Perímetro predial cargado (polígono válido)
select case when geom is not null and st_geometrytype(geom) = 'ST_Polygon' then 'PASA' else 'FALLA' end as test_perimetro
from predio where id = :'PREDIO';

-- 3) RPC arbol_geojson devuelve FeatureCollection con 504 features
select case
         when (arbol_geojson(:'PREDIO')->>'type') = 'FeatureCollection'
          and json_array_length((arbol_geojson(:'PREDIO')->'features')) = 504
         then 'PASA' else 'FALLA' end as test_rpc_geojson,
       json_array_length((arbol_geojson(:'PREDIO')->'features')) as n_features;

-- 3b) Una feature de ejemplo trae las propiedades esperadas
select (arbol_geojson(:'PREDIO')->'features'->0->'properties') as ejemplo_properties;

-- 4) Vista de KPIs responde
select case when n_arboles = 504 then 'PASA' else 'FALLA' end as test_kpis, *
from v_kpi_predio where id_predio = :'PREDIO';

-- 4b) Resumen por zona de manejo
select * from v_zona_manejo where id_predio = :'PREDIO' order by zona_manejo;

-- 5) Catálogo de estados responde (7 estados)
select case when count(*) >= 7 then 'PASA' else 'FALLA' end as test_catalogo, count(*) as n
from estado_catalogo;
select estado, etiqueta, color, prioridad from estado_catalogo order by prioridad desc;

-- 5b) RLS activo en tablas sensibles (arbol, monitoreo, estado_catalogo)
select relname as tabla,
       case when relrowsecurity then 'PASA' else 'FALLA' end as rls_activo
from pg_class
where relname in ('arbol','monitoreo','estado_catalogo','sector')
  and relnamespace = 'public'::regnamespace
order by relname;

-- 5c) Políticas existentes (debe haber SELECT público en arbol y catálogo)
select schemaname, tablename, policyname, cmd, roles
from pg_policies
where tablename in ('arbol','monitoreo','estado_catalogo','sector')
order by tablename, policyname;

-- 6) Cobertura de atributos (NDVI, rendimiento, zona)
select
  count(*)                                              as total,
  count(ndvi)                                           as con_ndvi,
  count(rendimiento_2020)                               as con_rend_2020,
  count(*) filter (where zona_manejo is not null)       as con_zona
from arbol where id_predio = :'PREDIO';

-- 7) Registrar un monitoreo de prueba vía RPC (NUNCA update directo a arbol)
--    Nota: auth.uid() será null fuera de una sesión autenticada; el insert igual funciona en SQL editor.
select registrar_monitoreo('LL-OLI-0001','intervencion','quintral',4,'PRUEBA: foco de quintral') as nuevo_monitoreo_id;

-- 8) El estado del árbol cambió mediante la RPC
select case when estado = 'intervencion' then 'PASA' else 'FALLA' end as test_cambio_estado,
       codigo, estado, ultimo_monitoreo
from arbol where codigo = 'LL-OLI-0001';

-- 9) El historial registra el evento
select case when count(*) >= 1 then 'PASA' else 'FALLA' end as test_historial, count(*) as eventos
from v_historial_arbol where codigo = 'LL-OLI-0001';
select * from v_historial_arbol where codigo = 'LL-OLI-0001' limit 5;

-- 10) (Opcional) revertir la prueba para dejar el estado base
-- update arbol set estado='sano' where codigo='LL-OLI-0001';
-- delete from monitoreo where id_arbol=(select id from arbol where codigo='LL-OLI-0001') and observacion like 'PRUEBA:%';

-- =====================================================================
-- Esperado: todos los tests con 'PASA'. Si alguno FALLA, revisar el orden
-- de ejecución de los scripts (01 → 02 → 03) y la extensión PostGIS.
-- =====================================================================
