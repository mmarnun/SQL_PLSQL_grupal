-- Realiza los módulos de programación necesarios para evitar que se emitan dos recibos
-- a un mismo propietario en menos de 30 días.

-- En primer lugar crearemos el encabezado del paquete
create or replace package gestion_recibos is
  procedure rellenar_tabla_recibos; -- declaramos el procedmiento
  function comprobar_fechas_recibos(p_fecha in recibos_cuotas.fecha%type, p_dni in recibos_cuotas.dni%type, p_codcomunidad in recibos_cuotas.codcomunidad%type) return number; -- declaramos la funcion con el tipo de datos correspondiente a la tabla recibos_cuotas
end gestion_recibos;
/

-- Creamos el cuerpo del paquete
create or replace package body gestion_recibos is
  type t_recibo is record ( -- definimos tipo de registro
    codcomunidad varchar2(8),
    dni varchar2(9),
    fecha date,
    importe number,
    pagado varchar2(2)
  );
  type t_tabla_recibos is table of t_recibo index by binary_integer; -- indexar tabla con el tipo de datos binary_integer
  tabla_recibos t_tabla_recibos; -- declarar tabla basada en la tabla
  procedure rellenar_tabla_recibos is -- definimos el procedimiento que rellena la tabla interna
  begin
    for recibo in (select codcomunidad, dni, fecha, importe, pagado from recibos_cuotas) loop -- bucle for para recorrer lso registros de la tabla recibos_cutoas y llena la tabla_ interna,
      tabla_recibos(tabla_recibos.count + 1).codcomunidad := recibo.codcomunidad; -- sumamos uno para para que tenga un indice más en la tabla interna
      tabla_recibos(tabla_recibos.count).dni := recibo.dni;
      tabla_recibos(tabla_recibos.count).fecha := recibo.fecha;
      tabla_recibos(tabla_recibos.count).importe := recibo.importe;
      tabla_recibos(tabla_recibos.count).pagado := recibo.pagado;
    end loop;
  end rellenar_tabla_recibos;

  function comprobar_fechas_recibos(p_fecha in recibos_cuotas.fecha%type, p_dni in recibos_cuotas.dni%type, p_codcomunidad in recibos_cuotas.codcomunidad%type) return number -- definimos funcion
  is
    v_rfecha number := 0;
  begin
    for i in 1..tabla_recibos.count loop -- con un bucle for recorremos la t_recibos desde el primer elemento hasta el ultimo que cuente, para ello usamos "1."" hasta el ultimo elemento "".tabla_recibos.count" que contará todos los elementos a recorrer
      if tabla_recibos(i).dni = p_dni and tabla_recibos(i).codcomunidad = p_codcomunidad then -- aqui verifica que coinciden los datos de tabla_recibos y los parametros a introducir coindicen
        if p_fecha between tabla_recibos(i).fecha and tabla_recibos(i).fecha + 30 then -- aqui verifica que si la fecha está dentro de los 30 dias pues v_rfecha cambia a 1
          v_rfecha := 1;
        end if;
      end if;
    end loop;
    return v_rfecha;
  end comprobar_fechas_recibos;
end gestion_recibos;
/

create or replace trigger recibos_duplicados -- finalmente creamos el trigger
before insert or update on recibos_cuotas -- antes de insertar o actualizar la tabla 
for each row -- para cada fila
declare
  v_rfecha number; -- declaramos la fecha del recibo
begin
  if inserting or updating then
    gestion_recibos.rellenar_tabla_recibos;
    v_rfecha := gestion_recibos.comprobar_fechas_recibos(:new.fecha, :new.dni, :new.codcomunidad);
    if v_rfecha = 1 then
      raise_application_error(-20001, 'No se puede emitir un recibo a un propietario en menos de 30 dias');
    end if;
  end if;
end recibos_duplicados;
/


--Alex
