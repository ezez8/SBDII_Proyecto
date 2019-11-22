create or replace view vi_asp as
    select asp_id, asp_nombre from alquiler_sp;

create or replace view vi_mau as
    select mau_id, mau_nombre, mau_pasajeros, mau_m_id from modelo_auto;

create or replace view vi_ho as
    select ho_id, ho_nombre, ho_puntuacion, ho_locacion from hotel;