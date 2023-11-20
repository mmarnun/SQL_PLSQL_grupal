-- Realiza los módulos de programación necesarios para que cuando se abone un recibo que lleve más de un año
-- impagado se avise por correo electrónico al presidente de la comunidad y al administrador que tiene un contrato de
-- mandato vigente con la comunidad correspondiente. Añade el campo e-mail tanto a la tabla Propietarios como
-- Administradores.

alter table propietarios
add email varchar2(50)
constraint c_email check (REGEXP_LIKE(email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'));

alter table administradores
add email varchar2(50)
constraint c_emailadmin check (REGEXP_LIKE(email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'));

update propietarios set email='josemanuel87@gmail.com'
where dni = '49027387N';
update propietarios set email='rosa-asenjo.93@hotmail.es'
where dni = '09291497A';
update propietarios set email='lau.buenomar90@gmail.com'
where dni = '71441529X';

update Administradores set email='elisarodadmin@hotmail.com'
where dni='52801993L';
update Administradores set email='josemadmin@hotmail.com'
where dni='27449907M';
update Administradores set email='carlosadmin@gmail.com'
where dni='23229790C';
update Administradores set email='tomasadmin@gmail.com' where dni='23229791T';

@$ORACLE_HOME/rdbms/admin/utlmail.sql
@$ORACLE_HOME/rdbms/admin/prvtmail.plb

alter session set "_ORACLE_SCRIPT"=TRUE;
grant execute on utl_mail to alfonso;

create or replace function devolver_email_propietario_presi(p_codcomunidad in varchar2) return propietarios.email%type
is
    v_email propietarios.email%type;
begin 
    select email
    into v_email
    from propietarios
    where dni = (
            select dni
            from historial_cargos
            where nombre_cargo = 'Presidente'
                and codcomunidad = p_codcomunidad);
    return v_email;
exception
    when no_data_found then
        return '-1';
end;
/

create or replace function devolver_email_administrador(p_codcomunidad in contratos_de_mandato.codcomunidad%type) return administradores.email%type
is 
    v_email administradores.email%type;
begin 
    select email
    into v_email
    from administradores
    where numcolegiado = (
            select numcolegiado
            from contratos_de_mandato
            where codcomunidad = p_codcomunidad);
    return v_email;
exception
    when no_data_found then
        return '-1';
end;
/

create or replace package paq_email as
    type t_email is record (
        emailpr propietarios.email%type,
        emailadmin administradores.email%type
    );
    type t_tabla_email is table of t_email index by binary_integer;
    procedure enviar_correo_presidente(p_emailpr in propiedades.email%type, p_subject in varchar2, p_message in varchar2);
    procedure enviar_correo_administrador(p_emailadmin in administradores.email%type, p_subject in varchar2, p_message in varchar2);
end paq_email;
/


create or replace package body paq_email as
    procedure enviar_correo_presidente(p_emailpr in propiedades.email%type, p_subject in varchar2, p_message in varchar2) is
    begin
        utl_mail.send(
            sender => 'alejandromanuelmartin03@gmail.com',
            recipients => p_emailpr,
            subject => p_subject,
            message => p_message);
    end;
    procedure enviar_correo_administrador(p_emailadmin in administradores.email%type, p_subject in varchar2, p_message in varchar2) is
    begin
        utl_mail.send(
            sender => 'alejandromanuelmartin03@gmail.com',
            recipients => p_emailadmin,
            subject => p_subject,
            message => p_message);
    end;
end paq_email;
/


create or replace trigger abono_recibo_tardio
after update of pagado on recibos_cuotas
for each row
declare
    v_fecha_actual date := sysdate;
    v_ano_recibo date := :old.fecha + interval '1' year;
    v_t_email paq_email.t_tabla_email;
begin
    if :new.pagado = 'Si' and v_ano_recibo <= v_fecha_actual then
        v_t_email(1).emailpr := devolver_email_propietario_presi(:new.dni);
        v_t_email(1).emailadmin := devolver_email_administrador(:new.codcomunidad);
        if v_t_email(1).emailpr is not null then
            paq_email.enviar_correo_presidente(v_t_email(1).emailpr, 'Recibo Pagado', 'El propietario ' || :new.dni || ' ha pagado un recibo.');
        end if;
        if v_t_email(1).emailadmin is not null then
            paq_email.enviar_correo_administrador(v_t_email(1).emailadmin, 'Recibo Pagado', 'El propietario ' || :new.dni || ' ha pagado un recibo.');
        end if;
        dbms_output.put_line('Email enviado');
    end if;
end abono_recibo_tardio;
/

--Alex
