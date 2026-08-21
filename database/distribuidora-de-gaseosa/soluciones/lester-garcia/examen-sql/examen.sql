USE distribuidora_del_valle;

-- FUNCION 
-- 1. Crear una función llamada total_pedidos_cliente_periodo.

DELIMITER //
CREATE FUNCTION fn_total_pedidos_cliente_periodo(
    p_id_cliente INT,
    p_fecha_inicio DATE,
    P_fecha_final DATE
    )
    RETURNS DECIMAL(10,2)
     NOT DETERMINISTIC
    READS SQL DATA
    BEGIN
    
    DECLARE v_monto_total DECIMAL(10,2);
     SELECT
         COALESCE(SUM(total_con_iva), 0.00) 
         INTO v_monto_total
         FROM pedidos
         WHERE dpi_cliente = p_id_cliente
         AND fecha_pedido BETWEEN p_fecha_inicio AND p_fecha_final;
         
         RETURN v_monto_total;
    END //
    DELIMITER ;
    
    SELECT fn_total_pedidos_cliente_periodo(3,'2026-01-01', '2026-01-28')
    AS Total_pedidos_por_cliente;

-- VISTA
-- -----------------------------------------------------------
-- Crear una vista llamada vista_clientes_activos
-- -----------------------------------------------------------

CREATE OR REPLACE VIEW vista_clientes_activos AS
SELECT
     c.dpi_cliente,
     CONCAT(c.nombre, ' ', c.apellido)AS nombre_cliente,
     COUNT(p.id_pedido)AS total_pedidos,
     COALESCE(SUM(p.total_con_iva), 0) AS valor_total_comprado
     FROM clientes c 
     INNER JOIN pedidos p 
         ON c.dpi_cliente = p.dpi_cliente
	 WHERE p.fecha_pedido >= CURRENT_DATE - INTERVAL 90 DAY 
     GROUP BY
            c.dpi_cliente,
            c.nombre,
            c.apellido;
            
-- VERIFICAR LA VISTA     
SELECT * FROM vista_clientes_activos;

-- CONSULTA ANALITICA
-- --------------------------------------------------------------------------------
-- Liste los cinco clientes con mayor valor total en pedidos durante el año actual.
-- --------------------------------------------------------------------------------
SELECT 
         c.dpi_cliente AS codigo_cliente,
         c.nombre AS cliente,
         COUNT(p.id_pedido) AS cantidad_pedidos,
         SUM(p.total_con_iva) AS total_comprado
FROM clientes c 
INNER JOIN pedidos p 
        ON c.dpi_cliente = p.dpi_cliente
WHERE YEAR(p.fecha_pedido)= YEAR(CURRENT_DATE)
GROUP BY
       c.dpi_cliente,
       c.nombre
ORDER BY total_comprado DESC
LIMIT 5;

-- TRIGGER
-- -----------------------------------------------------------------------------
-- Crear un trigger llamado registrar_nuevo_pedido_trigger
-- ----------------------------------------------------------------------------
-- Para poder ejecutar el triggers es necesario crear 
-- la tabla auditoria_pedido

CREATE TABLE IF NOT EXISTS auditoria_pedido (
id_auditoria INT PRIMARY KEY AUTO_INCREMENT,
id_pedido INT NOT NULL,
dpi_cliente INT NOT NULL ,
fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP,
total_pedido DECIMAL (10,2) NOT NULL,
usuario_responsable VARCHAR(100)
);

---
DELIMITER // 
CREATE TRIGGER registrar_nuevo_pedido_trigger
AFTER INSERT ON pedidos
FOR EACH ROW
BEGIN
     INSERT INTO auditoria_pedido(id_pedido, dpi_cliente, total_pedido, usuario_responsable
       )VALUES
       (NEW.id_pedido, NEW.dpi_cliente, NEW.total_con_iva, USER()
       );
END //
DELIMITER ;

-- prueba

INSERT INTO pedidos(dpi_cliente, id_sede, fecha_pedido, total_sin_iva, total_con_iva)values
(2, 1, CURRENT_DATE(), 100.00, 112.00);

SELECT * FROM auditoria_pedido;