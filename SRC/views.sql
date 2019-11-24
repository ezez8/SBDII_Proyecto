create or replace view vi_asp as
    select asp_id, asp_nombre from alquiler_sp;

create or replace view vi_mau as
    select mau_id, mau_nombre, mau_pasajeros, mau_m_id from modelo_auto;

create or replace view vi_ho as
    select ho_id, ho_nombre, ho_puntuacion, ho_locacion from hotel;

create or replace view vi_al as
    select al_id, al_nombre, al_tipo from aerolinea;

create or replace view vi_mav as
    select mav_id, mav_nombre, mav_vel_max, mav_alc, mav_alt_max, mav_enverg, mav_anch_cab, mav_alt_cab, mav_av_id from modelo_avion;

create or replace view vi_ase as
    select ase_id, ase_nombre from aseguradora;