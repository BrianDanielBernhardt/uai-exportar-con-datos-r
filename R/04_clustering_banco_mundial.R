# ========================================================================
# CASO 1 - AGRUPAMIENTO NO SUPERVISADO: K-MEANS
# Ejecutar: source('R/04_clustering_banco_mundial.R')
# Objetivo: agrupar paises por similitud, NO ordenar su atractivo comercial.
# ========================================================================
source("R/00_utilidades.R", encoding = "UTF-8")
comprobar_proyecto()
comprobar_paquetes(c("readr", "dplyr", "ggplot2", "maps", "countrycode"))

bm <- readr::read_csv("data/banco_mundial_2023.csv", show_col_types = FALSE)

preparados <- bm |>
  dplyr::filter(!is.na(pib_per_capita_usd), pib_per_capita_usd > 0,
                !is.na(poblacion), poblacion > 0,
                !is.na(importaciones_pib_pct),
                !is.na(usuarios_internet_pct)) |>
  dplyr::mutate(log_pib_pc = log10(pib_per_capita_usd),
                log_poblacion = log10(poblacion),
                iso2c = countrycode::countrycode(iso3c, origin = "iso3c", destination = "iso2c"))

if (nrow(preparados) < 40L) stop("Pocos paises completos para el ejercicio.")
cat("\nPaises utilizados en clustering:", nrow(preparados), "\n")
cat("Paises excluidos por datos faltantes/no positivos:",
    nrow(bm) - nrow(preparados), "\n")

variables_cluster <- c("log_pib_pc", "log_poblacion",
                       "importaciones_pib_pct", "usuarios_internet_pct")
X <- as.matrix(preparados[, variables_cluster])
X_esc <- scale(X)
stopifnot(all(is.finite(X_esc)))

set.seed(2026)
valores_k <- 2:8
wss <- vapply(valores_k, function(k) {
  stats::kmeans(X_esc, centers = k, nstart = 30, iter.max = 100)$tot.withinss
}, numeric(1))
metodo_codo <- data.frame(k = valores_k, wss = wss)
g7 <- ggplot2::ggplot(metodo_codo, ggplot2::aes(x = k, y = wss)) +
  ggplot2::geom_line(color = "#1B6688", linewidth = 0.9) +
  ggplot2::geom_point(color = "#1B6688", size = 3) +
  ggplot2::scale_x_continuous(breaks = valores_k) +
  ggplot2::labs(title = "Metodo del codo para K-means",
                subtitle = "Menor variabilidad interna no siempre implica mejor interpretacion",
                x = "Cantidad de grupos (k)", y = "Suma de cuadrados intragrupo") +
  ggplot2::theme_minimal(base_size = 13)
guardar_figura(g7, "bm_07_metodo_codo.png")

set.seed(2026)
modelo <- stats::kmeans(X_esc, centers = 3, nstart = 50, iter.max = 100)
preparados$grupo <- factor(modelo$cluster, labels = paste("Grupo", 1:3))

cat("\nTamanos de grupo:\n")
print(table(preparados$grupo))

pca <- stats::prcomp(X_esc, center = FALSE, scale. = FALSE)
coordenadas <- data.frame(
  pc1 = pca$x[, 1], pc2 = pca$x[, 2],
  grupo = preparados$grupo, country = preparados$country, iso2c = preparados$iso2c
)
variancia <- 100 * pca$sdev^2 / sum(pca$sdev^2)
seleccion <- c("Argentina", "Brazil", "Chile", "Mexico", "Germany",
               "Italy", "China", "India", "United States")

