create or replace type reg_ope as object(
    fecha_in  date,
    fecha_out date,
    
    member function validar_fechas(fechaIn DATE, fechaOut DATE) return number,
    member function validar_solapamiento(fechaIn DATE, fechaOut DATE, fechaIn2 DATE, fechaOut2 DATE) return number,
    member function calcular_precio (fechaIn DATE, fechaOut DATE, precio NUMBER) return number
);
/
create or replace type reg_loc as object(
    ciudad    varchar(20),
    pais      varchar(20),
    direccion varchar(40),
    latitud   number,
    longitud  number,
    
    member function calculo_distancia (latitud NUMBER, longitud NUMBER, latitud2 NUMBER, longitud2 NUMBER)return number,
    member function calculo_precio (latitud NUMBER, longitud NUMBER, latitud2 NUMBER, longitud2 NUMBER, precio NUMBER) return number
);
/
create or replace type cartera as object(
    millas number,
    dinero number,
    
    member function cambio_moneda return number,
    member function calculo_pago (identificador number, modo number) return number,
    member function ejecucion_pago (tarj varchar, tipo number, identificador number, modo number) return number
);
/
create or replace type reg_sta as object(
    status varchar(3),
    ubicacion varchar(50),
    
    member procedure validar_cambio_status(tipo number, identificador number, status varchar)
);