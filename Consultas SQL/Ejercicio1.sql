INSERT INTO historial_cargos (nombre_cargo, codcomunidad, dni, fecha_inicio, fecha_fin)
SELECT 'Presidente', codcomunidad, dni_propietario, SYSDATE, NULL
FROM (
    SELECT codcomunidad, dni_propietario, RANK() OVER (PARTITION BY codcomunidad ORDER BY SUM(porcentaje_participacion) DESC) AS rnk
    FROM propiedades
    GROUP BY codcomunidad, dni_propietario
)
WHERE rnk = 1
AND codcomunidad IN (
    SELECT l.codcomunidad
    FROM locales l
    JOIN horarios_apertura h ON l.codcomunidad = h.codcomunidad AND l.codpropiedad = h.codpropiedad
    WHERE TO_CHAR(h.hora_cierre, 'HH24:MI') > '18:00'
    GROUP BY l.codcomunidad
    HAVING COUNT(*) = (
        SELECT MAX(cnt)
        FROM (
            SELECT codcomunidad, COUNT(*) AS cnt
            FROM locales
            WHERE TO_CHAR(hora_cierre, 'HH24:MI') > '18:00'
            GROUP BY codcomunidad, hora_cierre 
        )
    )
);

--Juan Manuel
