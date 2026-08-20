DROP DATABASE IF EXISTS distribuidora_del_valle;
CREATE DATABASE distribuidora_del_valle;
USE distribuidora_del_valle;

CREATE TABLE clientes(
dpi_cliente INT PRIMARY KEY AUTO_INCREMENT,
nombre VARCHAR(60)NOT NULL,
apellido VARCHAR(60),
direccion VARCHAR(90),
telefono INT NOT NULL,
email VARCHAR(80)UNIQUE NOT NULL,
estado VARCHAR(20) DEFAULT 'Activo' CHECK (estado IN ("Activo","Inactivo", "Suspendido"))
)ENGINE = INNODB;

CREATE TABLE categorias(
id_categoria INT PRIMARY KEY AUTO_INCREMENT,
nombre VARCHAR(80) NOT NULL,
descripcion TEXT
)ENGINE = INNODB;

CREATE TABLE productos(
id_producto INT PRIMARY KEY AUTO_INCREMENT,
nombre VARCHAR(80)NOT NULL,
id_categoria INT NOT NULL,
precio_unitario DECIMAL(6,2) NOT NULL,
volumen_ml DECIMAL(5,1) NOT NULL,
FOREIGN KEY(id_categoria) REFERENCES categorias(id_categoria)
)ENGINE = INNODB;

CREATE TABLE sedes(
id_sede INT PRIMARY KEY AUTO_INCREMENT,
nombre_sede VARCHAR(70)NOT NULL,
ubicacion VARCHAR(200) NOT NULL,
capacidad_almacenamiento INT NOT NULL
)ENGINE = INNODB;

CREATE TABLE encargado(
id_encargado INT PRIMARY KEY AUTO_INCREMENT,
nombre VARCHAR(60)NOT NULL,
apellido VARCHAR(60)NOT NULL,
id_sede INT NOT NULL,
FOREIGN KEY(id_sede) REFERENCES sedes(id_sede)
)ENGINE = INNODB;

CREATE TABLE inventario(
id_inventario INT PRIMARY KEY AUTO_INCREMENT,
id_producto INT NOT NULL,
id_sede INT NOT NULL,
stock_actual INT NOT NULL,
stock_minimo INT CHECK(stock_minimo>0),
FOREIGN KEY(id_producto)REFERENCES productos(id_producto),
FOREIGN KEY(id_sede) REFERENCES sedes(id_sede)
)ENGINE = INNODB;

CREATE TABLE pedidos(
id_pedido INT PRIMARY KEY AUTO_INCREMENT,
dpi_cliente INT NOT NULL,
id_sede INT NOT NULL,
fecha_pedido DATE NOT NULL,
total_sin_iva DECIMAL(7,2)NOT NULL,
total_con_iva DECIMAL(7,2) NOT NULL,
FOREIGN KEY(dpi_cliente)REFERENCES clientes(dpi_cliente),
FOREIGN KEY(id_sede)REFERENCES sedes(id_sede)
)ENGINE = INNODB;

CREATE TABLE detalle_pedido(
id_detalle INT PRIMARY KEY AUTO_INCREMENT,
id_pedido INT,
id_producto INT NOT NULL,
cantidad DECIMAL(10,2),
precio_actual DECIMAL(10,2),
FOREIGN KEY(id_pedido)REFERENCES pedidos(id_pedido),
FOREIGN KEY(id_producto)REFERENCES productos(id_producto) 
)ENGINE=INNODB;

CREATE TABLE auditoria_precios(
id_auditoria INT PRIMARY KEY AUTO_INCREMENT,
id_producto INT NOT NULL,
fecha_actualizacion DATETIME NOT NULL,
precio_anterior DECIMAL(10,2),
precio_actual DECIMAL(10,2),
FOREIGN KEY(id_producto)REFERENCES productos(id_producto)
)ENGINE= INNODB;