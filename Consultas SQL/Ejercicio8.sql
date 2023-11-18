-- Muestra el nombre del propietario que mantiene más horas abierto su local en su
-- comunidad.


select p.nombre, sum(extract(hour from ha.hora_cierre - ha.hora_apertura)) as Horas_abierto
from  propietarios p, propiedades pr, horarios_apertura ha, comunidades c
where p.dni = pr.dni_propietario and pr.codcomunidad = ha.codcomunidad
and pr.codpropiedad = ha.codpropiedad and pr.codcomunidad = c.codcomunidad
group by p.nombre, p.apellidos, c.nombre
order by Horas_abierto desc;
FETCH FIRST 1 ROWS ONLY; 

--Alex
