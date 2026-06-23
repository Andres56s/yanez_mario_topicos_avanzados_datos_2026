/*Transacción: Se refiere a una unidad de trabajo lógica compuesta por un conjunto de operaciones 
en la base de datos que deben confirmarse de forma conjunta (éxito total) o deshacerse por completo 
(fallo total).

Garantía de integridad (Propiedades ACID):

- Atomicidad: Principio de "todo o nada". Si ocurre un fallo en medio del proceso, la transacción 
se cancela y se revierte (rollback) al estado inicial.
- Consistencia: Asegura que cualquier cambio lleve a la base de datos de un estado válido a otro 
igualmente válido, respetando todas las reglas de integridad y restricciones existentes.
- Aislamiento (Isolation): Garantiza que las operaciones concurrentes se ejecuten de manera 
independiente. Los datos modificados no serán visibles para otros usuarios hasta que la transacción finalice.
- Durabilidad: Valida que una vez aplicados los cambios (commit), estos se registren de forma 
permanente en el sistema de almacenamiento, resistiendo posibles fallas eléctricas o reinicios.
*/

SET SERVEROUTPUT ON;

CREATE OR REPLACE PROCEDURE registrar_pedido (
    p_cliente_id   IN NUMBER,
    p_total        IN NUMBER,
    p_fecha_pedido IN DATE
) AS
    v_conteo_cliente NUMBER;
BEGIN
    -- Establecemos punto de control inicial
    SAVEPOINT punto_inicio_pedido;
    
    -- Verificación de la existencia del cliente
    SELECT COUNT(*) INTO v_conteo_cliente
    FROM Clientes
    WHERE ClienteID = p_cliente_id;
    
    IF v_conteo_cliente = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'El cliente especificado no existe en el sistema.');
    END IF;
    
    -- Inserción del nuevo registro de pedido
    INSERT INTO Pedidos (PedidoID, ClienteID, Total, FechaPedido)
    VALUES ((SELECT COALESCE(MAX(PedidoID), 0) + 1 FROM Pedidos), p_cliente_id, p_total, p_fecha_pedido);
    
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        -- Retornamos al punto de control antes de limpiar
        ROLLBACK TO punto_inicio_pedido;
        DBMS_OUTPUT.PUT_LINE('Se ha producido un error: ' || SQLERRM || '. Reversión ejecutada.');
        ROLLBACK;
END;
/

/*
Data Warehouse: Es un almacén de datos centralizado y estructurado para la recopilación de información 
histórica y consolidada de diversas áreas operativas, cuyo fin exclusivo es facilitar el análisis 
de negocio y la toma de decisiones estratégicas (Business Intelligence).

Diferencias estructurales y de propósito frente a una BD Operativa:

Propósito:
- Base de datos operativa (OLTP): Orientada al negocio diario. Maneja transacciones rápidas de 
escritura, actualización y lectura en tiempo real para procesos cotidianos.
- Data Warehouse (OLAP): Orientado al análisis de tendencias a largo plazo. Está optimizado para 
ejecutar consultas complejas sobre volúmenes masivos de datos históricos.

Estructura:
- Base de datos operativa: Altamente normalizada (generalmente hasta la 3ra Forma Normal) para 
eliminar redundancias y asegurar la rapidez y consistencia en escrituras frecuentes.
- Data Warehouse: Desnormalizado intencionalmente. Emplea modelos específicos de consulta masiva 
(como el esquema Estrella o Copo de Nieve) para acelerar los tiempos de respuesta analítica a 
costa de cierta duplicidad de datos.
*/

CREATE TABLE Fact_Inventario (
    FactID             NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    ProductoID         NUMBER,
    FechaID            NUMBER,
    CantidadMovimiento NUMBER,
    TipoMovimiento     VARCHAR2(10),
    CONSTRAINT fk_inventario_to_producto FOREIGN KEY (ProductoID) REFERENCES Dim_Producto(ProductoID),
    CONSTRAINT fk_inventario_to_tiempo FOREIGN KEY (FechaID) REFERENCES Dim_Tiempo(FechaID)
);
/


