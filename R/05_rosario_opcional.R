# ========================================================================
# CASO 2 (OPCIONAL) - DATOS DE LA ADUANA DE ROSARIO, AGOSTO DE 2025
# Ejecutar: source('ejecutar_rosario_opcional.R')
# Fuente: archivo Agosto.xlsx aportado para la clase, con IDs anonimizados.
# IMPORTANTE: estados operativos sin validar; NO son totales oficiales.
# ========================================================================
source("R/00_utilidades.R", encoding = "UTF-8")
comprobar_proyecto()
comprobar_paquetes()

archivo <- "data/rosario_agosto_2025_demo.csv"
if (!file.exists(archivo)) {
  stop("No se encontro el dataset de Rosario: consulta el README.")
}
ros <- readr::read_csv(archivo, show_col_types = FALSE,
                       col_types = readr::cols(
                         operacion_id = readr::col_character(),
                         item_id = readr::col_character(),
                         estado = readr::col_character(),
                         capitulo_ncm = readr::col_character(),
                         via_transporte = readr::col_character(),
                         pais_destino = readr::col_character(),
                         fob_usd = readr::col_double(),
                         kg_netos = readr::col_double(),
                         unidad = readr::col_character()
                       ))

cat("\nFilas originales:", nrow(ros), "\n")
cat("Estados de registro (significado operativo a confirmar):\n")
print(table(ros$estado, useNA = "ifany"))

# 1) DIAGNOSTICO: una clave operacion_id + item_id puede aparecer varias veces.
# El conteo de filas NO es el conteo de items diferentes.
ros <- ros |>
  dplyr::mutate(clave = paste(operacion_id, item_id, sep = "__"))
cat("Claves operacion-item distintas:", dplyr::n_distinct(ros$clave), "\n")
cat("Filas con FOB exactamente cero:", sum(ros$fob_usd == 0, na.rm = TRUE), "\n")
cat("Filas con unidad 'No disponible':",
    sum(ros$unidad == "No disponible", na.rm = TRUE), "\n")

# Figura A. Diferentes estados: mostrar el problema sin inventar equivalencias.
estados <- ros |>
  dplyr::count(estado, name = "registros")
ga <- ggplot2::ggplot(estados,
  ggplot2::aes(x = estado, y = registros)) +
  ggplot2::geom_col(fill = "#356C91", width = 0.65) +
  ggplot2::geom_text(ggplot2::aes(label = registros), vjust = -0.4) +
  ggplot2::scale_y_continuous(expand = ggplot2::expansion(mult = c(0, .13))) +
  ggplot2::labs(title = "Estados presentes en los registros",
                subtitle = "No interpretar como cantidades definitivas exportadas",
                x = "Codigo de estado", y = "Filas originales") +
  ggplot2::theme_minimal(base_size = 13)
guardar_figura(ga, "rosario_01_estados.png")

# 2) PARA UNA DEMOSTRACION NO OFICIAL:
# Conservamos una fila por clave. Priorizamos la fila con FOB mas alto,
# pues la fuente contiene muchas filas duplicadas con FOB=0 y sin unidad.
# Esta regla se usa exclusivamente con fines didacticos, y hay que validarla
# antes de cualquier informe o suma oficial.
ros_unicos <- ros |>
  dplyr::arrange(dplyr::desc(fob_usd), dplyr::desc(kg_netos)) |>
  dplyr::distinct(clave, .keep_all = TRUE)

# 3) Seleccionamos SOLO estado AUTO con FOB positivo para una ilustracion.
# No afirmamos que AUTO represente exportaciones efectivamente realizadas.
# Si la UAI confirma otro criterio operativo, se debe revisar este filtro.
ejemplo <- ros_unicos |>
  dplyr::filter(estado == "AUTO", !is.na(fob_usd), fob_usd > 0,
                !is.na(pais_destino), pais_destino != "")
if (nrow(ejemplo) < 50L) stop("Muy pocos registros para el ejercicio opcional.")
cat("Filas en el subconjunto de demostracion (AUTO, FOB > 0):",
    nrow(ejemplo), "\n")

# Figura B. Principales paises segun valor FOB del SUBCONJUNTO AUTO.
destinos <- ejemplo |>
  dplyr::group_by(pais_destino) |>
  dplyr::summarise(fob = sum(fob_usd), .groups = "drop") |>
  dplyr::slice_max(fob, n = 12, with_ties = FALSE)
gb <- ggplot2::ggplot(destinos,
  ggplot2::aes(x = stats::reorder(pais_destino, fob), y = fob / 1e6)) +
  ggplot2::geom_col(fill = "#1D7087") +
  ggplot2::coord_flip() +
  ggplot2::labs(title = "Destinos del subconjunto de demostracion",
                subtitle = "Solo estado AUTO; FOB positivo; NO son totales oficiales",
                x = NULL, y = "FOB declarado (millones de USD)") +
  ggplot2::theme_minimal(base_size = 12)
guardar_figura(gb, "rosario_02_destinos_subconjunto.png", alto = 7)

# Figura C. Capitulos NCM: los primeros dos digitos del codigo arancelario.
capitulos <- ejemplo |>
  dplyr::group_by(capitulo_ncm) |>
  dplyr::summarise(fob = sum(fob_usd), .groups = "drop") |>
  dplyr::slice_max(fob, n = 12, with_ties = FALSE)
gc <- ggplot2::ggplot(capitulos,
  ggplot2::aes(x = stats::reorder(capitulo_ncm, fob), y = fob / 1e6)) +
  ggplot2::geom_col(fill = "#69834C") +
  ggplot2::coord_flip() +
  ggplot2::labs(title = "Capitulos NCM del subconjunto de demostracion",
                subtitle = "Agrupacion por dos digitos; interpretacion operativa pendiente",
                x = "Capitulo NCM (2 digitos)", y = "FOB declarado (millones de USD)") +
  ggplot2::theme_minimal(base_size = 12)
guardar_figura(gc, "rosario_03_capitulos_ncm.png")

# Figura D. Modalidades de transporte.
transportes <- ejemplo |>
  dplyr::group_by(via_transporte) |>
  dplyr::summarise(fob = sum(fob_usd), .groups = "drop")
gd <- ggplot2::ggplot(transportes,
  ggplot2::aes(x = stats::reorder(via_transporte, fob), y = fob / 1e6)) +
  ggplot2::geom_col(fill = "#7B5A90") +
  ggplot2::coord_flip() +
  ggplot2::labs(title = "Transporte en el subconjunto de demostracion",
                subtitle = "FOB de registros AUTO con FOB positivo; NO total oficial",
                x = NULL, y = "FOB declarado (millones de USD)") +
  ggplot2::theme_minimal(base_size = 12)
guardar_figura(gd, "rosario_04_vias_transporte.png")

cat("\nCaso Rosario finalizado. 4 imagenes rosario_*.png en output/.\n")
cat("IMPORTANTE: consultar definiciones AUTO/CANC/PRES/OFIC antes de publicar conclusiones.\n")
