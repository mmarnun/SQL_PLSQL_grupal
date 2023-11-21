CREATE OR REPLACE VIEW vista_administradores AS
SELECT
    A.nombre,
    A.apellidos,
    C.codcomunidad,
    NVL(COUNT(RC.codcomunidad), 0) AS recibos_impagados
FROM administradores A
JOIN contratos_de_mandato CM ON A.numcolegiado = CM.numcolegiado
JOIN comunidades C ON CM.codcomunidad = C.codcomunidad
LEFT JOIN recibos_cuotas RC ON C.codcomunidad = RC.codcomunidad AND RC.pagado = 'No'
WHERE (C.codcomunidad, A.numcolegiado) IN (
        SELECT codcomunidad, numcolegiado
        FROM (
            SELECT
                C.codcomunidad,
                A.numcolegiado,
                RANK() OVER (PARTITION BY A.numcolegiado ORDER BY COUNT(RC.codcomunidad) DESC) AS rnk
            FROM administradores A
            JOIN contratos_de_mandato CM ON A.numcolegiado = CM.numcolegiado
            JOIN comunidades C ON CM.codcomunidad = C.codcomunidad
            LEFT JOIN recibos_cuotas RC ON C.codcomunidad = RC.codcomunidad AND RC.pagado = 'No'
            GROUP BY C.codcomunidad, A.numcolegiado
        )
        WHERE rnk = 1
    )
GROUP BY A.nombre, A.apellidos, C.codcomunidad;

--Juan Manuel
