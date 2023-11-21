--5. Añade una columna ImportePendiente en la columna Propietarios y rellénalo con la suma de los importes de los recibo pendientes de pago de cada propietario. Realiza los módulos de programación necesarios para que los datos del a columna sean siempre coherentes con los datos que se encuentran en la tabla Recibos

alter table propietarios
add column importependiente numeric(10,2);

create or replace function sumarimportes(p_dni propietarios.dni%type)
returns numeric as $$
declare
    v_total numeric;
begin
    select coalesce(sum(importe), 0) into v_total
    from recibos_cuotas
    where dni = p_dni
    and pagado = 'no';
    return v_total;
end;
$$ language plpgsql;

create or replace procedure rellenar_fila_importependiente(p_dni propietarios.dni%type, p_total numeric) as $$
begin
    update propietarios
    set importependiente = p_total
    where dni = p_dni;
end;
$$ language plpgsql;

create or replace function actualizar_importependiente() returns void as $$
declare
    v_dni propietarios.dni%type;
    v_total numeric;
begin
    for v_dni in select dni from propietarios loop
        v_total := sumarimportes(v_dni);
        update propietarios
        set importependiente = v_total
        where dni = v_dni;
    end loop;
end;
$$ language plpgsql;

create or replace function rellenar_importependiente()
returns trigger as $$
begin
    perform actualizar_importependiente();
    return null;
end;
$$ language plpgsql;

create trigger rellenar_importependiente
after insert or update or delete on recibos_cuotas
for each statement
execute function rellenar_importependiente();

--Alex
