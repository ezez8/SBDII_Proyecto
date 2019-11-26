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
create or replace procedure repo5_1(cur out sys_refcursor)
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
    and u_correo = 'tpitmana@princeton.edu';
end;