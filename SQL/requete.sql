/* Première requête */
/* Permet d'obtenir le nombre de logements différents par années et au totale*/
SELECT year, count(DISTINCT logementId)
FROM DateDim NATURAL JOIN LogementDim NATURAL JOIN Reservations
GROUP BY year WITH ROLLUP;


/* Seconde requête */
/* Permet d'obtenir le nombre de logement par code postal, par an et totale */
SELECT zipcode, year, count(DISTINCT logementId)
FROM DateDim NATURAL JOIN LocalisationDim NATURAL JOIN LogementDim NATURAL JOIN Reservations
GROUP BY zipcode, year WITH ROLLUP;


/* Troisième requête */
/* Permet d'obtenir le prix que peut gagner chaque région, par mois, par années et au totale */
SELECT zipcode, year, month, SUM(price)
FROM DateDim NATURAL JOIN LocalisationDim NATURAL JOIN Reservations
WHERE available = 't'
GROUP BY zipcode, year, month WITH ROLLUP;


/* Quatrième requête */
/* Permet d'obtenir le prix moyen par an, par région et au total */
SELECT zipcode, year, AVG(price)
FROM DateDim NATURAL JOIN LocalisationDim NATURAL JOIN Reservations
WHERE price IS NOT NULL
GROUP BY zipcode, year WITH ROLLUP;


/* Cinquième requête */
/* Permet d'obtenir le rang des 20 personnes qui gagne le plus */
SET @curRank := 0;
SELECT *, @curRank := @curRank + 1 AS rank FROM (
   SELECT proprietaireId, host_name, year, SUM(price)
   FROM DateDim NATURAL JOIN LocalisationDim NATURAL JOIN ProprietaireDim NATURAL JOIN Reservations
   GROUP BY proprietaireId, year
   ORDER BY SUM(price) DESC
) AS t LIMIT 20;


/* Sixième requête */
/* Permet d'afficher le nombre de proprietaire par région et au total */
SELECT zipcode, count(DISTINCT proprietaireId)
FROM LocalisationDim NATURAL JOIN ProprietaireDim NATURAL JOIN Reservations
GROUP BY zipcode WITH ROLLUP;


/* Septième requête */
/* Permet d'obtenir le nombre de superhost par région et au total */
SELECT zipcode, count(proprietaireId)
FROM LocalisationDim NATURAL JOIN ProprietaireDim NATURAL JOIN Reservations
WHERE host_is_superhost = 't'
GROUP BY zipcode WITH ROLLUP;


/* Huitième requête */
/* Permet d'afficher le nombre de response_rate de chaque hote, et le nombre total */
SELECT host_name, host_response_rate, count(*)
FROM ProprietaireDim NATURAL JOIN Reservations
WHERE host_response_rate IS NOT NULL
GROUP BY host_response_rate, host_name WITH ROLLUP;


/* Neuvième requête */



/* Dixième requête */
