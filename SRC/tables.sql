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
    ha_th_id number      not null,
    ha_des   varchar(20),

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

    constraint pk_ua     primary key(ua_id),
    constraint fk_ua_al  foreign key(ua_al_id)  references aerolinea(al_id),
    constraint fk_ua_mav foreign key(ua_mav_id) references modelo_avion(mav_id)
);
/
create table asiento(
    asi_id       number,
    asi_clase    varchar(2)  not null check(asi_clase in ('EJ','CP','EE')),
    asi_a_nombre varchar(20) not null,
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
    vp_tipo   varchar(3) not null check(vp_tipo in ('ESC','NOR')),
    vp_modo   varchar(3) not null check(vp_modo in ('IDA','IYV')),
    vp_status reg_sta    not null,
    vp_pv_id  number     not null,
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
    fp_des    varchar(20) not null,

    constraint pk_fp primary key(fp_id)
);
/
create table reporte_pago(
    rp_id       number,
    rp_monto    number not null,
    rp_pv_id    number not null,
    rp_fp_id    number not null,
    rp_tarj_num varchar(20),

    constraint pk_rp    primary key(rp_id),
    constraint fk_rp_pv foreign key(rp_pv_id) references plan_viaje(pv_id),
    constraint fk_rp_fp foreign key(rp_fp_id) references forma_pago(fp_id)
);
/

-----------------------------SEGURO--------------------------------------
create table aseguradora(
    ase_id     number,
    ase_nombre varchar(20) not null,
    ase_des    varchar(20) not null,
    ase_logo   blob        default empty_blob(),

    constraint pk_ase primary key(ase_id)
);
/
create table seguro(
    se_id     number,
    se_nombre varchar(20) not null,
    se_des    varchar(20) not null,
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