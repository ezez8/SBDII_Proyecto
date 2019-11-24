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