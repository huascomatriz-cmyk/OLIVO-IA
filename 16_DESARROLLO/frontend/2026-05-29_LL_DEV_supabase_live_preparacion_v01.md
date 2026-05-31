# Preparación para Supabase Live — Dashboard operacional

**v01 · 2026-05-29.** Arquitectura exacta de transición desde el dashboard con datos embebidos hacia datos en vivo. **No conecta nada todavía**: define endpoints, contratos y seguridad para que el cambio sea de bajo riesgo.

## Principio de transición

El dashboard ya consume un FeatureCollection con un formato fijo. La RPC `arbol_geojson` (en `03_supabase/03_monitoreo_rpc_rls.sql`) devuelve **ese mismo formato**. Por tanto, pasar a vivo = reemplazar el bloque `const ARBOLES = {…}` por un `fetch`. El resto del código del mapa no cambia.

## Endpoints / API

Supabase expone PostgREST sobre el esquema. Se usarán RPC (funciones) en lugar de tablas crudas:

| Operación | Tipo | Endpoint | Auth |
|---|---|---|---|
| Árboles de un predio (GeoJSON) | RPC `GET/POST` | `/rest/v1/rpc/arbol_geojson` body `{p_predio}` | `anon` (lectura pública) |
| Catálogo de estados | REST `GET` | `/rest/v1/estado_catalogo` | `anon` |
| Historial de un árbol | REST `GET` | `/rest/v1/v_historial_arbol?codigo=eq.LL-OLI-0001` | `authenticated` |
| Registrar monitoreo | RPC `POST` | `/rest/v1/rpc/registrar_monitoreo` | `authenticated` |
| KPIs por predio | REST `GET` | `/rest/v1/v_kpi_predio` | `anon` |

## Cliente y fetch

```js
// lib/supabaseClient.js
import { createClient } from '@supabase/supabase-js';
export const supabase = createClient(import.meta.env.VITE_SUPABASE_URL, import.meta.env.VITE_SUPABASE_ANON_KEY);

// lib/api.js
export async function getArboles(idPredio){
  const { data, error } = await supabase.rpc('arbol_geojson', { p_predio: idPredio });
  if (error) throw error;
  return data;                         // mismo FeatureCollection que el demo embebido
}
export async function registrarMonitoreo(p){
  const { data, error } = await supabase.rpc('registrar_monitoreo', {
    p_codigo: p.codigo, p_estado: p.estado, p_tipo: p.tipo,
    p_severidad: p.severidad, p_observacion: p.obs, p_foto_url: p.fotoUrl ?? null });
  if (error) throw error;
  return data;                         // uuid del monitoreo creado
}
```

En el mapa, sustituir el dato embebido:

```js
// const ARBOLES = {...}           ← demo
const ARBOLES = await getArboles(ID_PREDIO);   // ← vivo
```

## Autenticación

- **Anónimo (`anon`):** lectura del mapa, catálogo y KPIs. Habilita el QR público y la demo sin login.
- **Autenticado (`authenticated`):** operadores y agrónomos; pueden registrar monitoreo. Login por email/OTP de Supabase Auth.
- **`service_role`:** solo backend/administración (cargas masivas, seeds). Nunca en el cliente.
- El rol **cliente** se modela como usuario autenticado con `usuario.rol='cliente'` y solo lectura (sin acción de registro en la UI).

## Sincronización

- **Lectura:** *fetch* al cargar y tras cada registro (`await getArboles` o actualización optimista del marcador). 
- **Fase 2 — Realtime:** suscripción a cambios de `arbol` (`supabase.channel('arbol').on('postgres_changes', …)`) para que el mapa se actualice por push sin recargar. No requerido para el MVP.
- **Offline (fase posterior):** cola local (IndexedDB) de monitoreos pendientes; al recuperar señal, se envían vía `registrar_monitoreo`.

## Caching

- Lectura del GeoJSON: *cache* en memoria + revalidación al registrar (o `stale-while-revalidate` con SWR/React Query).
- Catálogo de estados: cachear largo (cambia rara vez).
- Tiles del mapa: cache del navegador (CDN).

## Seguridad / RLS

- RLS activado en `arbol`, `monitoreo`, `estado_catalogo` (definido en el SQL).
- Lectura pública solo de lo necesario para QR/dashboard; `cliente`, `predio`, `usuario` quedan cerrados.
- La actualización de `arbol.estado` ocurre **solo** vía la RPC `registrar_monitoreo` (`security definer`): el cliente nunca hace `UPDATE` directo sobre el árbol.
- La `anon key` es pública por diseño (las políticas RLS son la defensa real). La `service_role key` jamás se expone en el frontend.
- Validación de severidad (0–5) y de existencia del árbol dentro de la RPC.

## Checklist de corte a vivo

1. Ejecutar `01_schema_mvp.sql`, `02_seed_los_loros.sql`, `03_monitoreo_rpc_rls.sql`.
2. Crear proyecto Supabase, copiar URL + anon key a variables de entorno.
3. Reemplazar datos embebidos por `getArboles(ID_PREDIO)`.
4. Conectar el formulario a `registrarMonitoreo(...)`.
5. Activar Auth para operadores; modo cliente solo-lectura.
6. Publicar la ruta `/qr/:codigo` en la web.
