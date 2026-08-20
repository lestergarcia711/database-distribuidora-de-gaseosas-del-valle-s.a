USE distribuidora_del_valle;
-- Consultas utiles en la base de datos
-- -------------------------------------------------------------
-- 1. CONSULTAR LOS PRODUCTOS CON stock por debajo del minimo
-- --------------------------------------------------------------
SELECT 
    s.nombre_sede AS Sede,
    p.nombre AS Producto,
    i.stock_actual AS Stock_Actual,
    i.stock_minimo AS Stock_Mínimo,
    (i.stock_minimo - i.stock_actual) AS Faltante_para_Mínimo
FROM inventario i
INNER JOIN productos p ON i.id_producto = p.id_producto
INNER JOIN sedes s ON i.id_sede = s.id_sede
WHERE i.stock_actual < i.stock_minimo
ORDER BY s.nombre_sede, (i.stock_minimo - i.stock_actual) DESC;


-- ------------------------------------------------------------------
-- 2. Consultar los pedidos realizados entre dos fechas(between).
-- ---------------------------------------------------------------------
SELECT
    p.id_pedido AS pedido,
    p.fecha_pedido AS fecha_pedido,
    c.nombre AS nombre_cliente,
    s.nombre_sede AS nombre_sede,
    p.total_sin_iva AS total_sin_iva,
    p.total_con_iva AS total_con_iva
FROM pedidos p
INNER JOIN clientes c ON p.dpi_cliente = c.dpi_cliente
INNER JOIN sedes s ON p.id_sede = s.id_sede
WHERE p.fecha_pedido BETWEEN "2026-02-10" AND "2026-02-20"
ORDER BY p.fecha_pedido ASC;
-- -----------------------------------------------------------------
-- 3. Listar los productos mas vendidos (con join y group by).
 -- ----------------------------------------------------------------  
 -- El limit para mostrar productos fue de 4.Por lo quemuestra solo los 4 pedidos mas vendidos.
 SELECT 
    p. id_producto AS codigo,
    p.nombre AS Producto,
    cat.nombre AS categoria,
    SUM(dp.cantidad) AS total_Unidades_Vendidas,
    CONCAT('Q ', FORMAT(SUM(dp.cantidad * dp.precio_actual), 2)) AS total_recaudado_sin_IVA
FROM detalle_pedido dp
INNER JOIN productos p ON dp.id_producto = p.id_producto
INNER JOIN categorias cat ON p.id_categoria = cat.id_categoria
GROUP BY p.id_producto, p.nombre, cat.nombre
ORDER BY SUM(dp.cantidad) DESC
LIMIT 4;

-- ----------------------------------------------------------------------
-- 4. Mostrar clientes y la cantidad de pedidos realizados
-- ------------------------------------------------------------------------

SELECT 
    c.dpi_cliente AS codigo_cliente,
    c.nombre AS Cliente,
    c.telefono AS Teléfono,
    c.estado AS Estado,
    COUNT(p.id_pedido) AS Total_Pedidos_Realizados,
    CONCAT('Q ', FORMAT(SUM(p.total_con_iva), 2)) AS 'Monto Total Comprado (Con IVA)'
FROM clientes c
INNER JOIN pedidos p ON c.dpi_cliente = p.dpi_cliente
GROUP BY c.dpi_cliente, c.nombre, c.telefono, c.estado
ORDER BY COUNT(p.id_pedido) DESC;

-- -----------------------------------------------------------------------------
-- 5.Buscar clientes por nombre parcial usando LIKE
-- -----------------------------------------------------------------------------
SELECT 
    dpi_cliente AS Código_cliente,
    nombre AS Nombre_o_Negocio,
    direccion AS Dirección,
    telefono AS Teléfono,
    email AS Correo,
    estado AS Estado
FROM clientes
WHERE nombre LIKE '%tienda%' OR apellido LIKE '%Pérez%'
ORDER BY nombre ASC;

-- -------------------------------------------------------------------------------
-- 6. consultar productos de ciertas categotias usando IN
-- --------------------------------------------------------------------------------
SELECT 
    p.id_producto AS Código,
    p.nombre AS Producto,
    c.nombre AS Categoría,
    CONCAT('Q ', p.precio_unitario) AS Precio_Unitario,
    CONCAT(p.volumen_ml, ' ml') AS Presentación
FROM productos p
INNER JOIN categorias c ON p.id_categoria = c.id_categoria
WHERE c.nombre IN ('Gaseosas Zero/Light', 'Aguas Minerales y Seltzers')
ORDER BY c.nombre ASC, p.precio_unitario DESC;

-- -------------------------------------------------------------------------------
-- 7. MOSTRAR EL CLIENTE CON MAYOR NUMERO DE PEDIDOS.
-- --------------------------------------------------------------------------------
SELECT 
    c.dpi_cliente AS Código_cliente,
    c.nombre AS cliente_o_negocio,
    c.telefono AS Teléfono,
    c.email AS Correo,
    COUNT(p.id_pedido) AS Total_Pedidos_Realizados
FROM clientes c
INNER JOIN pedidos p ON c.dpi_cliente = p.dpi_cliente
GROUP BY c.dpi_cliente, c.nombre, c.telefono, c.email
ORDER BY COUNT(p.id_pedido) DESC
LIMIT 1;

-- -------------------------------------------------------------------------------
-- 8. Consultar pedidos y sus totales agrupados por sede
-- --------------------------------------------------------------------------------
SELECT 
    s.nombre_sede AS Sede,
    COUNT(p.id_pedido) AS Total_Pedidos,
    CONCAT('Q ', FORMAT(COALESCE(SUM(p.total_con_iva), 0), 2)) AS Ventas_Totales
FROM sedes s
LEFT JOIN pedidos p ON s.id_sede = p.id_sede
GROUP BY s.id_sede, s.nombre_sede
ORDER BY COALESCE(SUM(p.total_con_iva), 0) DESC;