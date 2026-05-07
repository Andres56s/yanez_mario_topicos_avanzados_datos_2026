---sesion 6

---creamos el tipo de objeto producto_objeto con sus respectivos atributos
CREATE OR REPLACE TYPE producto_objeto AS OBJECT (
    ProductoID NUMBER,
    Nombre VARCHAR2(50),
    Precio NUMBER,
    MEMBER FUNCION get_info RETURN VARCHAR2 ---esta funcion va a retornar una cadena con la informacion del producto
);

/

---cuerpo de la funcion del objeto 
CREATE OR REPLACE TYPE BODY producto_objeto AS
    MEMBER FUNCTION get_info RETURN VARCHAR2 IS
    BEGIN
        RETURN 'Producto: ' || Nombre || ', Precio: ' || Precio;
    END;
END;
/

---tabla del objeto
CREATE TABLE productos_objeto OF producto_objeto (productoid PRIMARY KEY);
INSERT INTO productos_objeto VALUES (1, 'Laptop', 1200);
INSERT INTO productos_objeto VALUES (2, 'Smartphone', 800);
COMMIT;

--Escribe un bloque anónimo que use un cursor explícito basado en un objeto para listar 2 atributos de alguna clase, 
--ordenados por uno de los atributos.


DECLARE
    CURSOR c_productos IS
        SELECT VALUE(p) FROM productos_objeto p ORDER BY p.Precio DESC; ---ordeno por precio 
    variable_producto producto_objeto;
    
BEGIN
    OPEN c_productos;
    LOOP
        FETCH c_productos INTO variable_producto;
        EXIT WHEN c_productos%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(variable_producto.get_info()); ---se llama a la funcion objeto 
    END LOOP;
    CLOSE c_productos;
END;
/


---Escribe un bloque anónimo que use un cursor explícito con parámetro basado en un objeto 
---para aumentar un 10% el total de la suma de algún atributo numérico de un elemento de una tabla y 
---muestre los valores originales y actualizados. Usa FOR UPDATE o usa función dentro del objeto

DECLARE
    CURSOR cursor_productos (p_producto_id NUMBER) IS 
        SELECT VALUE(p) FROM productos_objeto p
        WHERE ProductoID = p_producto_id 
        FOR UPDATE OF p.Precio; ---selecciono el producto con id 1 para actualizar su precio
    
    variable_producto producto_objeto;
    variable_precio_original NUMBER;

BEGIN
    OPEN cursor_productos(1); ---abro el cursor para el producto con id 1
    LOOP
        FETCH cursor_productos INTO variable_producto;
        EXIT WHEN cursor_productos%NOTFOUND;
        
        variable_precio_original := variable_producto.Precio; ---guardo el precio original
        variable_producto.Precio := variable_producto.Precio * 1.10; ---aumento el precio en un 10%

        UPDATE productos_objeto 
        SET Precio = variable_producto.Precio 
        WHERE ProductoID = 1;
        WHERE CURRENT OF cursor_productos; ---actualizo el precio en la tabla usando el cursor

        DBMS_OUTPUT.PUT_LINE('Precio original: ' || variable_precio_original || ', Precio actualizado: ' || variable_producto.Precio);

    END LOOP;
    CLOSE cursor_productos;
END;
/





