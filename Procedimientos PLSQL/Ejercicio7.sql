--7. Realiza los módulos de programación necesarios para evitar que un administrador gestione más de cuatro comunidades de forma simultánea

CREATE OR REPLACE FUNCTION contar_contratos (p_numcolegiado contratos_de_mandato.numcolegiado%TYPE)
RETURN NUMBER IS
    v_numcontratos NUMBER:= 0;
BEGIN
    SELECT COUNT(*)
    INTO v_numcontratos
    FROM contratos_de_mandato
    WHERE numcolegiado = p_numcolegiado;
    RETURN v_numcontratos;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN v_numcontratos;
END;
/

CREATE OR REPLACE TRIGGER nomasdecuatro
BEFORE INSERT OR UPDATE ON contratos_de_mandato
FOR EACH ROW
DECLARE
    v_numcontratos NUMBER;
BEGIN
    v_numcontratos := contar_contratos(:new.numcolegiado);
    
    IF v_numcontratos >=4 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Este colegiado ya está gestionando 4 comunidades.');
    END IF;
END;
/

-- Fran
