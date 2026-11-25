# Comprobacion sencilla de reproducibilidad DESPUES de ejecutar los scripts.
source("R/00_utilidades.R", encoding = "UTF-8")
comprobar_proyecto()
comprobar_paquetes(c("readr"))
ruta <- "data/banco_mundial_2023.csv"
stopifnot(file.exists(ruta))
bm <- readr::read_csv(ruta, show_col_types = FALSE)
stopifnot(nrow(bm) >= 50, !anyDuplicated(bm$iso3c),
          all(c("country", "year", "region", "pib_per_capita_usd",
                "poblacion", "importaciones_pib_pct", "importaciones_usd", "usuarios_internet_pct") %in% names(bm)),
          all(bm$year == 2023L))
archivos <- list.files("output", full.names = FALSE, all.files = FALSE)
stopifnot(all(grepl("\\.png$", archivos, ignore.case = TRUE)))
figuras_bm <- c(
  "bm_01_disponibilidad.png", "bm_02_histograma_pib_pc.png",
  "bm_03_pib_internet.png", "bm_04_top_importaciones_usd.png",
  "bm_05_boxplot_crecimiento_region.png", "bm_06_correlaciones.png",
  "bm_07_metodo_codo.png", "bm_08_clusters_pca.png",
  "bm_09_perfiles_clusters.png", "bm_10_mapa_pib_pc.png",
  "bm_11_mapa_clusters.png", "bm_12_clusters_biplot.png",
  "bm_13_clusters_iso2.png"
)
stopifnot(all(file.exists(file.path("output", figuras_bm))))
stopifnot(all(file.info(file.path("output", figuras_bm))$size > 1000))
message("VALIDACION EXITOSA: datos BM consistentes, 13 PNG presentes, output/ solo contiene PNG.")
