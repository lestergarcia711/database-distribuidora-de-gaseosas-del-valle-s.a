USE distribuidora_del_valle;

-- Triggers o disparadores utiles
-- -----------------------------------------------------------
-- 1. Trigger tr_actualizar_stock
-- -----------------------------------------------------------
DELIMITER //

CREATE TRIGGER tr_actualizar_stock
AFTER INSERT ON detalle_pedido
FOR EACH ROW
BEGIN
    DECLARE v_id_sede INT;

    SELECT id_sede 
    INTO v_id_sede 
    FROM pedidos 
    WHERE id_pedido = NEW.id_pedido;

    UPDATE inventario
    SET stock_actual = stock_actual - NEW.cantidad
    WHERE id_producto = NEW.id_producto 
      AND id_sede = v_id_sede;
END //

DELIMITER ;

SELECT id_producto, id_sede, stock_actual 
FROM inventario 
WHERE id_producto = 1 AND id_sede = 1;

-- 2. Insertamos un nuevo detalle de pedido con 10 unidades para un pedido existente de la sede 1
INSERT INTO detalle_pedido (id_pedido, id_producto, cantidad, precio_actual) 
VALUES (1, 1, 10, 12.00);

-- 3. Volvemos a consultar el stock para verificar que se hayan descontado 10 unidades
SELECT id_producto, id_sede, stock_actual 
FROM inventario 
WHERE id_producto = 1 AND id_sede = 1;

-- ----------------------------------------------------------------------------------------
-- 2.Trigger tr_auditar_cambio_precio
-- ----------------------------------------------------------------------------------------  

DELIMITER //

CREATE TRIGGER tr_auditar_cambio_precio
AFTER UPDATE ON productos
FOR EACH ROW
BEGIN

    IF OLD.precio_unitario <> NEW.precio_unitario THEN
        INSERT INTO auditoria_precios (
            id_producto,
            fecha_actualizacion,
            precio_anterior,
            precio_actual
        ) VALUES (
            NEW.id_producto,
            NOW(),
            OLD.precio_unitario,
            NEW.precio_unitario
        );
    END IF;
END //

DELIMITER ;



-- Pruebas de funcionalidad
-- Verificar auditoría de precios

-- 1. Actualizamos el precio de un producto
UPDATE productos 
SET precio_unitario = 15.50 
WHERE id_producto = 1;

-- 2. Consultamos la tabla auditoria_precios para verificar el cambio
SELECT * FROM auditoria_precios;