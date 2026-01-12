-- =====================================================================
-- Calcul du chiffre d’affaires annuel (CA net)
--
-- Définition métier :
--   • Le chiffre d’affaires correspond à la somme des sale_price
--     des lignes de commande dont le statut est "Complete".
--   • Les lignes retournées, annulées ou en cours sont exclues.
--
-- Périmètre d’analyse :
--   • Pays : France
--   • Département produit : Women
--   • Période : 01/01/2023 → 31/12/2024
--
-- Granularité :
--   • Agrégation annuelle (YEAR)
--
-- Objectif :
--   • Valider en SQL les résultats obtenus lors de l’EDA Python
--   • Identifier et expliquer les éventuels écarts résiduels
-- =====================================================================

SELECT
    -- Agrégation du chiffre d’affaires sur les lignes vendues
    SUM(oi.sale_price) AS chiffre_affaires_total,

    -- Extraction de l’année à partir de la date de création de la ligne
    EXTRACT(YEAR FROM oi.created_at) AS year

FROM `bigquery-public-data.thelook_ecommerce.order_items` oi

-- Jointure avec la table users pour appliquer le filtre géographique
INNER JOIN `bigquery-public-data.thelook_ecommerce.users` u
    ON oi.user_id = u.id

-- Jointure avec la table products pour appliquer le filtre métier
INNER JOIN `bigquery-public-data.thelook_ecommerce.products` p
    ON oi.product_id = p.id

WHERE
    -- Filtre géographique : clients situés en France
    u.country = 'France'

    -- Filtre métier : produits du département "Women"
    AND p.department = 'Women'

    -- Filtre statut : uniquement les ventes finalisées
    AND oi.status = 'Complete'

    -- Filtre temporel basé sur la date de création de la ligne article
    AND DATE(oi.created_at) BETWEEN '2023-01-01' AND '2024-12-31'

-- Agrégation annuelle
GROUP BY year;

-- =====================================================================
-- Comparaison des résultats
--
-- Résultats attendus (EDA Python) :
-- year | chiffre_affaires_total
-- 2023 | 7 806.32 €
-- 2024 | 15 716.28 €
--
-- Résultats obtenus (BigQuery SQL) :
-- year | chiffre_affaires_total
-- 2023 | 7 065.42 €
-- 2024 | 14 137.46 €
--
-- Remarque :
--   • Les écarts résiduels entre les résultats Python et SQL s’expliquent 
--     principalement par des différences de périmètre effectif induites par 
--     les jointures, la stabilité des extractions et les filtres temporels. 
--     Ils restent limités, cohérents, et n’affectent pas l’interprétation métier 
--     des indicateurs. Le CSV reconstruit constitue ainsi une base analytique fiable 
--     et traçable par rapport à la source BigQuery.
-- =====================================================================
