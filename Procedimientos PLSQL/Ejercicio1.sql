CREATE OR REPLACE FUNCTION estado_local(
    p_codcomunidad IN VARCHAR2,
    p_codpropiedad IN VARCHAR2
) RETURN NUMBER
IS
    v_estado NUMBER;
BEGIN
    v_estado := 0;
    BEGIN
        SELECT COUNT(*)
        INTO v_estado
        FROM comunidades
        WHERE codcomunidad = p_codcomunidad;

        IF v_estado = 0 THEN
            RAISE NO_DATA_FOUND;
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20001, 'La comunidad no existe.');
    END;

    BEGIN
        SELECT COUNT(*)
        INTO v_estado
        FROM propiedades
        WHERE codcomunidad = p_codcomunidad AND codpropiedad = p_codpropiedad;

        IF v_estado = 0 THEN
            RAISE NO_DATA_FOUND;
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20002, 'La propiedad no existe en esa comunidad.');
    END;

    BEGIN
        SELECT COUNT(*)
        INTO v_estado
        FROM locales
        WHERE codcomunidad = p_codcomunidad AND codpropiedad = p_codpropiedad;

        IF v_estado = 0 THEN
            RAISE NO_DATA_FOUND;
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20003, 'La propiedad no es un local comercial.');
    END;

    BEGIN
        SELECT COUNT(*)
        INTO v_estado
        FROM horarios_apertura
        WHERE codcomunidad = p_codcomunidad
            AND codpropiedad = p_codpropiedad
            AND TO_TIMESTAMP(TO_CHAR(SYSDATE, 'YYYY-MM-DD') || ' ' || TO_CHAR(hora_apertura, 'HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS') <= SYSTIMESTAMP
            AND TO_TIMESTAMP(TO_CHAR(SYSDATE, 'YYYY-MM-DD') || ' ' || TO_CHAR(hora_cierre, 'HH24:MI:SS'), 'YYYY-MM-DD HH24:MI:SS') >= SYSTIMESTAMP;
        RETURN v_estado;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 0;
    END;
END estado_local;
/
----------------------------------------------------------------------------------
DECLARE
    v_estado NUMBER;
BEGIN
    v_estado := estado_local('codcomunidad', 'codpropiedad');
    DBMS_OUTPUT.PUT_LINE('Estado del local: ' || v_estado);
END;
/
-----------------------------------------------------------------------------------
DECLARE
    v_estado NUMBER;
BEGIN
    v_estado := estado_local('AAAA1', '0002');
    DBMS_OUTPUT.PUT_LINE('Estado del local: ' || v_estado);
END;
/


---Juan Manuel
