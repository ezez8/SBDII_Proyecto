CREATE OR REPLACE TRIGGER validacion_reserva_vuelo
BEFORE INSERT ON Vuelo_Plan
FOR EACH ROW
DECLARE
CURSOR reg_vuelo IS SELECT * FROM vuelo WHERE vu_id = :new.vp_vu_id;
CURSOR comp_reservas_ant IS SELECT * FROM vuelo JOIN vuelo_plan ON vuelo.vu_id = vuelo_plan.vp_vu_id WHERE :new.vp_pv_id = vuelo_plan.vp_pv_id;
CURSOR asiento_ocupado IS SELECT count(*) as contador FROM Vuelo_Plan WHERE :new.vp_asi_id = vuelo_plan.vp_asi_id AND vuelo_plan.vp_vu_id = :new.vp_vu_id;
reg_vue_el reg_vuelo%ROWTYPE;
BEGIN
    OPEN reg_vuelo;
    FETCH reg_vuelo INTO reg_vue_el;
    IF (reg_vue_el.vu_status.status <> 'ACT') THEN
            raise_application_error(-1020, 'No se puede realizar la reservacion a un vuelo inactivo/invalido');
    END IF;
    OPEN comp_reservas_ant;
    FOR reg_vue IN comp_reservas_ant LOOP
        IF (reg_vue.vu_fecha.validar_solapamiento(reg_vue.vu_fecha.fecha_in, reg_vue.vu_fecha.fecha_out, reg_vue_el.vu_fecha.fecha_in, reg_vue_el.vu_fecha.fecha_out) = 1) THEN
            raise_application_error(-1020, 'No se puede realizar la reservacion de un vuelo, cuando se tiene una reserva realizada en el mismo lapso de tiempo');
        END IF;
    END LOOP;
    OPEN asiento_ocupado;
    FOR asiento_ocu in asiento_ocupado LOOP
        IF (asiento_ocu.contador > 1) THEN
            raise_application_error(-1020, 'Asiento ocupado');
        END IF;
    END LOOP;
END;
/
CREATE OR REPLACE TRIGGER validacion_reserva_vuelo_stats
BEFORE UPDATE ON Vuelo_Plan
FOR EACH ROW
DECLARE
Cursor vuelo_reg IS SELECT * FROM Vuelo WHERE Vuelo.vu_id = :new.vp_vu_id;
vuelo_el vuelo_reg%ROWTYPE;
BEGIN
    OPEN vuelo_reg;
    FETCH vuelo_reg INTO vuelo_el;
    IF (:new.vp_status.status <> :old.vp_status.status) THEN
        :new.vp_status.validar_cambio_status(0, :new.vp_pv_id, :new.vp_id, :new.vp_status.status);
    END IF;
END;
/
CREATE OR REPLACE TRIGGER validacion_reserva_habitacion
BEFORE INSERT ON Reserva_hotel
FOR EACH ROW
DECLARE
CURSOR reg_reserva_habitacion IS SELECT * FROM Reserva_Hotel WHERE:new.rh_ha_id = reserva_hotel.rh_ha_id;
BEGIN
    OPEN reg_reserva_habitacion;
    IF (:new.rh_status.status <> 'ACT') THEN
        raise_application_error(-1020, 'No se puede realizar la reservacion a una habitacion inactivo/invalido');
    END IF;
    FOR reserva IN reg_reserva_habitacion LOOP
        IF (reserva.rh_fecha.validar_solapamiento(reserva.rh_fecha.fecha_in, reserva.rh_fecha.fecha_out, :new.rh_fecha.fecha_in, :new.rh_fecha.fecha_out) = 1) THEN
            raise_application_error(-1020, 'No se puede realizar la reservacion a una habitacion cuando esta esta reservada');
        END IF;
    END LOOP;
END;
/
CREATE OR REPLACE TRIGGER validacion_habitacion_stats
BEFORE UPDATE ON Reserva_hotel
FOR EACH ROW
DECLARE
BEGIN
    IF (:new.rh_status.status <> :old.rh_status.status) THEN
       :new.rh_status.validar_cambio_status(1, :new.rh_pv_id, :new.rh_id, :new.rh_status.status);
    END IF;
END;
/
CREATE OR REPLACE TRIGGER validacion_alquiler_auto
BEFORE INSERT ON Alquiler_Auto
FOR EACH ROW
DECLARE
CURSOR reg_alquiler_auto IS SELECT * FROM Alquiler_auto WHERE:new.aa_au_id = alquiler_auto.aa_au_id;
BEGIN
    OPEN reg_alquiler_auto;
    IF (:new.aa_status.status <> 'ACT') THEN
        raise_application_error(-1020, 'No se puede realizar la reservacion a una habitacion inactivo/invalido');
    END IF;
    FOR alquiler IN reg_alquiler_auto LOOP
        IF (alquiler.aa_fecha.validar_solapamiento(alquiler.aa_fecha.fecha_in, alquiler.aa_fecha.fecha_out, :new.aa_fecha.fecha_in, :new.aa_fecha.fecha_out) = 1) THEN
            raise_application_error(-1020, 'No se puede realizar la reservacion a una habitacion cuando esta esta reservada');
        END IF;
    END LOOP;
END;
/
CREATE OR REPLACE TRIGGER validacion_alquiler_auto_stats
BEFORE UPDATE ON Alquiler_Auto
FOR EACH ROW
DECLARE
BEGIN
    IF (:new.aa_status.status <> :old.aa_status.status) THEN
        :new.aa_status.validar_cambio_status(2, :new.aa_pv_id, :new.aa_id, :new.aa_status.status);
    END IF;
END;
/
CREATE OR REPLACE TRIGGER validacion_nodos
BEFORE INSERT ON nodo
FOR EACH ROW
DECLARE
 Cursor nodo_registrado IS SELECT * FROM nodo where :new.no_vu_id = nodo.no_vu_id;
 flag_or number:=1;
 flag_des number:=1;
BEGIN
    OPEN nodo_Registrado;
    FOR nodo_reg in nodo_registrado LOOP
        if(nodo_reg.no_modo ='ORI') then
            flag_or := flag_or -1;
        end if;
        if(nodo_reg.no_modo ='DES') then
            flag_des := flag_des -1;
        end if;
        if (flag_or < 0 or flag_des < 0) then
            raise_application_error(-1020, 'Mas de un nodo en una ruta no permitido');
        end if;
    END LOOP;
    close nodo_Registrado;
END;