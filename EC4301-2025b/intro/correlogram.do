/*=======================================================================
correlogram.do: Cálculando el autocorrelograma para el IMAE de Costa Rica.

Universidad de Costa Rica
Escuela de Economía
Curso: EC4301 Macroeconometría
Profesor: Randall Romero Aguilar, PhD
2020-03-05, UPDATED 2025-08-15

Este script es para Stata 17 o superior
========================================================================*/

**# Ajustes varios
cls
graph drop _all
set autotabgraphs on

local DATAPATH "https://raw.githubusercontent.com/randall-romero/teaching-materials/master/EC4301-2025b/data/"


**# Leemos datos del IMAE de Costa Rica (original y tendencia-ciclo)
use `DATAPATH'log_imae, clear

* Indexamos datos como series de tiempo
tsset fecha, monthly

* Graficamos las dos series
twoway (tsline Original) (tsline Tendencia_ciclo), name(niveles) xtitle(" ") ///
	 title("IMAE, evolución histórica")



**# AUTOCORRELOGRAMAS================================================ 
	 
**# Opciones comunes para los gráficos
capture  program drop figura

program define figura 
    args command figtitle figname
    
    local opciones note("") tlabel("") ttitle("") ylabel(-1(0.5)1, format(%3.1f) angle(0) labsize(vsmall)) ytitle(" ") 
    local tticks xlabel(0(12)36, labsize(vsmall)) 
    

    *Serie original
    `command' Original, name(ac_or) `opciones' ytitle("log(IMAE)") title("Original") 
    `command' D.Original, name(ac_d_or) `opciones' ytitle("D.log(IMAE)") 
    `command' S12.Original, name(ac_s12_or) `opciones' `xticks' ytitle("S12.log(IMAE)")
    
    
    *Serie tendencia-ciclo
    `command' Tendencia_ciclo, name(ac_tc) `opciones' title("Tendencia-ciclo")    
    `command' D.Tendencia_ciclo, name(ac_d_tc) `opciones'
    `command' S12.Tendencia_ciclo, name(ac_s12_tc) `opciones' 

    * Combinar los gráficos
    graph combine ac_or ac_tc ac_d_or ac_d_tc ac_s12_or ac_s12_tc, xcommon ycommon ///
        name(`figname') title(`figtitle') cols(2) imargin(tiny)

    graph drop ac_or ac_tc ac_d_or ac_d_tc ac_s12_or ac_s12_tc

end


**# Autocorrelogramas
figura ac "Autocorrelograma del IMAE en Costa Rica" autoc


**# Autocorrelogramas parciales
figura pac "Autocorrelograma parcial del IMAE en Costa Rica" pautoc



*=================================================================================
*=================================================================================
* ¿Es el crecimiento del IMAE ruido blanco?
* Pruebas de Ljung-Box
corrgram D.Tendencia_ciclo, lags(12)
