# Projet de fin de formation — DATAGONG  
## Analyse e-commerce 2023 vs 2024 — thelook_ecommerce (France × Women)

### 1) Contexte & périmètre
Ce projet analyse la performance e-commerce **TheLook Europe** sur le périmètre suivant :

- **Pays** : France  
- **Département** : Women  
- **Période** : du **01/01/2023** au **31/12/2024**  
- **Objectif** : comparer **2023 vs 2024** via une **EDA** (analyse exploratoire) et le calcul de **KPI métier**.

L’analyse est réalisée principalement en **Python** (EDA + KPI) et est destinée à alimenter un **dashboard Power BI**.

---

### 2) Objectifs de l’EDA
L’analyse exploratoire vise à :

- comprendre la structure des ventes et des retours sur 2023–2024,
- identifier les dynamiques temporelles, produits et géographiques,
- repérer d’éventuelles ruptures/anomalies avant formalisation définitive des KPI.

---

### 3) Données & grain d’analyse
#### Grain
Le dataset est au **grain ligne de commande (article)** :  
chaque ligne correspond à un article acheté associé à :
- une commande (`order_id`)
- un client (`user_id`)
- un produit (`product_id`)

#### Dates de référence
Deux dates coexistent :
- `order_created_at` : création de la commande
- `item_created_at` : création de la ligne (article)

✅ Pour respecter le périmètre temporel **au grain article**, toutes les analyses temporelles et le filtrage 2023–2024 sont basés sur **`item_created_at`**.

---

### 4) Contrôles qualité effectués
Les contrôles suivants ont été réalisés :

- **Doublons** : aucun doublon intégral ; `order_item_id` est unique.
- **Valeurs manquantes** :
  - `shipped_at` et `delivered_at` : valeurs manquantes attendues (commandes non expédiées/livrées) → conservées en `NaT`
  - `brand` : 2 valeurs manquantes imputées avec la modalité `"missing"` (0,12% du dataset)
- **Cohérence temporelle** :
  - `order_created_at <= shipped_at`
  - `shipped_at <= delivered_at`
  → aucune incohérence détectée
- **Contrôles métier sur les prix** :
  - `sale_price > 0`
  - `cost >= 0`
  - `sale_price >= cost`
  → aucune anomalie détectée

✅ Les données sont jugées exploitables pour l’EDA et le calcul des KPI.

---

### 5) Convention de calcul “CA réalisé”
Dans ce projet, le **chiffre d’affaires réalisé** est défini comme :

> **Somme des `sale_price` des lignes au statut `Complete`**

Les statuts `Processing`, `Shipped`, `Cancelled` correspondent à des étapes intermédiaires / annulées et sont exclus des calculs de performance.

---

### 6) Analyses réalisées (EDA)
Les explorations incluent notamment :

- distributions des prix de vente et des coûts (asymétrie à droite, présence de “premium”)
- répartition des statuts de lignes (`item_status`)
- contribution au CA réalisé :
  - **Top marques** (forte fragmentation du portefeuille)
  - **Top catégories** (Outerwear & Coats, Intimates, Jeans…)
  - **Top villes** (forte longue traîne géographique)
  - **saisonnalité mensuelle** (pics sur plusieurs mois + fin d’année)
- comparaison mensuelle du CA réalisé **2023 vs 2024** (hausse marquée en 2024)

---

### 7) KPI calculés (Python)
Les KPI sont calculés **sur les ventes réalisées** (`Complete`) :

- **Chiffre d’affaires réalisé**
- **Marge brute** : Σ(`sale_price` − `cost`)
- **Taux de marge brute** : Marge brute / CA réalisé
- **Panier moyen** : CA réalisé / nombre de commandes distinctes génératrices de revenu  
  (une commande est comptée si elle contient ≥ 1 ligne `Complete`)
- **Taux de retour** : proportion de lignes `Returned` parmi (`Returned` + `Complete`)
- **Taux de ré-achat** : part des clients ayant ≥ 2 commandes génératrices de revenu sur l’année

---

### 8) Particularité : KPI recalculés depuis BigQuery (source de vérité)
Des écarts ont été observés entre :
- les KPI calculés sur le **CSV fourni par l’équipe pédagogique**
- et les KPI recalculés depuis un **export reconstruit depuis BigQuery**

Ces différences s’expliquent par de légères variations de périmètre effectif (logique de jointures, filtres, stabilité de l’extraction, etc.).

✅ Les KPI calculés à partir de l’export BigQuery sont retenus comme **référence** pour la suite du projet et l’alimentation du dashboard Power BI.

---