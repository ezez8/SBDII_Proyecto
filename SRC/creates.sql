----------------------------------------------------------------------------------
----------------------------------------TDAS---------------------------------------
-----------------------------------------------------------------------------------

create or replace type reg_ope as object(
    fecha_in  date,
    fecha_out date,
    
    member function validar_fechas(fechaIn DATE, fechaOut DATE) return number,
    member function validar_solapamiento(fechaIn DATE, fechaOut DATE, fechaIn2 DATE, fechaOut2 DATE) return number,
    member function calcular_precio (fechaIn DATE, fechaOut DATE, precio NUMBER) return number
);
/
create or replace type cartera as object(
    millas number,
    dinero number,
    
    member function cambio_moneda return number,
    member function calculo_pago (identificador number, modo number) return number,
    member function ejecucion_pago (tarj varchar, tipo number, identificador number, modo number) return number
);
/
create or replace type body reg_ope
is
    member function validar_fechas (fechaIn DATE, fechaOut DATE) return number
    is
    begin
        if(fechaIn > fechaOut) THEN
            return 1;
        END IF;
        if (fechaIn < SYSDATE) THEN
            return 1;
        END IF;
        return 0;
    end;
    
    member function validar_solapamiento (fechaIn DATE, fechaOut DATE, fechaIn2 DATE, fechaOut2 DATE) return number
    is
    begin
        if(fechaIn > fechaIn2 AND fechaIn < fechaOut2) THEN
            return 1;
        END IF;
        if(fechaOut > fechaIn2 AND FechaOut < fechaOut2) THEN
            return 1;
        END IF;
        return 0;
    end;
    
    member function calcular_precio (fechaIn DATE, fechaOut DATE, precio NUMBER) return number
    is
    begin
        return (fechaOut - fechaIn) * precio;
    end;
end;
/
create or replace type reg_sta as object(
    status varchar(3),
    
    member procedure validar_cambio_status(tipo number, identificador number,reserva number, status varchar)
);
/
create or replace type reg_loc as object(
    ciudad    varchar(20),
    pais      varchar(20),
    direccion varchar(40),
    latitud number,
    longitud number,
    
    member function calculo_distancia (latitud NUMBER, longitud NUMBER, latitud2 NUMBER, longitud2 NUMBER)return number,
    member function calculo_precio (latitud NUMBER, longitud NUMBER, latitud2 NUMBER, longitud2 NUMBER, precio NUMBER) return number
);
/
create or replace type body reg_loc
is
    member function calculo_distancia (latitud NUMBER, longitud NUMBER, latitud2 NUMBER, longitud2 NUMBER) return number
    is
        earth_radius number := 6371;
        pi_approx number := 3.1415927/180;
        lat_delta number := (latitud2 - latitud)*pi_approx;
        lon_delta number := (longitud2 - longitud)*pi_approx;
        arc number := sin(lat_delta/2) * sin(lat_delta/2) + sin(lon_delta/2) * cos(latitud*pi_approx) * cos(latitud2*pi_approx);
    begin
        return earth_radius * 2 * atan2(sqrt(arc), sqrt(1-arc));
    end;
    
    member function calculo_precio (latitud NUMBER, longitud NUMBER, latitud2 NUMBER, longitud2 NUMBER, precio NUMBER) return number
    is
    begin
        return self.calculo_distancia(latitud, longitud, latitud2, longitud2) * precio;
    end;
end;
/
---------------------------------------------------------------------
----------------------------------SEQUENCES--------------------------
---------------------------------------------------------------------
create sequence seq_pv_id
    start with 1
    increment by 1;

create sequence seq_u_id
    start with 1
    increment by 1;

create sequence seq_pu_id
    start with 1
    increment by 1;

create sequence seq_asp_id
    start with 1
    increment by 1;

create sequence seq_m_id
    start with 1
    increment by 1;

create sequence seq_mau_id
    start with 1
    increment by 1;

create sequence seq_au_id
    start with 1
    increment by 1;

create sequence seq_aa_id
    start with 1
    increment by 1;

create sequence seq_ho_id
    start with 1
    increment by 1;

create sequence seq_th_id
    start with 1
    increment by 1;

create sequence seq_ha_id
    start with 1
    increment by 1;

