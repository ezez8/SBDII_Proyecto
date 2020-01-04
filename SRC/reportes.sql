create or replace procedure repo1_1(cur out sys_refcursor)
is
begin

    open cur for
    select distinct al_id,
    decode(al_tipo, 'REG', 'Regionales', 'RED', 'De Red', 'ESC', 'De gran escala') "tipo_al",
    listagg(av_nombre||' '||mav_nombre, chr(10)) within group (order by mav_nombre) over (partition by al_id) "flota"
    from aerolinea, unidad_avion, modelo_avion, avion
    where al_id = ua_al_id and ua_mav_id = mav_id and mav_av_id = av_id
    order by al_id;
/*/
    open cur for
    select al_id, al_logo "Logo Aerolinea",
    decode(al_tipo, 'REG', 'Regionales', 'RED', 'De Red', 'ESC', 'De gran escala') "Tipo de Aerolinea",
    listagg(av_nombre||' '||mav_nombre, chr(10)) within group (order by mav_nombre) over (partition by al_id) "Flota"
    from aerolinea, unidad_avion, modelo_avion, avion
    where al_id = ua_al_id and ua_mav_id = mav_id and mav_av_id = av_id
    order by al_id;
*/
end;
/
create or replace procedure repo1_2(cur out sys_refcursor)
is
begin
    open cur for
    select al_id, al_logo
    from aerolinea
    order by al_id;
end;
/
create or replace procedure repo2(cur out sys_refcursor, var_al_nombre in varchar)
is
begin
    open cur for
    select al_logo "Logo de Aerolínea", 
    av_nombre||chr(10)||mav_nombre "Avión",
    mav_foto "Foto avión",
    mav_nombre "Modelo",
    (select count(*) from unidad_avion where ua_al_id = al_id and ua_mav_id = mav_id) "Cantidad de aviones que posee",
    ua_dist_ej||' asientos en Clase Ejecutiva Dreams'||chr(10)||ua_dist_cp||' asientos en Economy Extra'||chr(10)||ua_dist_ee||' asientos en Cabina Principal' "Asientos disponibles por clase"
    from aerolinea, avion, modelo_avion, unidad_avion
    where al_nombre = lower(var_al_nombre) and al_id = ua_al_id and ua_mav_id = mav_id and mav_av_id = av_id;
end;
/
create or replace procedure repo3(cur out sys_refcursor, var_av_nombre in varchar, var_mav_nombre in varchar)
is
begin
    open cur for
    select al_logo "Logo de Aerolinea",
    av_nombre||' '||mav_nombre "Avion",
    mav_foto "Foto Avion",
    mav_nombre "Modelo",
    round(mav_vel_max/1234.8, 2)||'('||mav_vel_max||'km/h)' "Velocidad Máxima Mach",
    round(mav_alc/1.852, 0)||' millas nauticas('||mav_alc||'km)' "Alcance",
    mav_alt_max||' ft' "Altitud maxima de vuelo",
    mav_enverg||' m' "Envergadura",
    mav_anch_cab||' m',
    mav_alt_cab||' m' 
    from aerolinea, unidad_avion, modelo_avion, avion
    where av_nombre = initcap(var_av_nombre) and mav_nombre = lower(var_mav_nombre) and al_id = ua_al_id and ua_mav_id = mav_id and mav_av_id = av_id;
end;
/
create or replace procedure repo4(cur out sys_refcursor)
is
begin
    open cur for
    select u_correo "Correo de usuario",
    u_foto "Foto",
    u_nombre||' '||u_nombre2 "Nombre",
    u_apellido||' '||u_apellido2 "Apellido",
    u_telf "Numero de telefono"
    from usuario;
