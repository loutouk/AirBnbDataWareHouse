# Intégration et entrepôts de données

**Auteurs** | 
:---: | 
Boursier Louis |
Filaudeau Eloi |
Lasherme Loic |
Nantier Matthias |


## Origine des données

#### [Seattle Airbnb Open Data](https://www.kaggle.com/airbnb/seattle)
Les données proviennent du site web Kaggle et sont fournies par Airbnb sous licence [CC0: Public Domain](https://creativecommons.org/publicdomain/zero/1.0/). Le jeu de données porte sur les réservations de logements chez Airbnb à Seattle.

#### Contenu
- Les logements avec leurs propriétaires
- Les avis des utilisateurs sur leurs résevrations
- Les calendriers, c'est à dire les dates associées aux réservations à un certain prix, et leur disponibilité à cette date

### Idées
- Décrire les caractéristiques de chaque quartier de Seattle en utilisant la description des logements
- Quelles sont les plus forts moments d'affluence ? Comment les prix varient ?
- Quelle est la tendance vis à vis des visiteurs à Seattle et des logements proposés ?

## Transformation en schéma en étoile

### Seattle Airbnb Open Data
1. Créer une dimension date
    1. Créer un nouveau projet OpenRefine à partir du fichier `calendar.csv` Pour accélérer la vitesse des opérations, on peut ne charger qu'une partie des données `Load at most 100000 row(s) of data`
    2. Sous OpenRefine, créer une nouvelle colonne `year` depuis la colonne `date`. `Edit column` > `Add column based on this colulmn` > `split(value, "-")[0]`
    3. Faire la même chose pour les mois et les jours
    4. Créer la clé dateId pour notre nouvelle table à partir de la colonne `calendar`. Sa valeur est optenue avec l'expression suivante : `sha1(cells.year.value+cells.month.value+cells.day.value).substring(0,10)`
    5. Supprimer les colonnes `date`, `available`, `price`, `listing_id` qui ne sont plus utiles `Edit column` > `Remove this column`
    6. Pour chaque table des dimensions, on enlève les duplicats, c'est à dire que chaque ligne doit être unique (2FN). Voir l'annexe 'Removing duplicates' plus bas.
    7. On peut maintenant exporter ce projet en csv, pour récupérer notre dimension date
2. Créer une dimension localisation
    1. Créer un nouveau projet OpenRefine à partir du fichier `listings.csv` 
    2. Ne garder que les colonnes `neighbourhood_cleansed`, `neighbourhood_group_cleansed` et `zipcode`
    3. Créer la clé localisationId pour notre nouvelle table à partir de nos trois colonnes. Sa valeur est optenue avec l'expression suivante : `sha1(value + row.cells.zipcode.value + row.cells.neighbourhood_group_cleansed.value).substring(0,10)`
    4. Comme avant, éliminer les duplicats
    5. Exporter ce projet en csv pour récupérer la dimension localisation
3. Créer une dimension propriétaire
    1. Créer un nouveau projet OpenRefine à partir du fichier `listings.csv` 
    2. Ne garder que les colonnes `host_id`, `host_name`, `host_since`, `host_response_time`, `host_response_rate`, `host_acceptance_rate`, `host_is_superhost`
    3. Renommer la clé `host_id` en `proprietaireId`
    4. Comme avant, éliminer les duplicats sur `proprietaireId`
    5. Exporter ce projet en csv pour récupérer la dimension propriétaire
4. Créer une dimension logement
    1. Créer un nouveau projet OpenRefine à partir du fichier `listings.csv` 
    2. Ne garder que les colonnes `name`, `summary`, `space`, `description`
    3. Créer la clé `logementId` pour notre nouvelle table à partir de la colonne `name`. Sa valeur est optenue avec l'expression suivante : `sha1(value).substring(0,10)`
    4. Comme avant, éliminer les duplicats sur `logementId`
    5. Exporter ce projet en csv pour récupérer la dimension logement
5. Créer la première partie de la table des faits
    1. Créer un nouveau projet OpenRefine à partir du fichier `listings.csv` 
    2. Ne garder que les colonnes `id`, `host_id`, `name`, `neighbourhood_cleansed`, `neighbourhood_group_cleansed` et `zipcode`
    3. Recréer les colonnes correspondant aux clés des tables des dimensions à partir des colonnes gardées, comme fait dans les étapes précédentes
    4. Supprimer les colonnes gardées pour ne laisser que les colonnes générées correspondants aux clés des tables des dimensions en gardant la colonne `id` pour plus tard
    5. Exporter en csv
6. Créer la deuxième partie de la table des faits
    1. Créer un nouveau projet OpenRefine à partir du fichier `calendar.csv` 
    2. Recréer la colonne `dateId` à partir de la colonne `date`, comme avant, puis la supprimer la colonne `date`
    4. L'étape précédente est ralisée avec la commnade GREL suivante : `sha1(split(value, "-")[0] + split(value, "-")[1] + split(value, "-")[2]).substring(0,10)` 
    3. Exporter en csv
7. Fusionner les deux tables des faits en une seule avec une jointure sur `listing_id` / `id`
    1. Ouvrir le projet de la deuxième partie de la table des faits sous OpenRefine (celle qui contient le plus d'enregistrements)
    2. Sur la colonne `listing_id`, cliquer sur `Edit column` > `Add column based on this column`
        3. Joindre la colonne `logementId` de l'autre projet à notre projet avec l'expression `cell.cross("projetTableFaitsUne", "id").cells["logementId"].value[0]`
    4. Même chose avec la colonne `proprietaireId` et `localisationId`
    6. Supprimer la colonne `listing_id`
    7. Ne garder que la table des faits courante comme table des faits
    8. Exporter en csv

## Nettoyage
1. Enlever les valeurs nulles sous OpenRefine `Facet` > `Customized Facet` > `Facet by blank` puis cliquer sur `All` > `Edit rows` > `Remove all matching rows`
2. Enlever les valeurs erronées en les repérant avec le `Facet` > `Text Facet` pour les chaînes de caractères, et `Facet` > `Numeric Facet` pour les nombres, les enlever comme expliquer ci-dessus

---

## Schéma en étoile

### Table des faits - Analyse des réservations

**Réservations** |
 :---: |
 dateId      |
 logementId      |
 proprietaireId |
 localisationId |
 available |
 price |

### Dimension date

**Date** |
 :---: |
 dateId      |
 ...      |   

### Dimension logement

**Date** |
 :---: |
 dateId      |
 ...      |  

### Dimension propriétaire

**Proprietaire** |
 :---: |
 proprietaireId      |
 ...      |  

### Dimension localisation

**Localisation** |
 :---: |
 localisationId      |
 ...      |  

---

![Star scheama](https://github.com/loutouk/AirBnbDataWareHouse/blob/master/Rapport/schema_entrepot.png)

## Removing duplicates
These can be spotted by sorting them by a unique value, such as the Record ID (in this case we are assuming the Record ID should in fact be unique for each entry). The operation can be performed by clicking the triangle left of Record ID, then choosing ‘Sort‘… and selecting the ‘numbers’ bullet. In OpenRefine, sorting is only a visual aid, unless you make the reordering permanent. To do this, click the Sort menu that has just appeared at the top and choose ‘Reorder rows permanently’. If you forget to do this, you will get unpredictable results later in this tutorial.

Identical rows are now adjacent to each other. Next, blank the Record ID of rows that have the same Record ID as the row above them, marking them duplicates. To do this, click on the Record ID triangle, choose Edit cells > Blank down. The status message tells you that 84 columns were affected (if you forgot to reorder rows permanently, you will get only 19; if so, undo the blank down operation in the ‘Undo/Redo’ tab and go back to the previous paragraph to make sure that rows are reordered and not simply sorted). Eliminate those rows by creating a facet on ‘blank cells’ in the Record ID column (‘Facet’ > ‘Customized facets’ > ‘Facet by blank’), selecting the 84 blank rows by clicking on ‘true’, and removing them using the ‘All’ triangle (‘Edit rows’ > ‘Remove all matching rows’). Upon closing the facet, you see 75,727 unique rows.

Be aware that special caution is needed when eliminating duplicates. In the above mentioned step, we assume the dataset has a field with unique values, indicating that the entire row represents a duplicate. This is not necessarily the case, and great caution should be taken to manually verify whether the entire row represents a duplicate or not.
