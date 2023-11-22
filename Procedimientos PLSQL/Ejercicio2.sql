/*Realiza un procedimiento llamado MostrarInformes, que recibirá tres parámetros, siendo el primero de ellos un
número que indicará el tipo de informe a mostrar. Estos tipos pueden ser los siguientes:
Informe Tipo 1: Informe de cargos. Este informe recibe como segundo parámetro el código de una comunidad y
como tercer parámetro una fecha, mostrando la junta directiva que tenía dicha comunidad en esa fecha con el
siguiente formato:

INFORME DE CARGOS
Comunidad: NombreComunidad
PoblaciónComunidad CodPostalComunidad
Fecha: xx/xx/xx
PRESIDENTE D.xxxxxx xxxxxxxxx xxxxxxxxxx Teléfono
VICEPRESIDENTE D.xxxxxxxxxx xxxxxxxxx xxxxxxxxxx Teléfono
SECRETARIO D. xxxxxxxxx xxxxxxxxxxx xxxxxxxxxxx Teléfono
VOCALES:
    D. xxxxxxxxxx xxxxxxxxxxx xxxxxxxxxxxx Teléfono
    D. xxxxxxxxxx xxxxxxxxxxx xxxxxxxxxxxx Teléfono
    ….
Número de Directivos: nn

Informe Tipo 2: Informe de Recibos Impagados. El segundo parámetro será un código de comunidad y el tercer
parámetro estará en blanco. El informe muestra los recibos impagados, de forma que salgan en primer lugar los
propietarios que adeudan un mayor importe.

INFORME DE RECIBOS IMPAGADOS
Comunidad: NombreComunidad
PoblaciónComunidad CodPostalComunidad
Fecha: xx/xx/xx
Propietario 1: D.xxxxxxxxxx xxxxxxxxxx xxxxxxxxxx
    NumRecibo1 FechaRecibo1 Importe1
    …
    NumReciboN FechaReciboN ImporteN
Total Adeudado D. xxxxx xxxxxxxxxx xxxxxxxxx: n,nnn.nn
Propietario 2: D. xxxxxxxxxx xxxxxxxxxx xxxxxxxxxx
    NumRecibo1 FechaRecibo1 Importe1
    …
    NumReciboN FechaReciboN ImporteN
Total Adeudado D. xxxxx xxxxxxxxxx xxxxxxxxx: n,nnn.nn
….
Total Adeudado en la Comunidad: nnn,nnn.nn

Informe Tipo 3: Informe de Propiedades. Para este informe el segundo parámetro será un código de comunidad y el
tercero estará en blanco. Se mostrará ordenado por el porcentaje de participación total que corresponda a cada
propietario. En el caso de que la prpiedad tenga un inquilino se mostrarán su nombre y apellidos. Tendrá el
siguiente formato:

INFORME DE PROPIEDADES
Comunidad: NombreComunidad
PoblaciónComunidad CodPostalComunidad
Propietario1: D.xxxxxxxxxx xxxxxx xxxxxxxx
    CodPropiedad1 TipoPropiedad1 Portal Planta Letra PorcentajeParticipación1 Inquilino1
    …
    CodPropiedadN TipoPropiedadN Portal Planta Letra PorcentajeParticipaciónN InquilinoN
Porcentaje de Participación Total Propietario1: nn,nn %
Propietario2: D. xxxxx xxxxxxxx xxxxxxxxxx
...
*/


------------------Cabecera--------------------
-- Hecho por Fran y Alex
create or replace function devolver_nombre_comunidad(p_codcomunidad comunidades.codcomunidad%type) return comunidades.nombre%type
is
  v_nombre_comunidad comunidades.nombre%type;
begin
  select nombre into v_nombre_comunidad
  from comunidades
  where codcomunidad = p_codcomunidad;
  return v_nombre_comunidad;
end devolver_nombre_comunidad;
/

create or replace function devolver_codpostal(p_codcomunidad comunidades.codcomunidad%type) return comunidades.codigopostal%type
is
  v_codpostal comunidades.codigopostal%type;
begin
  select codigopostal into v_codpostal
  from comunidades
  where codcomunidad = p_codcomunidad;
  return v_codpostal;
