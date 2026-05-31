# QR Live y registro de monitoreo — BRUZZONE IA

**v01 · 2026-05-29.** Ruta pública `/qr/:codigo` y formulario de registro para operadores autenticados.
Página de referencia: `src/components/qr/2026-05-29_LL_QR_live_ficha_publica_v01.html`.

## 6. Ruta `/qr/:codigo`

Flujo: **ESCANEAR → IDENTIFICAR → VISUALIZAR → MONITOREAR → GUARDAR → ACTUALIZAR.**

1. **Recibe el código** desde la URL (`/qr/LL-OLI-0001` o `?codigo=LL-OLI-0001`).
2. **Consulta Supabase** (lectura pública del árbol, RLS `select using(true)`):
   ```js
   sb.from("arbol").select("codigo,zona_manejo,clase_vigor_kmeans,ndvi,ndvi_actual,rendimiento_2019,rendimiento_2020,estado,ultimo_monitoreo").eq("codigo",codigo).single();
   ```
3. **Muestra la ficha pública:** código, estado actual (pill con color), zona, NDVI, rendimiento, última visita.
4. **Monitoreos permitidos en público:** solo estado actual y última visita. El **historial completo** requiere sesión (RLS de `v_historial_arbol` / `monitoreo` = `authenticated`).
5. **Lectura sin login:** cualquier persona con el QR ve la ficha (cliente, auditor, operador).
6. **Bloqueo de registro:** si no hay sesión, se oculta el botón de registro y se ofrece "Iniciar sesión (operador)".

**UX móvil:** una sola columna, ancho máx. 480px, tipografía grande, estado destacado arriba, carga < 2 s, sin pasos intermedios. Pensada para usarse a pie de árbol.

## 7. Registro de monitoreo (operador autenticado)

Formulario (`registro.html` / componente `FormMonitoreo`) que captura:

| Campo | Origen | Notas |
|---|---|---|
| Código árbol | URL / selección | Fijo, no editable |
| Estado | selector (7 estados) | Nuevo estado del árbol |
| Tipo | selector | vigor · quintral · fitosanitario · poda · riego |
| Severidad | 0–5 | Validado |
| Observación | texto | Libre |
| Foto URL | subida a Storage | Se sube primero, se pasa la URL |
| Usuario | `auth.uid()` | Automático (no se pide) |
| Fecha | `now()` | Automático en el servidor |

**Regla inviolable:** el formulario llama **exclusivamente** a la RPC `registrar_monitoreo`. **Nunca** hace `UPDATE` directo sobre la tabla `arbol`. La RPC (security definer) es la única que actualiza `arbol.estado`.

```js
import { registrarMonitoreo } from "../../lib/api.js";
await registrarMonitoreo({ codigo, estado, tipo, severidad, observacion, fotoUrl });
// éxito → volver a la ficha / refrescar el mapa
```

**Subida de foto (Storage):**
```js
const path = `monitoreos/${codigo}/${Date.now()}.jpg`;
await sb.storage.from("evidencias").upload(path, file);
const { data:{ publicUrl } } = sb.storage.from("evidencias").getPublicUrl(path);
// usar publicUrl como fotoUrl en registrarMonitoreo
```

**Tras guardar:** confirmación, y el mapa/QR reflejan el nuevo estado (refetch de `arbol_geojson` o del árbol).
