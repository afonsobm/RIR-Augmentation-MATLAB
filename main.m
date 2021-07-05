% =======================================================
% GRADUATION PROJECT - ROOM IMPULSE RESPONSE AUGMENTATION
% =======================================================

% ================
% AUTHOR - VERSION
% ================

%   Author: Bruno Machado Afonso
%   Version: 1.0
%   Institution: Escola Politecnica - Universidade Federal do Rio de Janeiro (UFRJ), Rio de Janeiro, Brazil

% ===========
% DESCRIPTION
% ===========

%   This project is based on the implementation of the work presented on the following articles
        
        % 1) IMPULSE RESPONSE DATA AUGMENTATION AND DEEP NEURAL NETWORKS FOR BLIND ROOM ACOUSTIC PARAMETER ESTIMATION - Nicholas J. Bryan - Adobe Research, San Francisco, CA, USA
        % 2) A STUDY ON DATA AUGMENTATION OF REVERBERANT SPEECH FOR ROBUST SPEECH RECOGNITION - Tom Ko et al. - Huawei Noah’s Ark Research Lab, Hong Kong, China

%   The main objective is to create a method which generates artificial Room Impulse Response (RIR) by modifying the
%   Direct-to-Reverberant Ratio (DRR) and Reverberation Time (T60) parameters extracted from the RIR
%   Later, these can be aplied to speech signals to generate far-field speechs (using augmented RIR and artificial noises)

clear;
clc;
% Changing PWD to the main file and adding all subfolders to PATH
if(~isdeployed)
    folder = fileparts(which(mfilename));
    cd(folder);
    addpath(genpath(folder));
end

[h_air,air_info] = DataUtil.loadRIR(5);
%h_air = h_air * 100;

tfs = 16e3;

for i = 1:1

    targetDRR = DataUtil.getRandomDRRValue();
    targetT60 = DataUtil.getRandomT60Value();

    resultDRR = targetDRR;
    resultT60 = targetT60;

    [augmentedEarlyRIR, augmentedRIR_DRR, origDRR, resultDRR] = DRRAugmentationService.generateAugmentedRIR(h_air, air_info, targetDRR);
    [augmentedLateRIR, augmentedRIR_T60, origT60, resultT60] = T60AugmentationService.generateAugmentedRIR(h_air, air_info, targetT60);

    augmentedEarlyRIR = IRUtil.earlyResponseRIR(h_air, air_info.fs, Constants.DELAY_THRESHOLD, Constants.TOLERANCE_WINDOW);
    %augmentedLateRIR = IRUtil.lateResponseRIR(h_air, air_info.fs, Constants.DELAY_THRESHOLD, Constants.TOLERANCE_WINDOW);

    % Prevent uneven sized arrays between late and early augmentedRIR
    if (length(augmentedEarlyRIR) > length(augmentedLateRIR))
        augmentedEarlyRIR = augmentedEarlyRIR(1: length(augmentedLateRIR));
    elseif (length(augmentedEarlyRIR) < length(augmentedLateRIR))
        augmentedLateRIR = augmentedLateRIR(1: length(augmentedEarlyRIR));
    end

    augmentedRIR = augmentedEarlyRIR + augmentedLateRIR;

    [voiceData, voiceInfo] = AudioUtil.loadRandomAudioSample(Constants.SPEECH_LIBRARY_PATH, tfs);
    [ptNoiseData, ptNoiseInfo] = AudioUtil.loadRandomAudioSample(Constants.POINT_NOISE_LIBRARY_PATH, tfs);
    [bgNoiseData, bgNoiseInfo] = AudioUtil.loadRandomAudioSample(Constants.BG_NOISE_LIBRARY_PATH, tfs);

    rirVoice = conv(voiceData, h_air, 'full');
    %augmentedSpeechPure = conv(voiceData, augmentedRIR, 'full');
    [augmentedSpeechNoise, augmentedSpeechPure, resultSNR] = SpeechGeneratorService.generateAugmentedSpeech(augmentedRIR, voiceData, ptNoiseData, bgNoiseData);

    %converting t60 to integer (miliseconds)
    resultT60 = round(resultT60 * 1000);

    % RIR original
    figure;
    plot(h_air);
    title('RIR original');
    xlabel('Tempo (discreto)');
    ylabel('Intensidade');
    legend('h(t)');

    % RIR augmentada
    figure;
    plot(augmentedRIR);
    title('RIR modificada');
    xlabel('Tempo (discreto)');
    ylabel('Intensidade');
    legend('ha(t)');

    % amostra de voz original
    figure;
    plot(voiceData);
    title('Amostra de voz original');
    xlabel('Tempo (discreto)');
    ylabel('Intensidade');
    legend('s(t)');

    % amostra de voz augmentada
    figure;
    plot(augmentedSpeechPure);
    title('Amostra de voz reverberada');
    xlabel('Tempo (discreto)');
    ylabel('Intensidade');
    legend('sa(t)');

    % amostra de voz com ruido
    figure;
    plot(augmentedSpeechNoise);
    title('Amostra de voz com ruído');
    xlabel('Tempo (discreto)');
    ylabel('Intensidade');
    legend('sn(t)');

    % figure;
    % subplot(2,2,2);
    % plot(voiceData);
    % title('Original Voice');
    % subplot(2,2,2);
    % plot(rirVoice);
    % title('Far Voice - Original RIR');
    % subplot(2,2,3);
    % plot(augmentedSpeechPure);
    % title('Far Voice - Augmented RIR');
    % subplot(2,2,4);
    % plot(augmentedSpeechNoise);
    % title('Far Voice - Augmented RIR + Noise');

    % saving original RIR
    %(rirData, fs, isAug, roomName, distance, drrValue, t60Value)
    DataUtil.saveRIRData(h_air, tfs, false, air_info.room, air_info.distance, origDRR, origT60);
    % saving augmented RIR
    DataUtil.saveRIRData(augmentedRIR, tfs, true, air_info.room, air_info.distance, resultDRR, resultT60);

    % saving original voice
    DataUtil.saveAudioFile(voiceData, tfs, voiceInfo.name, [], [], [], [], [], [], []);
    % saving voice with original RIR
    DataUtil.saveAudioFile(rirVoice, tfs, voiceInfo.name, air_info.room, air_info.distance, [], [], [], [], []);
    % saving voice with augmented RIR
    DataUtil.saveAudioFile(augmentedSpeechPure, tfs, voiceInfo.name, air_info.room, air_info.distance, [], [], resultDRR, resultT60, []);
    % saving voice with augmented RIR and Noise
    DataUtil.saveAudioFile(augmentedSpeechNoise, tfs, voiceInfo.name, air_info.room, air_info.distance, ptNoiseInfo.name, bgNoiseInfo.name, resultDRR, resultT60, resultSNR);
end


% TO DISCUSS: 

%   1 - Proper way to use Hann Window
%   R1 - peak of the Hann Window should match the peak of the Signal

%   2 - Fullband T60 can be calculated as a mean of the Subbands T60
%   R2 - This is fine

%   3 - Proper way to find the late-field onset time
%   R3 - This is fine (for the moment)




