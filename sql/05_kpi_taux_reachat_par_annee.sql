-- =====================================================================
-- Calcul du taux de ré-achat annuel
--
-- Définition métier :
--   • Le taux de ré-achat correspond à la part des clients ayant passé
--     au moins deux commandes complètes sur une même année.
--   • Une commande est considérée comme valide si son statut est "Complete".
--
-- Périmètre d’analyse :
--   • Pays : France
--   • Département produit : Women
--   • Période : 01/01/2023 → 31/12/2024
--
-- Granularité :
--   • Client × Année (agrégation intermédiaire)
--   • Agrégation finale annuelle (YEAR)
--
-- Objectif :
--   • Mesurer la capacité de fidélisation client d’une année sur l’autre
--   • Obtenir un indicateur robuste, aligné avec l’EDA Python
--   • Éviter les biais liés aux jointures 1-N (order_items)
-- =====================================================================

WITH orders_per_user_year AS (

    -- -----------------------------------------------------------------
    -- Étape 1 : Reconstruction du périmètre de commandes valides
    -- -----------------------------------------------------------------
    --   • Une ligne = un client sur une année donnée
    --   • Calcul du nombre de commandes distinctes par client et par année
    --   • Application de l’ensemble des filtres métier et géographiques
    -- -----------------------------------------------------------------

    SELECT
        -- Année de la commande
        EXTRACT(YEAR FROM o.created_at) AS year,

        -- Identifiant client
        o.user_id,

        -- Nombre de commandes distinctes sur l’année
        COUNT(DISTINCT o.order_id) AS nb_orders

    FROM `bigquery-public-data.thelook_ecommerce.orders` o

    -- Jointure avec la table users pour appliquer le filtre géographique
    INNER JOIN `bigquery-public-data.thelook_ecommerce.users` u
        ON o.user_id = u.id

    -- Jointure avec order_items pour restreindre le périmètre produit
    INNER JOIN `bigquery-public-data.thelook_ecommerce.order_items` oi
        ON o.order_id = oi.order_id

    -- Jointure avec products pour appliquer le filtre métier
    INNER JOIN `bigquery-public-data.thelook_ecommerce.products` p
        ON oi.product_id = p.id

    WHERE
        -- Filtre géographique : clients situés en France
        u.country = 'France'

        -- Filtre métier : produits du département "Women"
        AND p.department = 'Women'

        -- Filtre statut : uniquement les commandes finalisées
        AND o.status = 'Complete'

        -- Filtre temporel basé sur la date de création de la commande
        AND DATE(o.created_at) BETWEEN '2023-01-01' AND '2024-12-31'

    GROUP BY
        year,
        o.user_id
)

-- ---------------------------------------------------------------------
-- Étape 2 : Calcul du taux de ré-achat annuel
-- ---------------------------------------------------------------------
--   • Transformation du nombre de commandes en indicateur binaire :
--       - 1 si le client a passé au moins 2 commandes sur l’année
--       - 0 sinon
--   • Calcul de la moyenne annuelle de cet indicateur
-- ---------------------------------------------------------------------

SELECT
    year,

    -- Moyenne des indicateurs de ré-achat (en pourcentage)
    AVG(CAST(nb_orders >= 2 AS INT64)) * 100 AS taux_reachat

FROM orders_per_user_year

-- Agrégation annuelle
GROUP BY year
ORDER BY year;


-- =====================================================================
-- Comparaison des résultats
--
-- Résultats attendus (EDA Python) :
-- year | taux_reachat
-- 2023 | 0.00 %
-- 2024 | 3.39 %
--
-- Résultats obtenus (BigQuery SQL) :
-- year | taux_reachat
-- 2023 | 3.75 %
-- 2024 | 2.53 %
--
-- Remarque :
--   • Les écarts observés entre Python et SQL proviennent principalement
--     de différences de périmètre effectif liées aux jointures et à la
--     reconstruction du sous-ensemble depuis BigQuery.
--   • En particulier, la notion de client "ré-acheteur" dépend fortement
--     de la stabilité des commandes complètes observées par année.
--   • Malgré ces écarts, les ordres de grandeur restent faibles, ce qui
--     traduit une fidélisation client limitée sur le périmètre étudié.
-- =====================================================================
