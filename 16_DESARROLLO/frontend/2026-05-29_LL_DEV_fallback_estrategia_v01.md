# Estrategia de fallback operacional — BRUZZONE IA

**v01 · 2026-05-29.** Sistema híbrido que mantiene el dashboard funcional pase lo que pase. La demo nunca se rompe.

## Tres modos de datos

| Modo | Cuándo | Origen de datos | Escritura |
|---|---|---|---|
| **LIVE** | Supabase configurado y responde | RPC `arbol_geojson` | RPC `registrar_monitoreo` (si hay sesión) |
| **CACHÉ** | Supabase configurado pero falla; hay cache local | `localStorage` (último LIVE) | Cola local (se sincroniza luego) |
| **DEMO** | Sin configurar o sin cache | GeoJSON embebido en el HTML | En memoria (no persiste) |

El badge del header muestra el modo activo: `● LIVE` / `● CACHÉ` / `● DEMO (local)`.

## Lógica de decisión (al cargar)

```
¿ENV con URL+anon key válidas?
  no  → DEMO (datos embebidos)
  sí  → intentar getArbolesLive() con timeout 7s
          éxito            → LIVE (y guardar en cache)
          error + cache    → CACHÉ
          error sin cache  → DEMO  (+ aviso "modo DEMO")
```

Implementado en el dashboard (`...LIVE_v03.html`, función `cargar()`) y en `services/dataService.js` (`obtenerArboles`).

## Comportamiento sin internet

- **Lectura:** si hubo una sesión LIVE previa, se sirve desde `localStorage` (modo CACHÉ). Si nunca hubo, modo DEMO con los 504 olivos embebidos.
- **Mapa base:** las tiles (Esri/OSM) requieren red; sin internet el mapa de fondo no carga, pero los **puntos de los olivos sí** (van en el archivo). Se ve la disposición y los estados aunque sin imagen satelital.

## Comportamiento con Supabase caído

- El `try/catch` + `Promise.race(timeout)` evita que la app se cuelgue.
- Cae a CACHÉ (si existe) o DEMO, y avisa con un *flash*.
- Botón **↻ Recargar** reintenta la conexión (reconexión manual). 

## Persistencia temporal (cola offline)

- `services/cache.js` ofrece `colaPush`/`colaTake`: los monitoreos registrados sin conexión se guardan en `localStorage` y se reenvían vía `registrar_monitoreo` al recuperar señal (fase 2).
- En modo DEMO/CACHÉ, los cambios de estado se reflejan en el mapa al instante (memoria), aunque no persistan en servidor hasta el corte LIVE.

## Garantía

Pase lo que pase —sin red, Supabase caído, claves no configuradas— el dashboard **siempre** abre, muestra los 504 olivos y permite navegar. Es la base de una demo comercial confiable.
