# Checklist MVP funcional — Frontend territorial vivo

**v01 · 2026-05-29.** Validación de extremo a extremo del dashboard LIVE de BRUZZONE IA.

## A. Dashboard y mapa (modo DEMO, sin Supabase)
- [ ] El dashboard abre con doble clic (`...LIVE_v03.html`).
- [ ] El badge muestra `● DEMO (local)`.
- [ ] El mapa responde: zoom, paneo, capas base (satélite/OSM).
- [ ] Se ven los **504 olivos** y el perímetro.
- [ ] GeoJSON válido (504 features con atributos).
- [ ] Colores por estado correctos; conmutador Estado/Zona funciona.
- [ ] Leyenda operacional con conteos; clic oculta/muestra estados.
- [ ] Filtros: zona, severidad ≥, solo quintral, "ver todo".
- [ ] KPIs coherentes (olivos, monitoreados, alertas, críticos…).
- [ ] Popup y ficha operacional abren con todos los campos + QR.
- [ ] Registrar monitoreo (en memoria) recolorea el árbol y actualiza KPIs/alertas.

## B. Supabase (modo LIVE)
- [ ] Scripts SQL ejecutados (01→02→03→04, todos "PASA").
- [ ] `.env` / `window.__ENV__` con URL + anon key reales.
- [ ] Al abrir, el badge muestra `● LIVE`.
- [ ] `arbol_geojson` responde FeatureCollection(504) → mapa carga datos vivos.
- [ ] `v_kpi_predio` / `estado_catalogo` responden.
- [ ] Botón **↻ Recargar** reconecta y refresca.

## C. Autenticación (operador)
- [ ] `login` envía OTP al correo y verifica el código.
- [ ] Sesión activa habilita el botón de registro; sin sesión queda solo-lectura.
- [ ] `registro de usuario` envía solicitud (OTP `shouldCreateUser`).

## D. Registro de monitoreo (LIVE)
- [ ] El formulario llama **solo** a `registrar_monitoreo` (sin UPDATE directo a `arbol`).
- [ ] Sube foto a Storage `evidencias` (si se adjunta).
- [ ] El **estado del árbol cambia** tras el registro.
- [ ] El dashboard refleja el nuevo estado al recargar.
- [ ] El popup/ficha muestra el evento en el historial.

## E. QR
- [ ] `/qr/:codigo` (o `qr...html?codigo=`) abre la ficha pública.
- [ ] Muestra estado actual y última visita sin login.
- [ ] Sin sesión: no permite registrar (ofrece login).
- [ ] Con sesión: enlaza al formulario de monitoreo.

## F. Fallback / estabilidad
- [ ] Con Supabase mal configurado → cae a DEMO sin romperse.
- [ ] Con Supabase caído y cache previa → modo CACHÉ.
- [ ] Sin internet → puntos visibles (sin tiles), app navegable.
- [ ] Mensajes de error amigables (flash), nunca pantalla en blanco.

**Criterio de aprobación MVP:** A y F completos (demo confiable) + B/C/D/E verificados una vez creado el proyecto Supabase real.
