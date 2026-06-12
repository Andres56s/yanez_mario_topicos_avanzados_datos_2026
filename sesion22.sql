-- Sesion 22

-- Diseña (sin script) una estrategia de alta disponibilidad para el esquema curso_topicos:
-- Número de nodos y su ubicación geográfica.
-- Tipo de replicación (síncrona o asíncrona).
-- Uso de los nodos secundarios (por ejemplo, para reportes).
-- Mecanismo de failover.

-- Estrategia de Alta Disponibilidad para curso_topicos
-- - Nodos:
--   * Nodos principales: Nodo 1 y Nodo 2 (Santiago, Chile) configurados en clúster Activo-Activo (Oracle RAC)
--   * Nodo standby: Nodo 3 (Concepción, Chile) en Centro de Datos secundario
-- - Replicación: Síncrona en modo Maximum Availability con Oracle Data Guard
--   * Motivo: Garantiza cero pérdida de datos (RPO = 0) ante fallos catastróficos, manteniendo baja latencia por la cercanía geográfica
-- - Uso del nodo standby:
--   * Consultas de solo lectura y reportes pesados de BI usando Active Data Guard para descargar el clúster principal
-- - Failover:
--   * Configurar Fast-Start Failover (FSFO) mediante un Observer independiente para una conmutación 100% automática
--   * MTTR objetivo: Menor a 30 segundos (redirección inmediata de aplicaciones mediante servicios dinámicos y SCAN)
-- - Consideraciones:
--   * Respaldo completo semanal e incrementales diarios en el nodo standby (Active Data Guard) para no impactar el rendimiento de producción en Santiago
--   * Monitoreo: Uso de Oracle Enterprise Manager (OEM) Cloud Control y alertas proactivas mediante Data Guard Broker


-- Consulta de solo lectura para el nodo standby (Concepción)
-- Reporte de ventas consolidadas por cliente para análisis de BI
SELECT c.ClientID, c.Nombre, SUM(p.Total) AS TotalVentas
FROM Clientes c
JOIN Pedidos p ON c.ClientID = p.ClientID
WHERE p.FechaPedido BETWEEN TO_DATE('2025-01-01', 'YYYY-MM-DD') AND TO_DATE('2025-06-30', 'YYYY-MM-DD')
GROUP BY c.ClientID, c.Nombre
ORDER BY TotalVentas DESC;

-- Uso de Active Data Guard:
-- - El nodo standby (Concepción) se mantiene abierto en modo de solo lectura (Read-Only With Apply) mientras aplica en tiempo real los cambios síncronos desde el clúster principal de Santiago.
-- - Esta consulta analítica pesada se ejecuta directamente en el nodo de Concepción, evitando la degradación de rendimiento y el consumo de CPU/Memoria en los nodos activos de producción (Santiago).
-- - Beneficio: Balanceo de carga inteligente y aislamiento de tráfico, garantizando que las operaciones críticas transaccionales (INSERT, UPDATE) corran en el clúster RAC sin competir con reportes de BI.
