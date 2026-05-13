Escribe un bloque PL/SQL con un cursor explícito que aumente en 10 las horas de todas las asignaciones asociadas a 
incidentes con severidad 'Critical'. Usa FOR UPDATE y maneja excepciones.

DECLARE
    CURSOR cursor_severidad IS
        SELECT Severidad FROM tabla_incidentes
        WHERE (Severidad) == 'Critical';

    v_Severidad    tabla_incidentes.Severidad%TYPE;
    
BEGIN
    DBMS_OUTPUT.PUT_LINE('Tabla incidentes');
    OPEN cursor_severidad;
    FETCH cursor_severidad INTO v_Severidad;

    if cursor_severidad =='Critical'%FOUND THEN
        v_Severidad = v_Severidad + 10;

        UPDATE tabla_incidentes
        SET Nueva_severidad = v_Severidad
        WHERE current of cursor_severidad

        DBMS_OUTPUT.PUT_LINE('severidad:' || v_Severidad ||);
    else 
        DBMS_OUTPUT.PUT_LINE('severidad no existe' || v_Severidad ||);
    END if ;
    CLOSE cursor_severidad;
END;

/*
Relación Muchos a Muchos (10 pts): Explica qué es una relación muchos a muchos y 
cómo se implementa en una base de datos relacional. Usa un ejemplo basado en las tablas del esquema creado para la prueba.

R: una relacion muchos a muchos es cuando un objeto o atributo se puede relacionar mas de una vez con otro atributo por ejemplo 
en la tabla de asignaciones se relaciona la asignacion del incidente con los incidentes, ya que se puede tener 1 o mas incidentes
y 1 o mas asignaciones de incidentes 



Vistas (10 pts): Describe qué es una vista y cómo la usarías para mostrar el total de horas 
dedicadas por incidente, incluyendo la descripción del incidente y su severidad. 
Escribe la consulta SQL para crear la vista (no es necesario ejecutarla).


una vista es una tabla que se crea para ver datos especificos sin tener que llamar a toda la tabla con un select * , la usaria 
sacando el total de horas del incidente fusionando la tabla asignaciones con la tabla incidentes ej:


Excepciones Predefinidas (10 pts): ¿Qué es una excepción predefinida en PL/SQL y cómo se maneja? 
Da un ejemplo de cómo manejarías la excepción NO_DATA_FOUND en un bloque PL/SQL.



Cursores Explícitos (10 pts): Explica qué es un cursor explícito y cómo se usa en PL/SQL. 
Menciona al menos dos atributos de cursor (como %NOTFOUND) y su propósito.

/*



