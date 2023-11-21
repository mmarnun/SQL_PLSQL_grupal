--3. Realiza los módulos de programación necesarios para que los honorarios anuales correspondientes a un contrato de mandato vayan en función del numero de propiedades de la comunidad y de la existencia o no de locales y oficinas, de acuerdo con la siguiente tabla

/*
| Num Propiedades | Honorarios Anuales |
|-----------------|--------------------|
| 1-5             | 600                |
| 6-10            | 1000               |
| 11-20           | 1800               |
| >20             | 2500               |
|-----------------|--------------------|
*/


create or replace function check_locales(p_codcomunidad comunidades.codcomunidad%type)
returns integer as $$
declare
    v_select varchar(4);
    v_bool integer := 0;
begin
    select 'dato' into v_select
    from locales
    where codcomunidad = p_codcomunidad
    limit 1;
    if v_select = 'dato' then
        v_bool := 1;
    end if;
    return v_bool;
exception
    when no_data_found then
        return v_bool;
end;
$$ language plpgsql;

create or replace function check_oficinas(p_codcomunidad comunidades.codcomunidad%type)
returns integer as $$
declare
    v_select varchar(4);
    v_bool integer := 0;
begin
    select 'dato' into v_select
    from oficinas
    where codcomunidad = p_codcomunidad
    limit 1;
    if v_select = 'dato' then
        v_bool := 1;
    end if;
    return v_bool;
exception
    when no_data_found then
        return v_bool;
end;
$$ language plpgsql;

create or replace function contar_propiedades(p_codcomunidad comunidades.codcomunidad%type)
returns integer as $$
declare
    v_count integer;
begin
    select count(*) into v_count
    from propiedades
    where codcomunidad = p_codcomunidad;
    return v_count;
end;
$$ language plpgsql;

create or replace function calculo_honorarios(p_codcomunidad comunidades.codcomunidad%type) returns void as $$
declare
    v_existe_comunidad comunidades.codcomunidad%type;
    v_honorarios numeric;
    v_existe_oficinas integer;
    v_existe_locales integer;
    v_numpropiedades integer;
begin
    begin
        select codcomunidad into v_existe_comunidad
        from comunidades
        where codcomunidad = p_codcomunidad;

        v_existe_oficinas:= check_oficinas(p_codcomunidad);
        v_existe_locales:= check_locales(p_codcomunidad);
        v_numpropiedades:= contar_propiedades(p_codcomunidad);

        case
            when v_numpropiedades >= 1 and v_numpropiedades <= 5 then
                v_honorarios:= 600;
            when v_numpropiedades >= 6 and v_numpropiedades <= 10 then
                v_honorarios:= 1000;
            when v_numpropiedades >= 11 and v_numpropiedades <= 20 then
                v_honorarios:= 1800;
            when v_numpropiedades > 20 then
                v_honorarios:= 2500;
            else
                v_honorarios:= 0;
        end case;

        case
            when v_existe_oficinas = 1 and v_existe_locales = 0 then
                v_honorarios:= v_honorarios * 1.10;
            when v_existe_oficinas = 0 and v_existe_locales = 1 then
                v_honorarios:= v_honorarios * 1.20;            
            when v_existe_oficinas = 1 and v_existe_locales = 1 then
                v_honorarios:= v_honorarios * 1.30;
            else
                null;
        end case;

        raise notice 'Honorarios anuales para %: %', p_codcomunidad, v_honorarios;
    exception
        when no_data_found then
            raise exception 'La comunidad no existe.';
    end;
end;
$$ language plpgsql;

select calculo_honorarios('AAAA1');

--Alex