create sequence seq_rh_id
    start with 1
    increment by 1;

create sequence seq_al_id
    start with 1
    increment by 1;

create sequence seq_av_id
    start with 1
    increment by 1;

create sequence seq_mav_id
    start with 1
    increment by 1;

create sequence seq_ua_id
    start with 1
    increment by 1;

create sequence seq_asi_id
    start with 1
    increment by 1;

create sequence seq_ap_id
    start with 1
    increment by 1;

create sequence seq_vu_id
    start with 1
    increment by 1;

create sequence seq_no_id
    start with 1
    increment by 1;

create sequence seq_vp_id
    start with 1
    increment by 1;

create sequence seq_fp_id
    start with 1
    increment by 1;

create sequence seq_rp_id
    start with 1
    increment by 1;

create sequence seq_ase_id
    start with 1
    increment by 1;

create sequence seq_se_id
    start with 1
    increment by 1;

create sequence seq_co_id
    start with 1
    increment by 1;

--------------------------------------------------------------------------
-----------------------------------TABLES---------------------------------
--------------------------------------------------------------------------

-----------------------------PLAN_VIAJE-----------------------------------
create table plan_viaje(
    pv_id           number,
    pv_fecha        date   not null,
    pv_precio_total number not null,

    constraint pk_pv primary key(pv_id)
);
/

-----------------------------USUARIO--------------------------------------
create table usuario(
    u_id        number,
    u_nombre    varchar(20) not null,
    u_apellido  varchar(20) not null,
    u_telf      varchar(20) not null,
    u_correo    varchar(20) not null,
    u_billetera cartera     not null,
    u_passw     varchar(20) not null,
    u_nick      varchar(20) not null,
    u_foto      blob        default empty_blob(),

    constraint pk_u primary key(u_id)
);
/
create table plan_usuario(
    pu_id        number,
    pu_comprador number(1) not null check(pu_comprador in (1,0)),
    pu_pv_id     number    not null,
    pu_u_id      number    not null,

    constraint pk_pu    primary key(pu_id),
    constraint fk_pu_pv foreign key(pu_pv_id) references plan_viaje(pv_id),
    constraint fk_pu_u  foreign key(pu_u_id)  references usuario(u_id)
);
/

-----------------------------ALQUILER DE AUTOS-----------------------------
create table alquiler_sp(
    asp_id     number,
    asp_nombre varchar(20) not null,
    asp_logo   blob        default empty_blob(),

    constraint pk_asp primary key(asp_id)
);
/
create table marca(
    m_id     number,
    m_nombre varchar(20) not null,

    constraint pk_m primary key(m_id)
);
/
create table modelo_auto(
    mau_id        number,
    mau_nombre    varchar(20) not null,
    mau_pasajeros number      not null,
    mau_m_id      number      not null,
    mau_foto      blob        default empty_blob(),
    mau_des       varchar(20),

    constraint pk_mau   primary key(mau_id),
    constraint fk_mau_m foreign key(mau_m_id) references marca(m_id)
);
/
create table automovil(
    au_id     number,
    au_precio number      not null,
    au_color  varchar(20) not null,
    au_asp_id number      not null,
    au_mau_id number      not null,
    au_status reg_sta not null,

    constraint pk_au     primary key(au_id),
    constraint fk_au_asp foreign key(au_asp_id) references alquiler_sp(asp_id),
    constraint fk_au_mau foreign key(au_mau_id) references modelo_auto(mau_id)
);
/
create table alquiler_auto(
    aa_id             number,
    aa_dir_recogida   reg_loc not null,
    aa_dir_devolucion reg_loc not null,
    aa_fecha          reg_ope not null,
    aa_precio_total   number  not null,
    aa_status         reg_sta not null,
    aa_pv_id          number  not null,
    aa_au_id          number  not null,

    constraint pk_aa primary key(aa_id),
    constraint fk_aa_pv foreign key(aa_pv_id) references plan_viaje(pv_id),
    constraint fk_aa_au foreign key(aa_au_id) references automovil(au_id)
);

