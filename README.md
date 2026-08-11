# Distribuidora de gaseosas del Valle S.A. — Sistema de Gestión de Base de Datos

## Contexto del problema.

**Gaseosas del Valle S.A.** es una empresa distribuidora autorizada de bebidas gaseosas ubicada en el municipio de **Girón**, con planes de expansión hacia **Bucaramanga y Piedecuesta**.

Actualmente, la empresa realiza la gestión de pedidos y el control de inventario mediante hojas de cálculo. Este método ha comenzado a generar diferentes problemas operativos, entre ellos:

* Errores en el registro de información.
* Pérdida o duplicación de datos.
* Dificultades para consultar información histórica.
* Falta de control sobre el stock disponible.
* Ausencia de trazabilidad sobre los cambios de precios.
* Dificultad para consolidar información de ventas por sede y cliente.
* Mayor riesgo de errores al gestionar los pedidos manualmente.

Debido al crecimiento proyectado de la empresa, se plantea la necesidad de reemplazar este sistema basado en hojas de cálculo por una **base de datos relacional desarrollada en MySQL**.

El proyecto busca establecer una estructura organizada, consistente y escalable que permita administrar la información relacionada con los **productos, clientes, pedidos, detalles de pedidos y sedes de distribución**, incorporando mecanismos de automatización y control mediante funciones, triggers y vistas.

---

## 🎯 Objetivo general

Diseñar e implementar una **base de datos relacional en MySQL** que permita gestionar de manera integral los productos, clientes, pedidos y sedes de distribución de Gaseosas del Valle S.A.

La solución también deberá incorporar mecanismos de automatización y control mediante:

* Funciones almacenadas.
* Triggers.
* Vistas.
* Relaciones entre entidades.
* Consultas SQL analíticas.
* Validaciones de inventario.
* Auditoría de cambios.
* Documentación y evidencias de ejecución.

---

## 🎯 Objetivos específicos

El proyecto tendrá como objetivos específicos:

1. Modelar correctamente las entidades principales del sistema y establecer sus relaciones **1:N y 1:1**.

2. Diseñar una estructura de base de datos normalizada que permita almacenar la información de forma organizada y reducir inconsistencias.

3. Implementar funciones para automatizar procesos como:

   * Cálculo del IVA.
   * Validación de disponibilidad de stock.

4. Desarrollar triggers para automatizar procesos relacionados con:

   * Actualización del inventario.
   * Auditoría de cambios de precios.

5. Construir consultas SQL utilizando diferentes herramientas del lenguaje, incluyendo:

   * `JOIN`
   * `GROUP BY`
   * `IN`
   * `LIKE`
   * `BETWEEN`
   * Subconsultas.

6. Crear vistas que permitan consultar información consolidada sobre:

   * Ventas por sede.
   * Productos con bajo stock.
   * Clientes activos.

7. Generar documentación técnica que permita comprender la estructura y funcionamiento de la solución.

8. Presentar evidencias de ejecución de los diferentes componentes implementados.

---

# Alcance del proyecto

El sistema estará enfocado en la gestión de información comercial y logística de la empresa.

Los principales módulos que se trabajarán serán:

### Gestión de productos

Permitirá registrar y administrar los productos comercializados por la empresa.

La información principal será:

* `id_producto`
* `nombre`
* `categoria`
* `precio`
* `volumen_ml`
* `stock_actual`
* `stock_minimo`

Además, se implementarán mecanismos para controlar los cambios de precio y stock.

Los cambios realizados sobre el precio deberán quedar registrados automáticamente en una tabla de auditoría.

---

### 👥 Gestión de clientes

Permitirá almacenar la información de los clientes que realizan pedidos.

Los campos principales serán:

* `id_cliente`
* `nombre_completo`
* `identificacion`
* `direccion`
* `telefono`
* `correo_electronico`

También se implementarán consultas que permitan localizar clientes mediante coincidencias parciales de su nombre utilizando `LIKE`.

---

### Gestión de sedes

El sistema permitirá registrar las diferentes sedes desde las cuales la empresa almacena y despacha sus productos.

Los campos principales serán:

* `id_sede`
* `nombre_sede`
* `ubicacion`
* `capacidad_almacenamiento`
* `encargado`

Cada pedido estará relacionado con la sede desde la cual se realiza el despacho.

Esta estructura permitirá posteriormente analizar el comportamiento de las ventas y pedidos por sede.

---

### Gestión de pedidos

El sistema permitirá registrar los pedidos realizados por los clientes.

Cada pedido tendrá información como:

* `id_pedido`
* `fecha_pedido`
* `id_cliente`
* `id_sede`
* `total_sin_iva`
* `total_con_iva`

Debido a que un pedido puede contener varios productos y un producto puede aparecer en diferentes pedidos, se utilizará una tabla intermedia denominada `detalle_pedido`.

Esta tabla contendrá:

* `id_pedido`
* `id_producto`
* `cantidad`
* `subtotal`

La relación entre pedidos y productos será, por lo tanto, de tipo **N:N**, resuelta mediante `detalle_pedido`.

---

# Automatización mediante funciones

El proyecto incorporará funciones almacenadas mediante `CREATE FUNCTION` para centralizar operaciones que serán utilizadas dentro de la base de datos.

## `fn_calcular_total_con_iva`

Esta función recibirá el identificador de un pedido:

