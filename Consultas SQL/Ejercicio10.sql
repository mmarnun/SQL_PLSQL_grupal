CREATE VIEW vista_administradores AS
SELECT A.nombre, A.apellidos, C.codcomunidad, COUNT(*) AS recibos_impagados
FROM administradores A
JOIN contratos_de_mandato CM ON A.numcolegiado = CM.numcolegiado
JOIN comunidades C ON CM.codcomunidad = C.codcomunidad
JOIN recibos_cuotas RC ON C.codcomunidad = RC.codcomunidad
WHERE RC.pagado = 'No'
GROUP BY A.nombre, A.apellidos, C.codcomunidad
HAVING COUNT(*) = (
    SELECT MAX(cnt)
    FROM (
        SELECT C.codcomunidad, COUNT(*) AS cnt
        FROM administradores A
        JOIN contratos_de_mandato CM ON A.numcolegiado = CM.numcolegiado
        JOIN comunidades C ON CM.codcomunidad = C.codcomunidad
        JOIN recibos_cuotas RC ON C.codcomunidad = RC.codcomunidad
        WHERE RC.pagado = 'No'
        GROUP BY C.codcomunidad
    )
);

--Juan Manuel
