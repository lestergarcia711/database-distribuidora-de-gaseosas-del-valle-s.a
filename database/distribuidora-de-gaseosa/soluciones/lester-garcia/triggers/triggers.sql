USE distribuidora_del_valle;

-- Triggers utiles o disparadores
-- -----------------------------------------------------------
-- 1. Trigger tr_actualizar_stock
-- Este trigger se ejecuta después de insertar un nuevo renglón en detalle_pedido.
-- Toma el id_producto, busca en qué id_sede se realizó el pedido (consultando la tabla pedidos)
-- y le resta la cantidad vendida al stock_actual en la tabla inventario.
-- -----------------------------------------------------------
DELIMITER //

CREATE TRIGGER tr_actualizar_stock
AFTER INSERT ON detalle_pedido
FOR EACH ROW
BEGIN
    DECLARE v_id_sede INT;

    -- 1. Obtenemos el ID de la sede a la que pertenece el pedido recién insertado
    SELECT id_sede 
    INTO v_id_sede 
    FROM pedidos 
    WHERE id_pedido = NEW.id_pedido;

    -- 2. Descontamos la cantidad vendida del stock actual de esa sede
    UPDATE inventario
    SET stock_actual = stock_actual - NEW.cantidad
    WHERE id_producto = NEW.id_producto 
      AND id_sede = v_id_sede;
END //

DELIMITER ;

-- Pruebas de funcionalidad
-- 1: Verificar actualización automática de stock

-- 1. Consultamos el stock actual de un producto (ej. id_producto = 1 en la sede 1)
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
-- Este trigger se ejecuta antes o después de actualizar un registro en la tabla productos.
-- Compara si el precio unitario cambió y,de ser así, inserta un registro histórico en 
-- la tabla auditoria_precios, la cual fue creada con este proposito.
-- ----------------------------------------------------------------------------------------

DELIMITER //

CREATE TRIGGER tr_auditar_cambio_precio
AFTER UPDATE ON productos
FOR EACH ROW
BEGIN
    -- Verificamos si hubo una modificación real en el precio del producto
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