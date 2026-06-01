# Auditoría de despliegue Vercel — BRUZZONE IA

**v01 · 2026-05-29.** Análisis de estructura deployable y configuración correcta de `Root Directory`.

## Resultado (formato solicitado)

```
INDEX PRINCIPAL:
16_DESARROLLO/web/index.html        (homepage comercial / landing — relativo a la raíz del repo)

ROOT DIRECTORY VERCEL:
(vacío = raíz del repositorio)      Repo = OLIVO-IA, cuya raíz son los contenidos de la carpeta local 00_BRUZZONE_IA.
                                    NO poner "00_BRUZZONE_IA" (la raíz del repo YA es esa carpeta).

ESTADO:
OK con arreglo aplicado (index.html raíz + vercel.json creados).  ERROR si se deja como estaba.

PROBLEMAS DETECTADOS:
1. No existía index.html en la raíz del repo  ->  Vercel sirve "/" y devuelve 404_NOT_FOUND.  [CORREGIDO]
2. "Root Directory does not exist": se configuró una ruta inexistente (probablemente "00_BRUZZONE_IA",
   pero la raíz del repo ya es esa carpeta -> Vercel busca 00_BRUZZONE_IA/00_BRUZZONE_IA).
3. Frontend fragmentado en 3 carpetas con enlaces que SALEN del directorio (../../):
   - web/index.html        -> ../frontend/index.html
   - web/demo/index.html   -> ../../frontend/... y ../../../09_DASHBOARDS_Y_PLATAFORMA/...
   - frontend/index.html   -> ../../09_DASHBOARDS_Y_PLATAFORMA/...
   Ningún subfolder es un sitio autocontenido.
4. Tres index.html "compitiendo": web/ (landing), web/demo/ (demo) y frontend/ (Centro de Demo).

RECOMENDACIÓN FINAL:
Dejar Root Directory VACÍO (raíz del repo) y desplegar todo el árbol como sitio estático.
Es la ÚNICA opción donde los enlaces ../../ resuelven. Se añadió un index.html en la raíz
(redirige a la landing) y un vercel.json con rutas amigables /inicio, /demo, /dashboard.
```

## Detalle técnico

### Repositorio
- **Raíz git:** `00_BRUZZONE_IA/` (ahí está `.git`). Remoto: `github.com/huascomatriz-cmyk/OLIVO-IA.git`, rama `master`.
- En GitHub, la raíz del repo = el **contenido** de `00_BRUZZONE_IA`. Por eso, en Vercel las rutas se escriben relativas a esa raíz (p. ej. `16_DESARROLLO/web`), **sin** el prefijo `00_BRUZZONE_IA`.
- ✅ Los 3 `index.html`, el branding, `bruzzone-ds.css` y los assets **sí están subidos** (282 archivos trackeados; 83 archivos de marca/CSS). El deploy no falla por archivos faltantes, sino por estructura/configuración.

### Los 3 frontends
| Archivo | Rol | Para producción |
|---|---|---|
| `16_DESARROLLO/web/index.html` | **Homepage comercial (landing)** | ✅ Homepage pública |
| `16_DESARROLLO/web/demo/index.html` | Página demo comercial | Secundaria |
| `16_DESARROLLO/frontend/index.html` | **Centro de Demo** (hub técnico interno) | Acceso interno |

### Dependencias de rutas (verificadas)
- `web/index.html` → `../frontend/index.html` (sale de `web/`).
- `web/demo/index.html` → `../../frontend/...`, `../../../09_DASHBOARDS_Y_PLATAFORMA/...` (sale de `web/`).
- `frontend/index.html` → `../../09_DASHBOARDS_Y_PLATAFORMA/...` (sale de `frontend/`).

**Conclusión:** como los enlaces cruzan entre `16_DESARROLLO/web`, `16_DESARROLLO/frontend` y `09_DASHBOARDS_Y_PLATAFORMA`, solo funcionan si se despliega **todo el repo** (Root Directory vacío). Si se pusiera Root = `16_DESARROLLO/web`, la landing y la demo cargarían, pero los enlaces a `frontend/` y al `dashboard` darían 404.

### ¿Sitio estático? Sí
No hay `package.json` ni build: es 100% estático (HTML/CSS/SVG + Supabase por CDN). En Vercel: **Framework Preset = Other**, sin build command, Output por defecto.

## Arreglo aplicado (en la raíz del repo)
- `index.html` — redirige a la landing (`16_DESARROLLO/web/index.html`) y muestra accesos de respaldo. Resuelve el `404` en `/`.
- `vercel.json` — rutas amigables: `/inicio`, `/demo`, `/dashboard`.
- `favicon.ico`, `apple-touch-icon.png`, `isotipo.svg`, `logo-horizontal.svg` en la raíz para el index de entrada.

## Pasos para estabilizar en Vercel
1. **Hacer commit y push** de estos archivos nuevos (`index.html`, `vercel.json`, favicon raíz) al repo `OLIVO-IA`.
2. En Vercel → Project → **Settings → General → Root Directory:** dejar **VACÍO** (o `./`). Guardar.
3. **Framework Preset:** *Other*. Sin build command.
4. **Redeploy**. La home `/` mostrará la landing; `/inicio`, `/demo`, `/dashboard` funcionarán.

## Recomendación a futuro (opcional, no urgente)
La estructura ideal sería **un solo directorio web autocontenido** (p. ej. `web-deploy/`) que incluya landing, dashboard, QR y assets con rutas internas, y publicar solo esa carpeta. Esto evitaría exponer públicamente datos internos (CSVs, SQL, docx) que hoy quedarían accesibles al desplegar todo el repo. Para estabilizar **ahora**, el arreglo de raíz es suficiente; la consolidación se puede hacer en una iteración posterior.
