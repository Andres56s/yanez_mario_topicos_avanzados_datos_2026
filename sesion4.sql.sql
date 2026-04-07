---actividad sesión 4 

---4.1) 


DECLARE
    v_bias_cantidad NUMBER := 5; ---"bias"
    v_cant_producto NUMBER;
    e_cantidad_baja EXCEPTION;
BEGIN
    ---intentamos obtener la cantidad
    SELECT Cantidad INTO v_cant_producto
    FROM DetallesPedidos
    WHERE ProductoID = 999; ---"id en caso de error"

    --- se verifica el bias
    IF v_cant_producto < v_bias_cantidad THEN
        RAISE e_cantidad_baja;
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('Cantidad valida: ' || v_cant_producto);

EXCEPTION
    WHEN e_cantidad_baja THEN
        DBMS_OUTPUT.PUT_LINE('Error: La cantidad (' || v_cant_producto || ') esta por debajo del umbral minimo de ' || v_bias_cantidad);
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Error: El ProductoID solicitado no existe en la tabla.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error inesperado: ' || SQLERRM);
END;
/


---4.2)



DECLARE
    v_id_cliente         NUMBER := 1; 
    v_nombre_cliente     VARCHAR2(50) := 'Carlos Sanchez';
    v_ciudad_cliente     VARCHAR2(50) := 'Concepcion';
    v_fecha_nacimiento   DATE := TO_DATE('1988-07-22', 'YYYY-MM-DD');
BEGIN
    ---intentamos insertar directamente
    INSERT INTO Clientes (ClienteID, Nombre, Ciudad, FechaNacimiento) 
    VALUES (v_id_cliente, v_nombre_cliente, v_ciudad_cliente, v_fecha_nacimiento);
    
    DBMS_OUTPUT.PUT_LINE('Cliente insertado correctamente.');
    COMMIT;

EXCEPTION
    ---exepcion para duplicados
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Error: No se puede insertar. El ID ' || v_id_cliente || ' ya existe en la base de datos.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error inesperado: ' || SQLERRM);
END;
/
