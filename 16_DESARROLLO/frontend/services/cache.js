// services/cache.js — cache local simple (localStorage) con expiración opcional.
export function cacheSet(key, value){
  try{ localStorage.setItem(key, JSON.stringify({t:Date.now(), v:value})); }catch(_){}
}
export function cacheGet(key, maxAgeMs){
  try{
    const raw = localStorage.getItem(key); if(!raw) return null;
    const {t,v} = JSON.parse(raw);
    if(maxAgeMs && (Date.now()-t)>maxAgeMs) return null;
    return v;
  }catch(_){ return null; }
}
// cola de monitoreos pendientes (modo offline)
export function colaPush(item){ const q=cacheGet("ll_cola_monitoreo")||[]; q.push(item); cacheSet("ll_cola_monitoreo",q); }
export function colaTake(){ const q=cacheGet("ll_cola_monitoreo")||[]; cacheSet("ll_cola_monitoreo",[]); return q; }
