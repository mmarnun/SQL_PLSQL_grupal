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

CREATE OR REPLACE FUNCTION check_locales (p_codcomunidad comunidades.codcomunidad%TYPE)
RETURN NUMBER IS
    v_select VARCHAR2(4);
    v_bool NUMBER:=0;
BEGIN
    SELECT 'dato' INTO v_select
    FROM locales
    WHERE codcomunidad = p_codcomunidad
    FETCH FIRST 1 ROW ONLY;

    IF v_select = 'dato' THEN
        v_bool:= 1;
    END IF;

    RETURN v_bool;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN v_bool;
END;
/

CREATE OR REPLACE FUNCTION check_oficinas (p_codcomunidad comunidades.codcomunidad%TYPE)
RETURN NUMBER IS
    v_select VARCHAR2(4);
    v_bool NUMBER:=0;
BEGIN
    SELECT 'dato' INTO v_select
    FROM oficinas
    WHERE codcomunidad = p_codcomunidad
    FETCH FIRST 1 ROW ONLY;

    IF v_select = 'dato' THEN
        v_bool:= 1;
    END IF;

    RETURN v_bool;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN v_bool;
END;
/

CREATE OR REPLACE FUNCTION contar_propiedades (p_codcomunidad comunidades.codcomunidad%TYPE)
RETURN NUMBER IS
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM propiedades
    WHERE codcomunidad = p_codcomunidad;
    
    RETURN v_count;
END;
/

CREATE OR REPLACE PROCEDURE calculo_honorarios (p_codcomunidad comunidades.codcomunidad%TYPE) AS
    v_existe_comunidad VARCHAR2(100);
    v_honorarios NUMBER;
    v_existe_oficinas NUMBER;
    v_existe_locales NUMBER;
    v_numpropiedades NUMBER;
BEGIN
    SELECT codcomunidad INTO v_existe_comunidad
    FROM comunidades
    WHERE codcomunidad = p_codcomunidad;

    v_existe_oficinas:= check_oficinas(p_codcomunidad);
    v_existe_locales:= check_locales(p_codcomunidad);
    v_numpropiedades:= contar_propiedades(p_codcomunidad);
    CASE
        WHEN v_numpropiedades >= 1 AND v_numpropiedades <= 5 THEN
            v_honorarios:= 600;
        WHEN v_numpropiedades >= 6 AND v_numpropiedades <= 10 THEN
            v_honorarios:= 1000;
        WHEN v_numpropiedades >= 11 AND v_numpropiedades <= 20 THEN
            v_honorarios:= 1800;
        WHEN v_numpropiedades > 20 THEN
            v_honorarios:= 2500;
        ELSE
            v_honorarios:= 0;
    END CASE;
    
    CASE
        WHEN v_existe_oficinas = 1 AND v_existe_locales = 0 THEN
            v_honorarios:= v_honorarios*1.10;
        WHEN v_existe_oficinas = 0 AND v_existe_locales = 1 THEN
            v_honorarios:= v_honorarios*1.20;            
        WHEN v_existe_oficinas = 1 AND v_existe_locales = 1 THEN
            v_honorarios:= v_honorarios*1.30;
        ELSE
            NULL;
    END CASE;

    dbms_output.put_line('Honorarios anuales para ' || p_codcomunidad || ': ' || v_honorarios);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20001, 'La comunidad no existe.');
END;
/
