# ========================================================================
# CASO 1 - DESCARGA DE INDICADORES DEL BANCO MUNDIAL (WDI)
# Ejecutar: source('R/01_descargar_banco_mundial.R')
# Primera ejecucion: requiere internet. Luego se utiliza el CSV en data/.
# Para volver a descargar: ACTUALIZAR_BM <- TRUE, y ejecutar el script.
# ========================================================================

source("R/00_utilidades.R", encoding = "UTF-8")
comprobar_proyecto()
comprobar_paquetes(c("WDI", "dplyr", "readr"))

ANIO_BM <- 2023L  # Mismo ano para todos: comparacion transversal.
ruta_bm <- file.path("data", paste0("banco_mundial_", ANIO_BM, ".csv"))
if (!exists("ACTUALIZAR_BM", inherits = TRUE)) ACTUALIZAR_BM <- FALSE

# Si alguien conservo el CSV de una version anterior, faltara importaciones_usd.
# Comprobamos solo la cabecera para no leer todos los datos innecesariamente.
columnas_obligatorias <- c(
  "country", "iso3c", "year", "region", "pib_per_capita_usd", "poblacion",
  "crecimiento_pib_pct", "importaciones_pib_pct", "importaciones_usd",
  "usuarios_internet_pct"
)
cache_actualizada <- FALSE
if (file.exists(ruta_bm)) {
  columnas_cache <- names(readr::read_csv(ruta_bm, n_max = 0, show_col_types = FALSE))
  cache_actualizada <- all(columnas_obligatorias %in% columnas_cache)
  if (!cache_actualizada) {
    message("El CSV local es de una version anterior y no contiene ",
            "todas las columnas necesarias. Se descargara de nuevo.")
  }
}

if (file.exists(ruta_bm) && !isTRUE(ACTUALIZAR_BM) && cache_actualizada) {
  message("Copia local encontrada: ", ruta_bm)
  message("Se utiliza la copia fija para mantener los resultados de la clase.")
} else {
  message("Descargando indicadores WDI de ", ANIO_BM, " ...")

  # Cada codigo corresponde a una variable publicada por el Banco Mundial.
  indicadores <- c(
    pib_per_capita_usd = "NY.GDP.PCAP.CD",       # PIB per capita, USD corrientes
    poblacion = "SP.POP.TOTL",                  # Poblacion total
    crecimiento_pib_pct = "NY.GDP.MKTP.KD.ZG",  # Crecimiento anual real del PIB (%)
    importaciones_pib_pct = "NE.IMP.GNFS.ZS",   # Bienes y servicios (% del PIB)
    importaciones_usd = "NE.IMP.GNFS.CD",       # Bienes y servicios, USD corrientes
    usuarios_internet_pct = "IT.NET.USER.ZS"    # Personas que usan internet (%)
  )

  datos_descargados <- tryCatch(
    WDI::WDI(country = "all", indicator = indicadores,
             start = ANIO_BM, end = ANIO_BM, extra = TRUE),
    error = function(e) stop("No fue posible actualizar el CSV del Banco Mundial: ",
                             conditionMessage(e),
                             ". Conecta el equipo a internet y ejecuta nuevamente ",
                             "R/01_descargar_banco_mundial.R. ",
                             "El CSV anterior (si existia) permanece sin modificar.")
  )

  columnas_necesarias <- c("country", "iso3c", "year", "region", names(indicadores))
  faltantes <- setdiff(columnas_necesarias, names(datos_descargados))
  if (length(faltantes)) stop("Faltan columnas devueltas por WDI: ",
                             paste(faltantes, collapse = ", "))

  # La API incluye agregados regionales; NO son paises y se deben excluir.
  datos_paises <- datos_descargados |>
    dplyr::filter(!is.na(region), region != "Aggregates",
                  !is.na(iso3c), nchar(iso3c) == 3L) |>
    dplyr::select(dplyr::all_of(columnas_necesarias)) |>
    dplyr::arrange(country)

  if (nrow(datos_paises) < 50L) {
    stop("La descarga devuelve menos de 50 paises; no se guardo el archivo.")
  }
  readr::write_csv(datos_paises, ruta_bm, na = "")
  message("Descarga finalizada: ", nrow(datos_paises), " paises/territorios.")
  message("Fuente: World Bank, World Development Indicators. Consultado: ", Sys.Date())
}
