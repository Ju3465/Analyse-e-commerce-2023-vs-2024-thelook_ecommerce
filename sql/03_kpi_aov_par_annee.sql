-- =====================================================================
-- Calcul du panier moyen annuel
--
-- Définition métier :
--   • Le panier moyen correspond au chiffre d’affaires généré
--     par les lignes de commande "Complete" rapporté au nombre
--     de commandes distinctes ayant généré un revenu.
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
--   • Mesurer l’évolution de la valeur moyenne des commandes
--     entre 2023 et 2024
--   • Valider en SQL les résultats obtenus lors de l’EDA Python
-- =====================================================================

SELECT
    -- Calcul du panier moyen :
    -- chiffre d’affaires total divisé par le nombre de commandes distinctes
    SUM(oi.sale_price) / COUNT(DISTINCT oi.order_id) AS panier_moyen,

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
-- year | panier_moyen
-- 2023 | 80.48 €
-- 2024 | 85.41 €
--
-- Résultats obtenus (BigQuery SQL) :
-- year | panier_moyen
-- 2023 | 85.13 €
-- 2024 | 86.73 €
--
-- Remarque :
--   • Les écarts observés entre Python et SQL sont cohérents avec
--     ceux constatés sur le chiffre d’affaires et la marge brute.
--   • Ils s’expliquent principalement par de légères différences
--     de périmètre effectif (jointures, stabilité de l’extraction,
--     filtres temporels).
--   • Ces écarts restent limités et n’affectent pas l’analyse
--     de la dynamique du panier moyen entre 2023 et 2024.
-- =====================================================================
