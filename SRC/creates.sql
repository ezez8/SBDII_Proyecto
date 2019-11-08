-----------------------------------------------------------------------------------
----------------------------------------TDAS---------------------------------------
-----------------------------------------------------------------------------------

create or replace type reg_ope as object(
    fecha_in  date,
    fecha_out date,
    
    member function validar_fechas return number,
    member function validar_solapamiento return number,
    member function calcular_precio return number
);
/
create or replace type body reg_ope
is
    member function validar_fechas return number
    is
    begin
        return 0;
    end;
    
    member function validar_solapamiento return number
    is
    begin
        return 0;
    end;
    
    member function calcular_precio return number
    is
    begin
        return 0;
    end;
end;
/

create or replace type reg_loc as object(
    ciudad    varchar(20),
    pais      varchar(20),
    latitud   number,
    longitud  number,
    direccion varchar(20),
    
    member function calculo_distancia return number,
    member function calculo_precio return number
);
/
create or replace type body reg_loc
is
    member function calculo_distancia return number
    is
    begin
        return 0;
    end;
    
    member function calculo_precio return number
    is
    begin
        return 0;
    end;
end;
/

create or replace type reg_sta as object(
    status varchar(3),
    
    member function validar_cambio_status return number,
    member function validar_ejecucion_status return number
);
/
create or replace type body reg_sta
is
    member function validar_cambio_status return number
    is
    begin
        return 0;
    end;
    
    member function validar_ejecucion_status return number
    is
    begin
        return 0;
    end;
end;
/

create or replace type cartera as object(
    millas number,
    dinero number,
    
    member function cambio_moneda return number,
    member function calculo_pago return number,
    member function ejecucion_pago return number
);
/
create or replace type body cartera
is
    member function cambio_moneda return number
    is
    begin
        return 0;
    end;
    
    member function calculo_pago return number
    is
    begin
        return 0;
    end;
    
    member function ejecucion_pago return number
    is
    begin
        return 0;
    end;
end;
/

--------------------------------------------------------------------------
-----------------------------------TABLES---------------------------------
--------------------------------------------------------------------------

-----------------------------PLAN_VIAJE-----------------------------------
create table plan_viaje(
    pv_id           number generated always as identity,
    pv_fecha        date   not null,
    pv_precio_total number not null,

    constraint pk_pv primary key(pv_id)
);
/

-----------------------------USUARIO--------------------------------------
create table usuario(
    u_id        number generated always as identity,
    u_nombre    varchar(20) not null,
    u_apellido  varchar(20) not null,
    u_telf      varchar(20) not null,
    u_correo    varchar(20) not null,
    u_billetera cartera     not null,
    u_passw     varchar(20) not null,
    u_nick      varchar(20) not null,
    u_foto      blob,

    constraint pk_u primary key(u_id)
);
/
create table plan_usuario(
    pu_id         number    generated always as identity,
    pu_comprador  number(1) not null check(pu_comprador in (1,0)),
    fk_pv_id         number    not null,
    fk_u_id          number    not null,

    constraint pk_pu primary key(pu_id),
    constraint fk_pv foreign key(fk_pv_id) references plan_viaje(pv_id),
    constraint fk_u  foreign key(fk_u_id)  references usuario(u_id)
);
/

-----------------------------ALQUILER DE AUTOS-----------------------------
create table alquiler_sp(
    id        number      primary key generated always as identity,
    nombre    varchar(20) not null,
    logo      blob
);
/
create table marca(
    id     number      primary key generated always as identity,
    nombre varchar(20) not null
);
/
create table modelo_auto(
    id        number      primary key generated always as identity,
    nombre    varchar(20) not null,
    des       varchar(20) not null,
    pasajeros number      not null,
    id_marca  number      not null references marca(id),
    foto      blob
);
/
create table automovil(
    id             number      primary key generated always as identity,
    precio         number      not null,
    color          varchar(20) not null,
    id_alquiler_sp number      not null references alquiler_sp(id),
    id_modelo_auto number      not null references modelo_auto(id)
);
/
create table alquiler_auto(
    id             number  primary key generated always as identity,
    dir_recogida   reg_loc not null,
    dir_devolucion reg_loc not null,
    fecha          reg_ope not null,
    precio_total   number  not null,
    status         reg_sta not null,
    id_plan_viaje  number  not null references plan_viaje(id),
    id_automovil   number  not null references automovil(id)
);

