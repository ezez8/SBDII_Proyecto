create or replace type reg_ope as object(
    fecha_in  date,
    fecha_out date,
    
    member function validar_fechas return number,
    member function validar_solapamiento return number,
    member function calcular_precio return number
);
/
create or replace type body reg_ope
is
    member function validar_fechas return number
    is
    begin
        return 0;
    end;
    
    member function validar_solapamiento return number
    is
    begin
        return 0;
    end;
    
    member function calcular_precio return number
    is
    begin
        return 0;
    end;
end;
/

create or replace type reg_loc as object(
    ciudad    varchar(20),
    pais      varchar(20),
    direccion varchar(40),
    
    member function calculo_distancia return number,
    member function calculo_precio return number
);
/
create or replace type body reg_loc
is
    member function calculo_distancia return number
    is
    begin
        return 0;
    end;
    
    member function calculo_precio return number
    is
    begin
        return 0;
    end;
end;
/

create or replace type reg_sta as object(
    status varchar(3),
    
    member function validar_cambio_status return number,
    member function validar_ejecucion_status return number
);
/
create or replace type body reg_sta
is
    member function validar_cambio_status return number
    is
    begin
        return 0;
    end;
    
    member function validar_ejecucion_status return number
    is
    begin
        return 0;
    end;
end;
/

create or replace type cartera as object(
    millas number,
    dinero number,
    
    member function cambio_moneda return number,
    member function calculo_pago return number,
    member function ejecucion_pago return number
);
/
create or replace type body cartera
is
    member function cambio_moneda return number
    is
    begin
        return 0;
    end;
    
    member function calculo_pago return number
    is
    begin
        return 0;
    end;
    
    member function ejecucion_pago return number
    is
    begin
        return 0;
    end;
end;