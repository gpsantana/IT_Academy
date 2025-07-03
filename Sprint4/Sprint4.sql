SELECT * FROM transactions;
SELECT * FROM clientes;
SELECT * FROM credit_cards;
SELECT * FROM products;


-- creamos el database
CREATE DATABASE sprint4;


-- creamos la tabla transaction

CREATE TABLE transactions (
id VARCHAR(50) not null,
card_id VARCHAR(50),
business_id VARCHAR(50),
timestamp timestamp ON UPDATE CURRENT_TIMESTAMP,
amount FLOAT,
declined BOOL,
product_ids VARCHAR(20),
user_id VARCHAR(20),
lat FLOAT,
longitude FLOAT,
primary key(id));

-- cargamos información tabla transaction

LOAD DATA LOCAL INFILE '/Users/gabrielpsantana/Documents/IT_ACADEMY/Sprint\ 4/transactions.csv'
INTO TABLE transactions
FIELDS TERMINATED BY ';'
IGNORE 1 ROWS;

-- creamos tabla clientes

CREATE TABLE clientes (
id VARCHAR(20) not null,
name CHAR(50),
surname CHAR(50),
phone VARCHAR(50),
email VARCHAR(250),
birthday VARCHAR(50),
country CHAR(50),
city CHAR(50),
postal_code VARCHAR(20),
adress VARCHAR(250),
primary key(id));

-- cargamos información tabla clientes

LOAD DATA LOCAL INFILE  '/Users/gabrielpsantana/Documents/IT_ACADEMY/Sprint\ 4/american_users.csv' 
INTO TABLE clientes
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
IGNORE 1 ROWS;

-- cargamos el otro documento de clientes a la tabla

LOAD DATA LOCAL INFILE  '/Users/gabrielpsantana/Documents/IT_ACADEMY/Sprint\ 4/european_users.csv ' 
INTO TABLE clientes
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
IGNORE 1 ROWS;

-- creamos la tabla credit_cards

CREATE TABLE credit_cards (
id VARCHAR(50) not null,
user_id VARCHAR(20),
iban VARCHAR(50),
pan VARCHAR(20),
pin CHAR(6),
cvv CHAR(6),
track1 VARCHAR(250),
rtack2 VARCHAR(250),
expiring_date VARCHAR(20),
primary key(id));

-- cargamos la información a credit__cards

LOAD DATA LOCAL INFILE  '/Users/gabrielpsantana/Documents/IT_ACADEMY/Sprint\ 4/credit_cards.csv' 
INTO TABLE credit_cards
FIELDS TERMINATED BY ','
IGNORE 1 ROWS;


-- creamos la tabla companies

CREATE TABLE companies (
company_id VARCHAR(50) not null,
company_name VARCHAR(250),
phone VARCHAR(50),
email VARCHAR(250),
country CHAR(50),
website VARCHAR(250),
primary key(company_id));

-- cargamos la información a tabla companies

LOAD DATA LOCAL INFILE  '/Users/gabrielpsantana/Documents/IT_ACADEMY/Sprint\ 4/companies.csv' 
INTO TABLE companies
FIELDS TERMINATED BY ','
IGNORE 1 ROWS;



-- creamos la tabla products

CREATE TABLE products (
id VARCHAR(50) not null,
product_name VARCHAR(250),
price CHAR(50),
colour VARCHAR(50),
weight FLOAT(50),
warehouse_id VARCHAR(50),
primary key(id));

-- cargamos la información a tabla products

LOAD DATA LOCAL INFILE  '/Users/gabrielpsantana/Documents/IT_ACADEMY/Sprint\ 4/products.csv' 
INTO TABLE products
FIELDS TERMINATED BY ','
IGNORE 1 ROWS;


-- ahora creamos las foreign keys

ALTER TABLE transactions
ADD CONSTRAINT fk_card_id
FOREIGN KEY (card_id) 
REFERENCES credit_cards(id);


ALTER TABLE transactions
ADD CONSTRAINT fk_business_id
FOREIGN KEY (business_id) 
REFERENCES companies(company_id);


ALTER TABLE transactions
ADD CONSTRAINT fk_user_id
FOREIGN KEY (user_id) 
REFERENCES clientes(id);


