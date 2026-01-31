# Analyse de la performance e-commerce — TheLook Europe

France | Women | 2023–2024

---

## 1. Contexte et objectifs du projet

Vous endossez le rôle de Data Analyst au sein de TheLook Europe. La direction e-commerce demande d’analyser la performance de l’activité sur un périmètre précis et de comparer l’année 2023 à 2024.

Les objectifs du projet sont :

- Contrôler la qualité des données (types, valeurs manquantes, doublons, cohérence temporelle).
- Réaliser une analyse exploratoire (EDA) en Python afin de comprendre les mécanismes de performance.
- Calculer les KPI en Python (chiffre d’affaires, marge, panier moyen, taux de retour, taux de ré-achat).
- Valider les KPI en SQL sur BigQuery (source de vérité).
- Construire un dashboard Power BI clair et décisionnel racontant l’évolution 2023 vs 2024.

---

## 2. Description du sous-périmètre

### Périmètre métier

- Pays : France  
- Département produit : Women  
- Période : du 01/01/2023 au 31/12/2024  

### Source de vérité

- Dataset BigQuery : bigquery-public-data.thelook_ecommerce

### Tables mobilisées

- users : profil client et géographie  
- orders : commandes  
- order_items : lignes de commande  
- products : référentiel produit (coût, marque, catégorie, département)

### Clés de jointure

- users.id = orders.user_id  
- orders.order_id = order_items.order_id  
- products.id = order_items.product_id  

---

## 3. Étape 1 — Analyse exploratoire en Python (EDA)

Cette étape est réalisée exclusivement en Python à partir du fichier CSV reconstruit.

Les travaux réalisés sont :

- Création d’un dictionnaire de données (définition, type, exemple).
- Vérification de la qualité des données :
  - doublons complets et doublons logiques,
  - valeurs manquantes,
  - cohérence des identifiants,
  - cohérence des bornes temporelles.
- Explorations descriptives :
  - distributions des prix de vente et des coûts,
  - contribution au chiffre d’affaires par marque, catégorie et ville,
  - analyse de la saisonnalité mensuelle (comparaison 2023 vs 2024).
- Calcul des KPI en Python selon les règles métier définies.

---

## 4. Étape 2 — SQL BigQuery (source de vérité)

### 4.1 Calcul des KPI en SQL

Chaque KPI est recalculé en SQL en respectant strictement le sous-périmètre métier :

- Les ventes correspondent aux lignes au statut Complete.
- Les retours correspondent aux lignes au statut Returned.
- Les agrégations sont réalisées à une granularité annuelle et mensuelle.

Les résultats obtenus en SQL sont comparés à ceux calculés en Python.  
Les écarts résiduels sont expliqués par des différences de jointures, de filtres temporels ou de stabilité d’extraction.

### 4.2 Reconstruction du fichier CSV (Étape 2.2)

Une requête SQL dédiée permet de reconstruire le fichier CSV utilisé en Python et Power BI.

Les choix effectués sont les suivants :

- Sélection des colonnes strictement nécessaires à l’analyse.
- Application explicite des filtres du sous-périmètre.
- Ordonnancement des données pour garantir la stabilité de l’extraction :

ORDER BY created_at, order_id, order_item_id

Le fichier CSV est ainsi entièrement traçable et reproductible à partir de la requête SQL.

---

## 5. Étape 3 — Dashboard Power BI

Le dashboard est construit à partir du CSV reconstruit.

Les principes retenus sont :

- Une lecture claire et synthétique.
- Une séparation des usages :
  - Page 1 : vision macro (KPI, tendances, contributions).
  - Page 2 : leviers de performance et zones de vigilance.
- Des interactions via des slicers (année).
- L’absence de texte long dans le dashboard, le storytelling étant porté par la soutenance orale.

---

## 6. Instructions d’installation et d’exécution

### Prérequis

- Python ≥ 3.10  
- Accès à Google BigQuery (GCP)  
- Power BI Desktop  

### Installation des dépendances Python

Les dépendances Python sont listées dans le fichier requirements.txt et doivent être installées avant l’exécution des notebooks.

---

## 7. Cheminement pour reproduire les résultats

1. Exécuter la requête SQL de reconstruction du fichier CSV sur BigQuery.  
2. Exporter le résultat au format CSV.  
3. Lancer le notebook Python d’EDA et exécuter les cellules dans l’ordre.  
4. Exécuter les requêtes SQL de calcul des KPI.  
5. Importer le CSV dans Power BI et construire le dashboard.

---

## 8. Principaux enseignements

- La croissance observée en 2024 est réelle mais hétérogène selon les mois.  
- Le chiffre d’affaires est fortement concentré sur un nombre limité de marques.  
- Certaines catégories génèrent une marge élevée mais présentent un taux de retour important.  
- Le panier moyen est davantage tiré par le mix produit et le niveau de prix que par le volume.

---

## 9. Limites et perspectives

### Limites

- Données exclusivement transactionnelles.  
- Absence d’informations sur les motifs de retour.  
- Absence de coûts marketing et logistiques.

### Perspectives

- Analyses par cohorte de clients.  
- Étude approfondie des retours par produit ou par marque.  
- Enrichissement avec des données marketing et opérationnelles.
