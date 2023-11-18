-- Muestra para cada propietario de locales comerciales el importe total que adeuda a su
-- comunidad, incluyendo a aquellos que están al corriente de pago actualmente.


select p.dni, p.nombre, p.apellidos, l.codcomunidad, SUM(rc.importe) AS Importe_Total_Adeudado
from propietarios p
join propiedades pr on p.dni = pr.dni_propietario
join locales l on pr.codcomunidad = l.codcomunidad and pr.codpropiedad = l.codpropiedad
left join recibos_cuotas rc on l.codcomunidad = rc.codcomunidad and p.dni = rc.dni
group by p.dni, p.nombre, p.apellidos, l.codcomunidad;

--Alex
