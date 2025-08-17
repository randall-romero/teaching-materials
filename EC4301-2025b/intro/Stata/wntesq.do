drop _all
cls
/*=======================================================================
wntestq.do: Pruebas de ruido blanco.

Universidad de Costa Rica
Escuela de Economía
Curso: EC4301 Macroeconometría
Profesor: Randall Romero Aguilar, PhD
2020-03-07, UPDATED 2025-08-15

Este script es para Stata 17 o superior
========================================================================*/

* Ajustes varios
graph drop _all
set autotabgraphs on

local DATAPATH "https://raw.githubusercontent.com/randall-romero/teaching-materials/master/EC4301-2025b/data/"
frames reset



*///////////////////////////////////////////////////////////////////////////////
*=========EJEMPLO 1> Crecimiento del IMAE de Costa Rica, serie tendencia-ciclo

frame create imae

frame imae {
    * Leemos datos del IMAE de Costa Rica (original y tendencia-ciclo)
    use `DATAPATH'log_imae, clear

    * Indexamos datos como series de tiempo
    tsset fecha, monthly    
    drop if fecha>=ym(2020,1)

    * Calculamos el crecimiento
    generate crecimiento = D.Tendencia_ciclo

    * Graficamos la serie
    tsline crecimiento, name(imae) xtitle(" ") title("Crecimiento del IMAE")

    * Calculamos correlograma, con pruebas Q de Ljung-Box
    corrgram crecimiento, lags(12) noplot
    ac crecimiento, name(rho_imae) 

    * Estadístico de Durbin-Watson
    regress crecimiento
    estat dwatson

}




*///////////////////////////////////////////////////////////////////////////////
*=========EJEMPLO 2> Crecimiento del tipo de cambio Euro/USD

frame create euro

frame euro {
    * Leemos datos de tipo de cambio dólar/euro
    import delimited `DATAPATH'euro.csv

    * Generamos serie de fechas diarias
    generate t = date(fecha,"YMD")
    tsset t, daily
    drop fecha

    * Generamos serie de días hábiles (no hay datos para fin de semana)
    bcal create euro, from(t) replace
    generate fecha = bofd("euro", t)
    format fecha %tbeuro
    tsset fecha
    drop t

    * Calculamos el crecimiento diario
    generate leuro = log(euro)
    generate depreciacion = D.leuro

    * Graficamos la serie
    tsline depreciacion, name(euro) xtitle(" ") title("Crecimiento diario del tipo de cambio Euro/USD")

    * Calculamos correlograma, con pruebas Q de Ljung-Box
    corrgram depreciacion, lags(12) noplot
    ac depreciacion, name(rho_euro) 

    * Estadístico de Durbin-Watson
    regress depreciacion
    estat dwatson

}
