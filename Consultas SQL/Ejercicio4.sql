-- SQL 4. La comunidad que lleva más tiempo trabajando con algún administrador de nuestra empresa va a iniciar un procedimiento judicial contra aquellos propietarios que tienen mas de tres recibos si pagar y ademas tienen inquilinos en alguna de sus propiedades. Obtén un listado con los nombres de los morosos y la fecha del recibo más antiguo que está pendiente de pago

SELECT p.nombre, p.apellidos, min(rc.fecha) AS Recibo_mas_antiguo 
FROM propietarios p, recibos_cuotas rc
WHERE p.DNI IN (SELECT DNI
              FROM recibos_cuotas
              WHERE pagado = 'No' 
              AND codcomunidad IN (SELECT codcomunidad
                                   FROM propiedades
                                   WHERE codpropiedad IN (SELECT DISTINCT codpropiedad
                                                          FROM inquilinos))
              GROUP BY DNI, pagado
              HAVING count(*) > 3)
AND p.DNI IN (SELECT DNI
            FROM historial_cargos
            WHERE codcomunidad IN (SELECT codcomunidad
                                   FROM contratos_de_mandato
                                   WHERE numcolegiado IN (SELECT numcolegiado
                                                          FROM administradores)
                                   GROUP BY codcomunidad, fecha_inicio
                                   HAVING fecha_inicio = min(fecha_inicio)))
GROUP BY p.nombre, p.apellidos;

-- Fran
