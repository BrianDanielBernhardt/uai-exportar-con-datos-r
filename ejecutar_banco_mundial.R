# SCRIPT PRINCIPAL DE LA CLASE: BANCO MUNDIAL (aprox. 75-90 minutos)
# Abrir el archivo .Rproj; en la consola ejecutar:
# source("ejecutar_banco_mundial.R")
# Primera vez: source("R/00_instalar_paquetes.R")

source("R/01_descargar_banco_mundial.R", encoding = "UTF-8")
source("R/02_introduccion_y_exploracion.R", encoding = "UTF-8")
source("R/03_eda_banco_mundial.R", encoding = "UTF-8")
source("R/04_clustering_banco_mundial.R", encoding = "UTF-8")
message("\nBanco Mundial finalizado: 13 imagenes PNG en output/.")
