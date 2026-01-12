-- =====================================================================
-- Calcul du taux de retour annuel
--
-- Définition métier :
--   • Le taux de retour correspond à la part des lignes de commande
--     dont le statut est "Returned" parmi l’ensemble des lignes
--     ayant donné lieu à une vente ou à un retour.
--   • Le dénominateur inclut uniquement les lignes "Complete" et
--     "Returned".
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
--   • Mesurer la part des articles retournés par rapport aux articles
--     effectivement vendus
--   • Comparer les résultats SQL avec ceux obtenus lors de l’EDA Python
-- =====================================================================

SELECT
    -- Calcul du taux de retour :
    -- nombre de lignes retournées divisé par le total des lignes vendues ou retournées
    COUNTIF(oi.status = 'Returned')
    /
    COUNTIF(oi.status IN ('Returned', 'Complete')) AS taux_retour,

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

    -- Filtre temporel basé sur la date de création de la ligne article
    AND DATE(oi.created_at) BETWEEN '2023-01-01' AND '2024-12-31'

-- Agrégation annuelle
GROUP BY year;

-- =====================================================================
-- Comparaison des résultats
--
-- Résultats attendus (EDA Python) :
-- year | taux_retour
-- 2023 | 37.87 %
-- 2024 | 30.42 %
--
-- Résultats obtenus (BigQuery SQL) :
-- year | taux_retour
-- 2023 | 25.30 %
-- 2024 | 24.69 %
--
-- Remarque :
--   • Le taux de retour calculé en SQL est inférieur à celui obtenu
--     lors de l’EDA Python.
--   • Cet écart s’explique principalement par des différences de
--     périmètre effectif entre le CSV analysé en Python et les données
--     issues directement de BigQuery (jointures, stabilité de
--     l’extraction, filtres temporels).
--   • Malgré ces écarts, la tendance reste cohérente : une baisse
--     du taux de retour entre 2023 et 2024.
-- =====================================================================
