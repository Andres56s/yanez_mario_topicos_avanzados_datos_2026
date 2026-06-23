---sesion24 

---Define al menos dos roles (por ejemplo, "Usuario", "Administrador").
---Asigna permisos específicos a cada rol.
---Crea usuarios y asigna los roles.
---Documenta los cambios en mejoras_proyecto.sql.

CREATE ROLE rol_usuario;
CREATE ROLE rol_admin;

GRANT SELECT, INSERT ON Planes TO rol_usuario;
GRANT SELECT, INSERT ON Asistencias TO rol_usuario;
GRANT ALL PRIVILEGES ON Planes, Asistencias, Miembros TO rol_admin;

---Creación de usuarios y asignación de roles
CREATE USER usuario1 IDENTIFIED BY user123;
GRANT rol_usuario TO usuario1;

CREATE USER admin1 IDENTIFIED BY admin123;
GRANT rol_admin TO admin1;


---Selecciona una consulta crítica de tu proyecto (por ejemplo, un reporte).
---Ejecuta EXPLAIN PLAN y analiza el plan de ejecución.
---Aplica una mejora (por ejemplo, crear un índice, reescribir la consulta).
---Documenta los cambios y el nuevo plan de ejecución en mejoras_proyecto.sql.

---Optimización de consulta
EXPLAIN PLAN FOR
SELECT m.Nombre, SUM(a.CostoSesion) AS TotalIngresos
FROM Miembros m
JOIN Asistencias a ON m.MiembroID = a.MiembroID
GROUP BY m.Nombre;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);


---Mejora Crear índice
CREATE INDEX idx_asistencias_miembroid ON Asistencias(MiembroID);

EXPLAIN PLAN FOR
SELECT m.Nombre, SUM(a.CostoSesion) AS TotalIngresos
FROM Miembros m
JOIN Asistencias a ON m.MiembroID = a.MiembroID
GROUP BY m.Nombre;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);