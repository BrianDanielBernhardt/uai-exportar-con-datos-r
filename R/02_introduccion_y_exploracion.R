# ========================================================================
# CASO 1 - PRIMEROS PASOS EN R Y EXPLORACION DE LOS DATOS
# Ejecutar: source('R/02_introduccion_y_exploracion.R')
# ========================================================================
source("R/00_utilidades.R", encoding = "UTF-8")
comprobar_proyecto()
comprobar_paquetes()

ruta <- "data/banco_mundial_2023.csv"
if (!file.exists(ruta)) stop("Primero ejecuta R/01_descargar_banco_mundial.R")

# 1) Leer el archivo CSV. No hay rutas absolutas de Windows/Mac.
bm <- readr::read_csv(ruta, show_col_types = FALSE)

# 2) ¿Cuantas observaciones y cuantas columnas hay?
cat("\nCantidad de paises/territorios:", nrow(bm), "\n")
cat("Cantidad de variables:", ncol(bm), "\n")

# 3) Revisar las primeras filas, nombres y tipos de variables.
print(utils::head(bm, 6))
print(names(bm))
str(bm)

# 4) Diferenciar variable numerica y categorica.
# country es texto, pib_per_capita_usd es un numero.
print(summary(bm$pib_per_capita_usd))
print(table(is.na(bm$pib_per_capita_usd)))

# 5) Ejemplo de filtro: paises con PIB per capita superior a USD 20.000.
paises_ejemplo <- bm |>
  dplyr::filter(!is.na(pib_per_capita_usd), pib_per_capita_usd > 20000) |>
  dplyr::select(country, pib_per_capita_usd) |>
  dplyr::arrange(dplyr::desc(pib_per_capita_usd))
cat("\nEjemplo de filtro (solo se muestra en consola):\n")
print(utils::head(paises_ejemplo, 10))

# No se exportan tablas: los resultados tabulares quedan en la consola.
