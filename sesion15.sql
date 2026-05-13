---sesion 15 

---Crea un índice compuesto en la tabla DetallesPedidos para las columnas PedidoID y ProductoID. 
---Luego, escribe una consulta que use este índice y analiza su plan de ejecución.

---Creamos el índice compuesto
CREATE INDEX idx_pedido_producto ON DetallesPedidos (PedidoID, ProductoID);

---Consulta que usa el indice
EXPLAIN PLAN FOR
SELECT * FROM DetallesPedidos
WHERE PedidoID = 101 AND ProductoID = 1;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

---ejecutamos la consulta para verificar que se use el índice
SELECT * FROM DetallesPedidos
WHERE PedidoID = 101 AND ProductoID = 1;


---Crea una tabla Ventas particionada por hash usando la columna ClienteID (4 particiones). 
---Inserta datos de Pedidos y escribe una consulta que muestre el total de ventas por cliente, verificando que las particiones se usen.


---Creamos la tabla Ventas particionada por hash
CREATE TABLE Ventas (
    VentaID NUMBER PRIMARY KEY,
    ClienteID NUMBER,
    Total NUMBER,
    FechaVenta DATE
)
PARTITION BY HASH (ClienteID) PARTITIONS 4;

---Insertamos datos de Pedidos en la tabla Ventas
INSERT INTO Ventas (VentaID, ClienteID, Total, FechaVenta)
SELECT PedidoID, ClienteID, Total, Fecha FROM Pedidos;

---Consultamos que usa las particiones
EXPLAIN PLAN FOR
SELECT ClienteID, SUM(Total) AS Total_Ventas FROM Ventas
GROUP BY ClienteID;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

---ejecutamos la consulta para verificar que se usen las particiones
SELECT ClienteID, SUM(Total) AS Total_Ventas FROM Ventas
GROUP BY ClienteID;