-----------------------------HOTEL--------------------------------------
create table hotel(
    id         number      primary key generated always as identity,
    nombre     varchar(20) not null,
    puntuacion number      not null,
    des        varchar(20) not null,
    locacion   reg_loc     not null,
    foto       blob
);
/
create table tipo_habitacion(
    id        number      primary key generated always as identity,
    huespedes number      not null,
    des       varchar(20) not null,
    precio    number      not null,
    id_hotel  number      not null references hotel(id),
    foto      blob
);
/
create table habitacion(
    id                 number      primary key generated always as identity,
    des                varchar(20) not null,
    id_tipo_habitacion number      not null references tipo_habitacion(id)
);
/
create table reserva_hotel(
    id            number  primary key generated always as identity,
    fecha         reg_ope not null,
    precio_total  number  not null,
    status        reg_sta not null,
    id_plan_viaje number  not null references plan_viaje(id),
    id_habitacion number  not null references habitacion(id),
    puntuacion    number
);
/

-----------------------------VUELO_PLAN--------------------------------------
create table aerolinea(
    id     number      primary key generated always as identity,
    nombre varchar(20) not null,
    tipo   varchar(3)  not null check(tipo in ('REG','RED','ESC')),
    logo   blob
);
/
create table avion(
    id     number      primary key generated always as identity,
    nombre varchar(20) not null
);
/
create table modelo_avion(
    id       number      primary key generated always as identity,
    nombre   varchar(20) not null,
    vel_max  number      not null,
    alc      number      not null,
    alt_max  number      not null,
    enverg   number      not null,
    anch_cab number      not null,
    alt_cab  number      not null,
    id_avion number      not null references avion(id),
    foto     blob
);
/
create table unidad_avion(
    id              number primary key generated always as identity,
    dist_ej         number not null,
    dist_cp         number not null,
    dist_ee         number not null,
    id_aerolinea    number not null references aerolinea(id),
    id_modelo_avion number not null references modelo_avion(id)
);
/
create table asiento(
    id              number      primary key generated always as identity,
    clase           varchar(2)  not null check(clase in ('EJ','CP','EE')),
    a_nombre        varchar(20) not null,
    id_unidad_avion number      not null references unidad_avion(id)
);
/
create table aeropuerto(
    id       number      primary key generated always as identity,
    nombre   varchar(20) not null,
    locacion reg_loc     not null,
    status   reg_sta     not null
);
/
create table vuelo(
    id        number  primary key generated always as identity,
    fecha     reg_ope not null,
    duracion  number  not null,
    status    reg_sta not null,
    precio_ej number  not null,
    precio_cp number  not null,
    precio_ee number  not null
);
/
create table nodo(
    id            number     primary key generated always as identity,
    modo          varchar(3) not null check(modo in ('ORI','DES')),
    status        reg_sta    not null,
    id_aeropuerto number     not null references aeropuerto(id),
    id_vuelo      number     not null references vuelo(id)
);
/
create table vuelo_plan(
    id            number     primary key generated always as identity,
    tipo          varchar(3) not null check(tipo in ('ESC','NOR')),
    modo          varchar(3) not null check(modo in ('IDA','IYV')),
    status        reg_sta    not null,
    id_plan_viaje number     not null references plan_viaje(id),
    id_asiento    number     not null references asiento(id),
    id_vuelo      number     not null references vuelo(id)
);
/

-----------------------------PAGO--------------------------------------
create table forma_pago(
    id     number      primary key generated always as identity,
    nombre varchar(20) not null,
    des    varchar(20) not null
);
/
create table reporte_pago(
    id            number primary key generated always as identity,
    monto         number not null,
    id_plan_viaje number not null references plan_viaje(id),
    id_forma_pago number not null references forma_pago(id),
    tarj_num      varchar(20)
);
/

-----------------------------SEGURO--------------------------------------
create table aseguradora(
    id     number      primary key generated always as identity,
    nombre varchar(20) not null,
    des    varchar(20) not null,
    logo   blob
);
/
create table seguro(
    id             number      primary key generated always as identity,
    nombre         varchar(20) not null,
    des            varchar(20) not null,
    precio         number      not null,
    id_aseguradora number      not null references aseguradora(id)
);
/
create table contrato(
    id            number primary key generated always as identity,
    cantidad      number not null,
    id_plan_viaje number not null references plan_viaje(id),
    id_seguro     number not null references seguro(id)
);
