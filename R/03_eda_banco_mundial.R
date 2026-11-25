# ========================================================================
# CASO 1 - EDA: EXPLORATORY DATA ANALYSIS (ANALISIS EXPLORATORIO)
# Ejecutar: source('R/03_eda_banco_mundial.R')
# Genera exclusivamente imagenes PNG en output/.
# ========================================================================
source("R/00_utilidades.R", encoding = "UTF-8")
comprobar_proyecto()
comprobar_paquetes(c("readr", "dplyr", "ggplot2", "maps", "countrycode"))

bm <- readr::read_csv("data/banco_mundial_2023.csv", show_col_types = FALSE)
variables <- c("pib_per_capita_usd", "poblacion", "crecimiento_pib_pct",
               "importaciones_pib_pct", "importaciones_usd", "usuarios_internet_pct")
if (!all(variables %in% names(bm))) stop("El CSV no contiene todas las variables.")

# ------------------------------------------------------------------------
# GRAFICO 1: ¿Que porcentaje de paises tiene dato para cada variable?
# Tener datos faltantes no equivale a tener un valor igual a cero.
# ------------------------------------------------------------------------
etiquetas <- c("PIB por habitante", "Poblacion", "Crecimiento del PIB",
               "Importaciones / PIB", "Importaciones totales (USD)",
               "Usuarios de internet")
stopifnot(length(etiquetas) == length(variables))
cobertura <- data.frame(
  variable = etiquetas,
  porcentaje = vapply(variables, function(v) 100 * mean(!is.na(bm[[v]])), numeric(1))
)

g1 <- ggplot2::ggplot(cobertura,
                       ggplot2::aes(x = stats::reorder(variable, porcentaje), y = porcentaje)) +
  ggplot2::geom_col(fill = "#22577A", width = .72) +
  ggplot2::coord_flip() +
  ggplot2::geom_text(ggplot2::aes(label = paste0(round(porcentaje, 1), "%")),
                     hjust = -0.1, size = 3.7) +
  ggplot2::scale_y_continuous(limits = c(0, 110), breaks = seq(0, 100, 20)) +
  ggplot2::labs(title = "Disponibilidad de indicadores (2023)",
                subtitle = "Proporcion de paises/territorios con datos observados",
                x = NULL, y = "Paises con dato (%)") +
  ggplot2::theme_minimal(base_size = 13)
guardar_figura(g1, "bm_01_disponibilidad.png")

# ------------------------------------------------------------------------
# GRAFICO 2: distribucion del PIB por habitante.
# Escala logaritmica: permite comparar mejor diferencias muy grandes.
# ------------------------------------------------------------------------
datos_pib <- bm |>
  dplyr::filter(!is.na(pib_per_capita_usd), pib_per_capita_usd > 0)
g2 <- ggplot2::ggplot(datos_pib, ggplot2::aes(x = pib_per_capita_usd)) +
  ggplot2::geom_histogram(bins = 32, fill = "#3182BD", color = "white") +
  ggplot2::scale_x_log10(labels = formatear_numero) +
  ggplot2::labs(title = "Distribucion del PIB por habitante",
                subtitle = "Escala logaritmica en el eje horizontal | 2023",
                x = "PIB per capita (USD corrientes)", y = "Cantidad de paises") +
  ggplot2::theme_minimal(base_size = 13)
guardar_figura(g2, "bm_02_histograma_pib_pc.png")

# ------------------------------------------------------------------------
# GRAFICO 3: relacion entre ingreso y conectividad digital.
# ------------------------------------------------------------------------
datos_scatter <- bm |>
  dplyr::filter(!is.na(pib_per_capita_usd), pib_per_capita_usd > 0,
                !is.na(usuarios_internet_pct))
etiquetas_paises <- c("Argentina", "Brazil", "Chile", "Mexico", "China",
                      "India", "United States", "Italy", "Germany")
