# -*- coding: utf-8 -*-
import re, json, os
import numpy as np
import pandas as pd

BASE = "/sessions/stoic-youthful-sagan/mnt/Bruzzone IA/00_BRUZZONE_IA"
SCI = f"{BASE}/01_METODOLOGIA/05_metodologia_referencias_cientificas/01_METODOLOGIA03_REFERENCIAS_CIENTIFICAS"
KML = f"{BASE}/03_GIS/02_capas_base/2026-05-29_LL_GIS_georreferenciacion_olivo_v01.kml.kml"
OUTDIR = f"{BASE}/03_GIS/06_ANALISIS_ESPACIAL"
os.makedirs(OUTDIR, exist_ok=True)
OUT = f"{OUTDIR}/2026-05-29_LL_GIS_arbolado_zonas_manejo_v01.geojson"

# 1. KML
txt = open(KML, encoding="utf-8", errors="ignore").read()
pms = re.findall(r"<Placemark>.*?</Placemark>", txt, re.S)
rows = []
for pm in pms:
    nm = re.search(r"<name>([^<]+)</name>", pm)
    co = re.search(r"<Point>.*?<coordinates>([^<]+)</coordinates>", pm, re.S)
    if not nm or not co: continue
    name = nm.group(1).strip()
    lon, lat, *_ = [float(x) for x in co.group(1).strip().split(",")]
    try: tid = int(name)
    except ValueError: tid = None
    rows.append({"id_arbol": tid, "name": name, "lon": lon, "lat": lat})
kml = pd.DataFrame(rows)
print(f"KML: {len(kml)} olivos | ids validos: {kml['id_arbol'].notna().sum()}")

# 2. NDVI multitemporal
nd = pd.read_csv(f"{SCI}/NDVI_indices/CSV/Datos_NDVI_arbol.csv").rename(columns={"ID Arbol":"id_arbol"})
dcols = list(nd.columns[1:])
nd["ndvi_mean"] = nd[dcols].mean(axis=1)
nd["ndvi_actual"] = nd[dcols[-1]]
nd = nd.drop_duplicates("id_arbol")
ndvi = nd[["id_arbol","ndvi_mean","ndvi_actual"]].copy()

# 2b. K-means oficial
km = pd.read_excel(f"{SCI}/K-means/CSV/DF_puntos_cluster_NDVI.xlsx").rename(columns={"Unnamed: 0":"id_arbol"})
def clase(row):
    for c,col in enumerate(["a_o1","a_o2","a_o3","a_o4"],1):
        if col in row and pd.notna(row[col]): return c, float(row[col])
    return None, None
km[["clase_kmeans","ndvi_kmeans"]] = km.apply(lambda r: pd.Series(clase(r)), axis=1)
km = km[["id_arbol","clase_kmeans","ndvi_kmeans"]].drop_duplicates("id_arbol")

# 3. Rendimiento
bd20 = pd.read_csv(f"{SCI}/Rendimiento/CSV/bd20.csv").rename(columns={"Idshp":"id_arbol","Kg.arbol":"rend_2020"})
r20 = bd20.groupby("id_arbol",as_index=False)["rend_2020"].mean()
bd19 = pd.read_csv(f"{SCI}/Rendimiento/CSV/bd_18-19.csv").rename(columns={"Idshp":"id_arbol","Kg arbol":"rend_2019"})
r19 = bd19.groupby("id_arbol",as_index=False)["rend_2019"].mean()

# 4. Merge
df = kml.merge(km,on="id_arbol",how="left").merge(ndvi,on="id_arbol",how="left").merge(r20,on="id_arbol",how="left").merge(r19,on="id_arbol",how="left")
assert len(df)==len(kml), f"fan-out {len(df)}"

# 5. Zonas
zmap={1:"bajo",2:"medio",3:"medio",4:"alto"}
df["zona_manejo"]=df["clase_kmeans"].map(zmap)
valid=df["ndvi_mean"].dropna(); q33,q66=valid.quantile([1/3,2/3])
def zf(v):
    if pd.isna(v): return None
    if v<q33: return "bajo"
    if v<q66: return "medio"
    return "alto"
m=df["zona_manejo"].isna()
df.loc[m,"zona_manejo"]=df.loc[m,"ndvi_mean"].apply(zf)
df["fuente_zona"]=df["clase_kmeans"].apply(lambda c:"kmeans_oficial" if pd.notna(c) else "tercil_ndvi")

# 6. atributos
df["codigo"]=[f"LL-OLI-{int(t):04d}" if pd.notna(t) else f"LL-OLI-{n}" for t,n in zip(df["id_arbol"],df["name"])]
df["estado"]="sin_monitoreo"
r2=lambda x: None if pd.isna(x) else round(float(x),3)
r1=lambda x: None if pd.isna(x) else round(float(x),1)

# 7. GeoJSON
features=[]
for _,r in df.iterrows():
    props={"codigo":r["codigo"],"id_arbol":int(r["id_arbol"]) if pd.notna(r["id_arbol"]) else None,
        "predio":"Olivar Los Loros","cultivo":"Olivo","variedad":None,
        "lon":round(r["lon"],7),"lat":round(r["lat"],7),
        "zona_manejo":r["zona_manejo"],
        "clase_vigor_kmeans":int(r["clase_kmeans"]) if pd.notna(r["clase_kmeans"]) else None,
        "ndvi":r2(r["ndvi_mean"]),"ndvi_actual":r2(r["ndvi_actual"]),
        "rendimiento_2019":r1(r["rend_2019"]),"rendimiento_2020":r1(r["rend_2020"]),
        "estado":r["estado"],"ultimo_monitoreo":None}
    features.append({"type":"Feature","geometry":{"type":"Point","coordinates":[round(r["lon"],7),round(r["lat"],7)]},"properties":props})

