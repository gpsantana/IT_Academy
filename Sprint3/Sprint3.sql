SELECT * FROM company;
SELECT * FROM transaction;
SELECT * FROM credit_card;
SELECT * FROM user;

-- La teva tasca és dissenyar i crear una taula anomenada "credit_card" que emmagatzemi 
-- detalls crucials sobre les targetes de crèdit. La nova taula ha de ser capaç d'identificar de manera única
-- cada targeta i establir una relació adequada amb les altres dues taules ("transaction" i "company"). 
-- Després de crear la taula serà necessari que ingressis la informació del document denominat
-- "dades_introduir_credit". Recorda mostrar el diagrama i realitzar una breu descripció d'aquest.


CREATE TABLE credit_card (
id VARCHAR(20) not null,
iban VARCHAR(50),
pan CHAR(50),
pin CHAR(6),
cvv CHAR(4),
expiring_date VARCHAR(20),
primary key(id));

-- nos muestra todos los registros de la tabla credit_card que acabamos de crear

SELECT * FROM credit_card;

-- al intentar crear la ForeignKey nos da error y con este comando vemos como fue creada.

Describe transaction;

-- con este comando eliminamos el CONSTRAINT de la tabla para poder crear uno nuevo

ALTER TABLE transaction DROP CONSTRAINT transaction_ibfk_1;

-- nos mustra información de como se creo la tabal junto con su PK y FK
show create table transaction;

-- ahora si creamos las Foreign Keys de la tabla transaction.
ALTER TABLE transaction
ADD CONSTRAINT fk_credit_card
FOREIGN KEY (credit_card_id) 
REFERENCES credit_card(id);

ALTER TABLE transaction
ADD CONSTRAINT fk_company_id
FOREIGN KEY (company_id) 
REFERENCES company(id);

-- esta selección nos permite comparar los datos de ambas tablas
SELECT transaction.credit_card_id 
FROM transaction
WHERE transaction.credit_card_id IS NOT NULL
AND transaction.credit_card_id NOT IN (SELECT credit_card.id FROM credit_card)
GROUP BY transaction.credit_card_id;

-- eliminamos los registros NULL de tabla credit_card
DELETE FROM credit_card
where id = null;

-- eliminamos el registro de la tabla transaction
DELETE FROM transaction
where credit_card_id = "CcU-9999";

-- comprobamos que el registro existe.
SELECT *
FROM credit_card
WHERE id = "CcU-2938";

-- hacemos el cambio del registro
UPDATE credit_card
SET iban = "TR323456312213576817699999"
WHERE id = "CcU-2938";

-- insertamos registro en la tabla credit_card
INSERT INTO credit_card (id)
VALUES  ("CcU-9999");

-- insertamos registro en la tabla company
INSERT INTO company (id)
VALUES  ("b-9999");

-- insertamos el resto de la información en la tabla transaction.
INSERT INTO transaction (id,credit_card_id,company_id,user_id,lat,longitude,amount,declined)
VALUES ("108B1D1D-5B23-A76C-55EF-C568E49A99DD","CcU-9999","b-9999",9999,829.999,-117.999,111.11,0);

SELECT *
FROM credit_Card;

-- eliminamos la columna pan de la tabla credit_card
ALTER TABLE credit_card
DROP COLUMN pan;

-- seleccionamos el registro con el id =
SELECT *
FROM transaction
WHERE id = "02C6201E-D90A-1859-B4EE-88D2986D3B02";

-- eliminamos el registro de la tabla transaction con el id =
DELETE FROM transaction
WHERE id = "02C6201E-D90A-1859-B4EE-88D2986D3B02";

-- La secció de màrqueting desitja tenir accés a informació específica per a realitzar anàlisi i estratègies
-- efectives. S'ha sol·licitat crear una vista que proporcioni detalls clau sobre les companyies i les seves
-- transaccions. Serà necessària que creïs una vista anomenada VistaMarketing que contingui la següent
-- informació: Nom de la companyia. Telèfon de contacte. País de residència.
-- Mitjana de compra realitzat per cada companyia. Presenta la vista creada, ordenant les dades de major a menor 
-- mitjana de compra.

CREATE VIEW VistaMarketing AS
SELECT company.company_name,company.phone,company.country,AVG(transaction.amount) as media_compras
FROM company
JOIN transaction
ON company.id=transaction.company_id
GROUP BY company.company_name,company.phone,company.country
ORDER BY AVG(transaction.amount) DESC;

-- Hacemos la selección de todos los registros de la vista.
SELECT * FROM VistaMarketing;

-- Eliminamos la vista
DROP VIEW VistaMarketing;


-- Hacemos la selección de las compañías del país Germany en la vista creada.
SELECT *
FROM VistaMarketing
WHERE country = "Germany";

-- Cambiamos el nombre a la tabla.
RENAME TABLE user TO data_user;

-- Modificamos el tipo de dato de la columna id
ALTER TABLE data_user MODIFY COLUMN id INT;

-- Eliminamos la columna website.
ALTER TABLE company
DROP COLUMN website;

-- Modificamos el tipo de dato de la columna pin
ALTER TABLE credit_card MODIFY COLUMN pin VARCHAR(4);

-- Modificamos el tipo de dato de la columna expiring_date
ALTER TABLE credit_card MODIFY COLUMN expiring_date VARCHAR(20);

-- Añadimos la columna fecha_actual con formato fecha
ALTER TABLE credit_card
ADD COLUMN fecha_actual DATE;


-- seleccionamos los datos que no están en la tabla data_user
SELECT transaction.user_id 
FROM transaction
WHERE transaction.user_id IS NOT NULL
AND transaction.user_id NOT IN (SELECT data_user.id FROM data_user)
GROUP BY transaction.user_id;

-- Eliminamos el registro del usuario 9999
DELETE FROM transaction
WHERE user_id = 9999;

-- Añadimos la ForeignKey a la tabla transaction
ALTER TABLE transaction
ADD CONSTRAINT fk_data_user_id
FOREIGN KEY (user_id) 
REFERENCES data_user(id);


-- L'empresa també et sol·licita crear una vista anomenada "InformeTecnico" que contingui la següent informació:

-- ID de la transacció
-- Nom de l'usuari/ària
-- Cognom de l'usuari/ària
-- IBAN de la targeta de crèdit usada.
-- Nom de la companyia de la transacció realitzada.
-- Assegura't d'incloure informació rellevant de totes dues taules i utilitza àlies per a canviar de nom columnes segons sigui necessari.
-- Mostra els resultats de la vista, ordena els resultats de manera descendent en funció de la variable ID de transaction.

CREATE VIEW InformeTecnico AS
SELECT transaction.id,data_user.name as nombre ,data_user.surname as apellido,data_user.country as pais, credit_card.iban,company.company_name as compañia,transaction.declined,transaction.amount
FROM transaction
JOIN data_user
ON data_user.id=transaction.user_id
JOIN credit_card
ON credit_card.id=transaction.credit_card_id
JOIN company
ON company.id=transaction.company_id
GROUP BY transaction.id,data_user.name ,data_user.surname, credit_card.iban,company.company_name,transaction.declined,transaction.amount
ORDER BY transaction.id DESC;


-- Hacemos la selección de todos los campos de la vista InformeTecnico.
SELECT *
FROM InformeTecnico;

-- Eliminamos la vista. 
DROP VIEW Informetecnico;