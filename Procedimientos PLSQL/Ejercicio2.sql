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


-- Solo el esqueleto de momento

CREATE OR REPLACE PROCEDURE MostrarInformes (p_tipo NUMBER, p_codcomunidad comunidades.codcomunidad%TYPE, p_fecha DATE DEFAULT sysdate) AS
BEGIN
    CASE
    WHEN p_tipo = 1 THEN
        IF p_fecha = sysdate THEN
            RAISE_APPLICATION_ERROR (20001, 'Se debe especificar la fecha de la junta directiva como tercer parámetro en informes de tipo 1.');
        END IF;
            dbms_output.put_line('INFORME DE CARGOS');
            Mostrar_Cabecera (p_tipo, p_comunidad, p_fecha);
            Mostrar_Info1(p_comunidad);
    WHEN p_tipo = 2 THEN
            dbms_output.put_line('INFORME DE RECIBOS IMPAGADOS');
            Mostrar_Cabecera (p_tipo, p_comunidad, p_fecha);
            Mostrar_Info2(p_comunidad);
    WHEN p_tipo = 3 THEN
            dbms_output.put_line('INFORME DE PROPIEDADES');
            Mostrar_Cabecera (p_tipo, p_comunidad, p_fecha);
            Mostrar_Info3(p_comunidad);
    ELSE
        IF p_comunidad = NULL THEN
            RAISE_APPLICATION_ERROR (20002, 'Uso: exec MostrarInformes < 1 | 2 | 3 > <codcomunidad> [Fecha]');
        ELSE
            RAISE_APPLICATION_ERROR (20003, 'El tipo de informe especificado no existe');
        END IF;
    END CASE;
END;
/

CREATE OR REPLACE PROCEDURE Mostrar_Cabecera(p_tipo NUMBER, p_codcomunidad comunidades.codcomunidad%TYPE, p_fecha DATE DEFAULT sysdate) AS
BEGIN
END;
/

CREATE OR REPLACE PROCEDURE Mostrar_info1(p_codcomunidad comunidades.codcomunidad%TYPE) AS
BEGIN
END;
/

CREATE OR REPLACE PROCEDURE Mostrar_info2(p_codcomunidad comunidades.codcomunidad%TYPE) AS
BEGIN
END;
/

CREATE OR REPLACE PROCEDURE Mostrar_info3(p_codcomunidad comunidades.codcomunidad%TYPE) AS
BEGIN
END;
/
