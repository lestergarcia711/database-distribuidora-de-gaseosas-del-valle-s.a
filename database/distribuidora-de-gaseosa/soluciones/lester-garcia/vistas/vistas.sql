USE distribuidora_del_valle;

-- VISTAS UTILES.
-- ------------------------------------------------------------------------
-- 1. Resumen de pedidos por sede
-- ------------------------------------------------------------------------
CREATE OR REPLACE VIEW vista_resumen_pedidos_por_sede AS
SELECT
    s.id_sede,
    s.nombre_sede AS sede,
    s.ubicacion,

    COUNT(p.id_pedido) AS total_pedidos,

    COALESCE(SUM(p.total_sin_iva), 0) AS ventas_sin_iva,

    COALESCE(SUM(p.total_con_iva - p.total_sin_iva),0) AS total_iva,

    COALESCE(SUM(p.total_con_iva), 0) AS ventas_totales_con_iva

FROM sedes AS s
LEFT JOIN pedidos AS p
ON p.id_sede = s.id_sede

GROUP BY s.id_sede, s.nombre_sede, s.ubicacion;
-- VERIFICAR VISTA
SELECT *
FROM vista_resumen_pedidos_por_sede;


-- ------------------------------------------------------------------------
-- 2. Productos con bajo stock
-- ------------------------------------------------------------------------
CREATE OR REPLACE VIEW vista_productos_bajo_stock AS
SELECT
    s.id_sede,
    s.nombre_sede AS sede,
    p.id_producto,
    p.nombre AS producto,
    cat.nombre AS categoria,
    i.stock_actual,
    i.stock_minimo,
    i.stock_minimo - i.stock_actual AS faltante_minimo

FROM inventario AS i
INNER JOIN productos AS p
    ON p.id_producto = i.id_producto
INNER JOIN categorias AS cat
    ON cat.id_categoria = p.id_categoria
INNER JOIN sedes AS s
    ON s.id_sede = i.id_sede

WHERE i.stock_actual <= i.stock_minimo;

-- VERIFICAR VISTA
SELECT *
FROM vista_productos_bajo_stock;

-- ------------------------------------------------------------------------
-- 3. Clientes activos
-- ------------------------------------------------------------------------
CREATE OR REPLACE VIEW vista_clientes_activos AS
SELECT
    c.dpi_cliente,
    CONCAT(c.nombre, ' ', c.apellido) AS cliente,
    c.telefono,
    c.email,
    COUNT(p.id_pedido) AS total_pedidos,
    MAX(p.fecha_pedido) AS ultima_compra,
    COALESCE(SUM(p.total_con_iva), 0) AS total_comprado

FROM clientes AS c
INNER JOIN pedidos AS p
    ON p.dpi_cliente = c.dpi_cliente

GROUP BY c.dpi_cliente, c.nombre, c.apellido, c.telefono, c.email;

-- VERIFICAR VISTA
SELECT *
FROM vista_clientes_activos;
