create or replace type body reg_ope
is
    member function validar_fechas (fechaIn DATE, fechaOut DATE) return number
    is
    begin
        if(fechaIn > fechaOut) THEN
            return 1;
        END IF;
        if (fechaIn < SYSDATE) THEN
            return 1;
        END IF;
        return 0;
    end;
    
    member function validar_solapamiento (fechaIn DATE, fechaOut DATE, fechaIn2 DATE, fechaOut2 DATE) return number
    is
    begin
        if(fechaIn > fechaIn2 AND fechaIn < fechaOut2) THEN
            return 1;
        END IF;
        if(fechaOut > fechaIn2 AND FechaOut < fechaOut2) THEN
            return 1;
        END IF;
        return 0;
    end;
    
    member function calcular_precio (fechaIn DATE, fechaOut DATE, precio NUMBER) return number
    is
    begin
        return (fechaOut - fechaIn) * precio;
    end;
end;
/
create or replace type body reg_loc
is
    member function calculo_distancia (latitud NUMBER, longitud NUMBER, latitud2 NUMBER, longitud2 NUMBER) return number
    is
        earth_radius number := 6371;
        pi_approx number := 3.1415927/180;
        lat_delta number := (latitud2 - latitud)*pi_approx;
        lon_delta number := (longitud2 - longitud)*pi_approx;
        arc number := sin(lat_delta/2) * sin(lat_delta/2) + sin(lon_delta/2) * cos(latitud*pi_approx) * cos(latitud2*pi_approx);
    begin
        return earth_radius * 2 * atan2(sqrt(arc), sqrt(1-arc));
    end;
    
    member function calculo_precio (latitud NUMBER, longitud NUMBER, latitud2 NUMBER, longitud2 NUMBER, precio NUMBER) return number
    is
    begin
        return self.calculo_distancia(latitud, longitud, latitud2, longitud2) * precio;
    end;