lons=df["lon"].values; lats=df["lat"].values
bbox=[float(lons.min()),float(lats.min()),float(lons.max()),float(lats.max())]
fc={"type":"FeatureCollection","name":"LL_arbolado_zonas_manejo_v01",
    "crs":{"type":"name","properties":{"name":"urn:ogc:def:crs:OGC:1.3:CRS84"}},"bbox":bbox,
    "metadata":{"predio":"Olivar Los Loros","comuna":"Freirina, Region de Atacama, Chile",
        "fecha_proceso":"2026-05-29","n_arboles":int(len(df)),
        "fuente_geom":"KML georreferenciacion (504 olivos)",
        "fuente_ndvi":"Serie NDVI por arbol 2016-2020 (8 fechas)",
        "fuente_rendimiento":"Cosechas 2018-2019 y 2020 (kg/arbol)",
        "fuente_zonas":"Zonificacion K-means oficial (4 clases NDVI) mapeada a 3 zonas de manejo",
        "mapeo_zonas":{"bajo":"Clase 1","medio":"Clases 2-3","alto":"Clase 4"},
        "fallback_terciles_ndvi_medio":{"bajo_<":round(float(q33),3),"medio_<":round(float(q66),3)}},
    "features":features}
json.dump(fc,open(OUT,"w",encoding="utf-8"),ensure_ascii=False)

# 8. diagnostico
print("\n===== DIAGNOSTICO =====")
print(f"Salida: {OUT}")
print(f"Tamano: {os.path.getsize(OUT)/1024:.1f} KB | features: {len(features)}")
print(f"BBox [W,S,E,N]: {[round(x,5) for x in bbox]}")
print(f"\nCobertura (sobre {len(df)} arboles):")
print(f"  NDVI:    {df['ndvi_mean'].notna().sum()} ({100*df['ndvi_mean'].notna().mean():.1f}%)")
print(f"  Rend2019:{df['rend_2019'].notna().sum()} ({100*df['rend_2019'].notna().mean():.1f}%)")
print(f"  Rend2020:{df['rend_2020'].notna().sum()} ({100*df['rend_2020'].notna().mean():.1f}%)")
print(f"  KmeansCl:{df['clase_kmeans'].notna().sum()} ({100*df['clase_kmeans'].notna().mean():.1f}%)")
print(f"\nFuente zona: {df['fuente_zona'].value_counts().to_dict()}")
print("Clase K-means (1=menor..4=mayor vigor):")
print(df['clase_kmeans'].value_counts(dropna=False).sort_index().to_string())
print("\nZonas de manejo:")
print(df["zona_manejo"].value_counts(dropna=False).to_string())
print("\nNDVI medio por zona:")
print(df.groupby("zona_manejo")["ndvi_mean"].agg(["count","mean","min","max"]).round(3).to_string())
print("\nRend 2019 (kg/arbol) por zona:")
print(df.groupby("zona_manejo")["rend_2019"].agg(["count","mean"]).round(1).to_string())
print("\nRend 2020 (kg/arbol) por zona:")
print(df.groupby("zona_manejo")["rend_2020"].agg(["count","mean"]).round(1).to_string())
s19=df.dropna(subset=["ndvi_kmeans","rend_2019"]); s20=df.dropna(subset=["ndvi_kmeans","rend_2020"])
print(f"\ncorr(NDVI kmeans, rend2019)={s19['ndvi_kmeans'].corr(s19['rend_2019']):.3f} (n={len(s19)})")
print(f"corr(NDVI kmeans, rend2020)={s20['ndvi_kmeans'].corr(s20['rend_2020']):.3f} (n={len(s20)})")

stats={"n_arboles":int(len(df)),"q33":float(q33),"q66":float(q66),
    "cov_ndvi":float(df['ndvi_mean'].notna().mean()),"cov_r19":float(df['rend_2019'].notna().mean()),
    "cov_r20":float(df['rend_2020'].notna().mean()),"cov_km":float(df['clase_kmeans'].notna().mean()),
    "fuente_zona":{k:int(v) for k,v in df['fuente_zona'].value_counts().items()},
    "zonas":{str(k):int(v) for k,v in df["zona_manejo"].value_counts(dropna=False).items()},
    "ndvi_por_zona":{k:float(v) for k,v in df.groupby("zona_manejo")["ndvi_mean"].mean().round(3).items()},
    "rend19_por_zona":{k:(None if pd.isna(v) else float(v)) for k,v in df.groupby("zona_manejo")["rend_2019"].mean().round(1).items()},
    "rend20_por_zona":{k:(None if pd.isna(v) else float(v)) for k,v in df.groupby("zona_manejo")["rend_2020"].mean().round(1).items()},
    "bbox":[round(x,6) for x in bbox]}
json.dump(stats,open("/sessions/stoic-youthful-sagan/mnt/outputs/stats.json","w"))
print("\nOK stats guardadas")
