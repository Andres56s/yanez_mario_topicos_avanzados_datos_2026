---actividad sesión 3

---rendimiento de ventas en tres sucursales distintas

---ventas altas: 50000 o mas
---ventas media: entre 20000 y 50000
---ventas bajas menos de 20000

DECLARE
    v_ventas_sucursalA NUMBER := 55000;
    v_ventas_sucursalB NUMBER := 32000;
    v_ventas_sucursalC NUMBER := 12000;
BEGIN
    
    IF v_ventas_sucursalA >= 50000 THEN
        DBMS_OUTPUT.PUT_LINE('Sucursal A: Venta Alta');
    ELSIF v_ventas_sucursalA >= 20000 THEN
        DBMS_OUTPUT.PUT_LINE('Sucursal A: Venta Media');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Sucursal A: Venta Baja');
    END IF;

 
    IF v_ventas_sucursalB >= 50000 THEN
        DBMS_OUTPUT.PUT_LINE('Sucursal B: Venta Alta');
    ELSIF v_ventas_sucursalB >= 20000 THEN
        DBMS_OUTPUT.PUT_LINE('Sucursal B: Venta Media');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Sucursal B: Venta Baja');
    END IF;

    IF v_ventas_sucursalC >= 50000 THEN
        DBMS_OUTPUT.PUT_LINE('Sucursal C: Venta Alta');
    ELSIF v_ventas_sucursalC >= 20000 THEN
        DBMS_OUTPUT.PUT_LINE('Sucursal C: Venta Media');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Sucursal C: Venta Baja');
    END IF;
END;
/
