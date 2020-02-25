#Intégration et entrepôts de données

**Auteurs** | 
--- | 
Boursier Louis |
Filaudeau Eloi |
Lasherme Loic |
Nantier Matthias |


##Origine des données

####[Michelin Restaurants](https://www.kaggle.com/jackywang529/michelin-restaurants)
La première partie des données provient du site web Kaggle. Le jeu de données porte sur les restaurants étoilés Michelin (liste non exhaustive). Il est décomposé en 3 fichiers, un pour chaque nombre d'étoile.

##Transformation

###Michelin Restaurants
1. Concatener les trois fichiers csv en un seul . Supprimer les headers qui viennent se dupliquer et en ne garder que celui en première ligne.
3. Les données sont déjà nettoyées.
4. Préparer les clés des futures tables des dimensions pour le schéma en étoile.
    1. Création de la colonne yearId selon la colonne year. Sa valeur est de 1 si l'année est 2018, et de 2 si l'année est 2019. Sur OpenRefine, on utilise l'expression GREL suivante pour créer une colonne à partir de year : `if(value==2018,1,2)`. Cela fonctionne comme nous avons seulement deux années à dans notre table.
    2. Création de la colonne locationId selon la colonne city. Sa valeur est otpenue avec l'expression suivante : `sha1(value).substring(0,10)`
    3. Même chose avec la colonne cuisine : on créer la colonne cuisineId avec le hashing.
    4. Dans la colonne price, on enlève les colonnes ayant pour valeur 'N/A'. Sur OpenRefine, on utilise le text facet, pour sélectionner les lignes correspondantes, puis on utilise le flag pour les marquer et les supprimer.
    5. On remplace les chaînes de caractères de la colonne price par un numéro représentant le nombre de `$` de cet colonne. On utilise le if vu précédemment de façon imbriquée. Exemple : `$$$` devient `3`.
    6. On remplace le type chaîne de caractère en type entier. Sur OpenRefine : Edit cells > Common transforms > To number.
5. On sauvegarde 4 copies de notre table. 3 pour les dimensions et une pour les faits.
    1. Dans la table des faits, on conserve uniquement les colonnes name, latitude, longitude, price, yearId, locationId, cuisineId.
    2. Dans la dimension de l'année, on garde la colonne year et yearId.
    3. Dans la dimension localisation, on garde la colonne city, region et locationId
    4. Dans la dimension cusisine, on garde la colonne cuisine et cuisineId.
6. Pour chaque table des dimensions, on enlève les duplicats, c'est à dire que chaque ligne doit être unique. Voir l'annexe 'Removing duplicates' plus bas.



---

##Removing duplicates
These can be spotted by sorting them by a unique value, such as the Record ID (in this case we are assuming the Record ID should in fact be unique for each entry). The operation can be performed by clicking the triangle left of Record ID, then choosing ‘Sort‘… and selecting the ‘numbers’ bullet. In OpenRefine, sorting is only a visual aid, unless you make the reordering permanent. To do this, click the Sort menu that has just appeared at the top and choose ‘Reorder rows permanently’. If you forget to do this, you will get unpredictable results later in this tutorial.

Identical rows are now adjacent to each other. Next, blank the Record ID of rows that have the same Record ID as the row above them, marking them duplicates. To do this, click on the Record ID triangle, choose Edit cells > Blank down. The status message tells you that 84 columns were affected (if you forgot to reorder rows permanently, you will get only 19; if so, undo the blank down operation in the ‘Undo/Redo’ tab and go back to the previous paragraph to make sure that rows are reordered and not simply sorted). Eliminate those rows by creating a facet on ‘blank cells’ in the Record ID column (‘Facet’ > ‘Customized facets’ > ‘Facet by blank’), selecting the 84 blank rows by clicking on ‘true’, and removing them using the ‘All’ triangle (‘Edit rows’ > ‘Remove all matching rows’). Upon closing the facet, you see 75,727 unique rows.

Be aware that special caution is needed when eliminating duplicates. In the above mentioned step, we assume the dataset has a field with unique values, indicating that the entire row represents a duplicate. This is not necessarily the case, and great caution should be taken to manually verify whether the entire row represents a duplicate or not.
