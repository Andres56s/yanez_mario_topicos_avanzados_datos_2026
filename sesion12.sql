-- Sesion 12

-- Crea una función calcular_total_con_descuento que reciba un PedidoID (parámetro IN) 
-- y devuelva el total del pedido con un descuento del 10% si el total supera 1000. 
-- Usa la función en un procedimiento aplicar_descuento_pedido que actualice el total del pedido.

CREATE OR REPLACE FUNCTION calcular_total_con_descuento (parametro_pedido_id IN NUMBER)
RETURN NUMBER AS
    variable_total NUMBER;
BEGIN
    SELECT Total INTO variable_total
    FROM Pedidos
    WHERE PedidoID = parametro_pedido_id;

    IF variable_total > 1000 THEN
        variable_total := variable_total * 0.9; -- Aplica un descuento del 10%
    END IF;

    RETURN variable_total;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20004, 'Pedido con ID ' || parametro_pedido_id || ' no encontrado.');

END;
/


CREATE OR REPLACE PROCEDURE aplicar_descuento_pedido (parametro_pedido_id IN NUMBER) AS
    variable_total_con_descuento NUMBER;
BEGIN
    variable_total_con_descuento := calcular_total_con_descuento(parametro_pedido_id);

    UPDATE Pedidos
    SET Total = variable_total_con_descuento
    WHERE PedidoID = parametro_pedido_id;

    DBMS_OUTPUT.PUT_LINE('Pedido ID: ' || parametro_pedido_id || ' actualizado con total con descuento: ' || variable_total_con_descuento);
    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        ROLLBACK;
END;
/

-- Crea un trigger validar_cantidad_detalle que se dispare antes de insertar o actualizar 
-- en DetallesPedidos y verifique que la Cantidad sea mayor a 0. Si no, lanza un error.

CREATE OR REPLACE TRIGGER validar_cantidad_detalle
BEFORE INSERT OR UPDATE ON DetallesPedidos
FOR EACH ROW
BEGIN
    IF :NEW.Cantidad <= 0 THEN
        RAISE_APPLICATION_ERROR(-20005, 'La cantidad debe ser mayor a 0. Detalle ID: ' || :NEW.DetalleID);
    END IF;
END;
/

