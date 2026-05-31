// services/dataService.js — capa de datos: orquesta API + cache + fallback.
import * as api from "../lib/api.js";
import { cacheGet, cacheSet } from "./cache.js";

const FALLBACK_KEY = "ll_arboles_fallback";

// Devuelve árboles: live -> cache -> fallback embebido (param)
export async function obtenerArboles(idPredio, fallbackFC){
  try{
    const fc = await api.getArboles(idPredio);
    cacheSet(FALLBACK_KEY, fc);          // refresca cache
    return { fc, modo: "live" };
  }catch(err){
    const cached = cacheGet(FALLBACK_KEY);
    if(cached) return { fc: cached, modo: "cache" };
    return { fc: fallbackFC, modo: "demo" };
  }
}
export const registrar = api.registrarMonitoreo;
export const kpis = api.getKpisPredio;
export const catalogo = api.getEstadosCatalogo;
export const historial = api.getHistorialArbol;
