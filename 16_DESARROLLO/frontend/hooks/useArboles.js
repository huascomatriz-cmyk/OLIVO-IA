// hooks/useArboles.js — hook (React) para cargar árboles con estado de carga/error/modo.
// Stub listo para la migración a React; en el HTML vivo se usa services/dataService directamente.
import { useEffect, useState } from "react";
import { obtenerArboles } from "../services/dataService.js";
export function useArboles(idPredio, fallbackFC){
  const [data,setData]=useState(null); const [modo,setModo]=useState("cargando"); const [error,setError]=useState(null);
  useEffect(()=>{ let vivo=true;
    obtenerArboles(idPredio, fallbackFC).then(r=>{ if(!vivo)return; setData(r.fc); setModo(r.modo); })
      .catch(e=>vivo&&setError(e));
    return ()=>{vivo=false;}; },[idPredio]);
  return { data, modo, error };
}
