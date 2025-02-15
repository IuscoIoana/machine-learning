clc; clear; close all;
%% 1. Încărcăm fișierul de test
[test_audio, Fs] = audioread('test.mp3'); 
test_audio = mean(test_audio, 2); % Convertim la mono

% Încarcă modelul de regresie
load('instrument_regression.mat', 'B');

% Definim dimensiunea ferestrei de analiză (1 secunda)
window_size = Fs * 1; % 1 sec = Fs eșantioane
num_segments = floor(length(test_audio) / window_size);

% Liste pentru rezultate
time_stamps = [];
predicted_instruments = [];

% Parcurgem fișierul în segmente de 1 sec
for i = 1:num_segments
    % Extragem segmentul curent
    start_idx = (i-1) * window_size + 1;
    end_idx = start_idx + window_size - 1;
    segment = test_audio(start_idx:end_idx);
    
    % Extragem MFCC pentru segment
    mfcc_segment = mfcc(segment, Fs, 'NumCoeffs', 13);
    mfcc_segment = normalize(mfcc_segment);
    
    % Facem predicția
    probabilities = mnrval(B, mfcc_segment);
    [~, predicted_label] = max(probabilities, [], 2);
    
    % Stocăm rezultatele
    time_stamps(end+1) = i; % Timpul în secunde
    predicted_instruments{end+1} = mode(predicted_label); % Instrumentul dominant
end

% Mapăm etichetele numerice la nume de instrumente
instrument_names = {'Pian', 'Chitară', 'Tobe'};
for i = 1:length(predicted_instruments)
    disp(['La secunda ', num2str(time_stamps(i)), ': ', instrument_names{predicted_instruments{i}}]);
end
