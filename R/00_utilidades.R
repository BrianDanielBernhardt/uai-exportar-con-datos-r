# ==============================================================
# FUNCIONES DE APOYO (no hace falta modificarlas para la clase)
# ==============================================================

# Trabajamos desde la carpeta principal del proyecto, donde estan README y R/.
comprobar_proyecto <- function() {
  if (!file.exists("README.md") || !dir.exists("R") || !dir.exists("data")) {
    stop(paste(
      "Abri el archivo .Rproj en RStudio antes de ejecutar.",
      "Alternativa: en la consola, usa setwd('RUTA_AL_PROYECTO')."
    ))
  }
  invisible(TRUE)
}

comprobar_paquetes <- function(paquetes = c("readr", "dplyr", "ggplot2")) {
  faltan <- paquetes[!vapply(paquetes, requireNamespace, logical(1), quietly = TRUE)]
  if (length(faltan)) {
    stop("Faltan paquetes: ", paste(faltan, collapse = ", "),
         ". Ejecuta: source('R/00_instalar_paquetes.R')")
  }
  invisible(TRUE)
}

guardar_figura <- function(grafico, nombre, ancho = 10, alto = 6) {
  if (!grepl("\\.png$", nombre, ignore.case = TRUE)) {
    stop("La carpeta output/ solo admite archivos PNG.")
  }
  dir.create("output", showWarnings = FALSE, recursive = TRUE)
  ruta <- file.path("output", nombre)
  ggplot2::ggsave(ruta, plot = grafico, width = ancho,
                  height = alto, units = "in", dpi = 160, bg = "white")
  message("Imagen generada: ", ruta)
  invisible(ruta)
}

# Formato numerico legible en ejes sin cambiar las unidades originales.
formatear_numero <- function(x) {
  format(x, big.mark = ".", decimal.mark = ",", scientific = FALSE, trim = TRUE)
}

# ------------------------------------------------------------------------
# MAPAS MUNDIALES PARA LA CLASE (sin necesidad de paquetes GIS complejos)
# {maps} aporta los poligonos, {countrycode} relaciona nombres con ISO3.
# Importante: la cartografia es ilustrativa, NO un mapa de fronteras oficial.
# ------------------------------------------------------------------------
preparar_mapa_mundial <- function() {
  comprobar_paquetes(c("ggplot2", "dplyr", "maps", "countrycode"))

  mapa <- ggplot2::map_data("world")
  nombres_mapa <- unique(mapa$region)
  codigos <- data.frame(region = nombres_mapa, stringsAsFactors = FALSE)
  equivalencias <- c(
    "USA" = "USA", "UK" = "GBR", "Russia" = "RUS",
    "Taiwan" = "TWN", "South Korea" = "KOR", "North Korea" = "PRK",
    "Ivory Coast" = "CIV", "Democratic Republic of the Congo" = "COD",
    "Republic of Congo" = "COG", "Czech Republic" = "CZE",
    "Venezuela" = "VEN", "Vietnam" = "VNM", "Iran" = "IRN",
    "Syria" = "SYR", "Bolivia" = "BOL", "Tanzania" = "TZA",
    "Laos" = "LAO", "Macedonia" = "MKD", "Burma" = "MMR",
    "Kosovo" = "XKX"
  )
  codigos$iso3c <- countrycode::countrycode(
    codigos$region,
    origin = "country.name", destination = "iso3c",
    custom_match = equivalencias, warn = FALSE
  )
  cat("\nMapa: regiones cartograficas sin ISO3 reconocido:",
      sum(is.na(codigos$iso3c)), "de", nrow(codigos), "\n")
  if (sum(!is.na(codigos$iso3c)) < 120) {
    stop("No se pudo asociar suficientes regiones del mapa a codigos ISO3.")
  }
  dplyr::left_join(mapa, codigos, by = "region")
}
