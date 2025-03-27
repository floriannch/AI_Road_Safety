# README

### Projet réalisé par Evan Da Costa Pina, Léna Fournier, Florian Nelcha et Khévin Vongkorad

## Description des fichiers

Ce projet contient deux fichiers principaux :

- **Donnée.m** : Un script MATLAB qui génère un ensemble de données basé sur des paramètres de pistes, de pneus, de vitesses et d'autres caractéristiques. Il effectue également une régression linéaire pour estimer le coefficient de frottement (µ) et génère un fichier CSV contenant les essais sélectionnés.
- **train_rnn.py** : Un script Python qui entraîne un réseau de neurones récurrent (LSTM) sur les données générées par MATLAB pour prédire le coefficient de frottement.

---

## Détail des fichiers

### 1. `Donnée.m`

#### Fonctionnalités principales :
Ce script MATLAB permet de générer un jeu de données de test en simulant diverses conditions de conduite et en calculant le coefficient de frottement µ en fonction de plusieurs paramètres. 

1. **Définition des paramètres de test** :
   - Différents types de pneus (`T1` à `T6`).
   - Différents types de pistes (`A'`, `A`, `E2`, `C`, `E1`).
   - Trois vitesses (`60`, `90`, `120` km/h).
   - Deux niveaux d'épaisseur d'eau (`WT1`, `WT2`).
   - Valeurs de rigidité spécifiques pour chaque type de pneu.
   - Coefficients de gomme correspondant à chaque pneu.
   - Force verticale `Fz_dim` appliquée aux pneus.

2. **Définition des valeurs de surface** :
   - Le script utilise des `containers.Map` pour associer chaque type de piste à des valeurs de `DFT` (profondeur de texture) et `MPD` (profondeur moyenne de profil).

3. **Création d'un jeu de données** :
   - Un tableau de données est créé avec les paramètres : `DFT`, `MPD`, `Épaisseur d'eau`, `Vitesse`, `Rigidité`, `Gomme` et le coefficient de frottement `µ`.
   - Ajout d'un terme constant dans la matrice X pour la régression linéaire.
   - Estimation des coefficients de la régression par la méthode des moindres carrés.

4. **Génération de combinaisons possibles** :
   - Le script crée toutes les combinaisons possibles des paramètres et calcule `µ` pour chaque configuration.
   - Pour chaque combinaison, la force longitudinale `Fx` est calculée comme :
     ```
     Fx = µ * Fz_dim
     ```

5. **Sélection aléatoire d'essais** :
   - Parmi toutes les combinaisons générées, `100` essais sont sélectionnés de manière aléatoire.
   - Ces essais sont enregistrés sous forme de table MATLAB et affichés dans la console.
   - Les essais sélectionnés sont exportés dans un fichier `selected_essais.csv`.

#### Exécution :
Pour exécuter le script MATLAB :
```matlab
run('Donnée.m');
```
Le fichier `selected_essais.csv` sera généré dans le répertoire courant et contiendra les données à utiliser pour l'entraînement du modèle en Python.

---

### 2. `train_rnn.py`

#### Fonctionnalités principales :
- Charge les données générées (`selected_essais.csv`).
- Sépare les données en variables d'entrée (X) et variable cible (y).
- Effectue une normalisation des données avec `StandardScaler`.
- Reshape les données pour une utilisation avec des couches LSTM.
- Construit un modèle de réseau de neurones récurrent LSTM comprenant :
  - Trois couches LSTM avec `100` unités chacune.
  - Des couches de dropout pour éviter l'overfitting.
  - Une couche de sortie dense avec activation linéaire.
- Compilation et entraînement du modèle avec l'optimiseur `adam` et la fonction de perte `mean_squared_error`.
- Prédiction des valeurs de coefficient de frottement (µ) sur l'ensemble de test.
- Évaluation de la performance du modèle en affichant l'erreur quadratique moyenne (`MSE`).
- Sauvegarde du modèle (`rnn_model.h5`) et du scaler (`scaler.pkl`).

#### Exécution :
Assurez-vous d'avoir les bibliothèques nécessaires installées :
```bash
pip install pandas numpy scikit-learn tensorflow joblib
```
Puis exécutez le script :
```bash
python train_rnn.py
```
Cela entraînera le modèle et affichera l'évaluation des performances.

---

## Résumé du pipeline de données

1. **Exécution de `Donnée.m`** :
   - Génération des combinaisons possibles et calcul du coefficient de frottement `µ`.
   - Exportation du jeu de données dans `selected_essais.csv`.
2. **Exécution de `train_rnn.py`** :
   - Chargement des données et entraînement d'un réseau LSTM pour la prédiction de `µ`.
   - Sauvegarde du modèle et du scaler.
3. **Utilisation du modèle entraîné** :
   - Charger `rnn_model.h5` pour des prédictions futures.

---

## Auteur
Projet développé pour l'analyse et la prédiction du coefficient de frottement en fonction des conditions de test.
