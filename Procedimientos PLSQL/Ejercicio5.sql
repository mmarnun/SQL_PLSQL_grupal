--5. Añade una columna ImportePendiente en la columna Propietarios y rellénalo con la suma de los importes de los recibo pendientes de pago de cada propietario. Realiza los módulos de programación necesarios para que los datos del a columna sean siempre coherentes con los datos que se encuentran en la tabla Recibos

ALTER TABLE propietarios
ADD ImportePendiente NUMBER (10,2)

CREATE OR REPLACE FUNCTION sumarimportes (p_dni propietarios.DNI%TYPE)
RETURN NUMBER IS
    v_total NUMBER;
BEGIN
    SELECT nvl(sum(importe),0) INTO v_total
    FROM recibos_cuotas
    WHERE DNI = p_dni
    AND pagado = 'No';
    RETURN v_total;
END;
/

CREATE OR REPLACE PROCEDURE rellenar_fila_importependiente (p_dni propietarios.DNI%TYPE, p_total NUMBER) AS
BEGIN
    UPDATE propietarios
    SET ImportePendiente = p_total
    WHERE DNI = p_dni;
END;
/

CREATE OR REPLACE PROCEDURE actualizar_ImportePendiente AS
    CURSOR c_dnis IS
        SELECT DNI
        FROM Propietarios;
    v_total NUMBER;
BEGIN
    FOR v_dni in c_dnis LOOP
        v_total:= sumarimportes(v_dni.DNI);
        rellenar_fila_importependiente(v_dni.DNI, v_total);
    END LOOP;
END;
/

CREATE OR REPLACE TRIGGER rellenar_ImportePendiente
AFTER INSERT OR UPDATE OR DELETE ON recibos_cuotas
DECLARE
BEGIN
    actualizar_ImportePendiente;
END;
/

-- Fran
