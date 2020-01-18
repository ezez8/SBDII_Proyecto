/*--- Creacion de los roles ---*/
DROP ROLE AdminHotel;
DROP ROLE AdminAerolinea;
DROP ROLE AdminAeropuerto;
DROP ROLE AdminPago;
DROP ROLE AdminSeguro;
DROP ROLE AdminUsuario;
DROP ROLE AdminAuto;
DROP ROLE Supervisor;
DROP ROLE Cliente;

CREATE ROLE AdminHotel;
CREATE ROLE AdminAerolinea;
CREATE ROLE AdminAeropuerto;
CREATE ROLE AdminPago;
CREATE ROLE AdminSeguro;
CREATE ROLE AdminUsuario;
CREATE ROLE AdminAuto;
CREATE ROLE Supervisor;
CREATE ROLE Cliente;

---Permisos definidos para los roles
-------Modulo de Hotel
GRANT ALL ON Hotel TO AdminHotel;
GRANT ALL ON Tipo_Habitacion TO AdminHotel;
GRANT ALL ON Habitacion TO AdminHotel;
GRANT SELECT ON Hotel TO Supervisor;
GRANT SELECT ON Tipo_Habitacion TO Supervisor;
GRANT SELECT ON Habitacion TO Supervisor;

-------Modulo de aerolinea
GRANT ALL ON Aerolinea to AdminAerolinea;
GRANT ALL ON Avion to AdminAerolinea;
GRANT ALL ON Modelo_Avion to AdminAerolinea;
GRANT ALL ON Unidad_Avion to AdminAerolinea;
GRANT ALL ON Asiento to AdminAerolinea;
GRANT SELECT ON Aerolinea to Supervisor;
GRANT SELECT ON Avion to Supervisor;
GRANT SELECT ON Modelo_Avion to Supervisor;
GRANT SELECT ON Unidad_Avion to Supervisor;
GRANT SELECT ON Asiento to Supervisor;

-------Modulo de Aeropuerto
GRANT ALL ON Aeropuerto to AdminAeropuerto;
GRANT ALL ON Nodo to AdminAeropuerto;
GRANT ALL ON Vuelo to AdminAeropuerto;
GRANT SELECT ON Aeropuerto to Supervisor;
GRANT SELECT ON Nodo to Supervisor;
GRANT SELECT ON Vuelo to Supervisor;

------Modulo de Pago
GRANT ALL ON Forma_Pago to AdminPago;
GRANT SELECT ON Forma_Pago to Supervisor;

------MOdulo de Seguro
GRANT ALL ON Aseguradora to AdminSeguro;
GRANT ALL ON Seguro to AdminSeguro;
GRANT SELECT ON Aseguradora to Supervisor;
GRANT SELECT ON Seguro to Supervisor;

------Modulo de Auto
GRANT ALL ON Alquiler_SP to AdminAuto;
GRANT ALL ON Marca to AdminAuto;
GRANT ALL ON Modelo_Auto to AdminAuto;
GRANT ALL ON Automovil to AdminAuto;
GRANT SELECT ON Alquiler_SP to Supervisor;
GRANT SELECT ON Marca to Supervisor;
GRANT SELECT ON MOdelo_Auto to Supervisor;
GRANT SELECT ON automovil to Supervisor;

------Modulo de Usuario
DROP User AdminHo CASCADE;
DROP User AdminAl CASCADE;
DROP User AdminAp CASCADE;
DROP User AdminPa CASCADE;
DROP User AdminSe CASCADE;
DROP User AdminUs CASCADE;
DROP User AdminAu CASCADE;
DROP User Super CASCADE;
DROP User Cli CASCADE;

GRANT Insert, update, select ON PLan_Viaje to Cliente;
GRANT Insert, update, select ON Plan_Usuario to Cliente;
GRANT Insert, update, select ON Usuario to Cliente;
GRANT Insert, update, select ON Alquiler_Auto to Cliente;
GRANT Insert, update, select ON Reserva_Hotel to Cliente;
GRANT Insert, update, select ON Vuelo_Plan to Cliente;
GRANT Insert, update, select ON Reporte_Pago to Cliente;
GRANT Insert, update, select ON Contrato to Cliente;

/*--- Creacion de usuarios y asignacion de roles ---*/
CREATE USER AdminHo identified by "123" default tablespace USERS temporary tablespace TEMP;
GRANT AdminHotel to AdminHo;
ALTER USER AdminHo DEFAULT ROLE AdminHotel;
CREATE USER AdminAl identified by "123" default tablespace USERS temporary tablespace TEMP;
GRANT AdminAerolinea to AdminAl;
ALTER USER AdminAl DEFAULT ROLE AdminAerolinea;
CREATE USER AdminAp identified by "123" default tablespace USERS temporary tablespace TEMP;
GRANT AdminAeropuerto to AdminAp;
ALTER USER AdminAp DEFAULT ROLE AdminAeropuerto;
CREATE USER AdminPa identified by "123" default tablespace USERS temporary tablespace TEMP;
GRANT AdminPago to AdminPa;
ALTER USER AdminPa DEFAULT ROLE AdminPago;
CREATE USER AdminSe identified by "123" default tablespace USERS temporary tablespace TEMP;
GRANT AdminSeguro to AdminSe;
ALTER USER AdminSe DEFAULT ROLE AdminSeguro;
CREATE USER AdminUs identified by "123" default tablespace USERS temporary tablespace TEMP;
GRANT AdminUsuario to AdminUs;
ALTER USER AdminUs DEFAULT ROLE AdminUsuario;
CREATE USER AdminAu identified by "123" default tablespace USERS temporary tablespace TEMP;
GRANT AdminAuto to AdminAu;
ALTER USER AdminAu DEFAULT ROLE AdminAuto;
CREATE USER Super identified by "123" default tablespace USERS temporary tablespace TEMP;
GRANT Supervisor to Super;
ALTER USER Super DEFAULT ROLE Supervisor;
CREATE USER Cli identified by "123" default tablespace USERS temporary tablespace TEMP;
GRANT Cliente to Cli;
ALTER USER CLi DEFAULT ROLE Cliente;