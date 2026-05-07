---sesion 8 

---Ejercicio 1: Escribe un cursor explícito que liste los pedidos con total mayor a 500 y muestre el nombre del cliente asociado, usando un JOIN.


DECLARE
	
    CURSOR pedido_mayor_500 IS
    	SELECT clientes.nombre, pedidos.total FROM Productos
    	WHERE total > 500
    	

	variable_nombre_cliente clientes.nombre%TYPE;
    variable_total_pedido_cliente pedidos.total%TYPE;


BEGIN
	OPEN pedido_mayor_500;
    LOOP
    	FETCH pedido_mayor_500 INTO variable_nombre_cliente, variable_total_pedido_cliente;
    	EXIT WHEN pedido_mayor_500%NOTFOUND;
    	DBMS_OUTPUT.PUT_LINE('Cliente: ' || variable_nombre_cliente || ', Total del Pedido: ' || variable_total_pedido_cliente);
    END LOOP;
    CLOSE pedido_mayor_500;
END;
/


-- Ejercicio 2: Escribe un cursor explícito que aumente un 15% los precios de productos con precio inferior a 1000 
-- y maneje una excepción si falla.


	
DECLARE
	CURSOR aumentar_15_productos IS

    	SELECT productos.nombre, productos.precio FROM Productos
    	WHERE productos.precio < 1000
    	FOR UPDATE;

	variable_nombre productos.nombre%TYPE;
	variable_precio productos.precio%TYPE;
    variable_precio_actualizado NUMBER;

BEGIN
	OPEN aumentar_15_productos;
	LOOP
    	FETCH aumentar_15_productos INTO variable_nombre, variable_precio;
    	EXIT WHEN aumentar_15_productos%NOTFOUND;

        variable_precio_actualizado := variable_precio * 1.15; ---calculo el nuevo precio con el aumento del 15%

    	UPDATE Productos
    	SET precio = variable_precio_actualizado
    	WHERE CURRENT OF aumentar_15_productos;

    	DBMS_OUTPUT.PUT_LINE('Producto ' || variable_nombre || ' actualizado a: ' || variable_precio_actualizado);
	END LOOP;
	CLOSE aumentar_15_productos;

EXCEPTION
	WHEN OTHERS THEN
    	DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
    	IF aumentar_15_productos%ISOPEN THEN
        	CLOSE aumentar_15_productos;
    	END IF;
END;
/


-- Ejercicio 3: Escribe un bloque PL/SQL con un cursor explícito que liste los clientes 
-- cuyo total de pedidos (suma de los valores de Total en la tabla Pedidos) sea mayor a 1000
-- mostrando el nombre del cliente y el total acumulado. Usa un JOIN entre Clientes y Pedidos
-- y agrupa los resultados con GROUP BY.


DECLARE
    CURSOR clientes_con_pedidos_mayores_1000 IS
        SELECT Clientes.Nombre, SUM(Pedidos.Total) AS TotalAcumulado FROM Clientes 
        INNER JOIN Pedidos ON Clientes.ClienteID = Pedidos.ClienteID
        GROUP BY Clientes.Nombre, Clientes.ClienteID
        HAVING SUM(Pedidos.Total) > 1000;

    variable_nombre_cliente Clientes.Nombre%TYPE;
    variable_total_acumulado NUMBER;

BEGIN
    OPEN clientes_con_pedidos_mayores_1000;
    LOOP
        FETCH clientes_con_pedidos_mayores_1000 INTO variable_nombre_cliente, variable_total_acumulado;
        EXIT WHEN clientes_con_pedidos_mayores_1000%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Cliente: ' || variable_nombre_cliente || ', Total Acumulado: ' || variable_total_acumulado);
    END LOOP;
    CLOSE clientes_con_pedidos_mayores_1000;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        IF clientes_con_pedidos_mayores_1000%ISOPEN THEN
            CLOSE clientes_con_pedidos_mayores_1000;
        END IF;
END;
/

