

CREATE OR REPLACE TYPE usuarios AS VARRAY(10) OF NUMBER;
/
CREATE OR REPLACE PROCEDURE generar_plan_viaje (fechaIn DATE, id_usuario_comprador number, acompanantes SYSTEM.usuarios, length_acomp number)
IS
    id_flag number;
BEGIN
    COMMIT;
    INSERT INTO PLAN_VIAJE (pv_fecha, pv_precio_total) VALUES (SYSDATE, 0);
    id_flag := seq_pv_id.CURRVAL;
    INSERT INTO PLAN_USUARIO (pu_comprador, pu_pv_id, pu_u_id) VALUES (1, id_flag, id_usuario_comprador);
    FOR i IN 1..length_acomp LOOP
        INSERT INTO PLAN_USUARIO (pu_comprador, pu_pv_id, pu_u_id) VALUES (0, id_flag, acompanantes(i));    
    END LOOP;
END;
/
CREATE OR REPLACE PROCEDURE generar_vuelo (id_aeropuerto_origen number, id_aeropuerto_destino number,
fecha_in DATE,
fecha_out DATE,
duracion number,
vu_stat varchar,
precio_ej number,
precio_ee number,
precio_cp number
)
IS
BEGIN
    INSERT INTO vuelo (vu_fecha, vu_duracion, vu_status, vu_precio_ej, vu_precio_ee, vu_precio_cp) VALUES (reg_ope(fecha_in, fecha_out), duracion, reg_sta(vu_stat), precio_ej, precio_ee, precio_cp);
    INSERT INTO nodo (no_modo, no_status, no_ap_id, no_vu_id) VALUES ('ORI', reg_sta('ACT'), id_aeropuerto_origen, seq_vu_id.CURRVAL);
    INSERT INTO nodo (no_modo, no_status, no_ap_id, no_vu_id) VALUES ('DES', reg_sta('ACT'), id_aeropuerto_destino, seq_vu_id.CURRVAL);
END;
/
CREATE OR REPLACE PROCEDURE generar_reserva_vuelo 
(id_vuelo number,
clase varchar,
id_unidad_avion number,
tipo varchar, 
modo varchar, 
status varchar,
id_plan_viaje number)
IS
CURSOR asiento_disp IS SELECT * FROM asiento WHERE asi_ua_id = id_unidad_avion AND asi_clase = clase;
asiento_el asiento_disp%ROWTYPE;
BEGIN
    OPEN asiento_disp;
    FETCH asiento_disp INTO asiento_el;
    IF asiento_disp%FOUND THEN
        INSERT INTO vuelo_plan (vp_tipo,
        vp_modo,
        vp_status,
        vp_pv_id,
        vp_asi_id,
        vp_vu_id) VALUES (tipo, modo, reg_sta(status), id_plan_viaje, asiento_el.asi_id, id_vuelo);
    END IF;
END;
/
CREATE OR REPLACE PROCEDURE generar_reserva_Hotel
(
    fecha_in DATE,
    fecha_out DATE,
    id_plan_viaje number,
    id_tipo_habitacion number
)
IS
CURSOR habitacion_disp IS SELECT * FROM habitacion WHERE ha_th_id = id_tipo_habitacion;
habitacion_el habitacion_disp%ROWTYPE;
BEGIN
    OPEN habitacion_disp;
    FETCH habitacion_disp INTO habitacion_el;
    IF habitacion_disp%FOUND THEN
        INSERT INTO Reserva_Hotel(rh_fecha,
            rh_precio_total,
            rh_status,
            rh_pv_id,
            rh_ha_id,
            rh_puntuacion) VALUES (reg_ope(fecha_in, fecha_out), 0, reg_sta('ACT'), id_plan_viaje, habitacion_el.ha_id, 0);
    END IF;
END;
/
CREATE OR REPLACE PROCEDURE generar_reserva_auto
(
    fecha_in DATE,
    fecha_out DATE,
    id_plan_viaje number,
    id_modelo number,
    id_isp number,
    recogida reg_loc,
    entrega reg_loc
)
IS
CURSOR auto_disp IS SELECT * FROM automovil WHERE au_mau_id = id_modelo AND au_asp_id = id_isp;
auto_el auto_disp%ROWTYPE;
BEGIN
    OPEN auto_disp;
    FETCH auto_disp INTO auto_el;
    IF auto_disp%FOUND THEN
        INSERT INTO alquiler_auto (aa_dir_recogida, aa_dir_devolucion, aa_fecha, aa_precio_total, aa_status, aa_pv_id, aa_au_id) 
        VALUES (recogida, entrega, reg_ope(fecha_in, fecha_out), 0, reg_sta('ACT'), id_plan_viaje, auto_el.au_id);
    END IF;
END;
/
CREATE OR REPLACE PROCEDURE generar_contrato
(
    cantidad number,
    id_plan_viaje number,
    id_seguro number
)
IS
BEGIN
    INSERT INTO contrato (co_cantidad, co_pv_id, co_se_id) VALUES (cantidad, id_plan_viaje, id_seguro);
END;




