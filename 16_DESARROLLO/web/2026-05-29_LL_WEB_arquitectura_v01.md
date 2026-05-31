# Arquitectura Web Empresarial — BRUZZONE IA

**v01 · 2026-05-29.** Estructura del sitio público, navegación, wireframes textuales y arquitectura SaaS futura.

## Estructura de carpetas (`16_DESARROLLO/web/`)

```
web/
├── index.html         Landing oficial (home)  ← entregado
├── demo/index.html    Demo comercial pública  ← entregado
├── servicios/         Detalle de las 8 líneas de servicio
├── clientes/          Casos / prueba social (Los Loros)
├── dashboard/         Embed/acceso al dashboard territorial
├── qr/                Explicación del sistema QR / landing de escaneo
├── nosotros/          Equipo, visión, método
├── contacto/          Formulario y agenda de demo
├── blog/              Contenido técnico-comercial (SEO)
├── assets/            Imágenes, screenshots, logos
└── styles/            Tokens compartidos (ver 14_BRANDING)
```

> Estado: `home` y `demo` construidos y funcionales. El resto son secciones definidas (esta guía) para completar en iteraciones siguientes; la landing ya contiene en una sola página las secciones de servicios, nosotros y contacto (one-page), por lo que las subcarpetas son para cuando se separen en páginas dedicadas.

## Navegación y jerarquía

- **Menú principal:** Servicios · Cómo funciona · Demo · Contacto · **[Ver demo en vivo]** (CTA dorado).
- **Jerarquía:** Home (visión + valor) → Demo (prueba) → Servicios (oferta) → Contacto (conversión).
- **CTA global:** "Ver demo" siempre visible; conversión hacia agendar demostración.
- **Footer:** contacto, identidad, nota DEMO/LIVE.

## Experiencia móvil

- Mobile-first: una columna, tipografía grande, menú colapsado (los enlaces secundarios se ocultan, queda el CTA).
- El hero y las tarjetas se apilan; el dashboard y el QR están pensados para teléfono (terreno).

## Wireframes textuales

**Home (one-page):**
```
[NAV: logo · Servicios · Cómo funciona · Demo · Contacto · (Ver demo)]
[HERO: titular + subcopy + CTA + visual malla de olivos]
[KPIs: 504 · R²0,74 · árbol a árbol · DEMO/LIVE]
[PROBLEMA: 6 dolores en tarjetas]
[SOLUCIÓN: 7 pasos georreferencia→postventa]
[SERVICIOS: 8 tarjetas sobre fondo verde]
[BANDA DEMO: CTA a /demo y Centro de Demo]
[POSTVENTA: hábito + diferenciador]
[ROADMAP: 5 fases]
[FOOTER/CONTACTO: email + identidad]
```

**Demo (/demo):**
```
[NAV: ← Inicio · (Abrir dashboard)]
[HERO: "Los Loros, árbol a árbol, en vivo"]
[QUÉ ES + KPIs territoriales]
[RECORRIDO 3 MIN: 6 pasos]
[PIEZAS DEL MVP: dashboard · QR · monitoreo · centro de demo · Supabase · postventa]
[CTA: agendar demostración]
```

## Integración del Centro de Demo

`16_DESARROLLO/frontend/index.html` se integra como:
- **Demo técnica:** acceso interno a dashboard, QR, monitoreo, login y documentación.
- **Demo comercial:** la web `/demo` lo enlaza como "explorar el centro de demo".
- **Presentación cliente:** se abre en pantalla durante la reunión.

**Cuándo DEMO / cuándo LIVE**
- **DEMO:** reuniones sin internet garantizado, primeras demostraciones, ferias. Datos embebidos, cero dependencia.
- **LIVE:** clientes en evaluación/onboarding, registro real de monitoreos. Requiere Supabase configurado.
- **Regla:** ante cualquier falla, volver a DEMO (placeholders en `window.__ENV__`); la presentación no se interrumpe.

## Arquitectura SaaS futura

Evolución: **Los Loros → múltiples predios → múltiples clientes → plataforma territorial.**

| Dimensión | MVP (hoy) | SaaS (futuro) |
|---|---|---|
| Datos | 1 predio (UUID fijo) | N predios por cliente, filtrados por `id_cliente` |
| Acceso | operador único / demo | login por cliente; cada cliente ve solo sus predios |
| Paneles | 1 dashboard | panel por cliente + panel interno BRUZZONE |
| Seguridad | RLS lectura pública + escritura autenticada | RLS por `id_cliente` (aislamiento entre clientes) |
| Licencias | — | planes por superficie / n.º de árboles (Trazabilidad / Pro / Territorial) |
| Postventa | reportes manuales/semi | reportes automáticos programados por cliente |
| Escalabilidad | Supabase free | Supabase escalado + CDN (Vercel/Cloudflare) |

**Multicliente (cómo):** añadir políticas RLS por `id_cliente` (un usuario solo ve filas de su cliente), un selector de predio, y vistas/RPC parametrizadas por predio (ya lo son). El frontend se mantiene; cambia el alcance de los datos, no la UI.

Ver narrativa, servicios, presentación y roadmap en `2026-05-29_LL_WEB_narrativa_comercial_v01.md`.