-----------------------------HOTEL--------------------------------------
create table hotel(
    ho_id         number,
    ho_nombre     varchar(20) not null,
    ho_puntuacion number      not null,
    ho_locacion   reg_loc     not null,
    ho_foto       blob        default empty_blob(),
    ho_des        varchar(20),

    constraint pk_ho primary key(ho_id)
);
/
create table tipo_habitacion(
    th_id        number,
    th_huespedes number      not null,
    th_precio    number      not null,
    th_ho_id     number      not null,
    th_des       varchar(20),

    constraint pk_th    primary key(th_id),
    constraint fk_th_ho foreign key(th_ho_id) references hotel(ho_id)
);
/
create table habitacion(
    ha_id    number,
    ha_des   varchar(20),
    ha_th_id number      not null,
    ha_status reg_sta not null,

    constraint pk_ha    primary key(ha_id),
    constraint fk_ha_th foreign key(ha_th_id) references tipo_habitacion(th_id)
);
/
create table reserva_hotel(
    rh_id           number,
    rh_fecha        reg_ope not null,
    rh_precio_total number  not null,
    rh_status       reg_sta not null,
    rh_pv_id        number  not null,
    rh_ha_id        number  not null,
    rh_puntuacion   number,

    constraint pk_rh    primary key(rh_id),
    constraint fk_rh_pv foreign key(rh_pv_id) references plan_viaje(pv_id),
    constraint fk_rh_ha foreign key(rh_ha_id) references habitacion(ha_id)
);
/

-----------------------------VUELO_PLAN--------------------------------------
create table aerolinea(
    al_id     number,
    al_nombre varchar(20) not null,
    al_tipo   varchar(3)  not null check(al_tipo in ('REG','RED','ESC')),
    al_logo   blob        default empty_blob(),

    constraint pk_al primary key(al_id)
);
/
create table avion(
    av_id     number,
    av_nombre varchar(20) not null,

    constraint pk_av primary key(av_id)
);
/
create table modelo_avion(
    mav_id       number,
    mav_nombre   varchar(20) not null,
    mav_vel_max  number      not null,
    mav_alc      number      not null,
    mav_alt_max  number      not null,
    mav_enverg   number      not null,
    mav_anch_cab number      not null,
    mav_alt_cab  number      not null,
    mav_av_id    number      not null,
    mav_foto     blob        default empty_blob(),

    constraint pk_mav    primary key(mav_id),
    constraint fk_mav_av foreign key(mav_av_id) references avion(av_id)
);
/
create table unidad_avion(
    ua_id      number,
    ua_dist_ej number not null,
    ua_dist_cp number not null,
    ua_dist_ee number not null,
    ua_al_id   number not null,
    ua_mav_id  number not null,
    ua_status reg_sta not null,

    constraint pk_ua     primary key(ua_id),
    constraint fk_ua_al  foreign key(ua_al_id)  references aerolinea(al_id),
    constraint fk_ua_mav foreign key(ua_mav_id) references modelo_avion(mav_id)
);
/
create table asiento(
    asi_id       number,
    asi_clase    varchar(2)  not null check(asi_clase in ('EJ','CP','EE')),
    asi_ua_id    number      not null,

    constraint pk_asi    primary key(asi_id),
    constraint fk_asi_ua foreign key(asi_ua_id) references unidad_avion(ua_id)
);
/
create table aeropuerto(
    ap_id       number,
    ap_nombre   varchar(20) not null,
    ap_locacion reg_loc     not null,
    ap_status   reg_sta     not null,

    constraint pk_ap primary key(ap_id)
);
/
create table vuelo(
    vu_id        number,
    vu_fecha     reg_ope not null,
    vu_duracion  number  not null,
    vu_status    reg_sta not null,
    vu_precio_ej number  not null,
    vu_precio_cp number  not null,
    vu_precio_ee number  not null,

    constraint pk_vu primary key(vu_id)
);
/
create table nodo(
    no_id     number,
    no_modo   varchar(3) not null check(no_modo in ('ORI','DES')),
    no_status reg_sta    not null,
    no_ap_id  number     not null,
    no_vu_id  number     not null,

    constraint pk_no    primary key(no_id),
    constraint fk_no_ap foreign key(no_ap_id) references aeropuerto(ap_id),
    constraint fk_no_vu foreign key(no_vu_id) references vuelo(vu_id)
);
/
create table vuelo_plan(
    vp_id     number,
    vp_tipo   varchar(3) check(vp_tipo in ('ESC','NOR')),
    vp_modo   varchar(3) check(vp_modo in ('IDA','IYV')),
    vp_status reg_sta    not null,
    vp_pv_id  number,
    vp_asi_id number     not null,
    vp_vu_id  number     not null,

    constraint pk_vp     primary key(vp_id),
    constraint fk_vp_pv  foreign key(vp_pv_id)  references plan_viaje(pv_id),
    constraint fk_vp_asi foreign key(vp_asi_id) references asiento(asi_id),
    constraint fk_vp_vu  foreign key(vp_vu_id)  references vuelo(vu_id)
);
/