end devolver_codpostal;
/

CREATE OR REPLACE PROCEDURE Mostrar_Cabecera(p_tipo NUMBER, p_codcomunidad comunidades.codcomunidad%TYPE, p_fecha DATE DEFAULT sysdate)
AS
    v_nombre_comunidad comunidades.nombre%TYPE;
    v_codpostal comunidades.codigopostal%type;
BEGIN
  v_nombre_comunidad := devolver_nombre_comunidad(p_codcomunidad);
  v_codpostal := devolver_codpostal(p_codcomunidad);
    dbms_output.put_line('Comunidad: ' || v_nombre_comunidad);
    dbms_output.put_line('Población Comunidad: ' || v_codpostal);
    IF p_tipo != 3 THEN
    dbms_output.put_line('Fecha: ' || p_fecha);
    END IF;
END;
/

------------------Informe1--------------------
-- Hecho Por Fran
CREATE OR REPLACE VIEW vista_info1 AS
    SELECT hc.nombre_cargo, hc.codcomunidad, hc.fecha_inicio, hc.fecha_fin, p.DNI, p.nombre, p.apellidos, p.tlf_contacto
    FROM historial_cargos hc, propietarios p
    WHERE hc.DNI = p.DNI
    ORDER BY nombre_cargo;

CREATE OR REPLACE PROCEDURE Info1_Presidente(p_codcomunidad comunidades.codcomunidad%TYPE, p_fecha DATE) AS
    v_presidente vista_info1%ROWTYPE;
BEGIN
    SELECT * INTO v_presidente
    FROM vista_info1
    WHERE nombre_cargo = 'Presidente'
    AND codcomunidad = p_codcomunidad
    AND fecha_inicio <= p_fecha
    AND (fecha_fin IS NULL OR fecha_fin >= p_fecha);

    dbms_output.put_line('PRESIDENTE D. ' || v_presidente.nombre || ' ' || v_presidente.apellidos || ' ' || v_presidente.tlf_contacto);
END;
/

CREATE OR REPLACE PROCEDURE Info1_Vicepresidente(p_codcomunidad comunidades.codcomunidad%TYPE, p_fecha DATE) AS
    v_vicepresidente vista_info1%ROWTYPE;
BEGIN
    SELECT * INTO v_vicepresidente
    FROM vista_info1
    WHERE nombre_cargo = 'Vicepresidente'
    AND codcomunidad = p_codcomunidad
    AND fecha_inicio <= p_fecha
    AND (fecha_fin IS NULL OR fecha_fin >= p_fecha);

    dbms_output.put_line('PRESIDENTE D. ' || v_vicepresidente.nombre || ' ' || v_vicepresidente.apellidos || ' ' || v_vicepresidente.tlf_contacto);
END;
/
CREATE OR REPLACE PROCEDURE Info1_Vocales(p_codcomunidad comunidades.codcomunidad%TYPE, p_fecha DATE, p_numdirectivos IN OUT NUMBER) AS
    CURSOR c_vocales IS
       SELECT * 
        FROM vista_info1
        WHERE nombre_cargo = 'Vocal'
        AND codcomunidad = p_codcomunidad
        AND fecha_inicio <= p_fecha
        AND (fecha_fin IS NULL OR fecha_fin >= p_fecha);
BEGIN
    dbms_output.put_line('VOCALES:');
    FOR v_vocal IN c_vocales LOOP
    dbms_output.put_line( '    ' || 'VOCAL D. ' || v_vocal.nombre || ' ' || v_vocal.apellidos || ' ' || v_vocal.tlf_contacto);
    p_numdirectivos:= p_numdirectivos+1;
    END LOOP;
END;
/

CREATE OR REPLACE PROCEDURE Mostrar_info1(p_codcomunidad comunidades.codcomunidad%TYPE, p_fecha DATE) AS
    v_numdirectivos NUMBER:= 2;
BEGIN
    Info1_Presidente(p_codcomunidad, p_fecha);
    Info1_Vicepresidente(p_codcomunidad, p_fecha);
    Info1_Vocales(p_codcomunidad, p_fecha, v_numdirectivos);
    dbms_output.put_line ('Numero de Directivos: ' || v_numdirectivos);
