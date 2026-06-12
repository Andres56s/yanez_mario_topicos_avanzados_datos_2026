-- Sesion 19 
-- Diseña una estrategia de respaldo para el esquema curso_topicos. Documenta la estrategia en comentarios y escribe un script RMAN para un respaldo completo y un respaldo incremental.



-- Estrategia de respaldo para el esquema curso_topicos:
-- 1. Respaldo completo semanal: Se realizará un respaldo completo del esquema curso_topicos cada domingo a las 2:00 AM. Este respaldo incluirá todos los objetos del esquema, como tablas, índices, procedimientos almacenados, etc.
-- 2. Respaldo incremental diario: Se realizará un respaldo incremental del esquema curso_topicos de lunes a sábado a las 2:00 AM. Este respaldo solo incluirá los cambios realizados desde el último respaldo completo o incremental, 
-- lo que permitirá ahorrar espacio y tiempo en el proceso de respaldo.
-- 3. Almacenamiento de respaldos: Los respaldos se almacenarán en un directorio específico en el servidor de base de datos, con una estructura organizada por fecha y tipo de respaldo (completo o incremental).
-- 4. Retención de respaldos: Se mantendrán los respaldos completos durante 4 semanas y los respaldos incrementales durante 2 semanas. Después de este período, los respaldos antiguos serán eliminados automáticamente para liberar espacio.


-- script rman para hacer el respaldo completo
rman target /
CONFIGURE RETENTION POLICY TO RECOVERY WINDOW OF 28 DAYS;
CONFIGURE CHANNEL DEVICE TYPE DISK FORMAT '/home/usuario/documentos/%U';
RUN {
    BACKUP DATABASE PLUS ARCHIVELOG;
    DELETE OBSOLETE;
}

-- script rman para hacer el respaldo incremental
rman target /
CONFIGURE RETENTION POLICY TO RECOVERY WINDOW OF 14 DAYS;
CONFIGURE CHANNEL DEVICE TYPE DISK FORMAT '/home/usuario/documentos/%U';
RUN {
    BACKUP INCREMENTAL LEVEL 1 DATABASE PLUS ARCHIVELOG;
    DELETE OBSOLETE;
}

LIST BACKUP SUMMARY;


