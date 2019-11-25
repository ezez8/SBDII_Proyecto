CREATE OR REPLACE TRIGGER validacion_reserva_vuelo
BEFORE INSERT ON Vuelo_Plan
FOR EACH ROW
DECLARE
CURSOR comp_reservas_ant IS SELECT * FROM vuelo JOIN vuelo_plan ON vuelo.vu_id = vuelo_plan.vp_vu_id WHERE :new.vp_pv_id = vuelo_plan.vp_pv_id;
reg_vue_el vuelo%ROWTYPE;
flag_asiento_ya_reservado number;
flag_vuelo_no_activo varchar(3);
flag_avion_no_activo varchar(3);
BEGIN
    SELECT count(*) into flag_asiento_ya_reservado FROM vuelo_plan WHERE vp_vu_id = :new.vp_vu_id AND vp_id <> :new.vp_id AND :new.vp_asi_id = vuelo_plan.vp_asi_id;
    IF (flag_asiento_ya_reservado > 0) THEN
            raise_application_error(-1020, 'Asiento ya reservado');
    END IF;
    SELECT A.vu_status.status into flag_vuelo_no_activo FROM Vuelo A WHERE A.vu_id = :new.vp_vu_id;
    IF (flag_vuelo_no_activo <> 'ACT') THEN
            raise_application_error(-1020, 'No se puede realizar la reservacion a un vuelo inactivo/invalido');
    END IF;
    SELECT A.ua_status.status into flag_avion_no_activo FROM Unidad_Avion A 
        JOIN Asiento B ON B.asi_ua_id = A.ua_id 
        JOIN Vuelo_plan C ON C.vp_asi_id = B.asi_id AND C.vp_id = :new.vp_id;
    IF (flag_avion_no_activo <> 'ACT') THEN
         raise_application_error(-1020, 'No se puede realizar la reservacion a un avion inactivo/invalido');
    END IF;
    SELECT * into reg_vue_el FROM Vuelo A WHERE A.vu_id = :new.vp_vu_id;
    IF (reg_vue_el.vu_fecha.validar_fechas(reg_vue_el.vu_fecha.fecha_in, reg_vue_el.vu_fecha.fecha_out) = 1) THEN
        raise_application_error(-1020, 'Las fechas establecidas para este vuelo no es valida');
    END IF;
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
    close vuelo_reg;
END;
/
CREATE OR REPLACE TRIGGER validacion_reserva_habitacion
BEFORE INSERT ON Reserva_hotel
FOR EACH ROW
DECLARE
CURSOR reg_reserva_habitacion IS SELECT * FROM Reserva_Hotel WHERE:new.rh_ha_id = reserva_hotel.rh_ha_id;
BEGIN
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
END;
/
CREATE OR REPLACE TRIGGER validacion_auto_stats
BEFORE UPDATE ON Automovil
FOR EACH ROW
DECLARE
BEGIN
    IF (:new.au_status.status <> :old.au_status.status) THEN
        :new.au_status.validar_cambio_status(3, null, :new.au_id, :new.au_status.status);
    END IF;
END;
/
CREATE OR REPLACE TRIGGER validacion_habitacion_ud_stats
BEFORE UPDATE ON Habitacion
FOR EACH ROW
DECLARE
BEGIN
    IF (:new.ha_status.status <> :old.ha_status.status) THEN
        :new.ha_status.validar_cambio_status(4, null, :new.ha_id, :new.ha_status.status);
    END IF;
END;
/
CREATE OR REPLACE TRIGGER validacion_reserva_habitacion
BEFORE INSERT ON Reserva_hotel
FOR EACH ROW
DECLARE
CURSOR reg_reserva_habitacion IS SELECT * FROM Reserva_Hotel WHERE:new.rh_ha_id = reserva_hotel.rh_ha_id;
BEGIN
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

----------------------------------------------------------
------------------TRIGGERS BLOBS--------------------------
----------------------------------------------------------
/
create or replace trigger tri_vi_asp
instead of insert on vi_asp
for each row
begin
    DECLARE 
    V_blob BLOB;
    V_bfile BFILE;
    BEGIN 
        INSERT INTO alquiler_sp(asp_id, asp_nombre, asp_logo) VALUES (:new.asp_id, :new.asp_nombre, empty_blob()) RETURNING asp_logo INTO V_blob;
        V_bfile := BFILENAME('IMGS_ASP', :new.asp_nombre||'.jpg');
        DBMS_LOB.OPEN(V_bfile, DBMS_LOB.LOB_READONLY);
        DBMS_LOB.LOADFROMFILE(V_blob, V_bfile, SYS.DBMS_LOB.GETLENGTH(V_bfile));
        DBMS_LOB.CLOSE(V_bfile);
        --COMMIT;
    END;