END;
/
------------------Informe2--------------------
--Hecho Por Alex

create or replace procedure mostrar_recibos(p_dni propietarios.dni%type)
is
    cursor c_recibos is
        select numrecibo, fecha, importe
        from recibos_cuotas
        where dni=p_dni;
    v_cont number := 1;
begin
    for v_recibo in c_recibos loop
        dbms_output.put_line('NumRecibo'||v_cont||':'||v_recibo.numrecibo||'    FechaRecibo'||v_cont||': '||v_recibo.fecha||'   Importe'||v_cont||': '||v_recibo.importe);
        v_cont := v_cont+1;
    end loop;
end;
/

create or replace function total_deu_propietario(p_dni propietarios.dni%type) return varchar2
is
    v_total varchar2(20);
begin
    select to_char(sum(r.importe), '999,999.99') into v_total
    from recibos_cuotas r, propietarios p
    where p.dni = r.dni and p.dni = p_dni;
    return v_total;
end;
/

create or replace function total_deu_comunidad(p_codcomunidad comunidades.codcomunidad%type) return varchar2
is
    v_total varchar2(20);
begin
    select to_char(sum(r.importe), '999,999.99') into v_total
    from recibos_cuotas r
    where r.codcomunidad = p_codcomunidad;
    return v_total;
end;
/

create or replace procedure Mostrar_Info2(p_codcomunidad comunidades.codcomunidad%TYPE, p_fecha DATE)
is
    cursor c_propietarios is
        select p.nombre, p.apellidos, p.dni
        from recibos_cuotas r, propietarios p
        where p.dni = r.dni and r.pagado = 'No' and r.codcomunidad = p_codcomunidad
        group by p.nombre, p.apellidos, p.dni
        order by sum(r.importe) desc;
    v_cont number := 1;
begin
    dbms_output.put_line(' ');
    for propietario in c_propietarios loop
        dbms_output.put_line('Propietario' || v_cont || ': D.' || propietario.nombre || ' ' || propietario.apellidos);
        mostrar_recibos(propietario.dni);
        dbms_output.put_line(' ');
        dbms_output.put_line('Total Adeudado D.' || propietario.nombre || ' ' || propietario.apellidos || ': ' || total_deu_propietario(propietario.dni));
        dbms_output.put_line(' ');
        v_cont := v_cont + 1;
    end loop;
    dbms_output.put_line('Total Adeudado en la Comunidad: ' || total_deu_comunidad(p_codcomunidad));
end;
/


------------------Informe3--------------------
-- Hecho por Juanma y Fran
CREATE OR REPLACE FUNCTION Devolver_Tipo (p_codpropiedad VARCHAR2, p_codcomunidad VARCHAR2) 
RETURN VARCHAR2 IS
  v_tipo VARCHAR2(30);
BEGIN
  SELECT
    CASE
      WHEN EXISTS (SELECT 1 FROM oficinas WHERE codpropiedad = p_codpropiedad AND codcomunidad = p_codcomunidad) THEN 'Oficina'
      WHEN EXISTS (SELECT 1 FROM locales WHERE codpropiedad = p_codpropiedad AND codcomunidad = p_codcomunidad) THEN 'Local'
      WHEN EXISTS (SELECT 1 FROM viviendas WHERE codpropiedad = p_codpropiedad AND codcomunidad = p_codcomunidad) THEN 'Vivienda'
      ELSE 'Otros'
    END INTO v_tipo
  FROM DUAL;
  RETURN v_tipo;
END;
/

CREATE OR REPLACE VIEW vista_propiedades_info3 AS
        SELECT pr.DNI_propietario, pr.codpropiedad, pr.codcomunidad, pr.portal, pr.planta, pr.letra, pr.porcentaje_participacion, i.nombre AS inquilino_nombre, i.apellidos AS inquilino_apellidos
        FROM propiedades pr
        LEFT JOIN inquilinos i ON pr.codpropiedad = i.codpropiedad AND pr.codcomunidad = i.codcomunidad;


