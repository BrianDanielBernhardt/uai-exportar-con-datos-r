# ==============================================================
# INSTALACION INICIAL: ejecutar una sola vez desde RStudio.
# El proyecto necesita conexion a internet en la primera descarga.
# ==============================================================

# Los mapas se construyen con polygons de {maps}.
# {countrycode} permite vincular territorios del mapa con codigos ISO3 del BM.
# Esta alternativa evita instalar paquetes GIS grandes como sf/terra.
paquetes <- c("WDI", "dplyr", "ggplot2", "readr", "maps", "countrycode")
faltan <- paquetes[!vapply(paquetes, requireNamespace, logical(1), quietly = TRUE)]

if (length(faltan) > 0) {
  message("Instalando paquetes: ", paste(faltan, collapse = ", "))
  install.packages(faltan, repos = "https://cloud.r-project.org")
} else {
  message("Todos los paquetes ya estan instalados.")
}

faltantes_finales <- paquetes[!vapply(paquetes, requireNamespace, logical(1), quietly = TRUE)]
if (length(faltantes_finales)) {
  stop("No se instalaron algunos paquetes: ", paste(faltantes_finales, collapse = ", "))
}
message("Instalacion completada. Ejecuta: source('ejecutar_banco_mundial.R')")
