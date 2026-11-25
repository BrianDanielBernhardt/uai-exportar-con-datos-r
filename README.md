# Exportar con éxito: análisis de datos e inteligencia comercial con R

**Seminario UAI · Let's Talk — 3 de diciembre de 2026**  
**Expositor:** Brian Daniel Bernhardt  
**Modalidad:** demostración de R/RStudio, orientada a estudiantes de comercio internacional.

Este repositorio acompaña la charla *«Exportar con éxito: la importancia de la correcta gestión de los datos. Análisis de casos»*. El caso principal utiliza los **World Development Indicators del Banco Mundial (2023)** para realizar análisis exploratorio (EDA), gráficos, mapas y segmentación de países con **K-means**. El código y los comentarios están en español.

## Cómo reproducir el caso principal

1. Instalar primero [R](https://cran.r-project.org/) y después [RStudio Desktop](https://posit.co/download/rstudio-desktop/).
2. Descargar este repositorio en ZIP o clonarlo. Abrir **`Seminario_UAI_2026.Rproj`** en RStudio.
3. En la consola, ejecutar:

```r
source("R/00_instalar_paquetes.R", encoding = "UTF-8")
source("ejecutar_banco_mundial.R", encoding = "UTF-8")
source("validar_resultados.R", encoding = "UTF-8")
```

El archivo **`data/banco_mundial_2023.csv` ya está incluido**, por lo que no se necesita volver a descargarlo para reproducir los resultados. El script de descarga reutiliza esta copia salvo que se defina `ACTUALIZAR_BM <- TRUE` en R. La instalación de paquetes sí requiere conexión a internet.

El caso principal produce **13 figuras PNG** en `output/`, que también se incluyen aquí. **No se guardan tablas en `output/`**: los resultados tabulares se muestran en consola.

Para enseñar o aprender paso a paso, abrir los scripts de `R/` y ejecutar bloques en orden (Ctrl+Enter en Windows/Linux, Cmd+Enter en macOS).

## Contenido del proyecto

| Carpeta o archivo | Contenido |
|---|---|
| `R/01_descargar_banco_mundial.R` | Indicadores oficiales WDI y copia local. |
| `R/02_introduccion_y_exploracion.R` | Exploración inicial de un dataset. |
| `R/03_eda_banco_mundial.R` | Disponibilidad, histogramas, importaciones totales, correlaciones y mapa coroplético. |
| `R/04_clustering_banco_mundial.R` | Estandarización, método del codo, K-means, PCA, biplot, códigos ISO2 y mapa de clusters. |
| `R/05_rosario_opcional.R` | Código del ejemplo complementario del Observatorio, condicionado a acceso autorizado a los datos. |
| `data/banco_mundial_2023.csv` | Datos WDI de 2023 utilizados en el seminario. |
| `output/` | Las 13 imágenes del Banco Mundial. |
| `slides/` | Carpeta prevista para el PDF de la presentación. |
| `docs/` | Diccionario de variables y guion docente. |
| `validar_resultados.R` | Comprobación básica de datos y figuras. |

## Presentación

El PDF de la clase se puede incorporar como `slides/Exportar_con_exito.pdf`. **Antes de publicarlo**, verificar que está permitido difundir las figuras basadas en datos del Observatorio de Exportaciones de Rosario que aparecen en el caso opcional.

## Caso adicional: Aduana de Rosario

El ejercicio sobre registros de agosto de 2025 es **opcional**. Su CSV no está incluido ni autorizado para redistribución pública en este repositorio. Para ejecutarlo, se necesita disponer legítimamente de `data/rosario_agosto_2025_demo.csv` y consultar las variables descritas en `docs/diccionario_variables.md`. No debe confundirse el registro de la *Aduana de Rosario* con todo el movimiento físico del *Puerto de Rosario*. Los estados administrativos y los criterios de cálculo de valores FOB deben validarse antes de formular conclusiones oficiales.

## Interpretación y limitaciones

- El ranking de importaciones utiliza **importaciones de bienes y servicios en USD corrientes** (`NE.IMP.GNFS.CD`): no mide demanda por un producto particular.
- El clustering se ajusta sobre cuatro variables transformadas y estandarizadas; `k = 3` se adopta con finalidad didáctica, no como un número óptimo demostrado.
- PCA proyecta los resultados a dos dimensiones **para visualizarlos**, no se utiliza para calcular los grupos.
- La similitud económica no equivale por sí sola a atractivo comercial: hacen falta indicadores sectoriales, restricciones, aranceles y logística.
- Los indicadores del Banco Mundial pueden ser revisados; conservar el CSV de esta versión permite reproducir los resultados trabajados.

**Fuentes:** [World Bank — World Development Indicators](https://databank.worldbank.org/source/world-development-indicators) y cartografía del paquete R `maps`.

**Derechos y licencias:** no se asigna por defecto una licencia de reutilización al código. Los datos y gráficos derivados de terceros pueden estar sujetos a condiciones de uso independientes. Se recomienda establecer una licencia de software una vez decidido cómo compartir los scripts.
