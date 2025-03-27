% Paramètres possibles
type_pneu = {'T1', 'T2', 'T3', 'T4', 'T5', 'T6'};
pistes = {'A''', 'A', 'E2', 'C', 'E1'};
vitesses = [60, 90, 120];
epais_eau = {'WT1', 'WT2'}; % Options pour épaisseur d'eau

rigidite = [41897000, 37188000, 39415000, 42865000, 43530000, 43205000];

gum = {'129.56', '110.4', '119.98', '67.04', '113.18', '90.11'};
fz_dim = [2500, 4000, 4500, 2500, 4000, 4500];

% Valeurs de DFT et MPD pour les surfaces
DFT_values = containers.Map({'A''', 'A', 'E2', 'C', 'E1'}, [0.655, 0.642, 0.557, 0.779, 0.639]);
MPD_values = containers.Map({'A''', 'A', 'E2', 'C', 'E1'}, [3.4575, 1.146, 1.001, 0.632, 0.744]);

% Échantillon de données pour régression (à remplir avec des données réelles)
data = [
    % DFT, MPD, Épaisseur d'eau, Vitesse, Rigidité, Gomme, µ
    0.655, 3.4575, 2, 60, 41897000, 129.56, 0.8;
    0.642, 1.146, 3, 90, 37188000, 110.4, 0.75;
    0.557, 1.001, 1, 120, 39415000, 119.98, 0.78;
    0.779, 0.632, 4, 60, 42865000, 67.04, 0.85;
    0.639, 0.744, 5, 90, 43530000, 113.18, 0.82;
    0.655, 3.4575, 6, 120, 43205000, 90.11, 0.7;
    % Ajoutez plus de lignes de données ici
];

% Séparer les variables indépendantes et la variable dépendante
X = data(:, 1:6); % Variables indépendantes
y = data(:, 7);   % Variable dépendante (µ)

% Ajouter une colonne de 1 pour le terme constant (intercept)
X = [ones(size(X, 1), 1) X];

% Calculer les coefficients de régression linéaire
coefficients = (X' * X) \ (X' * y);

% Extraire les coefficients
g = coefficients(1);
a = coefficients(2);
b = coefficients(3);
c = coefficients(4);
d = coefficients(5);
e = coefficients(6);
f = coefficients(7);

% Calculer le coefficient de frottement µ pour les combinaisons possibles
total_possibilities = length(type_pneu) * length(pistes) * length(vitesses) * length(epais_eau);
combinations = cell(total_possibilities, 13);