# GRAFICO 8: PCA simple con grupos
g8 <- ggplot2::ggplot(coordenadas, ggplot2::aes(x = pc1, y = pc2, color = grupo)) +
  ggplot2::geom_point(size = 2.6, alpha = 0.78) +
  ggplot2::geom_text(
    data = dplyr::filter(coordenadas, country %in% seleccion),
    ggplot2::aes(label = country), vjust = -0.7, size = 3, check_overlap = TRUE,
    show.legend = FALSE
  ) +
  ggplot2::labs(title = "Grupos de paises: K-means (k = 3)",
                subtitle = "PCA utilizada para visualizacion, no para ajustar K-means",
                x = sprintf("Componente 1 (%.1f%% de variacion)", variancia[1]),
                y = sprintf("Componente 2 (%.1f%% de variacion)", variancia[2]),
                color = "Grupo") +
  ggplot2::theme_minimal(base_size = 13)
guardar_figura(g8, "bm_08_clusters_pca.png")

# GRAFICO 9: perfiles de clusters
centros <- as.data.frame(modelo$centers)
centros$grupo <- paste("Grupo", seq_len(nrow(centros)))
perfiles <- do.call(rbind, lapply(variables_cluster, function(v) {
  data.frame(variable = v, grupo = centros$grupo, valor = centros[[v]])
}))
nombres_largos <- c(
  log_pib_pc = "PIB por habitante (log)",
  log_poblacion = "Poblacion (log)",
  importaciones_pib_pct = "Importaciones (% PIB)",
  usuarios_internet_pct = "Usuarios de internet (%)"
)
perfiles$variable <- factor(nombres_largos[perfiles$variable],
                           levels = unname(nombres_largos))
g9 <- ggplot2::ggplot(perfiles,
  ggplot2::aes(x = grupo, y = variable, fill = valor)) +
  ggplot2::geom_tile(color = "white", linewidth = 1) +
  ggplot2::geom_text(ggplot2::aes(label = sprintf("%+.2f", valor)), size = 4) +
  ggplot2::scale_fill_gradient2(low = "#B2182B", mid = "#FFFFFF",
                                 high = "#2166AC", midpoint = 0) +
  ggplot2::labs(title = "Perfil economico de cada grupo",
                subtitle = "Promedios estandarizados (z-scores); no son rankings",
                x = NULL, y = NULL, fill = "Valor z") +
  ggplot2::theme_minimal(base_size = 12)
guardar_figura(g9, "bm_09_perfiles_clusters.png")

# GRAFICO 11: mapa de clusters
mapa_base <- preparar_mapa_mundial()
mapa_clusters <- dplyr::left_join(
  mapa_base,
  preparados |> dplyr::select(iso3c, grupo),
  by = "iso3c"
)

cat("\nPaises incluidos en el clustering:", nrow(preparados), "\n")
g11 <- ggplot2::ggplot(mapa_clusters,
  ggplot2::aes(x = long, y = lat, group = group, fill = grupo)) +
  ggplot2::geom_polygon(color = "#FFFFFF", linewidth = 0.14) +
  ggplot2::coord_quickmap() +
  ggplot2::scale_fill_manual(
    values = c("Grupo 1" = "#E8AC2B", "Grupo 2" = "#24878C",
               "Grupo 3" = "#735EAA"),
    na.value = "#DCE1E6", drop = FALSE, name = "Segmento") +
  ggplot2::labs(
    title = "Segmentacion de paises mediante K-means (k = 3)",
    subtitle = "4 indicadores estandarizados (2023) | geografia solo para visualizar",
    caption = "Fuente: Banco Mundial (WDI). Gris = pais sin cluster / sin correspondencia cartografica.") +
  ggplot2::theme_void(base_size = 12) +
  ggplot2::theme(
    plot.background = ggplot2::element_rect(fill = "#F7F9FB", color = NA),
    panel.background = ggplot2::element_rect(fill = "#F7F9FB", color = NA),
    legend.position = "bottom",
    legend.key.size = grid::unit(0.5, "cm"),
    plot.title = ggplot2::element_text(face = "bold", size = 17),
    plot.subtitle = ggplot2::element_text(color = "#44505F"),
    plot.caption = ggplot2::element_text(color = "#6A737F", size = 9),
    plot.margin = ggplot2::margin(8, 15, 8, 15))
guardar_figura(g11, "bm_11_mapa_clusters.png", ancho = 13, alto = 7)

