
USE distribuidora_del_valle;

-- EVENTOS

CREATE TABLE IF NOT EXISTS reporte_ventas_mensual (
    id_reporte INT AUTO_INCREMENT PRIMARY KEY,
    id_sede INT,
    total_ventas DECIMAL(12,2),
    fecha_generacion DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 1.EVENTO PARA RESUMEN MENSUAL

DELIMITER //
CREATE EVENT evt_generar_reporte_mensual
ON SCHEDULE EVERY 1 MONTH
STARTS '2026-04-01 00:00:00'
DO
BEGIN
   INSERT INTO reporte_ventas_mensual(id_sede,total_ventas)
   SELECT 
	    id_sede,
        SUM(total_con_iva)
 FROM pedidos
 WHERE fecha_pedido >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)
 GROUP BY id_sede;
 
 END //
 DELIMITER ;
 
 
 -- SUBCONSULTAS
  -- 1. Identificar Productos con Inventario por debajo del Mínimo
 SELECT 
    p.id_producto,
    p.nombre,
    p.precio_unitario
FROM productos p
WHERE p.id_producto IN (
    SELECT DISTINCT i.id_producto
    FROM inventario i
    WHERE i.stock_actual < i.stock_minimo
);

-- 2 Clientes con Compras Superiores al Promedio General


SELECT 
    c.dpi_cliente,
    c.nombre,
    c.apellido,
    SUM(p.total_con_iva) AS total_gastado
FROM clientes c
JOIN pedidos p ON c.dpi_cliente = p.dpi_cliente
GROUP BY c.dpi_cliente, c.nombre, c.apellido
HAVING SUM(p.total_con_iva) > (
    SELECT AVG(total_con_iva) 
    FROM pedidos
)
ORDER BY total_gastado DESC;

-- STORE PROCEDURES
-- 1. Registrar Pedido y Descontar Stock
DELIMITER //

CREATE PROCEDURE sp_registrar_venta_detalle(
    IN p_id_pedido INT,
    IN p_id_producto INT,
    IN p_cantidad DECIMAL(10,2)
)
BEGIN
    DECLARE v_id_sede INT;
    DECLARE v_precio DECIMAL(10,2);
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error al registrar la venta. Transacción revertida.';
    END;

    START TRANSACTION;

    -- Obtener sede del pedido y precio actual del producto
    SELECT id_sede INTO v_id_sede FROM pedidos WHERE id_pedido = p_id_pedido;
    SELECT precio_unitario INTO v_precio FROM productos WHERE id_producto = p_id_producto;
    
    INSERT INTO detalle_pedido (id_pedido, id_producto, cantidad, precio_actual)
    VALUES (p_id_pedido, p_id_producto, p_cantidad, v_precio);
    
    UPDATE inventario
    SET stock_actual = stock_actual - p_cantidad
    WHERE id_producto = p_id_producto AND id_sede = v_id_sede;

    COMMIT;
END //

DELIMITER ;


 