---actividad sesion 5


---5.1)

DECLARE
    CURSOR c_categorias IS
        SELECT CategoriaID, NombreCategoria
        FROM Categorias
        ORDER BY NombreCategoria ASC;
    
    v_id     Categorias.CategoriaID%TYPE;
    v_nombre Categorias.NombreCategoria%TYPE;
BEGIN
    DBMS_OUTPUT.PUT_LINE('---Listado de Categorias---');
    OPEN c_categorias;
    LOOP
        FETCH c_categorias INTO v_id, v_nombre;
        EXIT WHEN c_categorias%NOTFOUND;
        
        DBMS_OUTPUT.PUT_LINE('ID: ' || v_id || ' | Categoria: ' || v_nombre);
    END LOOP;
    CLOSE c_categorias;
END;
/

---5.2)

DECLARE
    
    CURSOR c_actualizar_precio(p_id NUMBER) IS
        SELECT ProductoID, Precio
        FROM Productos
        WHERE ProductoID = p_id
        FOR UPDATE;
        
    v_id               Productos.ProductoID%TYPE;
    v_precio_original  Productos.Precio%TYPE;
    v_precio_nuevo     Productos.Precio%TYPE;
    v_target_id        NUMBER := 10; ---id producto a modificar

BEGIN
    OPEN c_actualizar_precio(v_target_id);
    FETCH c_actualizar_precio INTO v_id, v_precio_original;
    
    IF c_actualizar_precio%FOUND THEN
        ---calculo del aumento 
        v_precio_nuevo := v_precio_original * 1.10;
        
        
        UPDATE Productos 
        SET Precio = v_precio_nuevo 
        WHERE CURRENT OF c_actualizar_precio;
        
        DBMS_OUTPUT.PUT_LINE('Producto ID: ' || v_id);
        DBMS_OUTPUT.PUT_LINE('Precio original: ' || v_precio_original);
        DBMS_OUTPUT.PUT_LINE('Precio actualizado (10% mas): ' || v_precio_nuevo);
    ELSE
        DBMS_OUTPUT.PUT_LINE('Error: El producto con ID ' || v_target_id || ' no existe.');
    END IF;
    
    CLOSE c_actualizar_precio;
END;
/