# GRAFICO 12: biplot del PCA con cargas de variables
rot <- as.data.frame(pca$rotation[, 1:2])
rot$variable <- rownames(rot)
colnames(rot)[1:2] <- c("pc1", "pc2")
rot$etiqueta <- c(
  log_pib_pc = "PIB pc (log)",
  log_poblacion = "Poblacion (log)",
  importaciones_pib_pct = "Import./PIB",
  usuarios_internet_pct = "Internet (%)"
)[rot$variable]

lim_puntos <- max(abs(c(coordenadas$pc1, coordenadas$pc2)), na.rm = TRUE)
lim_flechas <- max(abs(c(rot$pc1, rot$pc2)), na.rm = TRUE)
mult <- 0.78 * lim_puntos / lim_flechas
rot$pc1 <- rot$pc1 * mult
rot$pc2 <- rot$pc2 * mult

g12 <- ggplot2::ggplot(coordenadas, ggplot2::aes(x = pc1, y = pc2, color = grupo)) +
  ggplot2::geom_hline(yintercept = 0, color = "grey85", linewidth = 0.4) +
  ggplot2::geom_vline(xintercept = 0, color = "grey85", linewidth = 0.4) +
  ggplot2::geom_point(size = 2.2, alpha = 0.70) +
  ggplot2::geom_segment(data = rot,
    ggplot2::aes(x = 0, y = 0, xend = pc1, yend = pc2),
    inherit.aes = FALSE, arrow = grid::arrow(length = grid::unit(0.18, "cm")),
    color = "#333333", linewidth = 0.7) +
  ggplot2::geom_text(data = rot,
    ggplot2::aes(x = pc1, y = pc2, label = etiqueta),
    inherit.aes = FALSE, color = "#222222", size = 3.4, vjust = -0.4, show.legend = FALSE) +
  ggplot2::labs(title = "Biplot del PCA con clusters",
                subtitle = "Puntos = paises | Flechas = direccion e intensidad de las variables",
                x = sprintf("Componente 1 (%.1f%% de variacion)", variancia[1]),
                y = sprintf("Componente 2 (%.1f%% de variacion)", variancia[2]),
                color = "Grupo") +
  ggplot2::theme_minimal(base_size = 13)
guardar_figura(g12, "bm_12_clusters_biplot.png", ancho = 10, alto = 7)

# GRAFICO 13: PCA con etiquetas ISO2 para distinguir paises puntuales
destacados_iso2 <- coordenadas |>
  dplyr::filter(!is.na(iso2c), country %in% seleccion)

g13 <- ggplot2::ggplot(coordenadas, ggplot2::aes(x = pc1, y = pc2, color = grupo)) +
  ggplot2::geom_point(size = 2.2, alpha = 0.42) +
  ggplot2::geom_text(
    data = destacados_iso2,
    ggplot2::aes(label = iso2c),
    size = 3.6, fontface = "bold", show.legend = FALSE
  ) +
  ggplot2::labs(title = "Clusters en PCA con etiquetas de pais (ISO2)",
                subtitle = "Se destacan algunos paises de referencia con codigos de dos letras",
                x = sprintf("Componente 1 (%.1f%% de variacion)", variancia[1]),
                y = sprintf("Componente 2 (%.1f%% de variacion)", variancia[2]),
                color = "Grupo") +
  ggplot2::theme_minimal(base_size = 13)
guardar_figura(g13, "bm_13_clusters_iso2.png", ancho = 10, alto = 7)

cat("\nEjemplos de paises por grupo:\n")
for (g in levels(preparados$grupo)) {
  paises <- preparados$country[preparados$grupo == g]
  cat("\n", g, " (", length(paises), " paises): ",
      paste(utils::head(sort(paises), 12), collapse = ", "), "\n", sep = "")
}
cat("\nATENCION: K-means identifica similitud economica, no oportunidad de exportacion.\n")
cat("\nClustering finalizado: 6 imagenes PNG (3 graficos + 1 mapa + 1 biplot + 1 version con ISO2).\n")
