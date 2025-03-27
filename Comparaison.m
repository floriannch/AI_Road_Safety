% Charger les données des fichiers essai.mat et ESSAI_WT2.mat
load('essai.mat');
load('ESSAI_WT2.mat');

% Extraire les structures ESSAI
data1 = ESSAI;
data2 = ESSAI_WT2;

% Convertir les structures en tables pour une manipulation plus facile
data_table1 = struct2table(data1);
data_table2 = struct2table(data2);

% Combiner les tables
combined_data = [data_table1; data_table2];

% Filtrer les lignes où mu_bloq1 n'est pas vide
filtered_data = combined_data(~cellfun('isempty', combined_data.mu_bloq1), :);

% Supprimer les colonnes spécifiées
columns_to_remove = {'mu_max_exp', 's_opt_exp', 'mu_max_p', 's_opt_p', ...
                     'B', 'C', 'D', 'E', 'mu', 'mu_pacejka', 's', ...
                     'R2', 'R2_old', 'mu_abs', 'freinage_essai', 'num_essai'};
filtered_data(:, columns_to_remove) = [];

% Initialiser de nouvelles colonnes
Epaisseur_eau = cell(height(filtered_data), 1);
Pneu = cell(height(filtered_data), 1);
Piste = cell(height(filtered_data), 1);
Vitesse = zeros(height(filtered_data), 1); % Changer ici pour un tableau de zéros

% Traiter la colonne 'nom' pour extraire les valeurs dans de nouvelles colonnes
for i = 1:height(filtered_data)
    % Extraire la chaîne de caractères et supprimer les accolades
    name_str = filtered_data.nom{i};
    name_str = char(name_str); % Convertir de cell à char si nécessaire
    name_str = name_str(2:end-1); % Supprimer les accolades
    
    % Diviser la chaîne en parties
    parts = split(name_str, '-');
    
    % Assigner les parties aux nouvelles colonnes
    Epaisseur_eau{i} = ['W', parts{1}]; % Ajouter 'W' devant chaque donnée
    Pneu{i} = parts{2};
    Piste{i} = parts{3};
    Vitesse(i) = str2double(parts{4}); % Convertir en format numérique
end

% Remplacer les colonnes originales par les nouvelles
filtered_data.WT = Epaisseur_eau;
filtered_data.pneu = Pneu;
filtered_data.piste = Piste;
filtered_data.vitesse_essai = Vitesse;

% Supprimer la colonne originale 'nom'
filtered_data.nom = [];

% Renommer les colonnes aux nouveaux noms
filtered_data.Properties.VariableNames{'WT'} = 'Epaisseur_eau';
filtered_data.Properties.VariableNames{'pneu'} = 'Pneu';
filtered_data.Properties.VariableNames{'piste'} = 'Piste';
filtered_data.Properties.VariableNames{'vitesse_essai'} = 'Vitesse';

% Charger les coefficients de frottement prédits du fichier untitled8.m
run('Code_compare.m'); % exécuter le fichier pour charger les données

% Initialiser la nouvelle colonne 'mu_predit' et 'Distance_arret'
mu_predit = zeros(height(filtered_data), 1);
Distance_arret = zeros(height(filtered_data), 1);

% Boucle pour calculer mu_predit et Distance_arret pour chaque ligne de filtered_data
for i = 1:height(filtered_data)
    % Extraire les paramètres de filtered_data
    epaisseur_eau = filtered_data.Epaisseur_eau{i};
    pneu = filtered_data.Pneu{i};
    piste = filtered_data.Piste{i};
    vitesse = filtered_data.Vitesse(i);
    
    % Trouver les lignes correspondantes dans essais_table
    match = strcmp(essais_table.Epaisseur_eau, epaisseur_eau) & ...
            strcmp(essais_table.Pneu, pneu) & ...
            strcmp(essais_table.Piste, piste) & ...
            essais_table.Vitesse == vitesse;
    
    % Calculer mu_predit en prenant la moyenne des mu prédits correspondants
    mu_predit(i) = mean(essais_table.Coeff_de_frottement(match));
    Distance_arret(i) = mean(essais_table.Distance_arret(match));
end

% Ajouter les colonnes 'mu_predit' et 'Distance_arret' à filtered_data
filtered_data.mu_predit = mu_predit;
filtered_data.Distance_arret = Distance_arret;

% Réorganiser les colonnes pour insérer 'Distance_arret' entre 'distance_freinage' et 'mu_bloq1'
filtered_data = movevars(filtered_data, 'Distance_arret', 'After', 'distance_freinage');

% Afficher le tableau résultant
disp(filtered_data);
