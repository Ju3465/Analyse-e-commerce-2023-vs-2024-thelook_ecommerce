# Projet de fin de formation — DATAGONG  
## Analyse e-commerce 2023 vs 2024 — TheLook (France × Women)

---

## 1. Contexte du projet

Ce projet s’inscrit dans le cadre de la spécialisation **Data Analyst – DATAGONG**.

La direction e-commerce de **TheLook Europe** souhaite analyser la performance de l’activité sur un périmètre précis et comparer les années **2023** et **2024**.

L’objectif est de :
- comprendre les dynamiques de **chiffre d’affaires**,
- analyser la **marge** et les **retours**,
- étudier le **comportement client**,
- restituer les enseignements via un **dashboard Power BI orienté décision**.

Le projet couvre l’ensemble de la chaîne analytique :
- **Exploration** & contrôle qualité des données (Python)
- **Calcul** formalisé des KPI (Python)
- **Validation SQL** sur BigQuery (source de vérité)
- **Construction** d’un dashboard décisionnel (Power BI)

---

## 2. Objectifs analytiques

Les objectifs sont :

1. **Comparer** la performance **2023 vs 2024**
2. **Identifier** les leviers de croissance
3. **Analyser** l’impact des retours sur la rentabilité
4. **Évaluer** la fidélisation client (ré-achat intra-annuel)
5. Construire des KPI **robustes**, **traçables** et **reproductibles**

---

## 3. Périmètre d’étude

- **Pays** : France  
- **Département produit** : Women  
- **Période** : du **01/01/2023** au **31/12/2024**  
- **Grain temporel appliqué** : `item_created_at`

### Sources de données

Deux jeux de données ont été utilisés :

1. **CSV pédagogique fourni par DATAGONG**  
   → utilisé exclusivement pour l’**analyse exploratoire (EDA)**

2. **Export reconstruit depuis BigQuery**  
   Dataset : `bigquery-public-data.thelook_ecommerce`  
   → considéré comme **source de vérité** pour les **KPI finaux** et le reporting **Power BI**

> Les KPI retenus dans le reporting final proviennent de l’export **BigQuery**.

---

## 4. Modèle de données & grain d’analyse

### Grain

Le dataset est au **grain ligne de commande (article)**.

Chaque ligne correspond à :
- un article acheté,
- associé à une commande (`order_id`),
- associé à un client (`user_id`),
- associé à un produit (`product_id`).

Ce grain est conservé :
- en **EDA**,
- en **SQL**,
- en **Power BI**.

### Dates de référence

Deux dates coexistent :
- `order_created_at` : date de création de la commande,
- `item_created_at` : date de création de la ligne (article).

Afin d’appliquer rigoureusement le périmètre au **grain article**,  
toutes les analyses temporelles 2023–2024 sont basées sur :

> **`item_created_at`**

---

## 5. Contrôles de qualité des données

Les contrôles suivants ont été réalisés :

### Doublons
- Aucun doublon intégral
- `order_item_id` **unique**  
  → fiabilité des agrégations

### Valeurs manquantes
- `shipped_at` et `delivered_at` : manquants **attendus** (cycle logistique incomplet)  
  → conservés en `NaT`
- `brand` : 2 valeurs manquantes imputées en **"missing"**

### Cohérence métier
- `sale_price > 0`
- `cost ≥ 0`
- `sale_price ≥ cost`

### Cohérence temporelle
- `order_created_at ≤ shipped_at`
- `shipped_at ≤ delivered_at`

**Conclusion** : les données sont **exploitables** et **robustes** pour l’analyse.

---

## 6. Conventions métier

### Chiffre d’affaires réalisé (CA)

Conformément aux consignes projet :

> **CA réalisé = somme des `sale_price` des lignes au statut `Complete`.**

Les statuts `Processing`, `Shipped`, `Cancelled` sont exclus des KPI de performance.

### Marge brute

> **Marge brute = somme (`sale_price − cost`) sur les lignes `Complete`.**

### Panier moyen (AOV)

> **Panier moyen = CA réalisé / nombre de commandes génératrices de revenu.**

Une commande est comptabilisée si elle contient **au moins une** ligne `Complete`.

### Taux de retour

> **Taux de retour = Returned / (Returned + Complete)**

Calcul au **grain ligne article**.

### Taux de ré-achat intra-annuel

> Part des clients ayant **≥ 2 commandes génératrices de revenu** sur une même année.

---

## 7. Analyse exploratoire (EDA Python)

L’EDA a permis d’identifier :

### 7.1 Structure des prix
- Distributions **asymétriques** (longue traîne)
- Catalogue majoritairement **milieu de gamme**
- Une part réduite de produits premium avec un impact potentiel disproportionné sur le CA/marge