-- Ejercicio 4: Escribe un bloque PL/SQL con un cursor explícito que aumente en 1 la cantidad de
-- los detalles de pedidos (DetallesPedidos) asociados a pedidos con
-- fecha anterior al 2 de marzo de 2025 (FechaPedido en la tabla Pedidos).
-- Usa FOR UPDATE para bloquear las filas y maneja excepciones.

DECLARE
	CURSOR detalles_pedidos_anteriores IS
		SELECT DetallePedidos.DetalleID, DetallePedidos.Cantidad, DetallePedidos.PedidoID FROM DetallesPedidos
		INNER JOIN Pedidos ON DetallesPedidos.PedidoID = Pedidos.PedidoID
		WHERE Pedidos.FechaPedido < TO_DATE('2025-03-02', 'YYYY-MM-DD')
		FOR UPDATE of DetallesPedidos.Cantidad;

	variable_cantidad DetallePedidos.Cantidad%TYPE;
	variable_detalle_id DetallePedidos.DetalleID%TYPE;
	variable_fecha_pedido_id Pedidos.FechaPedido%TYPE;
	variable_cantidad_nueva NUMBER;

BEGIN
	OPEN detalles_pedidos_anteriores;
	LOOP
		FETCH detalles_pedidos_anteriores INTO variable_detalle_id, variable_cantidad, variable_fecha_pedido_id;
		EXIT WHEN detalles_pedidos_anteriores%NOTFOUND;

		variable_cantidad_nueva := variable_cantidad + 1; 

		UPDATE DetallesPedidos
		SET Cantidad = variable_cantidad_nueva
		WHERE CURRENT OF detalles_pedidos_anteriores;

		DBMS_OUTPUT.PUT_LINE('Detalle ID: ' || variable_detalle_id || ', Cantidad actualizada a: ' || variable_cantidad_nueva);
	END LOOP;
	CLOSE detalles_pedidos_anteriores;

	COMMIT;
EXCEPTION
	WHEN OTHERS THEN
		DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
		IF detalles_pedidos_anteriores%ISOPEN THEN
			CLOSE detalles_pedidos_anteriores;
		END IF;
END;
/

-- Ejercicio 5: Crea un tipo de objeto cliente_obj con los atributos cliente_id, nombre, 
-- y un método get_info que devuelva una cadena con la información del cliente. 
-- Crea una tabla basada en ese tipo, transfiere los datos de la tabla Clientes a esa tabla, 
-- y escribe un bloque PL/SQL con un cursor explícito que liste la información de los clientes 
-- usando el método get_info.

CREATE OR REPLACE TYPE cliente_obj AS OBJECT (
	cliente_id NUMBER,
	nombre VARCHAR2(100),
	MEMBER FUNCTION get_info RETURN VARCHAR2
);
/

CREATE OR REPLACE TYPE BODY cliente_obj AS 
	MEMBER FUNCTION get_info RETURN VARCHAR2 IS
	BEGIN
		RETURN 'Cliente ID: ' || cliente_id || ', Nombre: ' || nombre;
	END get_info;
END;
/

CREATE TABLE clientes_obj_tab OF cliente_obj (cliente_id PRIMARY KEY);

INSERT INTO clientes_obj_tab (cliente_id, nombre)
SELECT ClienteID, Nombre FROM Clientes;
COMMIT;

DECLARE
	CURSOR clientes_cursor_obj IS
		SELECT cliente_id, nombre FROM clientes_obj_tab;

	variable_cliente cliente_obj;

	BEGIN
	OPEN clientes_cursor_obj;
	LOOP
		FETCH clientes_cursor_obj INTO variable_cliente;
		EXIT WHEN clientes_cursor_obj%NOTFOUND;

		DBMS_OUTPUT.PUT_LINE(variable_cliente.get_info());
	END LOOP;
	CLOSE clientes_cursor_obj;
	
EXCEPTION
	WHEN OTHERS THEN
		DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
		IF clientes_cursor_obj%ISOPEN THEN
			CLOSE clientes_cursor_obj;
		END IF;
END;
/



