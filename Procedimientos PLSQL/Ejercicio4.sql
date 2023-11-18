-- Realiza los módulos de programación necesarios para que cuando se abone un recibo que lleve más de un año
-- impagado se avise por correo electrónico al presidente de la comunidad y al administrador que tiene un contrato de
-- mandato vigente con la comunidad correspondiente. Añade el campo e-mail tanto a la tabla Propietarios como
-- Administradores.

alter table propietarios
add email varchar2(50)
constraint c_email check (REGEXP_LIKE(email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'));

alter table administradores
add email varchar2(50)
constraint c_email check (REGEXP_LIKE(email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'));

update propietarios set email='josemanuel87@gmail.com'
where dni = '49027387N';

update propietarios set email='rosa-asenjo.93@hotmail.es'
where dni = '09291497A';

update propietarios set email='lau.buenomar90@gmail.com'
where dni = '71441529X';