-----------------------------PAGO--------------------------------------
create table forma_pago(
    fp_id     number,
    fp_nombre varchar(20) not null,
    fp_des    varchar(20),

    constraint pk_fp primary key(fp_id)
);
/
create table reporte_pago(
    rp_id       number,
    rp_monto    number not null,
    rp_pv_id    number not null,
    rp_fp_id    number not null,
    rp_tarj_num varchar(20),
    rp_ar number not null,

    constraint pk_rp    primary key(rp_id),
    constraint fk_rp_pv foreign key(rp_pv_id) references plan_viaje(pv_id),
    constraint fk_rp_fp foreign key(rp_fp_id) references forma_pago(fp_id)
);
/

-----------------------------SEGURO--------------------------------------
create table aseguradora(
    ase_id     number,
    ase_nombre varchar(20) not null,
    ase_des    varchar(200),
    ase_logo   blob        default empty_blob(),

    constraint pk_ase primary key(ase_id)
);
/
create table seguro(
    se_id     number,
    se_nombre varchar(20) not null,
    se_des    varchar(200),
    se_precio number      not null,
    se_ase_id number      not null,

    constraint pk_se primary key(se_id),
    constraint fk_se_ase foreign key(se_ase_id) references aseguradora(ase_id)
);
/
create table contrato(
    co_id       number,
    co_cantidad number not null,
    co_pv_id    number not null,
    co_se_id    number not null,

    constraint pk_co    primary key(co_id),
    constraint fk_co_pv foreign key(co_pv_id) references plan_viaje(pv_id),
    constraint fk_co_se foreign key(co_se_id) references seguro(se_id)
);
/
create or replace type body cartera
is
    member function cambio_moneda return number
    is
    begin
        return 0;
    end;
     
    member function calculo_pago (identificador number, modo number) return number
    is
        CURSOR Precio_Hotel IS SELECT rh_precio_total as precio FROM reserva_hotel WHERE reserva_hotel.rh_pv_id = identificador;
        CURSOR Precio_Auto IS SELECT aa_precio_total as precio FROM alquiler_auto WHERE alquiler_auto.aa_pv_id = identificador;
        CURSOR Precio_Vuelo IS SELECT asiento.asi_clase, vuelo.vu_precio_ej, vuelo.vu_precio_ee, vuelo.vu_precio_cp FROM vuelo_plan 
            JOIN vuelo ON vuelo.vu_id = vuelo_plan.vp_vu_id
            JOIN asiento ON asiento.asi_id = vuelo_plan.vp_asi_id
            WHERE vuelo_plan.vp_pv_id = identificador;
        precio_total number := 0;
        CURSOR Precio_Contrato IS SELECT contrato.co_cantidad as cantidad, seguro.se_precio as precio FROM contrato 
        JOIN seguro ON seguro.se_id = contrato.co_se_id WHERE contrato.co_pv_id = identificador;
    begin
        DBMS_OUTPUT.PUT_LINE('Calculo de precio total para el plan de viaje');
        IF ( modo = 0 OR modo = 1) THEN
        OPEN Precio_Hotel;
        FOR precios IN Precio_Hotel LOOP
            precio_total:= precio_total + precios.precio;
        END LOOP;
        close precio_hotel;
        END IF;
        IF ( modo = 0 OR modo = 2) THEN
        OPEN Precio_Auto;
        FOR precios IN Precio_Auto LOOP
            precio_total:= precio_total + precios.precio;
        END LOOP;
        close precio_auto;
        END IF;
        IF ( modo = 0 OR modo = 3) THEN
        OPEN Precio_Vuelo;
        FOR precios IN Precio_Vuelo LOOP
            IF (Precios.asi_clase = 'EJ') THEN
                precio_total:= precio_total + precios.vu_precio_ej;
            END IF;
            IF (Precios.asi_clase = 'EE') THEN
                precio_total:= precio_total + precios.vu_precio_ee;
            END IF;
            IF (Precios.asi_clase = 'CP') THEN
                precio_total:= precio_total + precios.vu_precio_cp;
            END IF;
        END LOOP;
        close precio_vuelo;
        END IF;
        IF ( modo = 0 OR modo = 4) THEN
        OPEN Precio_Contrato;
        FOR precios IN Precio_Contrato LOOP
            precio_total:= precio_total + (precios.cantidad * precios.precio);
        END LOOP;
        close precio_contrato;
        END IF;
        return precio_total;
    end;
    
    member function ejecucion_pago(tarj varchar, tipo number, identificador number, modo number) return number
    is
        --Reportes pago hoteles--
        CURSOR Reportes_Pago_hotel IS SELECT rp_monto FROM reporte_pago WHERE rp_pv_id = identificador AND rp_ar = 1;
        --Reportes pago aviones--
        CURSOR Reportes_Pago_auto IS SELECT rp_monto FROM reporte_pago WHERE rp_pv_id = identificador AND rp_ar = 2;
        --Reportes pago autos--
        CURSOR Reportes_Pago_avion IS SELECT rp_monto FROM reporte_pago WHERE rp_pv_id = identificador AND rp_ar = 3;
        --Reportes pago seguro--
        CURSOR Reportes_Pago_seguro IS SELECT rp_monto FROM reporte_pago WHERE rp_pv_id = identificador AND rp_ar = 4;
        precio_total number;
    begin
            --Pago de toda la reservacion de todo
            IF (modo = 0) THEN
                precio_total:= calculo_pago(identificador,0);
                OPEN Reportes_Pago_hotel;
                FOR reporte IN Reportes_Pago_hotel LOOP
                    precio_total:= precio_total - reporte.rp_monto;
                END LOOP;
                close reportes_pago_hotel;
                OPEN Reportes_Pago_auto;
                FOR reporte IN Reportes_Pago_auto LOOP
                    precio_total:= precio_total - reporte.rp_monto;
                END LOOP;
                close reportes_pago_auto;
                OPEN Reportes_Pago_avion;
                FOR reporte IN Reportes_Pago_avion LOOP
                    precio_total:= precio_total - reporte.rp_monto;
                END LOOP;
                close reportes_pago_avion;
                OPEN Reportes_Pago_seguro;
                FOR reporte IN Reportes_Pago_seguro LOOP
                    precio_total:= precio_total - reporte.rp_monto;
                END LOOP;
                close reportes_pago_seguro;
            END IF;
            --Pago de toda la reservacion de hoteles
            IF (modo = 1 )THEN
                precio_total:= calculo_pago(identificador,1);
                OPEN Reportes_Pago_Hotel;
                FOR reporte IN Reportes_Pago_Hotel LOOP
                    precio_total:= precio_total - reporte.rp_monto;
                END LOOP;
                close reportes_pago_hotel;
            END IF;
            --Pago de toda la reservacion de autos
            IF(modo = 2 )THEN
                precio_total:= calculo_pago(identificador,2);
                OPEN Reportes_Pago_auto;
                FOR reporte IN Reportes_Pago_auto LOOP
                    precio_total:= precio_total - reporte.rp_monto;
                END LOOP;
                close reportes_pago_auto;
            END IF;
            --Pago de toda la reservacion de vuelos
            IF(modo = 3 )THEN
                precio_total:= calculo_pago(identificador,3);
                OPEN Reportes_Pago_avion;
                FOR reporte IN Reportes_Pago_avion LOOP
                    precio_total:= precio_total - reporte.rp_monto;
                END LOOP;
                close reportes_pago_avion;
            END IF;
            --Pago de toda la reservacion de seguros
            IF(modo = 4 )THEN
                precio_total:= calculo_pago(identificador,4);
                OPEN Reportes_Pago_seguro;
                FOR reporte IN Reportes_Pago_seguro LOOP
                    precio_total:= precio_total - reporte.rp_monto;
                END LOOP;
                close reportes_pago_seguro;
            END IF;
        --Condiciones de millas y pago incompleto.
        IF (tipo = 3 and modo <> 3) THEN
            raise_application_error(1020, 'No se puede pagar con millas reservaciones que no sean de viajes.');
        END IF;
        IF (tipo = 3 and self.millas < precio_total) THEN
            raise_application_error(1021, 'Solamente se puede pagar con millas la totalidad de la reserva.');
            END IF;
        IF (tipo = 4 and self.dinero < precio_total) THEN
            raise_application_error(1022, 'No hay dinero suficiente para el pago.');
        END IF;
        INSERT INTO REPORTE_PAGO (rp_monto, rp_tarj_num, rp_fp_id, rp_pv_id) VALUES (precio_total, tarj, tipo, identificador);
    end;