end;
/
create or replace procedure repo5(cur out sys_refcursor, p_u_correo varchar, p_fecha_s varchar, p_fecha_r varchar)
is 
begin
    open cur for
    select distinct
    u_correo "Correo de Usuario",
    (select aep.ap_locacion.pais from aeropuerto aep, nodo no where no.no_modo = 'ORI' and no.no_vu_id = vu_id and no.no_ap_id = aep.ap_id)
    ||'-'|| (select aep.ap_locacion.pais from aeropuerto aep, nodo no where no.no_modo = 'DES' and no.no_vu_id = vu_id and no.no_ap_id = aep.ap_id)
    ||'-'||to_char(vu.vu_fecha.fecha_in, 'dy mon dd yyyy') "Vuelo",
    to_char(vu.vu_fecha.fecha_in, 'mon dd yyyy') "Fecha de salida",
    to_char(vu.vu_fecha.fecha_out, 'mon dd yyyy') "Fecha de regreso",
    to_char(vu.vu_fecha.fecha_in, 'hh:mm') "Sale",
    to_char(vu.vu_fecha.fecha_out, 'hh:mm') "Llega",
    vu_duracion||'h 0m' "Duracion",
    '$'||vu_precio_ej "Precio pagado"
    from usuario, plan_usuario, plan_viaje pv, vuelo_plan, asiento, unidad_avion, aerolinea, vuelo vu, nodo, aeropuerto ap 
    where u_id = pu_u_id and pu_pv_id = pv_id and pv_id = vp_pv_id and vp_asi_id = asi_id and asi_ua_id = ua_id
    and ua_al_id = al_id and vp_vu_id = vu_id and vu_id = no_vu_id and no_ap_id = ap_id
    and u_correo = p_u_correo and to_date(p_fecha_s,'dd-mm-yyyy') <= vu.vu_fecha.fecha_in and to_date(p_fecha_r,'dd-mm-yyyy') >= vu.vu_fecha.fecha_out;
end;
/
create or replace procedure repo7(cur out sys_refcursor, p_fecha_s varchar, p_fecha_r varchar)
is 
begin
    open cur for
    select  p_fecha_s || ' - ' || p_fecha_r "fecha", D.ap_locacion.pais "Lugar de origen", E.ap_locacion.pais "Lugar de destino",
    --Se selecciona el count de los vuelos
        (select count(*) from vuelo_plan Z where Z.vp_vu_id = A.vu_id) "Cantidad de reservaciones"
    from vuelo A 
    join nodo B on B.no_vu_id = A.vu_id and B.no_modo = 'ORI'
    join nodo C on C.no_vu_id = A.vu_id and C.no_modo = 'DES'
    join aeropuerto D on D.ap_id = B.no_ap_id
    join aeropuerto E on E.ap_id = C.no_ap_id
    where A.vu_fecha.fecha_in >= to_date(p_fecha_s,'dd-mm-yyyy') and A.vu_fecha.fecha_in <= to_date(p_fecha_r, 'dd-mm-yyyy')
    and rownum <= 10
    order by "Cantidad de reservaciones" desc;
end;
/
create or replace procedure repo8(cur out sys_refcursor, origen varchar, destino varchar, p_fecha_s varchar, p_fecha_r varchar)
is 
begin
    open cur for
    select AL.al_logo "Logo de aerolinea", BASE.* FROM
    (select distinct A.al_id "id aero", p_fecha_s || ' - ' || p_fecha_r "fecha", H.ap_locacion.pais "Lugar de origen", I.ap_locacion.pais "Lugar de destino",
        (select count(*) from (select distinct vu.vu_id from vuelo vu
            join vuelo_plan vp on vp.vp_vu_id = vu.vu_id
            join asiento asi on asi.asi_id = vp_asi_id
            join unidad_avion ua on ua.ua_id = asi.asi_ua_id
            join nodo noF on noF.no_vu_id = vu.vu_id and noF.no_modo = 'ORI'
            join nodo noG on noG.no_vu_id = vu.vu_id and noG.no_modo = 'DES'
            join aeropuerto aeH on aeH.ap_id = noF.no_ap_id
            join aeropuerto aeI on aeI.ap_id = noG.no_ap_id
            where ua.ua_al_id = 1 and 
            vu.vu_fecha.fecha_in >= to_date(p_fecha_s,'dd-mm-yyyy') and vu.vu_fecha.fecha_in <= to_date(p_fecha_r, 'dd-mm-yyyy') and
            aeH.ap_locacion.pais = origen and aeI.ap_locacion.pais = destino
        ) src) "Cantidad de servicios"
    from aerolinea A
    join unidad_avion B on B.ua_al_id = A.al_id
    join asiento C on C.asi_ua_id = B.ua_id
    join vuelo_plan D on D.vp_asi_id = C.asi_id
    join vuelo E on E.vu_id = D.vp_vu_id
    join nodo F on F.no_vu_id = E.vu_id and F.no_modo = 'ORI'
    join nodo G on G.no_vu_id = E.vu_id and G.no_modo = 'DES'
    join aeropuerto H on H.ap_id = F.no_ap_id
    join aeropuerto I on I.ap_id = G.no_ap_id
    where E.vu_fecha.fecha_in >= to_date(p_fecha_s,'dd-mm-yyyy') and E.vu_fecha.fecha_in <= to_date(p_fecha_r, 'dd-mm-yyyy') and
    H.ap_locacion.pais = origen and I.ap_locacion.pais = destino) BASE
    join Aerolinea AL on AL.al_id = "id aero"
    where rownum <= 5
    ORDER BY "Cantidad de servicios" DESC;
