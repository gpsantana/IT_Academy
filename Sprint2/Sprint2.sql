SELECT *
FROM company;

SELECT *
FROM transaction;

-- Llistat dels països que estan generant vendes.
SELECT company.country
FROM company
JOIN transaction
ON company.id=transaction.company_id
GROUP BY country;

-- Des de quants països es generen les vendes.

SELECT COUNT(DISTINCT company.country)as TOTAL_PAISES
FROM company
JOIN transaction
ON company.id=transaction.company_id;


SELECT COUNT(country) as TOTAL_PAISES
FROM (SELECT company.country
FROM company
JOIN transaction
ON company.id=transaction.company_id
GROUP BY country) as paises;

-- Identifica la companyia amb la mitjana més gran de vendes.
SELECT company_name, AVG(amount) as promedio_ventas
FROM company
JOIN transaction
ON company.id=transaction.company_id
GROUP BY company_name
ORDER BY promedio_ventas DESC
LIMIT 1;

-- Mostra totes les transaccions realitzades per empreses d'Alemanya.
SELECT *
FROM transaction
WHERE transaction.company_id in (SELECT company.id
FROM company
WHERE country= "Germany");

-- Llista les empreses que han realitzat transaccions per un amount superior a la mitjana de totes les
-- transaccions
SELECT company.company_name
FROM company
WHERE company.id in (SELECT transaction.company_id
FROM transaction
WHERE transaction.amount > (SELECT AVG(transaction.amount)
FROM transaction)
GROUP BY transaction.company_id);

-- Eliminaran del sistema les empreses que no tenen transaccions registrades, entrega el llistat 
-- d'aquestes empreses.
SELECT company.id, company.company_name
FROM company
WHERE company.id NOT IN (SELECT transaction.company_id FROM transaction)
GROUP BY company.id,company.company_name;


-- Identifica els cinc dies que es va generar la quantitat més gran d'ingressos a l'empresa per vendes.
-- Mostra la data de cada transacció juntament amb el total de les vendes.
SELECT transaction.company_id,DATE(timestamp) as fecha,SUM(transaction.amount) as total_ventas
FROM transaction
GROUP BY transaction.company_id,DATE(timestamp)
ORDER BY SUM(transaction.amount) DESC LIMIT 5;


-- Quina és la mitjana de vendes per país? Presenta els resultats ordenats de major a menor mitjà.
SELECT company.country, AVG(transaction.amount) as media
FROM company
JOIN transaction
ON company.id=transaction.company_id
GROUP BY company.country
ORDER BY AVG(transaction.amount) DESC;

-- En la teva empresa, es planteja un nou projecte per a llançar algunes campanyes publicitàries per a fer 
-- competència a la companyia "Non Institute". Per a això, et demanen la llista de totes les transaccions 
-- realitzades per empreses que estan situades en el mateix país que aquesta companyia.

-- Usando JOIN y Subconsulta
SELECT *
FROM transaction
JOIN company
ON transaction.company_id=company.id
where company.country in (SELECT company.country
FROM company
WHERE company.company_name= "Non Institute");



-- Solo Subquery
SELECT *
FROM transaction
WHERE transaction.company_id in (SELECT company.id
FROM company
where country = (SELECT company.country
FROM company
WHERE company.company_name= "Non Institute"));


-- Presenta el nom, telèfon, país, data i amount, d'aquelles empreses que van realitzar transaccions 
-- amb un valor comprès entre 350 i 400 euros i en alguna d'aquestes dates: 
-- 29 d'abril del 2015, 20 de juliol del 2018 i 13 de març del 2024. 
-- Ordena els resultats de major a menor quantitat.
SELECT company.company_name,company.phone,company.country,DATE(timestamp)as fecha,transaction.amount
FROM company
JOIN transaction
ON company.id=transaction.company_id
WHERE DATE(timestamp) in ('2015-04-29','2018-07-20','2024-03-13')
and transaction.amount BETWEEN 350 and 400
ORDER BY transaction.amount DESC;

-- Necessitem optimitzar l'assignació dels recursos i dependrà de la capacitat operativa que es requereixi,
-- per la qual cosa et demanen la informació sobre la quantitat de transaccions que realitzen les empreses,
-- però el departament de recursos humans és exigent i vol un llistat de les empreses on especifiquis 
-- si tenen més de 400 transaccions o menys.
SELECT company.company_name, COUNT(company.id) AS total_transacciones,
CASE 
	WHEN COUNT(company.id) < 400 THEN 'NO'
	ELSE 'SI'
END AS mas_de_400
FROM company
JOIN transaction ON company.id = transaction.company_id
GROUP BY company.company_name;