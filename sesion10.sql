-- Sesion 10

-- Crea un procedimiento actualizar_total_pedidos que reciba un ClienteID (parámetro IN) y 
-- un porcentaje de aumento (parámetro IN con valor por defecto 10%). 
-- Aumenta el total de todos los pedidos del cliente en el porcentaje especificado. 
-- Usa un bucle para iterar sobre los pedidos.


CREATE OR REPLACE PROCEDURE actualizar_total_pedidos (pedido_cliente_id IN NUMBER, pedido_porcentaje_aumento IN NUMBER DEFAULT 10) AS
    variable_total NUMBER;

    CURSOR detalles_pedidos_anteriores IS
        SELECT PedidoID, Total FROM Pedidos
        WHERE ClienteID = pedido_cliente_id
        FOR UPDATE;

BEGIN
    FOR pedido IN detalles_pedidos_anteriores LOOP
        
        variable_nuevo_total := pedido.Total * (1 + (pedido_porcentaje_aumento / 100));

        UPDATE Pedidos
        SET Total = variable_nuevo_total
        WHERE CURRENT OF detalles_pedidos_anteriores
        DBMS_OUTPUT.PUT_LINE('Pedido ID: ' || pedido.PedidoID || ' actualizado a: ' || variable_nuevo_total);


    END LOOP;

    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        ROLLBACK; 
END;
/

-- Crea un procedimiento calcular_costo_detalle que reciba un DetalleID (parámetro IN) y 
-- devuelva el costo total del detalle (parámetro IN OUT). El costo se calcula 
-- como Precio * Cantidad (usando las tablas DetallesPedidos y Productos). 
-- Maneja excepciones si el detalle no existe.


CREATE OR REPLACE PROCEDURE calcular_costo_detalle (parametro_detalle_id IN NUMBER, parametro_costo_total IN OUT NUMBER) AS
    variable_precio NUMBER;
    variable_cantidad NUMBER;
BEGIN

    SELECT Productos.Precio, DetallesPedidos.Cantidad
    INTO variable_precio, variable_cantidad
    FROM DetallesPedidos
    INNER JOIN Productos ON DetallesPedidos.ProductoID = Productos.ProductoID
    WHERE DetallesPedidos.DetalleID = parametro_detalle_id;

    parametro_costo_total := variable_precio * variable_cantidad;

    DBMS_OUTPUT.PUT_LINE('Costo total para Detalle ID ' || parametro_detalle_id || ': ' || parametro_costo_total);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Error: Detalle ID ' || parametro_detalle_id || ' no encontrado.');
        parametro_costo_total := NULL; 
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        parametro_costo_total := NULL;
END;
/


