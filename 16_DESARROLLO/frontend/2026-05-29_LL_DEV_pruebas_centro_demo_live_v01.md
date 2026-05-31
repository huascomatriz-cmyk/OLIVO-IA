# Pruebas del Centro de Demo en LIVE — BRUZZONE IA

**v01 · 2026-05-29.** Qué probar desde `index.html` (Centro de Demo) una vez activado Supabase LIVE. Confirma que cada tarjeta del portal funciona de extremo a extremo.

## Enlaces que el Centro de Demo conecta (verificados)

| Tarjeta | Destino | Modo |
|---|---|---|
| Dashboard territorial | `../../09_DASHBOARDS_Y_PLATAFORMA/03_Mapas_Interactivos/2026-05-29_LL_DASH_leaflet_LIVE_v03.html` | DEMO + LIVE |
| QR de ejemplo | `src/components/qr/...QR_live_ficha_publica...html?codigo=LL-OLI-0001` | LIVE |
| Registro de monitoreo | `monitoring/...MON_registro_monitoreo...html?codigo=LL-OLI-0001` | LIVE |
| Login operador | `pages/...AUTH_login...html` | LIVE |
| Registro operador | `pages/...AUTH_registro_usuario...html` | LIVE |
| Documentación | `README.md` y guías `..._DEV_*.md` | DOCS |
| Checklist / guía Supabase | `../03_supabase/...checklist_supabase_live...` · `...guia_supabase_live...` | DOCS |

## Secuencia de pruebas (tras activar LIVE)

1. **Abrir `index.html`.** Carga la portada, tarjetas y "Estado actual MVP".
2. **Dashboard:** clic en *Abrir dashboard*. Verificar badge **● LIVE** y 504 olivos cargados desde Supabase. Probar filtros (estado, zona, severidad) y leyenda.
3. **Popup/ficha de árbol:** clic en un olivo → ver código, estado, NDVI, rendimiento, QR.
4. **QR de ejemplo:** volver al centro → *Ver ficha QR*. Debe abrir la ficha pública de `LL-OLI-0001` **sin login** y mostrar el estado real.
5. **Login operador:** *Iniciar sesión* → ingresar correo → recibir OTP → verificar. Sesión activa.
6. **Registro de monitoreo:** *Abrir formulario* (o desde el QR ya autenticado) → elegir estado (ej. *intervención*), tipo *quintral*, severidad, observación, foto → **Guardar**. Debe confirmar éxito.
7. **Verificar propagación:** volver al dashboard → **↻ Recargar** → el árbol monitoreado debe mostrar el nuevo estado y color. El historial debe incluir el evento.
8. **Bloqueo sin login:** cerrar sesión → abrir el QR → el botón de registro no aparece (solo lectura).

## Qué confirma cada prueba

- Pasos 2–3: `arbol_geojson` LIVE + render correcto.
- Paso 4: RLS de lectura pública del árbol.
- Paso 5: Supabase Auth (OTP).
- Pasos 6–7: RPC `registrar_monitoreo` (cambio de estado vía RPC, **nunca** UPDATE directo) + refresco del mapa.
- Paso 8: RLS de escritura solo autenticada.

## Si algo falla

Aplicar el **Plan de rollback** de la guía (`../03_supabase/2026-05-29_LL_DEV_guia_supabase_live_v01.md`, sección 9). Lo más rápido: devolver los placeholders a `window.__ENV__` → el sistema vuelve a **DEMO** y la presentación continúa con datos embebidos.

**Aprobado** cuando los 8 pasos se completan en LIVE y el rollback a DEMO funciona.