/*
La herencia en el motor Oracle se gestiona a través de las características Objeto-Relacionales empleando 
la sentencia CREATE TYPE. Un supertipo debe definirse habilitando la opción NOT FINAL para permitir 
descendencia. Posteriormente, se declara el subtipo utilizando la palabra clave UNDER, heredando de forma 
automática las propiedades del tipo padre y permitiendo añadir atributos o sobreescribir funciones específicas.
*/

CREATE OR REPLACE TYPE Tipo_Cliente AS OBJECT (
    ClienteID NUMBER,
    Nombre    VARCHAR2(50),
    Ciudad    VARCHAR2(50),
    MEMBER FUNCTION getDescuento RETURN NUMBER
) NOT FINAL;
/

CREATE OR REPLACE TYPE BODY Tipo_Cliente AS
    MEMBER FUNCTION getDescuento RETURN NUMBER IS
    BEGIN 
        RETURN 0; 
    END;
END;
/

CREATE OR REPLACE TYPE Tipo_ClientePremium UNDER Tipo_Cliente (
    DescuentoAdicional NUMBER,
    OVERRIDING MEMBER FUNCTION getDescuento RETURN NUMBER
);
/

CREATE OR REPLACE TYPE BODY Tipo_ClientePremium AS
    OVERRIDING MEMBER FUNCTION getDescuento RETURN NUMBER IS
    BEGIN 
        RETURN self.DescuentoAdicional; 
    END;
END;
/

-- Creación de la tabla orientada a objetos e índices correspondientes
CREATE TABLE Clientes OF Tipo_Cliente;

-- Índice para acelerar la búsqueda por ubicación geográfica del cliente
CREATE INDEX idx_clientes_by_ciudad ON Clientes (Ciudad);

-- Se añade la segmentación por rango trimestral para la tabla Pedidos
ALTER TABLE Pedidos ADD PARTITION BY RANGE (FechaPedido) (
    PARTITION p_trimestre1_2025 VALUES LESS THAN (TO_DATE('2025-04-01', 'YYYY-MM-DD')),
    PARTITION p_trimestre2_2025 VALUES LESS THAN (TO_DATE('2025-07-01', 'YYYY-MM-DD')),
    PARTITION p_trimestre3_2025 VALUES LESS THAN (TO_DATE('2025-10-01', 'YYYY-MM-DD')),
    PARTITION p_trimestre4_2025 VALUES LESS THAN (MAXVALUE)
);

-- Índice compuesto para acelerar consultas de clientes y montos económicos
CREATE INDEX idx_pedidos_cli_tot ON Pedidos (ClienteID, Total);


-- Creación del índice compuesto para optimizar cruces de detalles
CREATE INDEX idx_detalles_ped_prod ON DetallesPedidos (PedidoID, ProductoID);

-- Segmentación mensual de la tabla Pedidos para el año 2025
ALTER TABLE Pedidos ADD PARTITION BY RANGE (FechaPedido) (
    PARTITION p_2025_ene VALUES LESS THAN (TO_DATE('2025-02-01', 'YYYY-MM-DD')),
    PARTITION p_2025_feb VALUES LESS THAN (TO_DATE('2025-03-01', 'YYYY-MM-DD')),
    PARTITION p_2025_mar VALUES LESS THAN (TO_DATE('2025-04-01', 'YYYY-MM-DD')),
    PARTITION p_remanente VALUES LESS THAN (MAXVALUE)
);

-- Consulta analítica de agregación mensual empleando límites de rango de fechas alternativos
SELECT 
    ClienteID,
    SUM(Total) AS Acumulado_Mensual
FROM Pedidos
WHERE FechaPedido >= TO_DATE('2025-01-01', 'YYYY-MM-DD') 
  AND FechaPedido < TO_DATE('2025-02-01', 'YYYY-MM-DD')
GROUP BY ClienteID;