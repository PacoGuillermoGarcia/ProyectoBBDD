1. Realiza una función que reciba un código de comunidad y un código de propiedad y, en caso de que se trate de un
local nos devuelva un 1 si está abierto o un 0 si está cerrado en el momento de la ejecución de la función. Debes
contemplar las siguientes excepciones: Comunidad Inexistente, Propiedad Inexistente en esa Comunidad, La
propiedad no es un local comercial.


2. Realiza un procedimiento llamado MostrarInformes, que recibirá tres parámetros, siendo el primero de ellos un
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
....
Número de Directivos: nn
Informe Tipo 2: Informe de Recibos Impagados. El segundo parámetro será un código de comunidad y el tercer
parámetro estará en blanco. El informe muestra los recibos impagados, de forma que salgan en primer lugar los
propietarios que adeudan un mayor importe.
INFORME DE RECIBOS IMPAGADOS
Comunidad: NombreComunidad
PoblaciónComunidad CodPostalComunidad
Fecha: xx/xx/xx
Propietario 1: D.xxxxxxxxxx xxxxxxxxxx xxxxxxxxxx
NumRecibo1
FechaRecibo1 Importe1
FechaReciboN ImporteN
...
NumReciboN
Total Adeudado D. xxxxx xxxxxxxxxx xxxxxxxxx: n,nnn.nn
Propietario 2: D. xxxxxxxxxx xxxxxxxxxx xxxxxxxxxx
NumRecibo1
FechaRecibo1 Importe1
FechaReciboN ImporteN
...
NumReciboN
Total Adeudado D. xxxxx xxxxxxxxxx xxxxxxxxx: n,nnn.nn....
Total Adeudado en la Comunidad: nnn,nnn.nn
Informe Tipo 3: Informe de Propiedades. Para este informe el segundo parámetro será un código de comunidad y el
tercero estará en blanco. Se mostrará ordenado por el porcentaje de participación total que corresponda a cada
propietario. En el caso de que la prpiedad tenga un inquilino se mostrarán su nombre y apellidos. Tendrá el
siguiente formato:
INFORME DE PROPIEDADES
Comunidad: NombreComunidad
PoblaciónComunidad CodPostalComunidad
Propietario1: D.xxxxxxxxxx xxxxxx xxxxxxxx
CodPropiedad1
TipoPropiedad1 Portal Planta Letra PorcentajeParticipación1 Inquilino1
TipoPropiedadN Portal Planta Letra PorcentajeParticipaciónN InquilinoN
...
CodPropiedadN
Porcentaje de Participación Total Propietario1: nn,nn %
Propietario2: D. xxxxx xxxxxxxx xxxxxxxxxx
...

create or replace procedure ExcepcionesInformes(p_codcomunidad comunidades.codcomunidad%type)
is
begin
	comunidadnoexiste(p_codcomunidad);
	tablacomunidadesvacia;
	tablapropietariosvacia;
	tablacargosvacia;
	tablarecibosvacia;
	tablapropiedadesvacia;
end ExcepcionesInformes;
/

create or replace procedure comunidadnoexiste(p_codcomunidad comunidades.codcomunidad%type)
is
	v_nombre comunidades.nombre%type;
begin
	select nombre into v_nombre
	from comunidades
	where codcomunidad=p_codcomunidad;
exception	
	when NO_DATA_FOUND then
		dbms_output.put_line('No existe una comunidad con ese codigo');
end comunidadnoexiste;
/

create or replace procedure tablacomunidadesvacia
is
	v_num NUMBER:=0;
begin
	select count(*) into v_num
	from comunidades;
	if v_num=0 then
		raise_application_error(-20002,'La tabla comunidades esta vacia');
	end if;
end tablacomunidadesvacia;
/

create or replace procedure tablapropietariosvacia
is
	v_num NUMBER:=0;
begin
	select count(*) into v_num
	from propietarios;
	if v_num=0 then
		raise_application_error(-20002,'La tabla comunidades esta vacia');
	end if;
end tablapropietariosvacia;
/

create or replace procedure tablacargosvacia
is
	v_num NUMBER:=0;
begin
	select count(*) into v_num
	from historialcargos;
	if v_num=0 then
		raise_application_error(-20002,'La tabla comunidades esta vacia');
	end if;
end tablacargosvacia;
/

create or replace procedure tablarecibosvacia
is
	v_num NUMBER:=0;
