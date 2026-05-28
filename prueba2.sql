
---Parte 1 pregunta 1
'''En PL/SQL un procedimiento almacenado es un bloque de código que realiza una tarea específica y puede aceptar parámetros de entrada y salida, este no devuelve
 un valor directamente sino que puede modificar los datos o realizar acciones en la base de datos, por otro lado una función almacenada es un bloque de código que 
también puede aceptar parámetros como el procedimiento almacenado, pero la funcion almacenada, siempre devuelve un valor y las funciones se utilizan 
principalmente para realizar cálculos o transformaciones y devolver un resultado.

---Ejemplo de procedimiento almacenado

CREATE OR REPLACE PROCEDURE actualizar_salario (
    p_empleado_id IN NUMBER,
    p_nuevo_salario IN NUMBER
) AS
BEGIN
    UPDATE empleados
    SET salario = p_nuevo_salario
    WHERE empleado_id = p_empleado_id;
END;

---Ejemplo de función almacenada:
CREATE OR REPLACE FUNCTION calcular_descuento (
    p_precio IN NUMBER,
    p_descuento IN NUMBER
) RETURN NUMBER AS
BEGIN
    RETURN p_precio - (p_precio * p_descuento / 100);
END;


En el contexto de la base de datos de la prueba usaría el procedimiento almacenado "actualizar_salario" 
para actualizar el salario de un empleado específico en la tabla "empleados"
'''


---Parte 1 pregunta 2
'''
En pl/sql un parametero IN OUT es un tipo de parametro que puede recibir tanto un valor de entrada como devolver un valor de salida,
esto permite que el procedimiento modifique el valor del parametro y lo devuelva a quien lo llamo., en este caso lo usaria en un procedimiento almacenado 
para ajustar las horas de una asignación, por ejemplo:

CREATE OR REPLACE PROCEDURE ajustar_horas_asignacion (
    p_AsignacionID IN NUMBER,
    p_HorasAjuste IN NUMBER,
    p_HorasTotales IN OUT NUMBER
) AS

BEGIN

    SELECT Horas INTO p_HorasTotales FROM Asignaciones WHERE AsignacionID = p_AsignacionID;
    p_HorasTotales := p_HorasTotales + p_HorasAjuste;
    UPDATE Asignaciones SET Horas = p_HorasTotales WHERE AsignacionID = p_AsignacionID;
    END;
'''

---Parte 1 pregunta 3
'''
Para utilizar una funcion almacenada dentro de una consulta SQL, simplemente se llama a la funcion como parte de la consulta pasando primero 
por los parametros necesarios, ejemplo:

CREATE OR REPLACE FUNCTION calcular_horas_incidente(
    p_incidenteID IN NUMBER
) RETURN NUMBER AS
    v_total_horas_asignadas NUMBER;

BEGIN
    SELECT SUM(Horas) INTO v_total_horas_asignadas FROM Asignaciones WHERE IncidenteID = p_incidenteID;
    RETURN v_total_horas_asignadas;
END; 
'''

---Parte 1 pregunta 4

'''
Un trigger es un bloque de codigo que se ejecuta automaticamente en respuesta a ciertos eventos que ocurren en la base de datos, como inserciones, actualizaciones o
eliminaciones, los eventos que pueden disparar un trigger incluyen el after insert el cual se ejecuta despues de que se inserta un nuevo registro en una tabla y 
el before update que se ejecuta antes de que se actualice un registro en una tabla.

Ejemplo de trigger:

CREATE OR REPLACE TRIGGER actualizar_estado_incidente
AFTER INSERT ON Asignaciones
FOR EACH ROW 
BEGIN
    UPDATE Incidentes
    SET Estado = 'En Proceso'
    WHERE IncidenteID = NEW.IncidenteID AND Estado = 'Abierto';
END;
'''

--- Parte 2 Ejercicio 1
CREATE OR REPLACE PROCEDURE registrar_asignacion (
    parametro_AgenteID IN NUMBER,
    parametro_IncidenteID IN NUMBER,
    parametro_Horas IN NUMBER,
    parametro_Rol IN VARCHAR2,
    parametro_Estado IN VARCHAR2
) AS
    v_AsignacionID NUMBER;
BEGIN

    SELECT COUNT(*) INTO v_AsignacionID FROM Incidentes WHERE IncidenteID = parametro_IncidenteID;
    IF v_AsignacionID = 1 AND parametro_Estado = 'Abierto' THEN
        UPDATE Incidentes
        SET Estado = 'En Proceso'
        WHERE IncidenteID = parametro_IncidenteID AND Estado = 'Abierto';
    END IF;
    
    SELECT COUNT(*) INTO v_AsignacionID FROM Agentes WHERE AgenteID = parametro_AgenteID;
    IF v_AsignacionID = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'el agente no existe');
    END IF;
    
    SELECT COUNT(*) INTO v_AsignacionID FROM Incidentes WHERE IncidenteID = parametro_IncidenteID;
    IF v_AsignacionID = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'el incidente no existe');
    END IF;
    
    SELECT COUNT(*) INTO v_AsignacionID FROM Asignaciones 
    WHERE AgenteID = parametro_AgenteID AND IncidenteID = parametro_IncidenteID;
    IF v_AsignacionID > 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'el agente ya está asignado a este incidente');
    END IF;

    INSERT INTO Asignaciones (AgenteID, IncidenteID, Horas, Rol)
    VALUES (parametro_AgenteID, parametro_IncidenteID, parametro_Horas, parametro_Rol);
    DBMS_OUTPUT.PUT_LINE('Asignación registrada');
    
---Parte 2 Ejercicio 2 
CREATE OR REPLACE FUNCTION calcular_horas_agente (
    parametro_AgenteID IN NUMBER
) RETURN NUMBER AS
    v_TotalHoras NUMBER;
BEGIN
    SELECT SUM(Horas) INTO v_TotalHoras FROM Asignaciones WHERE AgenteID = parametro_AgenteID;
    RETURN v_TotalHoras;
END;

CREATE OR REPLACE PROCEDURE mostrar_carga_agentes AS
BEGIN
    FOR agente IN (SELECT AgenteID,Nombre,Especialidad FROM Agentes) LOOP
        DBMS_OUTPUT.PUT_LINE('Agente: ' || agente.Nombre || ', Especialidad: ' || agente.Especialidad || ', Horas Totales: ' || calcular_horas_agente(agente.AgenteID));
    END LOOP;
END;

---Parte 2 Ejercicio 3
CREATE TABLE AuditoriaAsignaciones (
    AuditoriaID NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    AsignacionID NUMBER,
    AgenteID NUMBER,
    IncidenteID NUMBER,
    Horas NUMBER,
    Accion VARCHAR2(10),
    FechaRegistro DATE
);

CREATE OR REPLACE TRIGGER auditar_asignaciones
AFTER INSERT OR DELETE ON Asignaciones
FOR EACH ROW
BEGIN
    IF insertar THEN
        INSERT INTO AuditoriaAsignaciones (AsignacionID, AgenteID, IncidenteID, Horas, Accion, FechaRegistro)
        VALUES (:NEW.AsignacionID, :NEW.AgenteID, :NEW.IncidenteID, :NEW.Horas, 'INSERT', SYSDATE);
    ELSIF borrar THEN
        INSERT INTO AuditoriaAsignaciones (AsignacionID, AgenteID, IncidenteID, Horas, Accion, FechaRegistro)
        VALUES (:OLD.AsignacionID, :OLD.AgenteID, :OLD.IncidenteID, :OLD.Horas, 'DELETE', SYSDATE);
    END IF;
END;











