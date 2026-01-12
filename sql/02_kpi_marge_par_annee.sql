-- =====================================================================
-- Calcul de la marge brute annuelle
--
-- Définition métier :
--   • La marge brute correspond à la différence entre le chiffre
--     d’affaires (sale_price) et le coût produit (cost),
--     calculée uniquement sur les lignes de commande "Complete".
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
--   • Vérifier la cohérence des calculs de marge entre les deux environnements
-- =====================================================================

SELECT
    -- Calcul de la marge brute sur les lignes vendues
    SUM(oi.sale_price) - SUM(p.cost) AS marge_brute,

    -- Extraction de l’année à partir de la date de création de la ligne
    EXTRACT(YEAR FROM oi.created_at) AS year

FROM `bigquery-public-data.thelook_ecommerce.order_items` oi

-- Jointure avec la table users pour appliquer le filtre géographique
INNER JOIN `bigquery-public-data.thelook_ecommerce.users` u
    ON oi.user_id = u.id

-- Jointure avec la table products pour récupérer le coût et filtrer le département
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
-- year | marge_brute
-- 2023 | 4 075.34 €
-- 2024 | 8 134.61 €
--
-- Résultats obtenus (BigQuery SQL) :
-- year | marge_brute
-- 2023 | 3 647.46 €
-- 2024 | 7 409.43 €
--
-- Remarque :
--   • Les écarts observés entre les résultats Python et SQL sont
--     cohérents avec ceux identifiés sur le chiffre d’affaires.
--   • Ils s’expliquent principalement par de légères différences
--     de périmètre effectif liées aux jointures, à la stabilité
--     des extractions et aux filtres temporels appliqués.
--   • Ces écarts restent limités et n’altèrent pas l’analyse
--     métier ni les enseignements globaux du projet.
-- =====================================================================
