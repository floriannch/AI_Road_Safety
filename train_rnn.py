import pandas as pd
import os
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
import tensorflow as tf
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Dense, LSTM, Dropout
from sklearn.metrics import mean_squared_error
import joblib

#Lecture du CSV
data = pd.read_csv(os.path.join(os.path.dirname(__file__),"selected_essais.csv"))

# Afficher les premières lignes du DataFrame pour vérifier les colonnes
print("Aperçu des données chargées :")
print(data.head())

#Caractéristiques (X) et cible (y)
X = data[['DFT','MPD','Epaisseur_eau_mm', 'Vitesse', 'Rigidite', 'Gum']].values
y = data['Coeff_de_frottement'].values

#Division des données en ensembles d'entraînement et de test
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.5, random_state=42)

#Normalisation des données
scaler = StandardScaler()
X_train = scaler.fit_transform(X_train)
X_test = scaler.transform(X_test)

#Reshape les données pour les LSTM
X_train_reshaped = np.reshape(X_train, (X_train.shape[0], 1, X_train.shape[1]))
X_test_reshaped = np.reshape(X_test, (X_test.shape[0], 1, X_test.shape[1]))

#Modèle LSTM
model = Sequential()
model.add(LSTM(units=100, return_sequences=True, input_shape=(1, X_train.shape[1])))
model.add(Dropout(0.3))
model.add(LSTM(units=100, return_sequences=True))
model.add(Dropout(0.3))
model.add(LSTM(units=100))
model.add(Dropout(0.3))
model.add(Dense(1, activation='linear')) 

#On compile le modèle
model.compile(optimizer='adam', loss='mean_squared_error')

#Entraînement du modèle
model.fit(X_train_reshaped, y_train, epochs=(100), batch_size=32)

#Prédiction
y_pred = model.predict(X_test_reshaped)

#Évaluation du modèle et affichage des résulats
mse = mean_squared_error(y_test, y_pred)
print(f"\nMean Squared Error: {mse}\n")

predictions = pd.DataFrame({'Valeurs µ réelles': y_test, 'Valeurs µ prédites': y_pred.flatten()})
print(predictions)

#Sauvegarde
model.save('rnn_model.h5')
joblib.dump(scaler, 'scaler.pkl')