### 7.2 Structure du portefeuille
- **Longue traîne** marques
- **Longue traîne** géographique
- Hiérarchisation claire des **catégories** contributrices

### 7.3 Saisonniété
- Pics en fin d’année (profil saisonnier structurel)
- Comparaison mois par mois permettant d’observer une hausse en 2024

### 7.4 Croissance 2023 vs 2024
- Hausse marquée du **CA**
- Progression conjointe du **volume de commandes** `Complete`
- **Panier moyen** relativement stable

**Conclusion EDA** : la croissance 2024 est principalement portée par le **volume**, plus que par une hausse structurelle de l’AOV.

---

## 8. KPI finaux (BigQuery — source de vérité)

### KPI 2023
- **CA réalisé** : 7 065 €  
- **Marge brute** : 3 647 €  
- **Panier moyen** : 85,13 €  
- **Taux de retour** : 25,30 %  
- **Taux de ré-achat** : 3,75 %

### KPI 2024
- **CA réalisé** : 14 137 €  
- **Marge brute** : 7 409 €  
- **Panier moyen** : 86,73 €  
- **Taux de retour** : 24,69 %  
- **Taux de ré-achat** : 2,52 %

### Lecture stratégique
- **CA** : +100 %  
- **Marge** : +103 %  
- **Panier moyen** : +1,9 %  
- **Taux de retour** : −0,6 pt  
- **Ré-achat** : −1,23 pt  

> La croissance est donc majoritairement portée par l’augmentation du **volume de commandes finalisées**.

---

## 9. Dashboard Power BI

Fichier : `powerbi/dashboard_thelook.pbix`  
Source : export **BigQuery reconstruit**

### Structure du dashboard

#### Page 1 — Executive Summary
- Cartes KPI (CA, marge, panier, retours, ré-achat)
- **Évolution relative** du CA 2024 vs référence 2023 (index)
- **Top marques** par CA
- **Top catégories** par marge

**Objectif** : vision synthétique pour une direction e-commerce.

#### Page 2 — Leviers de performance & zones de vigilance
- Carte : **CA et marge par ville** (taille = CA)
- Scatter : **compromis marge vs taux de retour** par catégorie
- Tableau de détail (CA, marge, taux de marge, taux de retour)
- Décomposition du panier : **AOV / articles par commande / prix moyen**

**Objectif** : prioriser les actions sur les catégories à fort enjeu économique et à risque retours.

### Décisions de design Power BI
- Sélecteur d’année (**2023 / 2024**) pour comparer instantanément
- Visuels orientés décision : **Top N**, carte, scatter, KPI cards
- Focus sur :
  - **Volume vs valeur** (AOV décomposé)
  - **Rentabilité vs retours** (scatter)
  - **Concentration / longue traîne** (Top marques / catégories)

---

## 10. Principaux enseignements métier

1. **Croissance forte mais “volume-driven”**  
   La hausse 2024 est principalement expliquée par le **volume de commandes finalisées**, l’AOV restant quasi stable.

2. **Retours significatifs (~25 %)**  
   Les retours restent un enjeu majeur de rentabilité ; priorité aux catégories à fort enjeu (CA exposé + marge).

3. **Longue traîne structurelle**  
   Fragmentation forte par marques et villes → nécessité d’optimiser découvrabilité, merchandising et disponibilité catalogue.

4. **Fidélisation limitée**  
   Ré-achat intra-annuel faible et en baisse → croissance davantage basée sur l’acquisition ; leviers : CRM, cross-sell, recommandations.

---

## 11. Reproduire les résultats (ordre d’exécution)

### 11.1 Python (EDA + KPI)
- Exécuter le notebook **EDA** (CSV pédagogique)
- Exécuter le notebook **checks** (comparaisons / recoupes)

### 11.2 SQL BigQuery
- Exécuter les requêtes KPI (validation)
- Exécuter la requête d’extraction du sous-périmètre
- Exporter le résultat en CSV (source reporting)

### 11.3 Power BI
- Ouvrir le fichier Power BI
- Vérifier la source de données (CSV issu de BigQuery)
- Rafraîchir et utiliser les filtres pour comparer 2023 / 2024

---

## 12. Conclusion

Le périmètre **France × Women** montre une **croissance marquée en 2024**.  
L’analyse met en évidence une dynamique principalement portée par le **volume de commandes finalisées**, avec un panier moyen relativement stable.

Les **retours** restent un enjeu important de rentabilité et doivent être pilotés prioritairement sur les catégories à fort enjeu économique.  
La **fidélisation** (ré-achat intra-annuel) demeure faible, suggérant un potentiel d’amélioration via CRM et cross-sell.

Les KPI sont sécurisés par une validation croisée **Python / SQL BigQuery**, et le dashboard **Power BI** restitue ces enseignements de manière exploitable pour une direction e-commerce.