end;
/
create or replace function reserva_hecha2(auto_identificador number) return number
IS
    retornable number;
BEGIN
    SELECT count(*) into retornable FROM Alquiler_Auto A 
                    INNER JOIN Alquiler_Auto B ON B.aa_id <> A.aa_id 
                    AND B.aa_au_id = auto_identificador
                    AND B.aa_fecha.validar_solapamiento(B.aa_fecha.fecha_in, B.aa_fecha.fecha_out, A.aa_fecha.fecha_in, A.aa_fecha.fecha_out) = 1;
    return retornable;
END;
/
create or replace procedure reemplazo_auto(reserva_auto_identificador number, identificador_automovil number)
IS
  Cursor automovil_disp IS Select * from automovil A WHERE A.au_mau_id =
    (SELECT B.au_mau_id FROM automovil B WHERE B.au_id = identificador_automovil)
    AND A.au_id <> identificador_automovil
    AND A.au_status.status = 'ACT';
    flag number:=1;
    reserva alquiler_auto%ROWTYPE;
    plan_v number;
BEGIN
    OPEN automovil_disp;
    FOR automovil_res IN automovil_disp LOOP
        IF (reserva_hecha2(automovil_res.au_id) = 0) THEN
            UPDATE Alquiler_Auto SET aa_id = reserva_auto_identificador, aa_au_id = automovil_res.au_id;
            flag := 0;
            EXIT;
        END IF;
    END LOOP;
    IF (flag = 1) THEN
        SELECT * INTO reserva FROM Alquiler_Auto A WHERE A.aa_id = reserva_auto_identificador;
        SELECT Plan_Viaje.pv_id INTO plan_v FROM Plan_Viaje JOIN Reserva_Hotel ON reserva.aa_pv_id = Plan_Viaje.pv_id;
        reserva.aa_status.validar_cambio_status(1, plan_v, reserva.aa_id, 'INA');
    END IF;
    close automovil_disp;
