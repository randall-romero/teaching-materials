/*=======================================================================
Componentes IMAE.do: Descomposición del IMAE por componentes (ingenua).

Universidad de Costa Rica
Escuela de Economía
Curso: EC4301 Macroeconometría
Profesor: Randall Romero Aguilar, PhD
2025-08-17, UPDATED 2025-08-17

Este script es para Stata 17 o superior
========================================================================*/

**# Ajustes varios
cls
graph drop _all
set autotabgraphs on

local DATAPATH "https://raw.githubusercontent.com/randall-romero/teaching-materials/master/EC4301-2025b/data/"

local ylabel ylabel(#3, angle(0) labsize(small))
local tlabel tlabel(, angle(90) labsize(vsmall))
local tclean ttitle(" ") tlabel("") 



* Leemos datos del log-IMAE de Costa Rica (original)
use `DATAPATH'log_imae, clear
generate IMAE = exp(Original)
rename Original logIMAE
drop Tendencia_ciclo

* Indexamos datos como series de tiempo
tsset fecha, monthly


*===============================================================================
* PROGRAMA PARA DESCOMPONER UNA SERIE

capture program drop naive_decompose
program naive_decompose
    args y
    /*
    Descompone la serie `y' en sus cuatro componentes: tendencia, ciclo, 
    estacional, e irregular. 
    
    Descomposición aditiva. 
    */
    
    
    * Step 1: Trend-cycle via centered 3-month moving average
    tssmooth ma trendcycle = `y' , window(6 1 6)
    generate detrended = `y' - trendcycle
    
    
    * Step 2: Use HP filter to separate trend from cycle
    tsfilter hp `y'_cycle = trendcycle, trend(`y'_trend) smooth(14400)
    
   
    * Step 3: Seasonal component via monthly averages
    gen month = month(dofm(fecha))
    egen `y'_seasonal = mean(detrended), by(month)

    * Step 4: Irregular component
    gen `y'_irregular = `y' - trendcycle - `y'_seasonal

    * Clean up intermediate variable
    drop trendcycle detrended month
end


*===============================================================================
* DESCOMPOSICIÓN ADITIVA
naive_decompose IMAE



tsline IMAE_trend, name(g1a) title(Aditivo) ytitle(tendencia) `tclean' `ylabel'
tsline IMAE_cycle, name(g2a) ytitle(ciclo) `tclean' `ylabel'
tsline IMAE_seasonal, name(g3a) ytitle(estacional) `tclean' `ylabel'
tsline IMAE_irregular, name(g4a) ytitle(irregular)  ttitle(" ")   `ylabel' `tlabel'


*===============================================================================
* DESCOMPOSICIÓN MULTIPLICATIVA
naive_decompose logIMAE

foreach var of varlist  logIMAE_* {
    display "Replacing `var'"
    replace `var' = exp(`var')

}

tsline logIMAE_trend, name(g1b) title(Multiplicativo) ytitle(" ") `tclean' `ylabel'
tsline logIMAE_cycle, name(g2b) ytitle(" ") `tclean' `ylabel'
tsline logIMAE_seasonal, name(g3b) ytitle(" ") `tclean' `ylabel'
tsline logIMAE_irregular, name(g4b) ytitle(" ") ttitle(" ") `ylabel' `tlabel'


*===============================================================================
* COMBINAR LOS GRÁFICOS
graph combine g1a g1b g2a g2b g3a g3b g4a g4b, name(components) cols(2)
graph drop g1a g1b g2a g2b g3a g3b g4a g4b