end;
/
create or replace type body cartera
is
    member function cambio_moneda return number
    is
    begin
        return 0;
    end;
     
    member function calculo_pago (identificador number, modo number) return number
    is
        CURSOR Precio_Hotel IS SELECT rh_precio_total as precio FROM reserva_hotel WHERE reserva_hotel.rh_pv_id = identificador;
        CURSOR Precio_Auto IS SELECT aa_precio_total as precio FROM alquiler_auto WHERE alquiler_auto.aa_pv_id = identificador;
        CURSOR Precio_Vuelo IS SELECT asiento.asi_clase, vuelo.vu_precio_ej, vuelo.vu_precio_ee, vuelo.vu_precio_cp FROM vuelo_plan 
            JOIN vuelo ON vuelo.vu_id = vuelo_plan.vp_vu_id
            JOIN asiento ON asiento.asi_id = vuelo_plan.vp_asi_id
            WHERE vuelo_plan.vp_pv_id = identificador;
        precio_total number := 0;
        CURSOR Precio_Contrato IS SELECT contrato.co_cantidad as cantidad, seguro.se_precio as precio FROM contrato 
        JOIN seguro ON seguro.se_id = contrato.co_se_id WHERE contrato.co_pv_id = identificador;
    begin
        DBMS_OUTPUT.PUT_LINE('Calculo de precio total para el plan de viaje');
        IF ( modo = 0 OR modo = 1) THEN
        OPEN Precio_Hotel;
        FOR precios IN Precio_Hotel LOOP
            precio_total:= precio_total + precios.precio;
        END LOOP;
        END IF;
        IF ( modo = 0 OR modo = 2) THEN
        OPEN Precio_Auto;
        FOR precios IN Precio_Auto LOOP
            precio_total:= precio_total + precios.precio;
        END LOOP;
        END IF;
        IF ( modo = 0 OR modo = 3) THEN
        OPEN Precio_Vuelo;
        FOR precios IN Precio_Vuelo LOOP
            IF (Precios.asi_clase = 'EJ') THEN
                precio_total:= precio_total + precios.vu_precio_ej;
            END IF;
            IF (Precios.asi_clase = 'EE') THEN
                precio_total:= precio_total + precios.vu_precio_ee;
            END IF;
            IF (Precios.asi_clase = 'CP') THEN
                precio_total:= precio_total + precios.vu_precio_cp;
            END IF;
        END LOOP;
        END IF;
        IF ( modo = 0 OR modo = 4) THEN
        OPEN Precio_Contrato;
        FOR precios IN Precio_Contrato LOOP
            precio_total:= precio_total + (precios.cantidad * precios.precio);
        END LOOP;
        END IF;
        return precio_total;
    end;
    
    member function ejecucion_pago(tarj varchar, tipo number, identificador number, modo number) return number
    is
        --Reportes pago hoteles--
        CURSOR Reportes_Pago_hotel IS SELECT rp_monto FROM reporte_pago WHERE rp_pv_id = identificador AND rp_ar = 1;
        --Reportes pago aviones--
        CURSOR Reportes_Pago_auto IS SELECT rp_monto FROM reporte_pago WHERE rp_pv_id = identificador AND rp_ar = 2;
        --Reportes pago autos--
        CURSOR Reportes_Pago_avion IS SELECT rp_monto FROM reporte_pago WHERE rp_pv_id = identificador AND rp_ar = 3;
        --Reportes pago seguro--
        CURSOR Reportes_Pago_seguro IS SELECT rp_monto FROM reporte_pago WHERE rp_pv_id = identificador AND rp_ar = 4;
        precio_total number;
    begin
            --Pago de toda la reservacion de todo
            IF (modo = 0) THEN
                precio_total:= calculo_pago(identificador,0);
                OPEN Reportes_Pago_hotel;
                FOR reporte IN Reportes_Pago_hotel LOOP
                    precio_total:= precio_total - reporte.rp_monto;
                END LOOP;
                OPEN Reportes_Pago_auto;
                FOR reporte IN Reportes_Pago_auto LOOP
                    precio_total:= precio_total - reporte.rp_monto;
                END LOOP;
                OPEN Reportes_Pago_avion;
                FOR reporte IN Reportes_Pago_avion LOOP
                    precio_total:= precio_total - reporte.rp_monto;
                END LOOP;
                OPEN Reportes_Pago_seguro;
                FOR reporte IN Reportes_Pago_seguro LOOP
                    precio_total:= precio_total - reporte.rp_monto;
                END LOOP;
            END IF;
            --Pago de toda la reservacion de hoteles
            IF (modo = 1 )THEN
                precio_total:= calculo_pago(identificador,1);
                OPEN Reportes_Pago_Hotel;
                FOR reporte IN Reportes_Pago_Hotel LOOP
                    precio_total:= precio_total - reporte.rp_monto;
                END LOOP;
            END IF;
            --Pago de toda la reservacion de autos
            IF(modo = 2 )THEN
                precio_total:= calculo_pago(identificador,2);
                OPEN Reportes_Pago_auto;
                FOR reporte IN Reportes_Pago_auto LOOP
                    precio_total:= precio_total - reporte.rp_monto;
                END LOOP;
            END IF;
            --Pago de toda la reservacion de vuelos
            IF(modo = 3 )THEN
                precio_total:= calculo_pago(identificador,3);
                OPEN Reportes_Pago_avion;
                FOR reporte IN Reportes_Pago_avion LOOP
                    precio_total:= precio_total - reporte.rp_monto;
                END LOOP;
            END IF;
            --Pago de toda la reservacion de seguros
            IF(modo = 4 )THEN
                precio_total:= calculo_pago(identificador,4);
                OPEN Reportes_Pago_seguro;
                FOR reporte IN Reportes_Pago_seguro LOOP
                    precio_total:= precio_total - reporte.rp_monto;
                END LOOP;
            END IF;
        --Condiciones de millas y pago incompleto.
        IF (tipo = 3 and modo <> 3) THEN
            raise_application_error(1020, 'No se puede pagar con millas reservaciones que no sean de viajes.');
        END IF;
        IF (tipo = 3 and self.millas < precio_total) THEN
            raise_application_error(1021, 'Solamente se puede pagar con millas la totalidad de la reserva.');
            END IF;
        IF (tipo = 4 and self.dinero < precio_total) THEN
            raise_application_error(1022, 'No hay dinero suficiente para el pago.');
        END IF;
        INSERT INTO REPORTE_PAGO (rp_monto, rp_tarj_num, rp_fp_id, rp_pv_id) VALUES (precio_total, tarj, tipo, identificador);
    end;