end;
/
create or replace trigger tri_vi_mau
instead of insert on vi_mau
for each row
begin
    DECLARE 
    V_blob BLOB;
    V_bfile BFILE;
    BEGIN 
        INSERT INTO modelo_auto(mau_id, mau_nombre, mau_pasajeros, mau_m_id, mau_foto) VALUES (:new.mau_id, :new.mau_nombre, :new.mau_pasajeros, :new.mau_m_id, empty_blob()) RETURNING mau_foto INTO V_blob;
        V_bfile := BFILENAME('IMGS_MAU', :new.mau_nombre||'.jpg');
        DBMS_LOB.OPEN(V_bfile, DBMS_LOB.LOB_READONLY);
        DBMS_LOB.LOADFROMFILE(V_blob, V_bfile, SYS.DBMS_LOB.GETLENGTH(V_bfile));
        DBMS_LOB.CLOSE(V_bfile);
        --COMMIT;
    END;
end;
/
create or replace trigger tri_vi_ho
instead of insert on vi_ho
for each row
begin
    DECLARE 
    V_blob BLOB;
    V_bfile BFILE;
    BEGIN 
        INSERT INTO hotel(ho_id, ho_nombre, ho_puntuacion, ho_locacion, ho_foto) VALUES (:new.ho_id, :new.ho_nombre, :new.ho_puntuacion, :new.ho_locacion, empty_blob()) RETURNING ho_foto INTO V_blob;
        V_bfile := BFILENAME('IMGS_HO', :new.ho_nombre||'.jpg');
        DBMS_LOB.OPEN(V_bfile, DBMS_LOB.LOB_READONLY);
        DBMS_LOB.LOADFROMFILE(V_blob, V_bfile, SYS.DBMS_LOB.GETLENGTH(V_bfile));
        DBMS_LOB.CLOSE(V_bfile);
        --COMMIT;
    END;
end;
/
create or replace trigger tri_vi_al
instead of insert on vi_al
for each row
begin
    DECLARE 
    V_blob BLOB;
    V_bfile BFILE;
    BEGIN 
        INSERT INTO aerolinea(al_id, al_nombre, al_tipo, al_logo) VALUES (:new.al_id, :new.al_nombre, :new.al_tipo, empty_blob()) RETURNING al_logo INTO V_blob;
        V_bfile := BFILENAME('IMGS_AL', :new.al_nombre||'.jpg');
        DBMS_LOB.OPEN(V_bfile, DBMS_LOB.LOB_READONLY);
        DBMS_LOB.LOADFROMFILE(V_blob, V_bfile, SYS.DBMS_LOB.GETLENGTH(V_bfile));
        DBMS_LOB.CLOSE(V_bfile);
        --COMMIT;
    END;
end;
/
create or replace trigger tri_vi_mav
instead of insert on vi_mav
for each row
begin
    DECLARE 
    V_blob BLOB;
    V_bfile BFILE;
    BEGIN 
        INSERT INTO modelo_avion(mav_id, mav_nombre, mav_vel_max, mav_alc, mav_alt_max, mav_enverg, mav_anch_cab, mav_alt_cab, mav_av_id, mav_foto) 
        VALUES (:new.mav_id, :new.mav_nombre, :new.mav_vel_max, :new.mav_alc, :new.mav_alt_max, :new.mav_enverg, :new.mav_anch_cab, :new.mav_alt_cab, :new.mav_av_id, empty_blob()) RETURNING mav_foto INTO V_blob;
        V_bfile := BFILENAME('IMGS_MAV', :new.mav_nombre||'.jpg');
        DBMS_LOB.OPEN(V_bfile, DBMS_LOB.LOB_READONLY);
        DBMS_LOB.LOADFROMFILE(V_blob, V_bfile, SYS.DBMS_LOB.GETLENGTH(V_bfile));
        DBMS_LOB.CLOSE(V_bfile);
        --COMMIT;
    END;
end;
/
create or replace trigger tri_vi_ase
instead of insert on vi_ase
for each row
begin
    DECLARE 
    V_blob BLOB;
    V_bfile BFILE;
    BEGIN 
        INSERT INTO aseguradora(ase_id, ase_nombre, ase_logo) VALUES (:new.ase_id, :new.ase_nombre, empty_blob()) RETURNING ase_logo INTO V_blob;
        V_bfile := BFILENAME('IMGS_ASE', :new.ase_nombre||'.jpg');
        DBMS_LOB.OPEN(V_bfile, DBMS_LOB.LOB_READONLY);
        DBMS_LOB.LOADFROMFILE(V_blob, V_bfile, SYS.DBMS_LOB.GETLENGTH(V_bfile));
        DBMS_LOB.CLOSE(V_bfile);
        --COMMIT;
    END;
end;