# Documentación de la funcion, vista, consulta y trigger realizada en el examen

## Descripción general

En este apartado del proyecto de **Distribuidora del Valle** se implementaron diferentes funcionalidades de MySQL con el objetivo de poner a prueba los conocimientos.

Los elementos desarrollados fueron:

1. **Crear una función llamada total_pedidos_cliente_periodo.**

* Una función para calcular el total de pedidos realizados por un cliente durante un período determinado.

2. **Crear una vista llamada vista_clientes_activos**

* Una vista para consultar los clientes que han realizado pedidos recientemente.

3. **Consulta analitica**
* Una consulta analítica para identificar los cinco clientes con mayor valor de compras durante el año actual.

4. **Crear un trigger llamado registrar_nuevo_pedido_trigger**

* Un trigger para registrar automáticamente los nuevos pedidos en una tabla de auditoría.

Estas funcionalidades permiten reducir consultas repetitivas, facilitar el análisis de información y mantener un registro de las operaciones realizadas sobre los pedidos.

---
# Conclusión

Con la implementación de estos elementos se incorporaron funcionalidades que permiten trabajar con la información de la distribuidora de una manera más organizada y automatizada.

La **función** facilita el cálculo de compras por cliente y período, evitando tener que escribir la misma consulta cada vez que se necesite este indicador.

La **vista** permite consultar rápidamente los clientes activos y obtener información resumida sobre sus pedidos.

La **consulta analítica** proporciona información útil para identificar a los clientes con mayor volumen de compras y apoyar procesos de análisis comercial.

Finalmente, el **trigger junto con la tabla de auditoría** permite registrar automáticamente los nuevos pedidos, proporcionando trazabilidad sobre las operaciones realizadas en la base de datos.

En conjunto, estas implementaciones contribuyen a que la base de datos de **Distribuidora del Valle** sea más funcional, automatizada y fácil de consultar.
