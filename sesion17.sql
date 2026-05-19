--Sesion 17
/*Crea un usuario user_analista y un rol rol_analista. El rol debe tener permisos para 
consultar (SELECT) todas las tablas de curso_topicos y para insertar (INSERT) en la tabla 
Pedidos. Asigna el rol al usuario y prueba los permisos.*/

---Creamos el rol rol_analista

CREATE ROLE rol_analista IDENTIFIED BY analista56;
GRANT CONNECT TO rol_analista;

--- Creamos roles y asignamos permisos

CREATE ROLE rol_analista;
GRANT SELECT ON Clientes TO rol_analista;
GRANT SELECT ON Pedidos TO rol_analista;
GRANT SELECT ON Productos TO rol_analista;
GRANT SELECT ON DetallesPedidos TO rol_analista;
GRANT INSERT ON Pedidos TO rol_analista;

---Asignamos el rol al usuario user_analista

GRANT rol_analista TO user_analista;

---Probamos los permisos con el usuario user_analista
CONNECT user_analista/analista56;

SELECT * FROM Clientes; 
SELECT * FROM Pedidos; 
SELECT * FROM Productos; 
SELECT * FROM DetallesPedidos; 
INSERT INTO Pedidos (PedidoID, ClienteID, Fecha, Total) VALUES (999, 1, SYSDATE, 100); 
SELECT * FROM Pedidos WHERE PedidoID = 999; -- Verificamos que el nuevo pedido se haya insertado correctamente



--Sesion 17.2
/*Configura auditoría para monitorear las acciones de user_analista al consultar la tabla 
Clientes y al insertar en la tabla Pedidos. Realiza algunas acciones y verifica los 
registros de auditoría.*/


-- Configuramos la auditoría para monitorear las acciones de user_analista

CONNECT sys/administrador56 AS SYSDBA;
AUDIT SELECT ON Clientes BY user_analista;
AUDIT INSERT ON Pedidos BY user_analista;

-- Realizamos algunas acciones con el usuario user_analista
CONNECT user_analista/analista56;
SELECT * FROM Clientes; -- accion de consulta que será auditada
INSERT INTO Pedidos (PedidoID, ClienteID, Fecha, Total) VALUES (1000, 2, SYSDATE, 200); -- accion de inserción que será auditada
SELECT * FROM Pedidos WHERE PedidoID = 1000; -- verificamos que el nuevo pedido se haya insertado correctamente

-- Verificamos los registros de auditoría
CONNECT sys/administrador56 AS SYSDBA;
SELECT USERNAME, ACTION_NAME, TIMESTAMP FROM DBA_AUDIT_TRAIL
WHERE USERNAME = 'USER_ANALISTA' 

