-- Muestra el porcentaje de inquilinos sobre el número total de propiedades que tiene cada comunidad, incluyendo a las que no tengan ninguno.

SELECT c.codcomunidad, ROUND(NVL(COUNT(i.dni) * 100.0 / NULLIF(COUNT(p.codpropiedad), 0), 0), 2) || '%' AS porcentaje_inquilinos
FROM comunidades c, propiedades p, inquilinos i 
WHERE c.codcomunidad = p.codcomunidad (+)
AND p.codpropiedad = i.codpropiedad (+)
AND p.codcomunidad = i.codcomunidad (+)
GROUP BY c.codcomunidad
ORDER BY c.codcomunidad;

-- Fran