END;
/
create or replace function reserva_hecha(habitacion_identificador number) return number
IS
    retornable number;
BEGIN
    SELECT count(*) into retornable FROM Reserva_hotel A 
                    INNER JOIN Reserva_Hotel B ON B.rh_id <> A.rh_id 
                    AND B.rh_ha_id = habitacion_identificador
                    AND B.rh_fecha.validar_solapamiento(B.rh_fecha.fecha_in, B.rh_fecha.fecha_out, A.rh_fecha.fecha_in, A.rh_fecha.fecha_out) = 1;
    return retornable;
END;
/
create or replace procedure reemplazo_habitacion(reserva_hotel_identificador number, identificador_habitacion number)
IS
  Cursor habitacion_disp IS Select * from habitacion A WHERE A.ha_th_id =
    (SELECT B.ha_th_id FROM habitacion B WHERE B.ha_id = identificador_habitacion)
    AND A.ha_id <> identificador_habitacion
    AND A.ha_status.status = 'ACT';
    flag number:=1;
    reserva reserva_hotel%ROWTYPE;
    plan_v number;
BEGIN
    OPEN habitacion_disp;
    FOR habitacion_res IN habitacion_disp LOOP
        IF (reserva_hecha(habitacion_res.ha_id) = 0) THEN
            UPDATE Reserva_Hotel SET rh_ha_id = habitacion_res.ha_id WHERE Reserva_Hotel.rh_id = reserva_hotel_identificador;
            flag := 0;
            EXIT;
        END IF;
    END LOOP;
    IF (flag = 1) THEN
        SELECT * INTO reserva FROM Reserva_Hotel A WHERE A.rh_id = reserva_hotel_identificador;
        SELECT Plan_Viaje.pv_id INTO plan_v FROM Plan_Viaje JOIN Reserva_Hotel ON reserva.rh_pv_id = Plan_Viaje.pv_id;
        reserva.rh_status.validar_cambio_status(1, plan_v, reserva.rh_id, 'INA');
    END IF;
    close habitacion_disp;
