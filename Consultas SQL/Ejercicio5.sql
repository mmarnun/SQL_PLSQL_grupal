-- Muestra los propietarios que han ocupado en los últimos tres años tanto el cargo de Presidente como el de Vicepresidente como el de Vocal en alguna comunidad con más de 5 propiedades

SELECT * 
FROM propietarios
WHERE DNI IN (SELECT DNI 
              FROM historial_cargos
              WHERE CODCOMUNIDAD IN (SELECT CODCOMUNIDAD
                                     FROM propiedades
                                     GROUP BY CODCOMUNIDAD
                                     HAVING count(*) > 5)
              AND (nombre_cargo = 'Presidente'
              OR nombre_cargo = 'Vicepresidente'
              OR nombre_cargo = 'Vocal'));
