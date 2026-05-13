-- SESION 13

-- Crea un procedimiento actualizar_inventario_pedido que reciba un PedidoID (parámetro IN) y 
-- reduzca la cantidad de productos en una tabla Inventario (crea la tabla si no existe) según los detalles del pedido. 
-- Usa savepoints para manejar errores si no hay suficiente inventario.

---Creamos la tabla Inventario
CREATE TABLE Inventario(
    ProductoID INT PRIMARY KEY,
    Cantidad NUMBER
);

INSERT INTO Inventario VALUES (1, 50); -- 50 laptops en inventario
INSERT INTO Inventario VALUES (2, 200); -- 200 mouse en inventario

---Procedimiento 

CREATE OR REPLACE PROCEDURE actualizar_inventario_pedido (parametro_pedido_id IN NUMBER) AS
    CURSOR detalles_cursor IS
        SELECT ProductoID, Cantidad FROM DetallesPedidos
        WHERE PedidoID = parametro_pedido_id;

    variable_producto_id NUMBER;
    variable_cantidad NUMBER;

BEGIN

    FOR detalle IN detalles_cursor LOOP
        variable_producto_id := detalle.ProductoID;
        variable_cantidad := detalle.Cantidad;

        ---Verificamos si hay suficiente inventario para el producto
       SELECT Cantidad INTO variable_cantidad FROM Inventario
        WHERE ProductoID = variable_producto_id;

        SAFEPOINT antes_de_actualizar; ---Creamos un savepoint antes de actualizar el inventario

        IF variable_cantidad < detalle.Cantidad THEN
            RAISE_APPLICATION_ERROR(-20006, 'No hay suficiente inventario para el producto ID: ' || variable_producto_id);
        END IF;

        ---Reducimos la cantidad en el inventario
        UPDATE Inventario
        SET Cantidad = Cantidad - detalle.Cantidad
        WHERE ProductoID = variable_producto_id;

        DBMS_OUTPUT.PUT_LINE('Inventario actualizado para Producto ID: ' || variable_producto_id || '. Cantidad reducida: ' || detalle.Cantidad);
    END LOOP;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Inventario actualizado correctamente para el Pedido ID: ' || parametro_pedido_id);

EXCEPTION 
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Error: Detalles del pedido no encontrados para Pedido ID: ' || parametro_pedido_id);
        ROLLBACK TO antes_de_actualizar; ---Volvemos al savepoint si no se encuentran los detalles del pedido

    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        ROLLBACK TO antes_de_actualizar; ---Volvemos al savepoint en caso de cualquier otro error
END;
/


-- Diseña una tabla de hechos Fact_Pedidos y una dimensión Dim_Ciudad para un Data Warehouse 
-- basado en curso_topicos. Escribe una consulta analítica que muestre el total de ventas por 
-- ciudad y año.


CREATE TABLE Dim_Ciudad (
    CiudadID NUMBER PRIMARY KEY,
    CiudadNombre VARCHAR2(100)
);

INSERT INTO Dim_Ciudad (CiudadID, CiudadNombre)
SELECT ROWNUM, Ciudad FROM (SELECT DISTINCT Ciudad FROM Clientes):

---Tabla de hechos Fact_Pedidos
CREATE TABLE Fact_Pedidos (
    PedidoID NUMBER,
    ClienteID NUMBER,
    CiudadID NUMBER,
    FechaID NUMBER,
    Total NUMBER,
    CONSTRAINT fk_pedido_cliente FOREIGN KEY (ClienteID) REFERENCES Clientes(ClienteID),
    CONSTRAINT fk_pedido_ciudad FOREIGN KEY (CiudadID) REFERENCES Dim_Ciudad(CiudadID),
    CONSTRAINT fk_pedido_tiempo FOREIGN KEY (FechaID) REFERENCES Dim_Tiempo(FechaID)
);


INSERT INTO Fact_Pedidos (PedidoID, ClienteID, CiudadID, FechaID, Total)
SELECT p.PedidoID, p.ClienteID, dc.CiudadID, dt.FechaID, p.Total FROM Pedidos p
JOIN Clientes c ON p.ClienteID = c.ClienteID
JOIN Dim_Ciudad dc ON c.Ciudad = dc.CiudadNombre
JOIN Dim_Tiempo dt ON p.Fecha = dt.Fecha;

---Consulta analítica para mostrar el total de ventas por ciudad y año
SELECT dc.CiudadNombre, dt.Año, SUM(fp.Total) AS Total_Ventas FROM Fact_Pedidos fp
JOIN Dim_Ciudad dc ON fp.CiudadID = dc.CiudadID
JOIN Dim_Tiempo dt ON fp.FechaID = dt.FechaID
GROUP BY dc.CiudadNombre, dt.Año;

