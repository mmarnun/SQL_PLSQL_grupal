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


------------------Principal--------------------

CREATE OR REPLACE PROCEDURE MostrarInformes (p_tipo NUMBER, p_codcomunidad comunidades.codcomunidad%TYPE, p_fecha DATE DEFAULT sysdate) AS
BEGIN
    CASE
    WHEN p_tipo = 1 THEN
        IF p_fecha is null THEN
            RAISE_APPLICATION_ERROR (20001, 'Se debe especificar la fecha de la junta directiva como tercer parámetro en informes de tipo 1.');
        END IF;
            dbms_output.put_line('INFORME DE CARGOS');
            Mostrar_Cabecera (p_tipo, p_codcomunidad, p_fecha);
            Mostrar_Info1(p_codcomunidad);
    WHEN p_tipo = 2 THEN
            dbms_output.put_line('INFORME DE RECIBOS IMPAGADOS');
            Mostrar_Cabecera (p_tipo, p_codcomunidad, p_fecha);
            Mostrar_Info2(p_codcomunidad);
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

------------------Cabecera--------------------
create or replace function devolver_nombre_comunidad(p_codcomunidad comunidades.codcomunidad%type) return comunidades.nombre%type
is
  v_nombre_comunidad comunidades.nombre%type;
begin
  select nombre into v_nombre_comunidad
  from comunidad
  where codcomunidad = p_codcomunidad;
  return v_nombre_comunidad;
end devolver_nombre_comunidad;
/

create or replace function devolver_codpostal(p_codcomunidad comunidades.codcomunidad%type) return comunidad.codigopostal%type
is
  v_codpostal comunidad.codigopostal%type;
begin
  select codigopostal into v_codpostal
  from comunidad
  where codcomunidad = p_codcomunidad;
  return v_codpostal;
end devolver_codpostal;
/

CREATE OR REPLACE PROCEDURE Mostrar_Cabecera(p_tipo NUMBER, p_codcomunidad comunidades.codcomunidad%TYPE, p_fecha DATE DEFAULT sysdate) AS
    v_nombre_comunidad comunidades.nombre%TYPE;
    v_codpostal
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

------------------Informe2--------------------
CREATE OR REPLACE PROCEDURE Mostrar_info2(p_codcomunidad comunidades.codcomunidad%TYPE) AS
BEGIN
END;
/

------------------Informe3--------------------
CREATE OR REPLACE PROCEDURE Mostrar_info3(p_codcomunidad comunidades.codcomunidad%TYPE) AS
BEGIN
END;
/
