UPDATE contratos_de_mandato
SET honorarios_anuales = honorarios_anuales * 1.1
WHERE numcolegiado = (
    SELECT numcolegiado
    FROM administradores
    ORDER BY fecha_inicio ASC
    FETCH FIRST 1 ROW ONLY
)
AND codcomunidad IN (
    SELECT DISTINCT codcomunidad
    FROM propiedades
    WHERE codcomunidad IN (
        SELECT codcomunidad
        FROM propiedades
        GROUP BY codcomunidad
        HAVING COUNT(DISTINCT dni_propietario) > 4
           AND COUNT(DISTINCT codpropiedad) > 0
    )
    AND codcomunidad IN (
        SELECT codcomunidad
        FROM oficinas
    )
    AND codcomunidad IN (
        SELECT codcomunidad
        FROM locales
    )
);

--Juan Manuel 