end;
/
create or replace procedure repo9(cur out sys_refcursor, p_fecha_s varchar, p_fecha_r varchar, correo varchar)
is 
begin
    open cur for
    select ho.ho_foto "Foto del automovil", BASE.* from
    (
        select distinct A.ho_id "id hotel", A.ho_nombre "Marca-Modelo Automovil",
        G.u_correo "Correo de usuario",
        D.rh_fecha.fecha_in "Fecha y hora de inicio",
        D.rh_fecha.fecha_out "Fecha y hora de fin",
        B.au_precio || 'USD/dia'"Precio por dia",
        D.aa_precio_total || 'USD' "Precio total"
        FROM modelo_auto A
        join automovil B on B.au_mau_id = A.mau_id
        join alquiler_sp C on C.asp_id = B.au_asp_id
        join alquiler_auto D on D.aa_au_id = B.au_id
        join plan_viaje E on E.pv_id = D.aa_pv_id
        join plan_usuario F on F.pu_pv_id = E.pv_id
        join Usuario G on G.u_id = F.pu_u_id and G.u_correo = correo
        where D.aa_fecha.fecha_in >= to_date(p_fecha_s,'dd-mm-yyyy') and D.aa_fecha.fecha_in <= to_date(p_fecha_r,'dd-mm-yyyy')
    ) BASE
    join hotel ho on ho.ho_id = "id hotel";
end;
/
create or replace procedure repo10(cur out sys_refcursor, lugar varchar, p_fecha_s varchar, p_fecha_r varchar)
is 
begin
    open cur for
    select ho.ho_foto "Foto del lugar", BASE.* FROM
    (
        select DISTINCT A.ho_id "id hotel", A.ho_locacion.ciudad "Nombre del lugar", to_date(p_fecha_s,'dd-mm-yyyy') "Fecha de inicio", to_date(p_fecha_r,'dd-mm-yyyy') "Fecha de fin", 
            (
                select count(rh.rh_id) "Cantidad de reservas" from reserva_hotel rh
                join tipo_habitacion B on B.th_ho_id = A.ho_id
                join habitacion C on C.ha_th_id = B.th_id
                where rh.rh_ha_id = C.ha_id and C.ha_th_id = B.th_id and A.ho_id = B.th_ho_id 
                and rh.rh_fecha.fecha_in >= to_date(p_fecha_s,'dd-mm-yyyy') and rh.rh_fecha.fecha_in <= to_date(p_fecha_r,'dd-mm-yyyy') 
            ) "Cantidad de reservas",
            (
                select coalesce(avg(rh.rh_puntuacion), 0) "Puntuacion promedio" from reserva_hotel rh
                join tipo_habitacion B on B.th_ho_id = A.ho_id
                join habitacion C on C.ha_th_id = B.th_id
                where rh.rh_ha_id = C.ha_id and C.ha_th_id = B.th_id and A.ho_id = B.th_ho_id 
                and rh.rh_fecha.fecha_in >= to_date(p_fecha_s,'dd-mm-yyyy') and rh.rh_fecha.fecha_in <= to_date(p_fecha_r,'dd-mm-yyyy') and rh.rh_puntuacion is not null
            ) "Puntuacion promedio"
        from hotel A
        where A.ho_nombre = lugar
    ) BASE
    join Hotel ho on ho.ho_id = "id hotel";
end;
/
create or replace procedure repo11(cur out sys_refcursor, p_fecha_s varchar, p_fecha_r varchar, correo varchar)
is 
begin
    open cur for
    select mau.mau_foto "Foto del automovil", BASE.* from
    (
        select distinct A.mau_id "id modelo", A.mau_nombre "Marca-Modelo Automovil", C.asp_logo "Proveedor de servicio",
        G.u_correo "Correo de usuario", D.aa_dir_recogida "Direccion de recogida",
        D.aa_dir_devolucion "Direccion de devolucion",
        D.aa_fecha.fecha_in "Fecha y hora de inicio",
        D.aa_fecha.fecha_out "Fecha y hora de fin",
        B.au_precio || 'USD/dia'"Precio por dia",
        D.aa_precio_total || 'USD' "Precio total"
        FROM modelo_auto A
        join automovil B on B.au_mau_id = A.mau_id
        join alquiler_sp C on C.asp_id = B.au_asp_id
        join alquiler_auto D on D.aa_au_id = B.au_id
        join plan_viaje E on E.pv_id = D.aa_pv_id
        join plan_usuario F on F.pu_pv_id = E.pv_id
        join Usuario G on G.u_id = F.pu_u_id and G.u_correo = correo
        where D.aa_fecha.fecha_in >= to_date(p_fecha_s,'dd-mm-yyyy') and D.aa_fecha.fecha_in <= to_date(p_fecha_r,'dd-mm-yyyy')
    ) BASE
    join modelo_auto mau on mau.mau_id = "id modelo";
