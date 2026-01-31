Analyse de la performance e-commerce — TheLook Europe

France | Women | 2023–2024

1. Contexte et objectifs du projet

Vous endossez le rôle de Data Analyst au sein de TheLook Europe. La direction e-commerce demande d’analyser la performance de l’activité sur un périmètre précis et de comparer l’année 2023 à 2024.

Les objectifs du projet sont :

Contrôler la qualité des données (types, valeurs manquantes, doublons, cohérence temporelle).

Réaliser une analyse exploratoire (EDA) en Python afin de comprendre les mécanismes de performance.

Calculer les KPI en Python (chiffre d’affaires, marge, panier moyen, taux de retour, taux de ré-achat).

Valider les KPI en SQL sur BigQuery (source de vérité).

Construire un dashboard Power BI clair et décisionnel racontant l’évolution 2023 vs 2024.

2. Description du sous-périmètre
Périmètre métier

Pays : France

Département produit : Women

Période : du 01/01/2023 au 31/12/2024

Source de vérité

Dataset BigQuery : bigquery-public-data.thelook_ecommerce

Tables mobilisées

users : profil client et géographie

orders : commandes

order_items : lignes de commande

products : référentiel produit (coût, marque, catégorie, département)

Clés de jointure

users.id = orders.user_id

orders.order_id = order_items.order_id

products.id = order_items.product_id

Filtres appliqués

users.country = 'France'

products.department = 'Women'

DATE(order_items.created_at) entre '2023-01-01' et '2024-12-31'

3. Étape 1 — Analyse exploratoire en Python (EDA)

Cette étape est réalisée exclusivement en Python à partir du CSV fourni ou reconstruit.

Travaux réalisés :

Mini dictionnaire de données (définition, type, exemple).

Contrôles de qualité :

doublons complets et doublons logiques,

valeurs manquantes,

cohérence des identifiants,

cohérence des bornes temporelles.

Explorations descriptives :

distributions des prix de vente et des coûts,

contribution au CA par marque, catégorie et ville,

saisonnalité mensuelle (comparaison 2023 vs 2024).

Calcul des KPI Python selon les règles métier.

4. Étape 2 — SQL BigQuery (source de vérité)
4.1 Calcul des KPI en SQL

Chaque KPI est recalculé en SQL en respectant strictement le sous-périmètre.

Ventes : lignes au statut Complete

Retours : lignes au statut Returned

Granularité : annuelle et mensuelle

Les résultats SQL sont comparés aux résultats Python et les écarts résiduels sont expliqués.

4.2 Reconstruction du fichier CSV (Étape 2.2)

Une requête SQL dédiée permet de reconstruire le CSV utilisé en Python et Power BI.

Principes :

Colonnes minimales nécessaires à l’analyse.

Filtres explicites du périmètre métier.

Tri pour assurer la stabilité de l’extraction :
ORDER BY created_at, order_id, order_item_id.

Traçabilité : le CSV est reproductible à l’identique depuis BigQuery à partir de la requête documentée.

5. Étape 3 — Dashboard Power BI

Le dashboard est construit à partir du CSV reconstruit.

Principes de design

Lecture claire et synthétique.

Séparation entre :

Page 1 — Vision macro (KPI, tendances, contributions).

Page 2 — Leviers et risques (géographie, retours vs marge, panier moyen).

Interactions utiles (slicers).

Pas de surcharge textuelle dans les visuels.

6. Installation et exécution
Prérequis

Python ≥ 3.10

Accès à BigQuery (GCP)

Power BI Desktop

Installation des dépendances Python
pip install -r requirements.txt


Dépendances principales :

pandas, numpy

matplotlib, seaborn

jupyter, ipykernel

7. Cheminement pour reproduire les résultats

BigQuery

Exécuter la requête de reconstruction du CSV (Étape 2.2).

Exporter le résultat en CSV.

Python

Ouvrir le notebook d’EDA.

Exécuter les cellules dans l’ordre : qualité → explorations → KPI.

SQL

Exécuter les requêtes KPI (Étape 2.1).

Comparer SQL vs Python.

Power BI

Importer le CSV.

Créer les mesures DAX.

Construire les deux pages du dashboard.

8. Principaux enseignements

La croissance 2024 est réelle mais hétérogène selon les mois.

Le chiffre d’affaires est fortement concentré sur un nombre limité de marques et de catégories.

Certaines catégories structurent la marge, mais présentent un taux de retour élevé.

Le panier moyen est davantage tiré par le prix/mix produit que par le volume.

9. Limites et perspectives
Limites

Données uniquement transactionnelles.

Absence des motifs de retour.

Pas de coûts marketing ou logistiques.

Perspectives

Analyses par cohorte client.

Étude fine des retours par produit/marque.

Enrichissement avec données marketing et logistiques.