% Valeurs associées aux combinaisons de piste et vitesse (distance d'arrêt)
distances_arret = {
    % Valeurs T1
    'T1', 'A''', 60, 50;
    'T1', 'A''', 90, 65;
    'T1', 'A''', 120, 87;
    'T1', 'E2', 60, 20;
    'T1', 'E2', 90, 45;
    'T1', 'E2', 120, 60;
    'T1', 'A', 60, 50;
    'T1', 'A', 90, 30;
    'T1', 'A', 120, 38;
    'T1', 'E1', 60, 20;
    'T1', 'E1', 90, 30;
    'T1', 'E1', 120, 50;
    'T1', 'C', 60, 17;
    'T1', 'C', 90, 20;
    'T1', 'C', 120, 38;

    % Valeurs T2
    'T2', 'A''', 60, 30;
    'T2', 'A''', 90, 30;
    'T2', 'A''', 120, 40;
    'T2', 'E2', 60, 20;
    'T2', 'E2', 90, 65;
    'T2', 'E2', 120, 87;
    'T2', 'A', 60, 18;
    'T2', 'A', 90, 27;
    'T2', 'A', 120, 38;
    'T2', 'E1', 60, 42;
    'T2', 'E1', 90, 39;
    'T2', 'E1', 120, 57;
    'T2', 'C', 60, 17;
    'T2', 'C', 90, 30;
    'T2', 'C', 120, 38;

    % Valeurs T3
    'T3', 'A''', 60, 15;
    'T3', 'A''', 90, 55;
    'T3', 'A''', 120, 73;
    'T3', 'E2', 60, 20;
    'T3', 'E2', 90, 45;
    'T3', 'E2', 120, 60;
    'T3', 'A', 60, 20;
    'T3', 'A', 90, 27;
    'T3', 'A', 120, 38;
    'T3', 'E1', 60, 20;
    'T3', 'E1', 90, 30;
    'T3', 'E1', 120, 50;
    'T3', 'C', 60, 20;
    'T3', 'C', 90, 35;
    'T3', 'C', 120, 43;

    % Valeurs T4
    'T4', 'A''', 60, 15;
    'T4', 'A''', 90, 35;
    'T4', 'A''', 120, 46;
    'T4', 'E2', 60, 45;
    'T4', 'E2', 90, 45;
    'T4', 'E2', 120, 60;
    'T4', 'A', 60, 18;
    'T4', 'A', 90, 27;
    'T4', 'A', 120, 40;
    'T4', 'E1', 60, 19;
    'T4', 'E1', 90, 38;
    'T4', 'E1', 120, 50;
    'T4', 'C', 60, 20;
    'T4', 'C', 90, 39;
    'T4', 'C', 120, 53;

    % Valeurs T5
    'T5', 'A''', 60, 18;
    'T5', 'A''', 90, 32;
    'T5', 'A''', 120, 42;
    'T5', 'E2', 60, 20;
    'T5', 'E2', 90, 46;
    'T5', 'E2', 120, 64;
    'T5', 'A', 60, 17;
    'T5', 'A', 90, 22;
    'T5', 'A', 120, 38;
    'T5', 'E1', 60, 20;
    'T5', 'E1', 90, 38;
    'T5', 'E1', 120, 56;
    'T5', 'C', 60, 17;
    'T5', 'C', 90, 35;
    'T5', 'C', 120, 50;

    % Valeurs T6
    'T6', 'A''', 60, 25;
    'T6', 'A''', 90, 63;
    'T6', 'A''', 120, 84;
    'T6', 'E2', 60, 21;
    'T6', 'E2', 90, 40;
    'T6', 'E2', 120, 53;
    'T6', 'A', 60, 18;
    'T6', 'A', 90, 30;
    'T6', 'A', 120, 55;
    'T6', 'E1', 60, 20;
    'T6', 'E1', 90, 39;
    'T6', 'E1', 120, 58;
    'T6', 'C', 60, 19;
    'T6', 'C', 90, 30;
    'T6', 'C', 120, 38;
};

% Générer les combinaisons possibles
idx = 1;
for pneu = 1:length(type_pneu)
    for piste = 1:length(pistes)
        for vitesse = 1:length(vitesses)
            for epaisseur = 1:length(epais_eau)
                combinations{idx, 1} = epais_eau{epaisseur};
                combinations{idx, 2} = type_pneu{pneu};
                combinations{idx, 3} = pistes{piste};
                combinations{idx, 4} = vitesses(vitesse);
                combinations{idx, 5} = rigidite(pneu);
                combinations{idx, 6} = DFT_values(pistes{piste});
                combinations{idx, 7} = MPD_values(pistes{piste});
                combinations{idx, 8} = gum{pneu};
                
                % Initialiser l'épaisseur d'eau (mm)
                if strcmp(epais_eau{epaisseur}, 'WT1')
                    epaisseur_eau_mm = rand() * 2;  % WT1 entre 0 et 2
                else
                    epaisseur_eau_mm = 2 + rand() * 8;  % WT2 entre 2 et 10
                end
                combinations{idx, 9} = epaisseur_eau_mm;
                
                % Trouver la distance d'arrêt correspondante
                distance_arret = NaN;
                for l = 1:size(distances_arret, 1)
                    if strcmp(distances_arret{l, 1}, type_pneu{pneu}) && ...
                       strcmp(distances_arret{l, 2}, pistes{piste}) && ...
                       distances_arret{l, 3} == vitesses(vitesse)
                        distance_arret = distances_arret{l, 4};
                        break;
                    end
                end
                combinations{idx, 10} = fz_dim(pneu);
                combinations{idx, 11} = distance_arret;
                
                % Calculer le coefficient de frottement μ
                rigidity = rigidite(pneu);
                gum_value = str2double(gum{pneu});
                DFT = DFT_values(pistes{piste});
                MPD = MPD_values(pistes{piste});
                mu = a * DFT + b * MPD + c * epaisseur_eau_mm + d * vitesses(vitesse) + e * rigidity + f * gum_value + g;
                combinations{idx, 12} = mu;
                
                % Calculer la force longitudinale Fx
                fx = mu * fz_dim(pneu);
                combinations{idx, 13} = fx;
                
                idx = idx + 1;
            end
        end
    end
end

% Sélectionner aléatoirement 100 essais parmi les combinaisons possibles
num_essais = 100;
selected_essais = cell(num_essais, 13);

for i = 1:num_essais
    % Sélectionner un essai aléatoire parmi les combinaisons possibles
    random_idx = randi(total_possibilities);
    selected_essai = combinations(random_idx, :);
    
    % Enregistrer l'essai modifié
    selected_essais(i, :) = selected_essai;
end

% Convertir le tableau en table MATLAB
essais_table = cell2table(selected_essais, 'VariableNames', {'Epaisseur_eau', 'Pneu', 'Piste', 'Vitesse', ...
                                                            'Rigidite', 'DFT', 'MPD', 'Gum', 'Epaisseur_eau_mm', ...
                                                            'Fz_dim', 'Distance_arret', 'Coeff_de_frottement', 'Fx'});

% Afficher le tableau des essais sélectionnés
disp(essais_table);

% Enregistrer les essais sélectionnés en fichier CSV
writetable(essais_table, 'selected_essais.csv');