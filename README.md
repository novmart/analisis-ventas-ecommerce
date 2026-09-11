# Análisis de ventas - The Look E-commerce

Proyecto de portfolio: SQL (BigQuery) + R + Tableau.

## Dataset
`bigquery-public-data.thelook_ecommerce` — dataset público y gratuito de BigQuery
que simula una tienda de e-commerce de ropa (órdenes, productos, usuarios, distribución).

## Requisitos
- Cuenta de Google Cloud con un proyecto creado (el free tier de BigQuery alcanza:
  1 TB de consultas gratis por mes).
- R con los paquetes: `bigrquery`, `dplyr`, `ggplot2`, `lubridate`, `scales`.
- Tableau Desktop o Tableau Public.

## Pasos

### 1. SQL (BigQuery)
Abrí `01_consultas_bigquery.sql` en la consola de BigQuery (console.cloud.google.com/bigquery)
y corré las consultas. No necesitás cargar datos: el dataset ya es público.

### 2. R (RStudio)
Abrí `02_analisis.R`. Reemplazá `"TU_PROJECT_ID"` por el ID de tu proyecto de Google Cloud.
El script:
- Se conecta a BigQuery
- Descarga los datos con la consulta consolidada
- Limpia duplicados, precios inválidos y órdenes canceladas
- Genera 3 gráficos básicos (ventas por mes, top categorías, top países)
- Exporta `datos_limpios_ecommerce.csv`

### 3. Tableau
Dos opciones:
- **Conexión directa**: Tableau > Conectar > Google BigQuery > iniciar sesión >
  elegir el dataset `thelook_ecommerce`.
- **Vía CSV**: usar el archivo `datos_limpios_ecommerce.csv` que exporta el script de R.

Armá un dashboard con:
- KPI de ventas totales e ingresos promedio
- Gráfico de línea temporal (ventas por mes)
- Mapa o barras por país
- Ranking de categorías/productos

## Estructura sugerida del repo
```
proyecto_ecommerce/
├── 01_consultas_bigquery.sql
├── 02_analisis.R
├── datos_limpios_ecommerce.csv   (generado por R)
├── dashboard_tableau.twbx        (tu archivo de Tableau)
└── README.md
```

## Conclusiones

**1. El crecimiento en ventas es genuino, no por aumento de precios.**
Entre 2023 y 2026 las ventas mensuales crecieron de forma sostenida, pero el
ticket promedio se mantuvo estable (entre $81 y $88 durante todo el período).
Esto indica que el crecimiento está impulsado por un aumento real en la
cantidad de órdenes (más clientes/compras), no por subas de precio.

**2. Julio 2026 presenta un salto atípico que amerita investigación.**
Mientras el resto de la serie crece de forma gradual, julio 2026 casi duplica
la cantidad de órdenes del mes anterior (4.948 → 8.192). Antes de proyectar
este mes como tendencia, habría que confirmar si el dato está completo o si
responde a un evento puntual (campaña, error de carga, estacionalidad).

**3. Outerwear & Coats y Jeans lideran el ranking de categorías, mientras
que probablemente cada una lidera por una lógica de negocio distinta.**
Outerwear se explica por precio unitario alto (prendas de invierno, más
caras por unidad), mientras que Jeans probablemente lidera por rotación
constante durante todo el año, sin depender de estacionalidad. Una línea de
análisis a futuro es calcular el ingreso promedio por unidad vendida en cada
categoría para confirmar esta hipótesis.

**4. China, Estados Unidos y Brasil concentran el mayor volumen de ingresos
por país.**
China y EE.UU. lideran de forma esperable por tamaño de mercado y nivel de
consumo. Brasil aparece en el top 3 principalmente por volumen de población
(el mercado de e-commerce más grande de Latinoamérica), aunque su ticket
promedio por cliente sea probablemente menor que en mercados europeos —
compensa con cantidad de compradores, no con gasto individual.

**Nota metodológica:** el dataset (`thelook_ecommerce`) es sintético y se
regenera continuamente por Google, por lo que el salto de julio 2026 podría
reflejar una característica del generador de datos más que un patrón real
de negocio. En un proyecto con datos reales de una empresa, este tipo de
anomalía se valida siempre con el equipo antes de reportarla como hallazgo.
