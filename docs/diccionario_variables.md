# Diccionario de variables y procedencia

## Banco Mundial (World Development Indicators, WDI)

Ano utilizado: **2023** para todos los indicadores. Las cifras pueden ser revisadas por el Banco Mundial. El archivo `data/banco_mundial_2023.csv` se genera al ejecutar el proyecto por primera vez.

| Variable del CSV | Indicador WDI | Descripcion y unidad |
|---|---|---|
| `country` | Metadata WDI | Nombre del pais/territorio |
| `iso3c` | Metadata WDI | Codigo de 3 letras |
| `year` | Metadata WDI | Ano de referencia |
| `region` | Metadata WDI | Region del Banco Mundial; agregados excluidos |
| `pib_per_capita_usd` | `NY.GDP.PCAP.CD` | PIB por habitante, USD corrientes |
| `poblacion` | `SP.POP.TOTL` | Poblacion total, personas |
| `crecimiento_pib_pct` | `NY.GDP.MKTP.KD.ZG` | Crecimiento anual del PIB real, porcentaje |
| `importaciones_pib_pct` | `NE.IMP.GNFS.ZS` | Importaciones de bienes y servicios como porcentaje del PIB |
| `importaciones_usd` | `NE.IMP.GNFS.CD` | Importaciones de bienes y servicios, USD corrientes (valor absoluto) |
| `usuarios_internet_pct` | `IT.NET.USER.ZS` | Personas que utilizan internet como porcentaje de poblacion |

API: https://api.worldbank.org/v2/ · WDI: https://data.worldbank.org/ · Paquete: https://cran.r-project.org/package=WDI

**Observacion:** un pais o territorio. La muestra para clustering usa solo casos completos de 4 variables: `log10(pib_per_capita_usd)`, `log10(poblacion)`, `importaciones_pib_pct`, `usuarios_internet_pct`. Se excluyen PIB/poblacion no positivos y faltantes.

## Rosario (extracto de Agosto.xlsx aportado por el usuario)

| Variable de demostracion | Procedencia | Observacion |
|---|---|---|
| `operacion_id` | Identificador original | Recodificado como `OP000001`, etc. No permite recuperar el numero original. |
| `item_id` | Item | Numero del item. Junto con operacion_id puede repetirse entre filas. |
| `estado` | Estado | Codigos AUTO, CANC, PRES, OFIC; significado por validar. |
| `capitulo_ncm` | NCM-SIM | Solo primeros 2 digitos; categorias de productos a nivel capitulo. |
| `via_transporte` | Via Transporte | Modalidad declarada, segun la fuente. |
| `pais_destino` | Pais de Destino | Destino comercial declarado. |
| `fob_usd` | U$S FOB | Valor declarado, no necesariamente total de exportaciones efectivas. |
| `kg_netos` | Kgs. Netos | Masa neta consignada en la fila. |
| `unidad` | Unidad | Incluye 'No disponible'; no confundir vacio/ausente con cero. |

**Datos no incluidos:** nombre de exportador, localidad, identificadores oficiales, marcas, descripciones arancelarias completas y otros datos innecesarios para los ejercicios. El registro pertenece a la Aduana de Rosario y no puede considerarse automaticamente todo el Puerto de Rosario.

**Mapas:** el emparejamiento usa codigos ISO3 y fronteras del paquete `maps`; no siempre hay correspondencia exacta para territorios y la cartografia es ilustrativa, no normativa.
