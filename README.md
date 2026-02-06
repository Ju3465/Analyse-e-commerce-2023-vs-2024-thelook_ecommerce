# Projet de fin de formation — DATAGONG  
## Analyse e-commerce 2023 vs 2024 — thelook_ecommerce  
**Périmètre : France × Women**

---

## 1. Contexte du projet

Ce projet s’inscrit dans le cadre du **projet de fin de formation Data Analyst – DATAGONG**.  
Il vise à analyser la performance e-commerce de **TheLook Europe** et à comparer les résultats des années **2023** et **2024** sur un périmètre métier défini.

Le projet couvre l’ensemble de la chaîne analytique :
- exploration et contrôle des données,
- formalisation d’indicateurs métier,
- validation des résultats via SQL (BigQuery),
- restitution des enseignements à l’aide d’un dashboard Power BI.

---

## 2. Objectifs

Les objectifs principaux sont les suivants :
- Comprendre les dynamiques de performance e-commerce entre **2023 et 2024**
- Analyser le **chiffre d’affaires**, la **marge**, les **retours** et le **comportement client**
- Construire des **KPI robustes et traçables**
- Alimenter un **tableau de bord Power BI** destiné à une direction e-commerce

---

## 3. Périmètre d’étude

- **Pays** : France  
- **Département produit** : Women  
- **Période** : du **01/01/2023** au **31/12/2024**

### Sources de données
- **CSV pédagogique** fourni par l’équipe DATAGONG  
  → utilisé exclusivement pour l’**analyse exploratoire (EDA)**
- **Export reconstruit depuis BigQuery**  
  (*bigquery-public-data.thelook_ecommerce*)  
  → considéré comme la **source de vérité** pour les KPI et le reporting

---

## 4. Données & grain d’analyse

### Grain du dataset
Le dataset est au **grain ligne de commande (article)**.  
Chaque ligne correspond à un article acheté, associé à :
- une commande (`order_id`),
- un client (`user_id`),
- un produit (`product_id`).

Ce grain est conservé tout au long du projet (EDA, KPI, SQL, Power BI).

### Dates de référence
Deux dates coexistent :
- `order_created_at` : date de création de la commande,
- `item_created_at` : date de création de la ligne (article).

👉 Afin d’appliquer rigoureusement le périmètre temporel **au grain article**,  
**toutes les analyses temporelles et les filtres 2023–2024 sont basés sur `item_created_at`.**

---

## 5. Contrôles de qualité des données

Avant toute analyse, des contrôles systématiques ont été réalisés :

### Doublons
- Aucun doublon intégral détecté
- `order_item_id` est unique  
→ fiabilité des agrégations au grain ligne

### Valeurs manquantes
- `shipped_at`, `delivered_at` : valeurs manquantes attendues (cycle logistique incomplet)  
  → conservées en `NaT`
- `brand` : 2 valeurs manquantes (≈ 0,12 %)  
  → imputées avec la modalité `"missing"`

### Cohérence temporelle
- `order_created_at ≤ shipped_at`
- `shipped_at ≤ delivered_at`  
→ aucune incohérence détectée

### Contrôles métier sur les prix
- `sale_price > 0`
- `cost ≥ 0`
- `sale_price ≥ cost`  
→ aucune anomalie détectée

**Conclusion** : les données sont jugées exploitables pour l’analyse exploratoire et le calcul des indicateurs.

---

## 6. Conventions métier

### Chiffre d’affaires réalisé
Conformément aux consignes du projet :

> **Le chiffre d’affaires réalisé correspond à la somme des `sale_price` des lignes au statut `Complete`.**

Les statuts `Processing`, `Shipped` et `Cancelled` correspondent à des ventes non finalisées ou annulées et sont exclus des calculs de performance.

Cette convention est appliquée de manière homogène :
- dans l’EDA Python,
- dans les KPI Python,
- dans les requêtes SQL BigQuery,
- dans le dashboard Power BI.

---

## 7. Analyse exploratoire (EDA Python)

L’EDA vise à comprendre les grandes structures et dynamiques des données avant toute formalisation de KPI.

Elle inclut notamment :
- Analyse des **distributions** (prix de vente, coûts, marges unitaires)
- Analyse des **statuts de lignes** (`item_status`)
- Analyse des **contributions au chiffre d’affaires réalisé** :
  - par marque (portefeuille fragmenté, longue traîne),
  - par catégorie (hiérarchisation claire des familles produit),
  - par ville (forte dispersion géographique)
- Analyse de la **saisonnalité mensuelle**
- Analyse de la **marge** :
  - marges unitaires,
  - contribution à la marge par catégorie,
  - taux de marge par catégorie
- Comparaison temporelle **2023 vs 2024** :
  - évolution mensuelle du chiffre d’affaires,
  - évolution conjointe du CA et du nombre de commandes finalisées

L’EDA se limite volontairement à des **constats descriptifs** ;  
les mécanismes explicatifs sont approfondis dans la phase KPI.

---

## 8. KPI calculés en Python

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
- **Taux de ré-achat intra-annuel** :
  - part des clients ayant ≥ 2 commandes génératrices de revenu sur une même année

---

## 9. Source de vérité & validation BigQuery

Des écarts ont été observés entre :
- les KPI calculés à partir du **CSV pédagogique**,
- et ceux recalculés à partir d’un **export reconstruit depuis BigQuery**.

Ces écarts s’expliquent par :
- des différences de périmètre effectif,
- la logique de jointures,
- les filtres temporels appliqués au grain ligne.

👉 Les KPI **recalculés depuis BigQuery** sont retenus comme **référence finale** :
- alignement avec les requêtes SQL,
- cohérence avec le dashboard Power BI,
- meilleure robustesse méthodologique.

---

## 10. Conclusion

L’analyse met en évidence une **croissance marquée entre 2023 et 2024** sur le périmètre étudié, accompagnée d’une évolution des volumes de commandes finalisées.  
Elle souligne également l’importance du **mix produit**, des **retours** et de la **marge** dans le pilotage de la performance e-commerce.

Les règles métier et les indicateurs ont été sécurisés par une validation croisée **Python / SQL BigQuery**, et les KPI issus de BigQuery constituent la base du reporting Power BI.