CREATE OR REPLACE PROCEDURE info3_propiedad(p_propietario propietarios.DNI%TYPE, p_participacion OUT FLOAT) AS
    CURSOR c_propiedades IS
        SELECT *
        FROM vista_propiedades_info3
        WHERE DNI_propietario = p_propietario;
    v_totalparticipacion NUMBER:= 0;
    v_numpropiedades NUMBER:= 0;
    v_tipo VARCHAR2(50);
BEGIN
    FOR v_propiedad IN c_propiedades LOOP
        v_tipo := Devolver_Tipo(v_propiedad.codpropiedad, v_propiedad.codcomunidad);
        v_numpropiedades := v_numpropiedades + 1;
        dbms_output.put_line ('     Propiedad ' || v_numpropiedades || ': ' || v_propiedad.codpropiedad || ' ' || v_tipo || ' ' || v_propiedad.portal || ' ' || v_propiedad.planta || v_propiedad.letra || ' ' || round(v_propiedad.porcentaje_participacion, 2) || '% ' || v_propiedad.inquilino_nombre || ' ' || v_propiedad.inquilino_apellidos );
        v_totalparticipacion := v_totalparticipacion + v_propiedad.porcentaje_participacion;
    END LOOP;
        p_participacion := (v_totalparticipacion / v_numpropiedades);
END;
/

CREATE OR REPLACE VIEW vista_propietarios_info3 AS
        SELECT p.DNI, p.nombre, p.apellidos, pr.codcomunidad
        FROM propietarios p, propiedades pr
        WHERE p.dni = pr.dni_propietario;

CREATE OR REPLACE PROCEDURE Mostrar_info3(p_codcomunidad comunidades.codcomunidad%TYPE) AS
    CURSOR c_propietarios IS
        SELECT *
        FROM vista_propietarios_info3
        WHERE codcomunidad = p_codcomunidad;
    v_participacion FLOAT;
    v_contador NUMBER:= 0;
BEGIN
    FOR v_propietario IN c_propietarios LOOP
        v_contador := v_contador + 1;
        dbms_output.put_line('Propietario ' || v_contador || ': D.' || v_propietario.nombre || ' ' || v_propietario.apellidos);
        info3_propiedad(v_propietario.DNI, v_participacion);
        dbms_output.put_line ('Porcentaje de Participación Total Propietario1: ' || round(v_participacion, 2) || '%');
    END LOOP;
END;
/

--------------------------------Procedimiento Principal-----------------------------------
CREATE OR REPLACE PROCEDURE MostrarInformes (p_tipo NUMBER, p_codcomunidad comunidades.codcomunidad%TYPE, p_fecha DATE DEFAULT sysdate) AS
BEGIN
    CASE
    WHEN p_tipo = 1 THEN
        IF p_fecha is null THEN
            RAISE_APPLICATION_ERROR (20001, 'Se debe especificar la fecha de la junta directiva como tercer parámetro en informes de tipo 1.');
        END IF;
            dbms_output.put_line('INFORME DE CARGOS');
            Mostrar_Cabecera (p_tipo, p_codcomunidad, p_fecha);
            Mostrar_Info1(p_codcomunidad, p_fecha);
    WHEN p_tipo = 2 THEN
            dbms_output.put_line('INFORME DE RECIBOS IMPAGADOS');
            Mostrar_Cabecera (p_tipo, p_codcomunidad, p_fecha);
            Mostrar_Info2(p_codcomunidad, p_fecha);
    WHEN p_tipo = 3 THEN
            dbms_output.put_line('INFORME DE PROPIEDADES');
            Mostrar_Cabecera (p_tipo, p_codcomunidad, p_fecha);
            Mostrar_Info3(p_codcomunidad);
    ELSE
        IF p_codcomunidad = NULL THEN
            RAISE_APPLICATION_ERROR (20002, 'Uso: exec MostrarInformes < 1 | 2 | 3 > <codcomunidad> [Fecha]');
        ELSE
            RAISE_APPLICATION_ERROR (20003, 'El tipo de informe especificado no existe');
        END IF;
    END CASE;
END;
/


