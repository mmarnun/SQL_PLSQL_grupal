-- Muestra el número de comunidades a cargo de cada administrador actualmente y las
-- ganancias totales que le generan al año.

select a.numcolegiado as NAdministrador, count(c.codcomunidad) as Num_Comunidades, sum(cm.honorarios_anuales) as Ganancias_Totales
from administradores a
left join contratos_de_mandato cm on a.numcolegiado = cm.numcolegiado
left join comunidades c on cm.codcomunidad = c.codcomunidad
group by a.numcolegiado
order by a.numcolegiado;

--Alex