g3 <- ggplot2::ggplot(datos_scatter,
  ggplot2::aes(x = pib_per_capita_usd, y = usuarios_internet_pct)) +
  ggplot2::geom_point(alpha = 0.65, color = "#17527C", size = 2.2) +
  ggplot2::geom_text(
    data = dplyr::filter(datos_scatter, country %in% etiquetas_paises),
    ggplot2::aes(label = country), vjust = -0.65, size = 3, check_overlap = TRUE
  ) +
  ggplot2::scale_x_log10(labels = formatear_numero) +
  ggplot2::labs(title = "Ingreso y usuarios de internet",
                subtitle = "Cada punto representa un pais o territorio (2023)",
                x = "PIB per capita (USD; escala logaritmica)",
                y = "Personas que usan internet (%)") +
  ggplot2::theme_minimal(base_size = 13)
guardar_figura(g3, "bm_03_pib_internet.png")

# ------------------------------------------------------------------------
# GRAFICO 4: 15 mayores mercados importadores en dolares corrientes.
# ------------------------------------------------------------------------
top_importaciones <- bm |>
  dplyr::filter(!is.na(importaciones_usd), importaciones_usd > 0) |>
  dplyr::arrange(dplyr::desc(importaciones_usd), country) |>
  dplyr::slice_head(n = 15)
if (nrow(top_importaciones) < 15L) {
  stop("No hay suficientes datos de importaciones absolutas para el top 15.")
}

top_importaciones <- top_importaciones |>
  dplyr::mutate(importaciones_miles_millones = importaciones_usd / 1e9)
g4 <- ggplot2::ggplot(top_importaciones,
  ggplot2::aes(x = stats::reorder(country, importaciones_miles_millones),
               y = importaciones_miles_millones)) +
  ggplot2::geom_col(fill = "#D0A21B", width = 0.70) +
  ggplot2::geom_text(ggplot2::aes(label = format(round(importaciones_miles_millones),
                      big.mark = ".", decimal.mark = ",", trim = TRUE)), hjust = -0.12, size = 3.1) +
  ggplot2::coord_flip() +
  ggplot2::scale_y_continuous(expand = ggplot2::expansion(mult = c(0, 0.19))) +
  ggplot2::labs(title = "Top 15 paises por importaciones totales (2023)",
                subtitle = "Importaciones de bienes y servicios | WDI NE.IMP.GNFS.CD",
                x = NULL, y = "Miles de millones de USD corrientes") +
  ggplot2::theme_minimal(base_size = 12) +
  ggplot2::theme(panel.grid.major.y = ggplot2::element_blank())
guardar_figura(g4, "bm_04_top_importaciones_usd.png", ancho = 11, alto = 7)

# ------------------------------------------------------------------------
# GRAFICO 5: crecimiento economico por region.
# ------------------------------------------------------------------------
datos_region <- bm |>
  dplyr::filter(!is.na(crecimiento_pib_pct), !is.na(region))
g5 <- ggplot2::ggplot(datos_region,
  ggplot2::aes(x = region, y = crecimiento_pib_pct)) +
  ggplot2::geom_boxplot(fill = "#9ECAE1", outlier.color = "#CF5C36") +
  ggplot2::coord_flip() +
  ggplot2::labs(title = "Crecimiento del PIB por region (2023)",
                subtitle = "Distribucion transversal de tasas de crecimiento real",
                x = NULL, y = "Crecimiento anual del PIB (%)") +
  ggplot2::theme_minimal(base_size = 12)
guardar_figura(g5, "bm_05_boxplot_crecimiento_region.png", alto = 7)

# ------------------------------------------------------------------------
# GRAFICO 6: correlaciones de Spearman entre indicadores.
# ------------------------------------------------------------------------
datos_cor <- bm |>
  dplyr::mutate(log_pib_pc = ifelse(pib_per_capita_usd > 0,
                                   log10(pib_per_capita_usd), NA_real_),
                log_poblacion = ifelse(poblacion > 0,
                                      log10(poblacion), NA_real_)) |>
  dplyr::select(log_pib_pc, log_poblacion,
                importaciones_pib_pct, usuarios_internet_pct, crecimiento_pib_pct)