END;
/
create or replace type body reg_sta
is
    member procedure validar_cambio_status(tipo number, identificador number,reserva number, status varchar)
    is
        Cursor registro IS select vuelo.vu_precio_ej, vuelo.vu_precio_ee, vuelo.vu_precio_cp, asiento.asi_clase, Vuelo_Plan.vp_id
            FROM vuelo JOIN vuelo_plan on vuelo_plan.vp_vu_id = vuelo.vu_id
            JOIN asiento on asiento.asi_id = vuelo_plan.vp_asi_id
            WHERE vuelo_plan.vp_pv_id=identificador;
        Cursor hotel_reg IS SELECT Reserva_Hotel.rh_precio_total as precio FROM Reserva_Hotel
            WHERE Reserva_Hotel.rh_pv_id = identificador AND Reserva_Hotel.rh_id = reserva;
        Cursor auto_reg IS SELECT Alquiler_Auto.aa_precio_total as precio FROM Alquiler_Auto
            WHERE Alquiler_auto.aa_pv_id = identificador AND Alquiler_Auto.aa_id = reserva;
        Cursor billetera_reg IS SELECT Usuario.u_billetera.dinero as dinero, Usuario.u_billetera.millas as millas, Usuario.u_id FROM Usuario
            JOIN Plan_Usuario on plan_usuario.pu_u_id = usuario.u_id
            JOIN Plan_Viaje on plan_usuario.pu_pv_id = plan_viaje.pv_id
            WHERE Plan_Viaje.pv_id = identificador;
        Cursor reservas_hab IS SELECT * FROM Reserva_Hotel WHERE Reserva_Hotel.rh_ha_id = reserva;
        Cursor reservas_aut IS SELECT * FROM Alquiler_Auto WHERE Alquiler_Auto.aa_au_id = reserva;
        busq_billetera billetera_reg%ROWTYPE;
        busq_hotel hotel_reg%ROWTYPE;
        busq_auto auto_reg%ROWTYPE;
        reg_fecha reg_ope;
    begin
        --Cuando se realiza el cambio de status debe  realizar las distintas validaciones
        --Recordar comprobar sysdate para el cambio de fechas, etc.
            OPEN billetera_reg;
            FETCH billetera_reg into busq_billetera;
            IF ( tipo = 0 ) THEN
            ------------------------AVION----------------------------------------
                --validar el cambio de status y asignacion a un vuelo mas cercano.
                IF( status <> 'ACT' ) THEN
                        IF (self.status <> status AND self.status <> 'RTR') THEN
                            --Primero se busca otro vuelo en las mismas fechas
                            --Segundo se busca otro vuelo como sustitucion en otra aerolinea.
                            --Tercero se busca otro vuelo en otras fechas.
                            --Cuarto se devuelve el dinero de la rservacion.
                            dbms_output.put_line('SE CANCELO RESERVA DE VUELO');
                            OPEN registro;
                            FOR busq in registro LOOP
                                IF (busq.asi_clase = 'EJ') THEN
                                    UPDATE Usuario SET Usuario.u_billetera = cartera(busq_billetera.millas, busq_billetera.dinero + busq.vu_precio_ej * 0.8);
                                END IF;
                                IF (busq.asi_clase = 'EE') THEN
                                    UPDATE Usuario SET Usuario.u_billetera = cartera(busq_billetera.millas, busq_billetera.dinero + busq.vu_precio_ee * 0.8);
                                END IF;
                                IF (busq.asi_clase = 'CP') THEN
                                    UPDATE Usuario SET Usuario.u_billetera = cartera(busq_billetera.millas, busq_billetera.dinero + busq.vu_precio_cp * 0.8);
                                END IF;
                                UPDATE Vuelo_Plan SET vp_pv_id = null WHERE Vuelo_Plan.vp_id = busq.vp_id;
                            END LOOP;
                            close registro;
                        END IF;
                        IF (self.status = 'RTR') THEN
                            dbms_output.put_line('SE CANCELO RESERVA DE VUELO');
                            
                        END IF;
                END IF;
            END IF;
            IF( tipo = 1 )THEN
            ------------------------HOTEL----------------------------------------
                --validar el cambio de status y asignacion a un vuelo mas cercano.
                    IF( status <> 'ACT' ) THEN
                        IF (status <> self.status) THEN
                            -- Primero se busca una habitacion disponible en las fechas especificadas
                            -- Segundo se busca una habitacion de menor precio y se devuelve el dinero
                            -- Tercero se busca una habitacion en otro hotel cercano y se devuelve el dinero si es necesario.
                            -- Cuarto se devuelve el dinero al no conseguir habitacion.
                            dbms_output.put_line('EPALE');
                            OPEN hotel_Reg;
                            FETCH hotel_Reg into busq_hotel;
                            UPDATE Usuario SET Usuario.u_billetera = cartera(busq_billetera.millas, busq_billetera.dinero + busq_hotel.precio * 0.8);
                            close hotel_reg;
                        END IF;
                    END IF;
            END IF;
            IF( tipo = 2 )THEN
            ------------------------AUTO----------------------------------------
                --validar el cambio de status y asignacion a un vuelo mas cercano.
                    IF( status <> 'ACT' ) THEN
                        IF (status <> self.status) THEN
                            --Primero se busca un auto en el lugar de encuentro
                            --Segundo se busca un auto en otro alquiler de autos.
                            --Tercero se devuelve el dinero al no conseguir habitacion.
                            dbms_output.put_line('EPALE');
                            OPEN auto_Reg;
                            FETCH auto_Reg into busq_auto;
                            UPDATE Usuario SET Usuario.u_billetera = cartera(busq_billetera.millas, busq_billetera.dinero + busq_auto.precio * 0.8);
                            close auto_reg;
                        END IF;
                END IF;
            END IF;
            IF( tipo = 3 )THEN
            ------------------------HABITACION-UNIDAD----------------------------------------
                --validar el cambio de status y asignacion a un vuelo mas cercano.
                    IF( status <> 'ACT' ) THEN
                        IF (status <> self.status) THEN
                            --Primero se busca un auto en el lugar de encuentro
                            --Segundo se busca un auto en otro alquiler de autos.
                            --Tercero se devuelve el dinero al no conseguir habitacion.
                            dbms_output.put_line('EPALE');
                            OPEN reservas_hab;
                            FOR reservaloop in reservas_hab LOOP
                                reg_fecha := reservaloop.rh_fecha;
                                if (reservaloop.rh_fecha.validar_fechas(reg_fecha.fecha_in, reg_fecha.fecha_out) = 0) then
                                    reemplazo_habitacion(reservaloop.rh_id, reserva);
                                end if;
                            END LOOP;
                            close reservas_hab;
                        END IF;
                END IF;
            END IF;
            IF( tipo = 4 )THEN
            ------------------------AUTO-UNIDAD----------------------------------------
                --validar el cambio de status y asignacion a un vuelo mas cercano.
                    IF( status <> 'ACT' ) THEN
                        IF (status <> self.status) THEN
                            --Primero se busca un auto en el lugar de encuentro
                            --Segundo se busca un auto en otro alquiler de autos.
                            --Tercero se devuelve el dinero al no conseguir habitacion.
                            dbms_output.put_line('EPALE');
                            OPEN reservas_aut;
                            FOR reservaloop in reservas_aut LOOP
                                dbms_output.put_line('EPALE');
                                reg_fecha := reservaloop.aa_fecha;
                                if (reg_fecha.validar_fechas(reg_fecha.fecha_in, reg_fecha.fecha_out) = 0) then
                                    reemplazo_auto(reservaloop.aa_id, reserva);
                                end if;
                            END LOOP;
                            close reservas_aut;
                        END IF;
                END IF;
            END IF;
            close billetera_reg;
    end;
end;