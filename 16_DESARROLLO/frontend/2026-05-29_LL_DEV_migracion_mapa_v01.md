# Migración del mapa Leaflet a datos en vivo

**v01 · 2026-05-29.** Cómo pasar el dashboard de datos embebidos a Supabase con el mínimo cambio y **sin romper la demo** (fallback automático).

## Principio

Hoy el HTML tiene:
```js
const ARBOLES = {...};   // FeatureCollection embebido
const MON = {...};       // monitoreo simulado
```
El objetivo es obtener `ARBOLES` (y el estado real) desde la RPC, conservando el resto del código del mapa.

## Paso 1 — Cargar Supabase y el wrapper

En el `<head>` (modo HTML simple, vía CDN UMD):
```html
<script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>
<script>
  window.__ENV__ = {
    SUPABASE_URL: "https://TU-PROYECTO.supabase.co",
    SUPABASE_ANON_KEY: "TU_ANON_KEY"
  };
</script>
```
Y los módulos:
```html
<script type="module">
  import { getArboles } from "../../16_DESARROLLO/frontend/lib/api.js";
  import { ID_PREDIO } from "../../16_DESARROLLO/frontend/lib/supabaseClient.js";
  window.getArboles = getArboles; window.ID_PREDIO = ID_PREDIO;
</script>
```
> En un proyecto Next/Vite se importa directamente; aquí se expone en `window` para el HTML.

## Paso 2 — Reemplazar el origen de datos (con fallback)

Sustituir la línea `const ARBOLES = {...}` por una carga con protección:

```js
const ARBOLES_EMBEBIDO = {/* …FeatureCollection de respaldo… */}; // conservar como fallback

async function cargarArboles() {
  setLoading(true);
  try {
    if (!window.getArboles) throw new Error("Supabase no disponible");
    const fc = await window.getArboles(window.ID_PREDIO);
    // Validación del FeatureCollection
    if (!fc || fc.type !== "FeatureCollection" || !Array.isArray(fc.features) || fc.features.length === 0) {
      throw new Error("FeatureCollection inválido o vacío");
    }
    setLoading(false);
    return fc;                      // datos VIVOS
  } catch (err) {
    console.warn("[BRUZZONE IA] Usando datos embebidos (fallback):", err.message);
    flash("Sin conexión a Supabase — mostrando datos locales");
    setLoading(false);
    return ARBOLES_EMBEBIDO;        // FALLBACK: la demo nunca se rompe
  }
}

// init asíncrono
(async () => {
  const ARBOLES = await cargarArboles();
  iniciarMapa(ARBOLES);             // todo el código actual del mapa entra en iniciarMapa()
})();
```

## Paso 3 — Loading y error (UX)

```js
function setLoading(on){
  let el = document.getElementById("loading");
  if(!el){ el=document.createElement("div"); el.id="loading";
    el.style.cssText="position:absolute;inset:0;display:flex;align-items:center;justify-content:center;background:rgba(255,255,255,.7);z-index:9998;font:600 14px sans-serif;color:#2E5E3A";
    el.textContent="Cargando olivar…"; document.getElementById("map").appendChild(el); }
  el.style.display = on ? "flex" : "none";
}
```
- **Loading:** overlay mientras llega la RPC.
- **Error/timeout:** el `try/catch` cae al fallback embebido y avisa con `flash(...)`.
- **Protección si Supabase no responde:** envolver con timeout (`Promise.race` a 6 s) y, si vence, fallback.

## Paso 4 — Estado real en vez de `MON` simulado

Con datos vivos, el estado de cada árbol llega en `feature.properties.estado` (lo provee `arbol_geojson`). El mapa ya colorea por `MON[codigo].estado`; al ir a vivo, leer `p.estado` directamente:
```js
const est = p.estado || "monitoreo_pendiente";   // en vivo
// (en demo era: MON[p.codigo]?.estado)
```

## Paso 5 — Refrescar tras registrar monitoreo

Reemplazar el guardado en memoria por la RPC y recargar:
```js
async function guardar(cod){
  await window.registrarMonitoreo({ codigo:cod, estado, tipo, severidad:sev, observacion:obs, fotoUrl:null });
  const fc = await window.getArboles(window.ID_PREDIO);  // refetch
  iniciarMapa(fc);                                        // o actualizar solo ese marcador
  flash("Monitoreo guardado · mapa actualizado");
}
```

## Resultado

- Mismo mapa, misma UI, mismos colores y leyenda.
- Datos vivos cuando Supabase está disponible; datos embebidos cuando no.
- Cambio localizado: origen de `ARBOLES` y función `guardar`. El resto del código no se toca.