begin
	select count(*) into v_num
	from reciboscuotas;
	if v_num=0 then
		raise_application_error(-20002,'La tabla comunidades esta vacia');
	end if;
end tablarecibosvacia;
/		

create or replace procedure tablapropiedadesvacia
is
	v_num NUMBER:=0;
begin
	select count(*) into v_num
	from propiedades;
	if v_num=0 then
		raise_application_error(-20002,'La tabla comunidades esta vacia');
	end if;
end tablapropiedadesvacia;
/

create or replace procedure MostrarTipo1(p_codcomunidad comunidades.codcomunidad%type,p_fecha DATE)
is
	cursor c_cargo is
	select p.nombre||' '||p.apellidos as nombreape,p.tlfcontacto,h.nombrecargo
	from comunidades c,propietarios p,historialcargos h
	where h.codcomunidad=c.codcomunidad
	and p.dni=h.dni
	and p_fecha between h.fechainicio and h.fechafin
	and h.codcomunidad=p_codcomunidad
	order by h.nombrecargo;
begin
	dbms_output.put_line('INFORME CARGOS');
	Infocomunidad(p_codcomunidad,p_fecha);
	for v_prop in c_cargo loop
		case v_prop.nombrecargo
			when 'Presidente' then
				dbms_output.put_line('PRESIDENTE D.'||v_prop.nombreape||' '||'TLF:'||v_prop.tlfcontacto);
			when 'Vicepresidente' then
				dbms_output.put_line('VICEPRESIDENTE D.'||v_prop.nombreape||' '||'TLF:'||v_prop.tlfcontacto);
			when 'Secretario' then
				dbms_output.put_line('SECRETARIO D.'||v_prop.nombreape||' '||'TLF:'||v_prop.tlfcontacto);
			when 'Vocal' then
				dbms_output.put_line('VOCALES D.'||v_prop.nombreape||' '||'TLF:'||v_prop.tlfcontacto);
		end case;	
	end loop;
end MostrarTipo1;
/

create or replace procedure Infocomunidad(p_codcomunidad comunidades.codcomunidad%type,p_fecha DATE)
is
	nombrecom comunidades.nombre%type;
	codigopos comunidades.codigopostal%type;
begin
	select nombre,codigopostal into nombrecom,codigopos
	from comunidades
	where codcomunidad=p_codcomunidad;
	dbms_output.put_line('Comunidad:'||nombrecom||chr(10)||'Poblacion:'||codigopos||chr(10)||'Fecha:'||p_fecha);
end Infocomunidad;
/

create or replace procedure MostrarInformes(p_tipo NUMBER,p_codcomunidad comunidades.codcomunidad%type,p_fecha DATE)
is 
begin
	if p_tipo=1 then
		MostrarTipo1(p_codcomunidad,p_fecha);
	elsif p_tipo=2 then
		MostrarTipo2(p_codcomunidad);
	elsif p_tipo=3 then 
		MostrarTipo3(p_codcomunidad);
	else
		raise_application_error(-20001,'Tipo de informe incorrecto');
	end if;
end MostrarInformes;
/



3.Realiza los módulos de programación necesarios para que los honorarios anuales correspondientes a un contrato
de mandato vayan en función del número de propiedades de la comunidad y de la existencia o no de locales y
oficinas, de acuerdo con la siguiente tabla:
Num Propiedades Honorarios Anuales
1-5 600
6-10 1000
11-20 1800
>20 2500
La existencia de locales incrementará en un 20% los honorarios y la de oficinas en otro 10%
4. Realiza los módulos de programación necesarios para que cuando se abone un recibo que lleve más de un año
impagado se avise por correo electrónico al presidente de la comunidad y al administrador que tiene un contrato de
mandato vigente con la comunidad correspondiente. Añade el campo e-mail tanto a la tabla Propietarios como
Administradores.
5. Añade una columna ImportePendiente en la columna Propietarios y rellénalo con la suma de los importes de los
recibos pendientes de pago de cada propietario. Realiza los módulos de programación necesarios para que los
datos de la columna sean siempre coherentes con los datos que se encuentran en la tabla Recibos.
6. Realiza los módulos de programación necesarios para evitar que un propietario pueda ocupar dos cargos
diferentes en la misma comunidad de forma simultánea.
7. Realiza los módulos de programación necesarios para evitar que un administrador gestione más de cuatro
comunidades de forma simultánea.
8. Realiza los módulos de programación necesarios para evitar que se emitan dos recibos a un mismo propietario en
menos de 30 días.