-- Exercici 1
-- Realitza una subconsulta que mostri tots els usuaris amb més de 80 transaccions utilitzant almenys 2 taules.

SELECT *
FROM clientes as c
HAVING c.id IN (
				SELECT t.user_id
				FROM transactions as t
				GROUP BY t.user_id
				HAVING COUNT(DISTINCT t.id)>80)
;



-- Exercici 2
-- Mostra la mitjana d'amount per IBAN de les targetes de crèdit a la companyia Donec Ltd, utilitza almenys 2 taules

SELECT cc.id, cc.iban, TRUNCATE(AVG(t.amount), 2) as media,c.company_name
FROM credit_cards as cc
JOIN transactions as t
ON cc.id=t.card_id
JOIN companies as c
ON t.business_id=c.company_id
WHERE company_name LIKE "Donec Ltd"
GROUP BY cc.id,cc.iban,c.company_name
ORDER BY media DESC;


-- Crea una nova taula que reflecteixi l'estat de les targetes de crèdit basat en si les últimes tres 
-- transaccions van ser declinades i genera la següent consulta.

CREATE TABLE tarjetas_activas (
card_id VARCHAR(50) NOT NULL,
estado VARCHAR(50),
PRIMARY KEY (card_id));

INSERT INTO tarjetas_activas (card_id,estado)
SELECT t.card_id,
CASE WHEN COUNT(*)=3 AND SUM(declined)=3 THEN "bloqueada"
ELSE "activa"
END as estado
FROM (SELECT *,
row_number() OVER (partition by card_id ORDER BY timestamp DESC) as contador
FROM transactions) as t
WHERE contador<=3
GROUP BY t.card_id;


select * from tarjetas_activas;

select *
FROM transactions
WHERE card_id LIKE "%4870"
ORDER BY timestamp DESC;

-- Quantes targetes estan actives?

SELECT * FROM tarjetas_activas
WHERE estado="bloqueada";

SELECT COUNT(card_id) as total_activas
FROM tarjetas_activas
WHERE estado ="activa";




SELECT t.card_id,
CASE WHEN COUNT(*)=3 AND SUM(declined)=3 THEN "bloqueada"
ELSE "activa"
END as estado
FROM (SELECT *,
row_number() OVER (partition by card_id ORDER BY timestamp DESC) as contador
FROM transactions) as t
WHERE contador<=3
GROUP BY t.card_id;


SELECT *,
row_number() OVER (partition by card_id ORDER BY timestamp DESC) as contador
FROM transactions;




-- Crea una taula amb la qual puguem unir les dades del nou arxiu products.csv amb la base de dades creada, 
-- tenint en compte que des de transaction tens product_ids. Genera la següent consulta:

-- Exercici 1
-- Necessitem conèixer el nombre de vegades que s'ha venut cada producte.


CREATE TABLE transitionproduct ( 
id  VARCHAR (255),
product_id VARCHAR(50));

INSERT INTO transitionproduct (id,product_id)
WITH RECURSIVE numero as (
    SELECT 1 as n
    UNION ALL
    SELECT n + 1 FROM numero WHERE n < 100
),
split_ids as (
    SELECT 
        id,
        SUBSTRING_INDEX(SUBSTRING_INDEX(t.product_ids, ',', numero.n), ',', -1) as product_id
    FROM transactions as t
    JOIN numero ON numero.n <= CHAR_LENGTH(t.product_ids) - CHAR_LENGTH(REPLACE(t.product_ids, ',', '')) + 1
)
SELECT id,product_id
FROM split_ids;

SELECT * FROM transitionproduct;

UPDATE transitionproduct SET product_id = TRIM(product_id);

ALTER TABLE transitionproduct
ADD CONSTRAINT fk_transactions
FOREIGN KEY (id)
REFERENCES transactions(id);


ALTER TABLE transitionproduct
ADD CONSTRAINT fk_products
FOREIGN KEY (product_id)
REFERENCES products(id);

-- Necessitem conèixer el nombre de vegades que s'ha venut cada producte.
SELECT p.id,p.product_name,COUNT(tp.product_id) AS ventas
FROM products p
JOIN transitionproduct AS tp
ON p.id=tp.product_id
group by tp.product_id
ORDER BY p.id;
