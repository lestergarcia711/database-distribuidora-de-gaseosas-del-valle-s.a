USE distribuidora_del_valle;

-- -------------------------------------------------------------
-- 1.fn_calcular_total_con_iva(id_pedido)

-- IVA DEL PEDIDO(12%) A PARTIR DE LA SUMA DE SUBTOTALES.
-- --------------------------------------------------------------

DELIMITER //

CREATE FUNCTION fn_calcular_total_con_iva(p_id_pedido INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_subtotal DECIMAL(10,2);
    DECLARE v_total_con_iva DECIMAL(10,2);

    -- Sumamos la venta total de todos los productos en el pedido
    SELECT COALESCE(SUM(cantidad * precio_actual), 0)
    INTO v_subtotal
    FROM detalle_pedido
    WHERE id_pedido = p_id_pedido;

    -- Calculamos el total agregando el 12% de IVA (Subtotal * 1.12)
    SET v_total_con_iva = v_subtotal * 1.12;

    RETURN v_total_con_iva;
END //

DELIMITER ;

-- caso para prueba individual para un pedido
SELECT fn_calcular_total_con_iva(1) AS 'Total Calculado Con IVA (Q)';


-- caso dentro de una consulta normal

SELECT 
    id_pedido AS 'No. Pedido',
    fecha_pedido AS 'Fecha',
    total_con_iva AS 'Monto en Tabla',
    fn_calcular_total_con_iva(id_pedido) AS 'Monto Recalculado con Función'
FROM pedidos;

-- --------------------------------------------------------------------------------
-- 2.fn_validar_stock(id_producto, cantidad)

-- REtorna un mensaje indicando si hay suficiente stock antes de confiram el pedido
-- ---------------------------------------------------------------------------------
DELIMITER //

CREATE FUNCTION fn_validar_stock(p_id_producto INT, p_cantidad INT)
RETURNS VARCHAR(100)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_stock_disponible INT;
    DECLARE v_nombre_producto VARCHAR(100);
    DECLARE v_mensaje VARCHAR(100);

    -- 1. Obtenemos el nombre del producto
    SELECT nombre 
    INTO v_nombre_producto
    FROM productos
    WHERE id_producto = p_id_producto;

    -- Si el producto no existe en el catálogo
    IF v_nombre_producto IS NULL THEN
        RETURN 'ERROR: El producto especificado no existe.';
    END IF;

    -- 2. Sumamos el stock disponible en todas las sedes para este producto
    SELECT COALESCE(SUM(stock_actual), 0)
    INTO v_stock_disponible
    FROM inventario
    WHERE id_producto = p_id_producto;

    -- 3. Evaluamos si el stock disponible cubre la cantidad requerida
    IF v_stock_disponible >= p_cantidad THEN
        SET v_mensaje = CONCAT('OK: Stock suficiente para "', 
        v_nombre_producto, '". Disponible: ', v_stock_disponible, ' unidades.');
    ELSE
        SET v_mensaje = CONCAT('ALERTA: Stock insuficiente para "',
        v_nombre_producto, '". Solicitado: ', p_cantidad, ' | Disponible: ', v_stock_disponible);
    END IF;

    RETURN v_mensaje;
END //

DELIMITER ;

-- CASO PRUEBA DENTRO D UN STOCK DISPNIBLE
SELECT fn_validar_stock(1, 50) AS 'Resultado Validación';

-- CASO PRUEBA DENTRO DE UN STOCK CON CANTIDAD EXCESIVA.

SELECT fn_validar_stock(1, 99999) AS 'Resultado Validación';
