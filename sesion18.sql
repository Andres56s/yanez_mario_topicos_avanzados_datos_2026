-- Sesion 18

-- Crea un paquete gestion_clientes con:
-- Un procedimiento registrar_cliente que reciba ClienteID, Nombre, Ciudad y FechaNacimiento, 
-- y valide que la fecha de nacimiento sea anterior a la fecha actual.
-- Una función obtener_edad que reciba un ClienteID y devuelva la edad del cliente.
-- Usa una variable global para contar los clientes registrados.

    CREATE OR REPLACE PACKAGE gestion_clientes AS
        PROCEDURE registrar_cliente(
            p_cliente_id IN NUMBER, 
            p_nombre IN VARCHAR2, 
            p_ciudad IN VARCHAR2, 
            p_fecha_nacimiento IN DATE);

        FUNCTION obtener_edad(
            p_cliente_id IN NUMBER) 
            RETURN NUMBER;    
    END gestion_clientes;

    CREATE OR REPLACE PACKAGE BODY gestion_clientes AS

        var_global_clientes NUMBER := 0;

        PROCEDURE registrar_cliente(
            p_cliente_id IN NUMBER, 
            p_nombre IN VARCHAR2, 
            p_ciudad IN VARCHAR2, 
            p_fecha_nacimiento IN DATE) AS
        BEGIN
            IF p_fecha_nacimiento >= SYSDATE THEN
                RAISE_APPLICATION_ERROR(-20001, 'La fecha de nacimiento debe ser anterior a la fecha actual.');
            END IF;

            INSERT INTO Clientes (ClienteID, Nombre, Ciudad, FechaNacimiento)
            VALUES (p_cliente_id, p_nombre, p_ciudad, p_fecha_nacimiento);

            var_global_clientes := var_global_clientes + 1;
        END registrar_cliente;

        FUNCTION obtener_edad(
            p_cliente_id IN NUMBER) 
            RETURN NUMBER AS
            v_fecha_nac DATE;
            v_edad NUMBER;
        BEGIN
            SELECT FechaNacimiento INTO v_fecha_nac FROM Clientes WHERE ClienteID = p_cliente_id;
            v_edad := TRUNC(MONTHS_BETWEEN(SYSDATE, v_fecha_nac) / 12);
            RETURN v_edad;
        END obtener_edad;

    END gestion_clientes;


DECLARE
    v_edad NUMBER;
BEGIN
    -- se registran clientes nuevos
    gestion_clientes.registrar_cliente(1, 'Juan Perez', 'Santiago', TO_DATE('1990-05-15', 'YYYY-MM-DD'));
    gestion_clientes.registrar_cliente(2, 'Maria Lopez', 'Concepcion', TO_DATE('1985-10-30', 'YYYY-MM-DD'));
    gestion_clientes.registrar_cliente(3, 'Carlos Gomez', 'Valparaiso', TO_DATE('1995-03-20', 'YYYY-MM-DD'));
    
    -- se muestra el contador global
    DBMS_OUTPUT.PUT_LINE('Clientes registrados en esta sesión: ' || gestion_clientes.var_global_clientes);
    
    -- se calcula la edad del cliente
    v_edad := gestion_clientes.obtener_edad(1);
    DBMS_OUTPUT.PUT_LINE('Edad del cliente con id 1: ' || v_edad || ' años.');
END;
/


--Modifica el paquete gestion_clientes para incluir una excepción personalizada e_edad_invalida que se lance si el cliente tiene menos de 18 años al registrarlo. Prueba el paquete con un cliente menor de edad.

    CREATE OR REPLACE PACKAGE gestion_clientes AS
        PROCEDURE registrar_cliente(
            p_cliente_id IN NUMBER, 
            p_nombre IN VARCHAR2, 
            p_ciudad IN VARCHAR2, 
            p_fecha_nacimiento IN DATE);

        FUNCTION obtener_edad(
            p_cliente_id IN NUMBER) 
            RETURN NUMBER;    

        e_edad_invalida EXCEPTION;
    END gestion_clientes;

    CREATE OR REPLACE PACKAGE BODY gestion_clientes AS

        var_global_clientes NUMBER := 0;

        PROCEDURE registrar_cliente(
            p_cliente_id IN NUMBER, 
            p_nombre IN VARCHAR2, 
            p_ciudad IN VARCHAR2, 
            p_fecha_nacimiento IN DATE) AS
            v_edad NUMBER;
        BEGIN
            IF p_fecha_nacimiento >= SYSDATE THEN
                RAISE_APPLICATION_ERROR(-20001, 'La fecha de nacimiento debe ser anterior a la fecha actual.');
            END IF;

            v_edad := TRUNC(MONTHS_BETWEEN(SYSDATE, p_fecha_nacimiento) / 12);
            
            IF v_edad < 18 THEN
                RAISE e_edad_invalida;
            END IF;

            INSERT INTO Clientes (ClienteID, Nombre, Ciudad, FechaNacimiento)
            VALUES (p_cliente_id, p_nombre, p_ciudad, p_fecha_nacimiento);

            var_global_clientes := var_global_clientes + 1;
        END registrar_cliente;

        FUNCTION obtener_edad(
            p_cliente_id IN NUMBER) 
            RETURN NUMBER AS
            v_fecha_nac DATE;
            v_edad NUMBER;
        BEGIN
            SELECT FechaNacimiento INTO v_fecha_nac FROM Clientes WHERE ClienteID = p_cliente_id;
            v_edad := TRUNC(MONTHS_BETWEEN(SYSDATE, v_fecha_nac) / 12);
            RETURN v_edad;
        END obtener_edad;

    END gestion_clientes;

DECLARE
    v_edad NUMBER;
BEGIN
    -- se intenta registrar un cliente menor de edad
    gestion_clientes.registrar_cliente(4, 'Ana Torres', 'La Serena', TO_DATE('2008-07-10', 'YYYY-MM-DD'));
EXCEPTION
    WHEN gestion_clientes.e_edad_invalida THEN
        DBMS_OUTPUT.PUT_LINE('Error: El cliente debe ser mayor de 18 años para registrarse.');
END;
    

