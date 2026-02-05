# Projet de fin de formation — DATAGONG  
## Analyse e-commerce 2023 vs 2024 — thelook_ecommerce  
**Périmètre : France × Women**

---

## 1. Contexte & objectifs

Ce projet s’inscrit dans le cadre du projet de fin de formation **Data Analyst – DATAGONG**.  
Il consiste à analyser la performance e-commerce de **TheLook Europe** et à comparer les résultats des années **2023** et **2024** sur un périmètre métier précis.

### Objectifs principaux
- Analyser la performance commerciale (chiffre d’affaires, marge, retours, comportement client)
- Comparer les dynamiques **2023 vs 2024**
- Formaliser des **KPI métier robustes**
- Alimenter un **dashboard Power BI** destiné à une direction e-commerce

---

## 2. Périmètre d’étude

- **Pays** : France  
- **Département produit** : Women  
- **Période** : du **01/01/2023** au **31/12/2024**  
- **Source de données** :  
  - CSV pédagogique (EDA exploratoire)
  - Export reconstruit depuis **BigQuery** (*bigquery-public-data.thelook_ecommerce*) — **source de vérité**

---

## 3. Données & grain d’analyse

### Grain
Le dataset est au **grain ligne de commande (article)**.  
Chaque ligne correspond à un article acheté, associé à :
- une commande (`order_id`)
- un client (`user_id`)
- un produit (`product_id`)

Ce grain est conservé tout au long de l’EDA et des calculs de KPI.

### Dates de référence
Deux dates coexistent dans les données :
- `order_created_at` : date de création de la commande
- `item_created_at` : date de création de la ligne (article)

👉 Afin de respecter le périmètre temporel **au grain article**, **toutes les analyses temporelles et le filtrage 2023–2024 sont basés sur `item_created_at`**.

---

## 4. Contrôles de qualité des données

Les contrôles suivants ont été réalisés avant toute analyse :

### Doublons
- Aucun doublon intégral détecté
- `order_item_id` est unique → fiabilité des agrégations

### Valeurs manquantes
- `shipped_at`, `delivered_at` : valeurs manquantes attendues (cycle logistique incomplet) → conservées en `NaT`
- `brand` : 2 valeurs manquantes (0,12 %) imputées avec la modalité `"missing"`

### Cohérence temporelle
- `order_created_at ≤ shipped_at`
- `shipped_at ≤ delivered_at`
→ aucune incohérence détectée

### Contrôles métier sur les prix
- `sale_price > 0`
- `cost ≥ 0`
- `sale_price ≥ cost`
→ aucune anomalie détectée

**Conclusion** : les données sont jugées exploitables pour l’EDA et le calcul des KPI.

---

## 5. Conventions métier retenues

### Chiffre d’affaires réalisé
Conformément aux consignes du projet :

> **Le chiffre d’affaires réalisé correspond à la somme des `sale_price` des lignes au statut `Complete`.**

Les statuts `Processing`, `Shipped` et `Cancelled` correspondent à des ventes non finalisées ou annulées et sont exclus des calculs de performance.

Cette convention est appliquée de manière homogène sur l’ensemble du projet (EDA, KPI Python, SQL BigQuery, Power BI).

---

## 6. Analyse exploratoire (EDA Python)

Les analyses exploratoires portent exclusivement sur le périmètre défini et incluent notamment :

- **Analyse des distributions** :
  - prix de vente et coûts (asymétrie à droite, longue traîne, produits premium)
- **Analyse des statuts de lignes** (`item_status`)
- **Contributions au chiffre d’affaires réalisé** :
  - par marque (forte fragmentation du portefeuille)
  - par catégorie (hiérarchisation claire des familles de produits)
  - par ville (longue traîne géographique)
- **Analyse de la saisonnalité mensuelle**
- **Analyse de la marge** :
  - marges unitaires
  - contribution à la marge par catégorie
  - taux de marge par catégorie
- **Comparaison temporelle 2023 vs 2024** :
  - évolution mensuelle du CA
  - mise en évidence d’une croissance principalement portée par le volume

L’EDA permet d’identifier les grands mécanismes de performance avant formalisation des KPI.

---

## 7. KPI calculés en Python

Les KPI sont calculés sur les **ventes réalisées** (`item_status = Complete`) :

- **Chiffre d’affaires réalisé**
- **Marge brute** : Σ(`sale_price` − `cost`)
- **Taux de marge brute** : Marge brute / CA réalisé
- **Panier moyen** :
  - CA réalisé / nombre de commandes distinctes génératrices de revenu
  - une commande est comptabilisée dès lors qu’elle contient ≥ 1 ligne `Complete`
- **Taux de retour** :
  - proportion de lignes `Returned` parmi (`Returned` + `Complete`)
  - calcul au grain ligne de commande
- **Taux de ré-achat** :
  - part des clients ayant ≥ 2 commandes génératrices de revenu sur une même année

---

## 8. Source de vérité & recalcul BigQuery

Des écarts ont été observés entre :
- les KPI calculés à partir du **CSV pédagogique**
- et ceux recalculés à partir d’un **export reconstruit depuis BigQuery**

Ces écarts s’expliquent par des différences de périmètre effectif (jointures, filtres temporels, stabilité de l’extraction).

👉 Les KPI **recalculés depuis BigQuery** sont retenus comme **référence finale** :
- alignement avec les requêtes SQL
- cohérence avec le dashboard Power BI
- robustesse méthodologique

---

## 10. Conclusion

L’analyse met en évidence une **croissance marquée entre 2023 et 2024**, principalement portée par une augmentation du **volume de commandes finalisées**, tandis que le panier moyen évolue faiblement.  
Elle souligne également l’importance du **mix produit**, des **retours** et de la **marge** dans le pilotage de la performance e-commerce.

Les règles métier ont été sécurisées via une vérification croisée Python / SQL BigQuery, et les KPI issus de BigQuery constituent la base du reporting Power BI.