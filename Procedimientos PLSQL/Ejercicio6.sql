CREATE OR REPLACE TRIGGER evitar_doble_cargo
BEFORE INSERT OR UPDATE ON historial_cargos
FOR EACH ROW
DECLARE
    v_num_cargos NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_num_cargos
    FROM historial_cargos
    WHERE dni = :NEW.dni
      AND codcomunidad = :NEW.codcomunidad
      AND ((:NEW.fecha_inicio BETWEEN fecha_inicio AND NVL(fecha_fin, :NEW.fecha_inicio))
           OR (:NEW.fecha_fin BETWEEN fecha_inicio AND NVL(fecha_fin, :NEW.fecha_inicio)
           OR (fecha_inicio BETWEEN :NEW.fecha_inicio AND NVL(:NEW.fecha_fin, fecha_inicio))));

    IF v_num_cargos > 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'El propietario ya ocupa un cargo en esta comunidad en esa fecha.');
    END IF;
END;
/

--Para probarlo por ejemplo 
select * from historial_cargos;

INSERT INTO historial_cargos
VALUES('Presidente/Vicepresidente/Vocal','AAAA1','DNI',TO_DATE('2016/01/15','YYYY/MM/DD'),TO_DATE('2017/01/15','YYYY/MM/DD'));

INSERT INTO historial_cargos
VALUES('Presidente','AAAA1','10880946Z',TO_DATE('2016/01/15','YYYY/MM/DD'),TO_DATE('2017/01/15','YYYY/MM/DD'));




-- Juan Manuel
