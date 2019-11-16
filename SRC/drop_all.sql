--------------------------------------------------------------------------
-----------------------------------TABLES---------------------------------
--------------------------------------------------------------------------

-----------------------------SEGURO--------------------------------------
drop table contrato;
drop table seguro;
drop table aseguradora;

-----------------------------PAGO--------------------------------------
drop table reporte_pago;
drop table forma_pago;

-----------------------------VUELO_PLAN--------------------------------------
drop table vuelo_plan;
drop table nodo;
drop table vuelo;
drop table aeropuerto;
drop table asiento;
drop table unidad_avion;
drop table modelo_avion;
drop table avion;
drop table aerolinea;

-----------------------------HOTEL--------------------------------------
drop table reserva_hotel;
drop table habitacion;
drop table tipo_habitacion;
drop table hotel;

-----------------------------ALQUILER DE AUTOS-----------------------------
drop table alquiler_auto;
drop table automovil;
drop table modelo_auto;
drop table marca;
drop table alquiler_sp;

-----------------------------USUARIO--------------------------------------
drop table plan_usuario;
drop table usuario;

-----------------------------PLAN_VIAJE-----------------------------------
drop table plan_viaje;


---------------------------------------------------------------------
----------------------------------SEQUENCES--------------------------
---------------------------------------------------------------------
drop sequence seq_pv_id;
drop sequence seq_u_id;
drop sequence seq_pu_id;
drop sequence seq_asp_id;
drop sequence seq_m_id;
drop sequence seq_mau_id;
drop sequence seq_au_id;
drop sequence seq_aa_id;
drop sequence seq_ho_id;
drop sequence seq_th_id;
drop sequence seq_ha_id;
drop sequence seq_rh_id;
drop sequence seq_al_id;
drop sequence seq_av_id;
drop sequence seq_mav_id;
drop sequence seq_ua_id;
drop sequence seq_asi_id;
drop sequence seq_ap_id;
drop sequence seq_vu_id;
drop sequence seq_no_id;
drop sequence seq_vp_id;
drop sequence seq_fp_id;
drop sequence seq_rp_id;
drop sequence seq_ase_id;
drop sequence seq_se_id;
drop sequence seq_co_id;

-----------------------------------------------------------------------------------
----------------------------------------TDAS---------------------------------------
-----------------------------------------------------------------------------------
drop type reg_ope;
drop type reg_loc;
drop type reg_sta;
drop type cartera;