end;
/
create or replace procedure repo12(cur out sys_refcursor, p_fecha_s varchar, p_fecha_r varchar)
is 
begin
    open cur for
    select AL.al_logo, BASE.* from
    (
        select  DISTINCT A.vu_id "id vuelo", A.vu_fecha.fecha_in "Fecha y hora de vuelo", D.ap_locacion.pais "Lugar de origen", E.ap_locacion.pais "Lugar de destino",
            A.vu_fecha.fecha_in + 1/24 * A.vu_duracion "Hora estimada de llegada"
        from vuelo A 
        join nodo B on B.no_vu_id = A.vu_id and B.no_modo = 'ORI'
        join nodo C on C.no_vu_id = A.vu_id and C.no_modo = 'DES'
        join aeropuerto D on D.ap_id = B.no_ap_id
        join aeropuerto E on E.ap_id = C.no_ap_id
        where A.vu_fecha.fecha_in >= to_date(p_fecha_s,'dd-mm-yyyy') and A.vu_fecha.fecha_in <= to_date(p_fecha_r, 'dd-mm-yyyy')
    ) BASE
    join vuelo_plan vp on vp.vp_vu_id = "id vuelo"
    join asiento asi on asi.asi_id = vp_asi_id
    join unidad_avion ua on ua.ua_id = asi.asi_ua_id
    join aerolinea AL on Al.al_id = ua.ua_al_id;
end;
/
create or replace procedure repo13(cur out sys_refcursor, p_fecha_s varchar, p_fecha_r varchar)
is 
begin
    open cur for
    select ase.ase_logo, BASE.* FROM
    (
        select distinct A.ase_id "id aseguradora", p_fecha_s || ' - ' || p_fecha_r "Fecha (dese - hasta)",
        I.ap_locacion.pais "Lugar de destino",
        J.ap_locacion.pais "Lugar de origen",
        (
            select count(co.co_id) from contrato co
            where co.co_pv_id = C.pv_id
        ) "Cantidad de servicios"
        from aseguradora A
        join seguro D on D.se_ase_id = A.ase_id
        join Contrato B on B.co_se_id = D.se_id
        join Plan_Viaje C on C.pv_id = B.co_pv_id
        join vuelo_plan E on E.vp_pv_id = C.pv_id
        join vuelo F on F.vu_id = E.vp_vu_id
        join nodo G on G.no_vu_id = F.vu_id and G.no_modo = 'ORI'
        join nodo H on H.no_vu_id = F.vu_id and H.no_modo = 'DES'
        join aeropuerto I on I.ap_id = G.no_ap_id
        join aeropuerto J on J.ap_id = H.no_ap_id
        where F.vu_fecha.fecha_in >= to_date(p_fecha_s,'dd-mm-yyyy') and F.vu_fecha.fecha_in <= to_date(p_fecha_r, 'dd-mm-yyyy')
    ) BASE
    join aseguradora ase on ase.ase_id = "id aseguradora";
end;

/*
    select ase.ase_logo, BASE.* FROM
    (
        select distinct A.ase_id "id aseguradora", '01-01-2020' || ' - ' || '29-01-2020' "Fecha (desde - hasta)",
        (
            select count(co.co_id) FROM contrato co
            where co.co_pv_id = C.pv_id
        ) 
        "Cantidad de servicios",
        I.ap_locacion.pais "Lugar de destino",
        J.ap_locacion.pais "Lugar de origen"
        FROM aseguradora A
        join seguro D on D.se_ase_id = A.ase_id
        join Contrato B on B.co_se_id = D.se_id
        join Plan_Viaje C on C.pv_id = B.co_pv_id
        join vuelo_plan E on E.vp_pv_id = C.pv_id
        join vuelo F on F.vu_id = E.vp_vu_id
        join nodo G on G.no_vu_id = F.vu_id and G.no_modo = 'ORI'
        join nodo H on H.no_vu_id = F.vu_id and H.no_modo = 'DES'
        join aeropuerto I on I.ap_id = G.no_ap_id
        join aeropuerto J on J.ap_id = H.no_ap_id
        where F.vu_fecha.fecha_in >= to_date('01-01-2020','dd-mm-yyyy') and F.vu_fecha.fecha_in <= to_date('29-01-2020', 'dd-mm-yyyy')
    ) BASE
    join aseguradora ase on ase.ase_id = "id aseguradora";
*/