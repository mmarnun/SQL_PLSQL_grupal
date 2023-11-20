SELECT DISTINCT P.nombre, P.apellidos
FROM propietarios P
JOIN propiedades PR ON P.dni = PR.dni_propietario
LEFT JOIN inquilinos I ON PR.codpropiedad = I.codpropiedad AND PR.codcomunidad = I.codcomunidad
LEFT JOIN historial_cargos H ON PR.codcomunidad = H.codcomunidad AND P.dni = H.dni
WHERE I.dni IS NULL
  AND (H.fecha_fin IS NULL OR H.fecha_fin >= SYSDATE - INTERVAL '2' YEAR)
  AND PR.codcomunidad IS NOT NULL
  AND PR.codpropiedad IS NOT NULL;

--Juan Manuel
