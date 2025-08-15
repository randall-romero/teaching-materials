/*====================================================================
Transforme.do: Cálculo de transformaciones de la serie del PIB de 
Costa Rica.

Universidad de Costa Rica
Escuela de Economía
Curso: EC4301 Macroeconometría
Profesor: Randall Romero Aguilar, PhD
2020-01-22, UPDATED 2025-08-15

Este script es para Stata 17 o superior
======================================================================*/
* Ajustes varios
graph drop _all
set autotabgraphs on

local DATAPATH "https://raw.githubusercontent.com/randall-romero/teaching-materials/master/EC4301-2025b/data/"

* Leer datos del PIB trimestral de Costa Rica
cls



use `DATAPATH'pib, clear


* Indexar datos como serie de tiempo
tsset trimestre, quarterly

local PIBseries Original Desestacionalizado TendenciaCiclo




* Programa para generar varias series con una misma fórmula
capture program drop bulk_generate   
program bulk_generate 
    version 17.0
    syntax varlist, formula(string)
    
    foreach var of varlist `varlist' {
        `formula'
    }
end    




* Programa para crear y unir varios gráficos
capture  program drop figura
program define figura
    version 17.0
    syntax varlist(min=3 max=3) , Title(string) subtitle(string) name(string)
    /*
        Grafica series original, desestacionalizado y tendencia-ciclo una sobre otra
        para ilustrar sus diferencias.
        
        Con líneas verticales se resaltan fechas en que ocurrieron choques adversos.
    */
    

    local figsize ysize(3) xsize(6)
    
    // First plot
    tsline `1', ///
        ytitle("original") ttitle("") tlabel("") ///
        title("") `figsize' ///
		tline(1996q1 1997q3 2009q2 2020q2, lcolor(green)) ///
        name(g1, replace)

    // Second plot
    tsline `2', ///
        ytitle("desestacionalizado") ttitle("") tlabel("") ///
        title("") `figsize' ///
		tline(1996q1 1997q3 2009q2 2020q2, lcolor(green)) ///
        name(g2, replace)

    // Third plot
    tsline `3', ///
        ytitle("tendencia-ciclo") ttitle("") ///
        title("") `figsize' ///
		tline(1996q1 1997q3 2009q2 2020q2, lcolor(green)) ///
        name(g3, replace)

    // Combine them
    graph combine g1 g2 g3, ///
        ycommon col(1) ///
        title("`title'") `figsize' ///
		subtitle("`subtitle'") ///
        name("`name'", replace)

    // Drop the temporary individual graphs
    graph drop g1 g2 g3

end


*-------------------------------------------------------------------------------
* Datos originales
figura `PIBseries' , ///
    title("Series en nivel") ///
    subtitle("billones de colones constantes") ///
    name("pib")


*-------------------------------------------------------------------------------
* Primera diferencia
bulk_generate `PIBseries', formula("generate D_\`var' = D.\`var'")

figura D_Original D_Desestacionalizado D_TendenciaCiclo , ///
    title("Cambio trimestral en el PIB de Costa Rica") ///
    subtitle("billones de colones constantes")  ///
    name("d_pib")


*-------------------------------------------------------------------------------
* Tasa de variación
bulk_generate `PIBseries', formula("generate G_\`var' = 100*D_\`var' / L.\`var'")

figura G_Original G_Desestacionalizado G_TendenciaCiclo , ///
    title("Tasa de crecimiento trimestral del PIB de Costa Rica") ///
    subtitle("por ciento") ///
	name(dpc_pib)


*-------------------------------------------------------------------------------	
* Tasa de variación continua


bulk_generate `PIBseries', formula("generate log\`var' = log(\`var')")
bulk_generate `PIBseries', formula("generate G_log\`var' = 100 * D.log\`var'")
  
figura G_logOriginal G_logDesestacionalizado G_logTendenciaCiclo , ///
    title("Tasa de crecimiento trimestral del PIB de Costa Rica") ///
    subtitle("por ciento") ///
  	name(dlog_pib)

	
*-------------------------------------------------------------------------------	
* Cambio interanual
bulk_generate `PIBseries', formula("generate S4_\`var' = S4.\`var'")

figura S4_Original S4_Desestacionalizado S4_TendenciaCiclo , ///
    title("Cambio interanual en el PIB de Costa Rica") ///
    subtitle("billones de colones constantes") ///
	name(s_pib)
	
	
*-------------------------------------------------------------------------------	
* Tasa de variación interanual
bulk_generate `PIBseries', formula("generate S_log\`var' = 100 * S4.log\`var'")

figura S_logOriginal S_logDesestacionalizado S_logTendenciaCiclo , ///
    title("Tasa de crecimiento interanual del PIB de Costa Rica") ///
    subtitle("por ciento") ///
	name(s_lpib)	
	
	
*-------------------------------------------------------------------------------	
* Serie suavizada
bulk_generate `PIBseries', formula("tssmooth ma MA_\`var' = \`var', window(3 1 0)")


figura MA_Original MA_Desestacionalizado MA_TendenciaCiclo , ///
    title("PIB serie suavizada por media móvil") ///
    subtitle("billones de colones constantes") ///
    name(pib_ma)

    