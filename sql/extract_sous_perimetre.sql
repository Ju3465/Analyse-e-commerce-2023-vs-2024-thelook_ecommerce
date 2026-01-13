-- =====================================================================
-- Reconstruction du fichier CSV source utilisé pour l’EDA Python
-- et le tableau de bord Power BI
--
-- Source : bigquery-public-data.thelook_ecommerce
-- Périmètre métier :
--   • Pays : France
--   • Département produit : Women
--   • Période : 01/01/2023 → 31/12/2024
--
-- Objectif :
--   Reconstituer un jeu de données traçable, stable et cohérent
--   avec celui utilisé lors de l’analyse exploratoire (EDA).
--
-- Choix méthodologiques :
--   • Conservation de tous les statuts de lignes de commande
--     (Complete, Returned, Cancelled, Processing, Shipped)
--     afin de permettre les calculs ultérieurs de CA, marge
--     et taux de retour selon les règles métier.
--   • Sélection d’un sous-ensemble minimal de colonnes,
--     suffisant pour répondre aux objectifs analytiques.
--   • Exclusion volontaire de colonnes non indispensables
--     (ex : shipped_at, delivered_at, product_id).
--   • Les filtres géographiques, temporels et métier sont 
--     appliqués exclusivement en SQL afin de garantir la  
--     reproductibilité des analyses et la cohérence entre 
--     Python, SQL et Power BI.
-- =====================================================================

SELECT
    -- Identifiants de commande et de ligne
    oi.order_id,
    oi.id AS order_item_id,

    -- Date de création de la ligne article
    oi.created_at AS item_created_at,

    -- Statut et montant de la ligne article
    oi.status AS item_status,
    oi.sale_price,

    -- Informations produit
    p.cost,
    p.category,
    p.department,
    p.brand,
    p.name AS product_name,

    -- Informations commande (utiles notamment pour le taux de ré-achat)
    o.status AS order_status,
    o.created_at AS order_created_at,

    -- Informations client et géographiques
    u.id AS user_id,
    u.gender,
    u.country,
    u.state,
    u.city

FROM `bigquery-public-data.thelook_ecommerce.order_items` oi

-- Jointure avec la table des commandes
INNER JOIN `bigquery-public-data.thelook_ecommerce.orders` o
    ON oi.order_id = o.order_id

-- Jointure avec la table des utilisateurs (profil et géographie)
INNER JOIN `bigquery-public-data.thelook_ecommerce.users` u
    ON o.user_id = u.id

-- Jointure avec le référentiel produits
INNER JOIN `bigquery-public-data.thelook_ecommerce.products` p
    ON oi.product_id = p.id

WHERE
    -- Filtre géographique : commandes passées en France
    u.country = 'France'

    -- Filtre métier : produits du département "Women"
    AND p.department = 'Women'

    -- Filtre temporel basé sur la date de création de la ligne article
    AND DATE(oi.created_at) BETWEEN '2023-01-01' AND '2024-12-31'

-- Ordonnancement
ORDER BY
    item_created_at,
    oi.order_id,
    order_item_id;
