# Roadmap inmediato — Frontend territorial vivo

**v01 · 2026-05-29.** Prioridad: estabilidad, demostración comercial, facilidad de implementación y operación real.

## Construir inmediatamente (ya entregado o de cierre directo)
- Dashboard LIVE con fallback (DEMO/CACHÉ/LIVE) y filtros estado/zona/severidad. ✔
- Cliente Supabase + API wrapper + servicios (cache/cola). ✔
- Formulario de monitoreo vía `registrar_monitoreo` (sin UPDATE directo). ✔
- Ficha QR pública y login/registro OTP. ✔
- **Cierre:** crear proyecto Supabase real, completar `.env`, ejecutar checklist B–E.

## Estabilizar (corto plazo)
- Subida de fotos a Storage (políticas y compresión en cliente).
- Manejo de errores y reintentos consistente en todas las páginas.
- Refresh selectivo del marcador tras monitoreo (en vez de recargar todo).
- Sincronización de la cola offline al recuperar señal.
- QA en móvil real (operador en terreno) y ajustes de UX.

## Dejar para fase 2
- Migrar el HTML monolítico a componentes React/Next (la estructura `frontend/` ya está lista).
- Supabase Realtime (push al mapa sin recargar).
- Multipredio y panel multicliente con RLS por cliente.
- Roles finos y administración de usuarios.
- Capa de rendimiento (mapa de calor) y comparación temporal avanzada.

## NO construir todavía
- IA de detección de quintral (YOLO): primero acumular fotos etiquetadas del monitoreo real.
- Modelo predictivo de rendimiento en producción.
- App móvil nativa (la web responsiva + QR cubre el MVP).

**Regla:** cada nueva pieza debe mejorar estabilidad, demo o operación real. Si no, espera.