end;
/
create or replace type body reg_sta
is
    member procedure validar_cambio_status(tipo number, identificador number,reserva number, status varchar)
    is
        Cursor registro IS select vuelo.vu_precio_ej, vuelo.vu_precio_ee, vuelo.vu_precio_cp, asiento.asi_clase
            FROM vuelo JOIN vuelo_plan on vuelo_plan.vp_vu_id = vuelo.vu_id
            JOIN asiento on asiento.asi_id = vuelo_plan.vp_asi_id
            WHERE vuelo_plan.vp_pv_id=identificador;
        Cursor hotel_reg IS SELECT Reserva_Hotel.rh_precio_total as precio FROM Reserva_Hotel
            WHERE Reserva_Hotel.rh_pv_id = identificador AND Reserva_Hotel.rh_id = reserva;
        Cursor auto_reg IS SELECT Alquiler_Auto.aa_precio_total as precio FROM Alquiler_Auto
            WHERE Alquiler_auto.aa_pv_id = identificador AND Alquiler_Auto.aa_id = reserva;
         Cursor billetera_reg IS SELECT Usuario.u_billetera.dinero as dinero, Usuario.u_billetera.millas as millas, Usuario.u_id FROM Usuario
            JOIN Plan_Usuario on plan_usuario.pu_u_id = usuario.u_id
            JOIN Plan_Viaje on plan_usuario.pu_pv_id = plan_viaje.pv_id
            WHERE Plan_Viaje.pv_id = identificador;
        busq_billetera billetera_reg%ROWTYPE;
        busq_hotel hotel_reg%ROWTYPE;
        busq_auto auto_reg%ROWTYPE;
    begin
        --Cuando se realiza el cambio de status debe  realizar las distintas validaciones
        --Recordar comprobar sysdate para el cambio de fechas, etc.
            OPEN billetera_reg;
            FETCH billetera_reg into busq_billetera;
            IF ( tipo = 0 ) THEN
            ------------------------AVION----------------------------------------
                --validar el cambio de status y asignacion a un vuelo mas cercano.
                IF( status <> 'ACT' ) THEN
                        IF (self.status <> status AND self.status <> 'RTR') THEN
                            --Primero se busca otro vuelo en las mismas fechas
                            --Segundo se busca otro vuelo como sustitucion en otra aerolinea.
                            --Tercero se busca otro vuelo en otras fechas.
                            --Cuarto se devuelve el dinero de la rservacion.
                            dbms_output.put_line('SE CANCELO RESERVA DE VUELO');
                            OPEN registro;
                            FOR busq in registro LOOP
                                IF (busq.asi_clase = 'EJ') THEN
                                    UPDATE Usuario SET Usuario.u_billetera = cartera(busq_billetera.millas, busq_billetera.dinero + busq.vu_precio_ej * 0.8);
                                END IF;
                                IF (busq.asi_clase = 'EE') THEN
                                    UPDATE Usuario SET Usuario.u_billetera = cartera(busq_billetera.millas, busq_billetera.dinero + busq.vu_precio_ee * 0.8);
                                END IF;
                                IF (busq.asi_clase = 'CP') THEN
                                    UPDATE Usuario SET Usuario.u_billetera = cartera(busq_billetera.millas, busq_billetera.dinero + busq.vu_precio_cp * 0.8);
                                END IF;
                            END LOOP;
                        END IF;
                        IF (self.status = 'RTR') THEN
                            dbms_output.put_line('SE CANCELO RESERVA DE VUELO');
                        END IF;
                END IF;
            END IF;
            IF( tipo = 1 )THEN
            ------------------------HOTEL----------------------------------------
                --validar el cambio de status y asignacion a un vuelo mas cercano.
                    IF( status <> 'ACT' ) THEN
                        IF (status <> self.status) THEN
                            -- Primero se busca una habitacion disponible en las fechas especificadas
                            -- Segundo se busca una habitacion de menor precio y se devuelve el dinero
                            -- Tercero se busca una habitacion en otro hotel cercano y se devuelve el dinero si es necesario.
                            -- Cuarto se devuelve el dinero al no conseguir habitacion.
                            dbms_output.put_line('EPALE');
                            OPEN hotel_Reg;
                            FETCH hotel_Reg into busq_hotel;
                            UPDATE Usuario SET Usuario.u_billetera = cartera(busq_billetera.millas, busq_billetera.dinero + busq_hotel.precio * 0.8);
                        END IF;
                    END IF;
            END IF;
            IF( tipo = 2 )THEN
            ------------------------AUTO----------------------------------------
                --validar el cambio de status y asignacion a un vuelo mas cercano.
                    IF( status <> 'ACT' ) THEN
                        IF (status <> self.status) THEN
                            --Primero se busca un auto en el lugar de encuentro
                            --Segundo se busca un auto en otro alquiler de autos.
                            --Tercero se devuelve el dinero al no conseguir habitacion.
                            dbms_output.put_line('EPALE');
                            OPEN auto_Reg;
                            FETCH auto_Reg into busq_auto;
                            UPDATE Usuario SET Usuario.u_billetera = cartera(busq_billetera.millas, busq_billetera.dinero + busq_auto.precio * 0.8);
                        END IF;
                END IF;
            END IF;
    end;
end;
