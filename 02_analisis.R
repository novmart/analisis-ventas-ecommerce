# =========================================================
# Proyecto: Análisis de ventas - The Look E-commerce
# Nivel: Básico (conexión + limpieza + gráficos)
# =========================================================

# ---- 1. Paquetes ----
# install.packages(c("bigrquery", "dplyr", "ggplot2", "lubridate", "scales"))
library(bigrquery)
library(dplyr)
library(ggplot2)
library(lubridate)
library(scales)

# ---- 2. Autenticación y conexión a BigQuery ----
# La primera vez te va a abrir el navegador para loguearte con tu cuenta de Google.
# Necesitás un proyecto de Google Cloud (el free tier alcanza para este dataset).

bq_auth()  # autenticación interactiva

proyecto_id <- "TU_PROJECT_ID"  # reemplazar por tu Project ID de Google Cloud

consulta <- "
  SELECT
    oi.id AS item_id,
    oi.order_id,
    DATE(oi.created_at) AS fecha,
    oi.sale_price,
    oi.status,
    p.name AS producto,
    p.category AS categoria,
    u.country AS pais,
    u.gender AS genero,
    u.age AS edad
  FROM `bigquery-public-data.thelook_ecommerce.order_items` oi
  JOIN `bigquery-public-data.thelook_ecommerce.products` p ON oi.product_id = p.id
  JOIN `bigquery-public-data.thelook_ecommerce.users` u ON oi.user_id = u.id
  WHERE DATE(oi.created_at) >= '2023-01-01'
"

tabla <- bq_project_query(proyecto_id, consulta)
datos <- bq_table_download(tabla)

# ---- 3. Limpieza básica ----
datos_limpios <- datos %>%
  filter(!is.na(sale_price), sale_price > 0) %>%       # sacamos precios inválidos
  filter(status != "Cancelled") %>%                     # sacamos cancelados
  mutate(
    fecha = as.Date(fecha),
    mes = floor_date(fecha, "month"),
    categoria = trimws(categoria)
  ) %>%
  distinct(item_id, .keep_all = TRUE)                   # sacamos duplicados

# Vistazo rápido
glimpse(datos_limpios)
summary(datos_limpios$sale_price)

# ---- 4. Ventas totales por mes ----
ventas_mes <- datos_limpios %>%
  group_by(mes) %>%
  summarise(ventas = sum(sale_price), ordenes = n_distinct(order_id))

ggplot(ventas_mes, aes(x = mes, y = ventas)) +
  geom_line(color = "steelblue", linewidth = 1) +
  geom_point(color = "steelblue") +
  scale_y_continuous(labels = dollar_format()) +
  labs(title = "Ventas totales por mes", x = "Mes", y = "Ventas (USD)") +
  theme_minimal()

# ---- 5. Top 10 categorías por ingresos ----
top_categorias <- datos_limpios %>%
  group_by(categoria) %>%
  summarise(ingresos = sum(sale_price)) %>%
  arrange(desc(ingresos)) %>%
  slice_head(n = 10)

ggplot(top_categorias, aes(x = reorder(categoria, ingresos), y = ingresos)) +
  geom_col(fill = "darkorange") +
  coord_flip() +
  scale_y_continuous(labels = dollar_format()) +
  labs(title = "Top 10 categorías por ingresos", x = "Categoría", y = "Ingresos (USD)") +
  theme_minimal()

# ---- 6. Distribución de ventas por país ----
ventas_pais <- datos_limpios %>%
  group_by(pais) %>%
  summarise(ingresos = sum(sale_price)) %>%
  arrange(desc(ingresos)) %>%
  slice_head(n = 10)

ggplot(ventas_pais, aes(x = reorder(pais, ingresos), y = ingresos)) +
  geom_col(fill = "seagreen") +
  coord_flip() +
  scale_y_continuous(labels = dollar_format()) +
  labs(title = "Top 10 países por ingresos", x = "País", y = "Ingresos (USD)") +
  theme_minimal()

# ---- 7. Exportar dataset limpio para Tableau ----
write.csv(datos_limpios, "datos_limpios_ecommerce.csv", row.names = FALSE)
