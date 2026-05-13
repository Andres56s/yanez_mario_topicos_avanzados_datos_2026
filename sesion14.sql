-- Sesion 14

-- Crea un supertipo Vehiculo con atributos Marca y Año, y un método obtener_antiguedad. 
-- Luego, crea un subtipo Automovil que herede de Vehiculo, con un atributo adicional 
-- NumeroPuertas y un método descripcion que devuelva una cadena con los detalles del 
-- automóvil.


---Creamos el supertipo Vehiculo
CREATE OR REPLACE TYPE Vehiculo AS OBJECT (
    Marca VARCHAR2(50),
    Año NUMBER,
    MEMBER FUNCTION obtener_antiguedad RETURN NUMBER
)NOT FINAL;
/

---Implementamos el cuerpo del metodo
CREATE OR REPLACE TYPE BODY Vehiculo AS 
    MEMBER FUNCTION obtener_antiguedad RETURN NUMBER IS
    BEGIN
        RETURN 2026 - Año;
    END;
END;
/

---Creamos el subtipo Automovil que hereda de Vehiculo
CREATE OR REPLACE TYPE Automovil UNDER Vehiculo (
    NumeroPuertas NUMBER,
    MEMBER FUNCTION detalles_automovil RETURN VARCHAR2
);
/

---Implementamos el cuerpo del metodo descripcion
CREATE OR REPLACE TYPE BODY Automovil AS 
    MEMBER FUNCTION detalles_automovil RETURN VARCHAR2 IS
    BEGIN
        RETURN 'Automóvil: Marca ' || Marca || ', Año ' || Año || ', Número de Puertas: ' || NumeroPuertas;
    END;
END;
/

---Creamos la tabla Automoviles para almacenar objetos del tipo Automovil
CREATE TABLE Automoviles OF Automovil;

---Insertamos un automóvil en la tabla
INSERT INTO Automoviles VALUES (Automovil('Toyota', 2015, 4));

---Seleccionamos el automóvil y mostramos su descripción y antigüedad
SELECT variable.detalles_automovil() AS Descripcion, variable.obtener_antiguedad() AS Antiguedad, TREAT(VALUE(variable) AS Automovil).detalles_automovil() AS Detalles FROM Automoviles variable;
WHERE VALUE(variable) IS OF (Automovil);

--- Crear un subtipo camion que herede de vehiculo, con un atributo adicional capacidad_carga(en toneladas) y 
---sobreescriba el metodo obtener_antiguedad para sumar 2 año9s adicionales(los camiones envejecen mas rapido), insertar un camion
--- en la tabla vehiculos y consultar su antiguedad y detalles

---Creamos el subtipo Camion que hereda de Vehiculo
CREATE OR REPLACE TYPE Camion UNDER Vehiculo (
    CapacidadCarga NUMBER,
    OVERRIDING MEMBER FUNCTION obtener_antiguedad RETURN NUMBER
);
/

---Implementamos el cuerpo del metodo obtener_antiguedad para el camion
CREATE OR REPLACE TYPE BODY Camion AS
    OVERRIDING MEMBER FUNCTION obtener_antiguedad RETURN NUMBER IS
    BEGIN
        RETURN (2026 - Año) + 2; -- Los camiones envejecen 2 años adicionales
    END;
END;
/

---Insertamos un camión en la tabla Vehiculos
INSERT INTO Vehiculos VALUES (Camion('Volvo', 2010, 20));
SELECT variable.marca, variable.obtener_antiguedad() AS Antiguedad FROM Vehiculos variable
WHERE VALUE(variable) IS OF (Camion);