matriz_cor <- stats::cor(datos_cor, method = "spearman", use = "pairwise.complete.obs")
datos_matriz <- as.data.frame(as.table(matriz_cor))
names(datos_matriz) <- c("variable_x", "variable_y", "correlacion")
g6 <- ggplot2::ggplot(datos_matriz,
  ggplot2::aes(x = variable_x, y = variable_y, fill = correlacion)) +
  ggplot2::geom_tile(color = "white") +
  ggplot2::geom_text(ggplot2::aes(label = sprintf("%.2f", correlacion)), size = 3.5) +
  ggplot2::scale_fill_gradient2(low = "#B2182B", mid = "#FFFFFF",
                                 high = "#2166AC", midpoint = 0,
                                 limits = c(-1, 1)) +
  ggplot2::coord_equal() +
  ggplot2::labs(title = "Correlaciones de Spearman",
                subtitle = "Variables macroeconomicas (2023)",
                x = NULL, y = NULL, fill = "Rho") +
  ggplot2::theme_minimal(base_size = 11) +
  ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 45, hjust = 1))
guardar_figura(g6, "bm_06_correlaciones.png", ancho = 10, alto = 7)

# ------------------------------------------------------------------------
# GRAFICO 10: MAPA COROPLETICO DEL PIB POR HABITANTE.
# Ajustes visuales: leyenda vertical y etiquetas compactas para evitar solapes.
# ------------------------------------------------------------------------
mapa_base <- preparar_mapa_mundial()
valores_mapa <- bm |>
  dplyr::transmute(iso3c,
    pib_mapa = dplyr::if_else(!is.na(pib_per_capita_usd) &
       pib_per_capita_usd > 0, pib_per_capita_usd, NA_real_))
mapa_pib <- dplyr::left_join(mapa_base, valores_mapa, by = "iso3c")

cat("\nPaises con PIB per capita valido:", sum(!is.na(valores_mapa$pib_mapa)), "\n")
g10 <- ggplot2::ggplot(mapa_pib,
  ggplot2::aes(x = long, y = lat, group = group, fill = pib_mapa)) +
  ggplot2::geom_polygon(color = "#FFFFFF", linewidth = 0.14) +
  ggplot2::coord_quickmap() +
  ggplot2::scale_fill_gradientn(
    colours = c("#FFF6CF", "#EFCB5D", "#D49C19", "#7B631E", "#28354A"),
    trans = "log10", na.value = "#DCE1E6",
    breaks = c(1000, 5000, 20000, 100000),
    labels = c("1k", "5k", "20k", "100k"),
    name = "PIB por
habitante",
    guide = ggplot2::guide_colorbar(
      title.position = "top", title.hjust = 0.5,
      barheight = grid::unit(4.7, "cm"),
      barwidth = grid::unit(0.55, "cm")
    )
  ) +
  ggplot2::labs(
    title = "PIB por habitante en el mundo (2023)",
    subtitle = "Mapa coropletico | USD corrientes | escala de colores logaritmica",
    caption = "Fuente: Banco Mundial (WDI). Poligonos: paquete maps. Gris = sin dato / sin correspondencia."
  ) +
  ggplot2::theme_void(base_size = 12) +
  ggplot2::theme(
    plot.background = ggplot2::element_rect(fill = "#F7F9FB", color = NA),
    panel.background = ggplot2::element_rect(fill = "#F7F9FB", color = NA),
    legend.position = "right",
    plot.title = ggplot2::element_text(face = "bold", size = 17),
    plot.subtitle = ggplot2::element_text(color = "#44505F"),
    plot.caption = ggplot2::element_text(color = "#6A737F", size = 9),
    plot.margin = ggplot2::margin(8, 15, 8, 15)
  )
guardar_figura(g10, "bm_10_mapa_pib_pc.png", ancho = 13, alto = 7)

cat("\nEDA finalizado: 7 imagenes PNG (6 graficos + 1 mapa) en output/.\n")
