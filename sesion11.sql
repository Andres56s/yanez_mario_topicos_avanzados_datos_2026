-- Sesion 11


-- Crea una función calcular_edad_cliente que reciba un ClienteID (parámetro IN) y 
-- devuelva la edad del cliente en años (basado en FechaNacimiento). 
-- Maneja excepciones si el cliente no existe.


CREATE OR REPLACE FUNCTION calcular_edad_cliente (parametro_cliente_id IN NUMBER) 
RETURN NUMBER AS
    variable_fecha_nacimiento DATE;
    variable_edad NUMBER;

BEGIN

    SELECT FechaNacimiento INTO variable_fecha_nacimiento
    FROM Clientes
    WHERE ClienteID = parametro_cliente_id;

    variable_edad := TRUNC(MONTHS_BETWEEN(SYSDATE, variable_fecha_nacimiento) / 12); ---la funcion MONTHS_BETWEEN devuelve el número de meses entre dos fechas, y luego se divide por 12 para obtener la edad en años.

    RETURN variable_edad;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20003, 'Cliente con ID ' || p_cliente_id || ' no encontrado.');

END;
/


-- Crea una función obtener_precio_promedio que devuelva el precio promedio de todos 
-- los productos. Úsala en una consulta SQL para listar los productos cuyo precio 
-- está por encima del promedio.

CREATE OR REPLACE FUNCTION obtener_precio_promedio 
RETURN NUMBER AS
    variable_precio_promedio NUMBER;

BEGIN

    SELECT AVG(Precio) INTO variable_precio_promedio
    FROM Productos;

    RETURN variable_precio_promedio;

END;
/

SELECT ProductoID, Nombre, Precio FROM Productos
WHERE Precio > obtener_precio_promedio();
