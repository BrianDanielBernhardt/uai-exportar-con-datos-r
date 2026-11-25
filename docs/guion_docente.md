# Guion para el seminario (120 minutos)

**Modalidad:** mostrar una diapositiva con la pregunta; alternar con RStudio para ejecutar los bloques; volver a la diapositiva para interpretar el grafico. No es necesario que las personas instalen R en vivo.

| Minutos | Actividad | Script | Pregunta disparadora |
|---|---|---|---|
| 0-10 | Motivacion y caso | diapositivas | ¿Que agrega R al analisis de mercados? |
| 10-25 | RStudio e instalacion | `00_instalar_paquetes.R` + `02_introduccion_y_exploracion.R` | ¿Como abrir y revisar un dataset? |
| 25-65 | EDA WDI, paso a paso | `03_eda_banco_mundial.R` | ¿Como se distribuyen las caracteristicas economicas de los paises? |
| 65-100 | Clustering WDI e interpretacion | `04_clustering_banco_mundial.R` | ¿Que perfiles economicos similares podemos encontrar? |
| 100-105 | Preguntas | - | ¿Que limites tiene este tipo de segmentacion? |
| 105-116 | Rosario si alcanza el tiempo | `05_rosario_opcional.R` | ¿Que problemas reales aparecen al tratar exportaciones? |
| 116-120 | Conclusiones y GitHub | README | ¿Como reproducir los resultados en casa? |

## Notas sobre cada figura

- `bm_01_disponibilidad.png`: cada variable puede perder observaciones de forma distinta. En clustering usamos casos completos; se comunica el tamano de muestra.
- `bm_02_histograma_pib_pc.png`: distribución desigual; escala logaritmica; no confundir transformacion de escala con cambio de la unidad de los datos.
- `bm_03_pib_internet.png`: relaciones entre variables; evitar lenguaje causal o predictivo.
- `bm_04_top_importaciones_usd.png`: los mayores importadores de bienes y servicios en USD corrientes. El tamaño no equivale a demanda para un producto concreto.
- `bm_05_boxplot_crecimiento_region.png`: dispersion, mediana y valores atipicos; no inferir relaciones temporales desde un corte transversal.
- `bm_06_correlaciones.png`: correlaciones de Spearman; cada par puede usar distinta cantidad de observaciones por NA.
- `bm_07_metodo_codo.png`: explorar candidatos para k sin suponer que 3 es un optimo demostrado.
- `bm_08_clusters_pca.png`: PCA es una proyeccion; distancias aparentes en dos ejes no resumen toda la agrupacion.
- `bm_09_perfiles_clusters.png`: centros en z-score; interpretar diferencias relativas, sin etiquetas arbitrarias de 'bueno' o 'malo'.
- `bm_10_mapa_pib_pc.png`: paises coloreados segun PIB por habitante. No confundir con importaciones, superficie o poder de compra de un segmento especifico.
- `bm_11_mapa_clusters.png`: los mismos clusters anteriores colocados sobre un mapa. La ubicacion NO se utilizo para construir los grupos.
- `rosario_01_estados.png`: validar las categorias de estado antes de calcular totales.
- `rosario_02_destinos_subconjunto.png`: solo descriptivo de subconjunto AUTO; no totales de exportaciones.
- `rosario_03_capitulos_ncm.png`: composicion por capitulo NCM, sin asignar sectores no verificados.
- `rosario_04_vias_transporte.png`: diferencia entre via registrada y destino fisico de la carga.

## Recomendacion operativa

Antes del encuentro descargar WDI y ejecutar todos los scripts en tu equipo, manteniendo el CSV local. En directo mostrar bloques y graficos guardados. Si falla internet, el CSV local permite continuar.
