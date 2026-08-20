USE distribuidora_del_valle;

-- -------------------------------------------------------------
-- 1.fn_calcular_total_con_iva(id_pedido)
-- --------------------------------------------------------------
DROP FUNCTION IF EXISTS fn_calcular_total_con_iva;
DELIMITER //
CREATE FUNCTION fn_calcular_total_con_iva(p_id_pedido INT, p_iva DECIMAL(5,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_subtotal DECIMAL(10,2);
    DECLARE v_total_con_iva DECIMAL(10,2);

    SELECT COALESCE(SUM(cantidad * precio_actual), 0)
    INTO v_subtotal
    FROM detalle_pedido
    WHERE id_pedido = p_id_pedido;

    SET v_total_con_iva = v_subtotal * (1 + ( p_iva/100));

    RETURN v_total_con_iva;
END //

DELIMITER ;

-- prueba
SELECT fn_calcular_total_con_iva(1, 12.00) AS 'Total Calculado Con IVA (Q)';

-- prueba dentro de una consulta
SELECT 
    id_pedido AS No_Pedido,
    fecha_pedido AS Fecha,
    total_con_iva AS Monto_en_Tabla,
    fn_calcular_total_con_iva(id_pedido,12.00) AS 'Monto Recalculado, utilizando la función'
FROM pedidos;

-- --------------------------------------------------------------------------------
-- 2.fn_validar_stock(id_producto, cantidad)
-- ---------------------------------------------------------------------------------
DELIMITER //

CREATE FUNCTION fn_validar_stock(p_id_producto INT, p_cantidad INT)
RETURNS VARCHAR(255)
READS SQL DATA
BEGIN
    DECLARE v_stock_disponible INT;
    DECLARE v_nombre_producto VARCHAR(100);
    DECLARE v_mensaje VARCHAR(255);

    SELECT 
        p.nombre, 
        COALESCE(SUM(i.stock_actual), 0)
    INTO 
        v_nombre_producto, 
        v_stock_disponible
    FROM productos p
    LEFT JOIN inventario i ON p.id_producto = i.id_producto
    WHERE p.id_producto = p_id_producto
    GROUP BY p.nombre;

    IF v_nombre_producto IS NULL THEN
        RETURN 'ERROR: El producto especificado no existe.';
    END IF;

    IF v_stock_disponible >= p_cantidad THEN
        SET v_mensaje = CONCAT('Aun hay stock suficiente para "', 
            v_nombre_producto, '". Disponible: ', v_stock_disponible, ' unidades.');
    ELSE
        SET v_mensaje = CONCAT('ups!: No hay suficiente stock para "', 
            v_nombre_producto, '". Solicitado: ', p_cantidad, ' | Disponible: ', v_stock_disponible);
    END IF;

    RETURN v_mensaje;
END //

DELIMITER ;

-- prueba con stock suficiente.
SELECT fn_validar_stock(3, 10);
-- prueba con stock insuficiente.
SELECT fn_validar_stock(3,80000);