```text
fn_calcular_total_con_iva(id_pedido)
```

Su responsabilidad será calcular el total del pedido aplicando un **IVA del 19%** sobre la suma de los subtotales de sus productos.

La finalidad es evitar realizar este cálculo manualmente y mantener la lógica directamente dentro de la base de datos.

---

## `fn_validar_stock`

Esta función recibirá:

```text
fn_validar_stock(id_producto, cantidad)
```

Su responsabilidad será verificar si existe suficiente stock disponible para atender la cantidad solicitada.

El resultado deberá indicar si la cantidad solicitada puede ser atendida o si el inventario disponible es insuficiente.

---

#  Automatización mediante triggers

Los triggers permitirán ejecutar acciones automáticamente cuando ocurran determinados eventos en las tablas.

## `tr_actualizar_stock`

Este trigger se ejecutará cuando se inserte un nuevo registro en `detalle_pedido`.

Su función será descontar automáticamente del inventario la cantidad de productos vendidos.

De esta manera, el stock se mantendrá actualizado sin necesidad de modificarlo manualmente después de cada pedido.

---

## `tr_auditar_cambio_precio`

Este trigger se ejecutará cuando se actualice el campo `precio` de un producto.

Cada cambio deberá registrarse en la tabla `auditoria_precios`, almacenando información como:

* Producto afectado.
* Precio anterior.
* Nuevo precio.
* Fecha del cambio.

Esto permitirá mantener una trazabilidad histórica de las modificaciones realizadas sobre los precios.

---

# 🔎 Consultas SQL

El proyecto incluirá consultas orientadas a obtener información útil para la gestión comercial y logística.

Se desarrollarán consultas para:

### Inventario

* Consultar productos cuyo stock se encuentre por debajo del mínimo.

### Pedidos por período

* Consultar pedidos realizados entre dos fechas utilizando `BETWEEN`.

### Productos más vendidos

* Identificar los productos con mayor cantidad de unidades vendidas utilizando `JOIN` y `GROUP BY`.

### Actividad de clientes

* Mostrar los clientes junto con la cantidad de pedidos realizados.

### Búsqueda parcial

* Buscar clientes mediante una parte de su nombre utilizando `LIKE`.

### Categorías

* Consultar productos pertenecientes a determinadas categorías utilizando `IN`.

### Cliente con mayor cantidad de pedidos

* Identificar al cliente con mayor número de pedidos mediante una subconsulta.

### Ventas por sede

* Consultar los pedidos y sus respectivos totales agrupados por sede.

Estas consultas permitirán generar información que pueda ser utilizada para analizar el comportamiento de las ventas, los clientes y el inventario.

---

# Vistas de la base de datos

Para facilitar consultas frecuentes y consolidar información importante, se crearán vistas mediante `CREATE VIEW`.

## `vista_resumen_pedidos_por_sede`

Permitirá visualizar información consolidada de los pedidos realizados desde cada sede.

Se mostrará:

* Sede.
* Cantidad total de pedidos.
* Total de ventas.

---

## `vista_productos_bajo_stock`

Permitirá identificar rápidamente los productos cuyo inventario sea igual o inferior al stock mínimo establecido.

La condición principal será:

```sql
stock_actual <= stock_minimo
```

Esta vista facilitará la identificación de productos que requieren atención para evitar problemas de disponibilidad.

---

## `vista_clientes_activos`

Mostrará los clientes que tengan al menos un pedido registrado.

Esta vista permitirá identificar fácilmente los clientes que actualmente tienen actividad dentro del sistema.

---

# 🛠️ Tecnologías

El proyecto será desarrollado utilizando:

* **MySQL** — Sistema gestor de base de datos.
* **SQL** — Lenguaje utilizado para la creación, manipulación y consulta de la información.
* **MySQL Workbench** — Herramienta para administrar y ejecutar los scripts de la base de datos.
* **Git** — Control de versiones del proyecto.
* **GitHub** — Repositorio para almacenar y documentar el proyecto.
* **VisualCode** - Control de versiones con git y github.

---

---

#  Plan de trabajo

El desarrollo del proyecto seguirá una secuencia para evitar construir funcionalidades sobre una estructura incompleta.

---

# Resultado esperado

Al finalizar el proyecto se espera contar con una base de datos relacional funcional que permita a **Gaseosas del Valle S.A.** administrar de manera estructurada sus productos, clientes, pedidos y sedes.

La solución deberá reducir la dependencia de hojas de cálculo y proporcionar mecanismos que permitan:

* Mantener información organizada.
* Controlar el inventario.
* Validar la disponibilidad de productos.
* Automatizar cálculos.
* Actualizar el stock automáticamente.
* Registrar cambios de precios.
* Consultar información comercial.
* Analizar las ventas por sede.
* Identificar productos con bajo inventario.
* Identificar clientes activos.
* Mantener trazabilidad sobre operaciones importantes.

El proyecto también busca aplicar buenas prácticas de diseño de bases de datos y demostrar el uso de funcionalidades de MySQL más allá de las operaciones básicas de `INSERT`, `SELECT`, `UPDATE` y `DELETE`.

---

---

## Nota

La documentación previa a la implementación permite establecer claramente **qué problema se está resolviendo, qué funcionalidades se deben desarrollar, cómo se organizará el proyecto y qué resultado se espera obtener**.

