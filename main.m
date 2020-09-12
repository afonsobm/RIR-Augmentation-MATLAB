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

%--------------------------------------------------------------------------
% Example 1
%--------------------------------------------------------------------------
% Binaural RIR of lecture room
% Distance: 4m
% With dummy head
% left channel
airpar.fs = 48e3;
airpar.rir_type = 1;
airpar.room = 4;
airpar.channel = 1;
airpar.head = 1;
airpar.rir_no = 4;
[h_air,air_info] = LoadAIR.loadAIR(airpar, Constants.AIR_LIBRARY_PATH);

tfs = 48e3;

for i = 1:2

    targetDRR = DataUtil.getRandomDRRValue();
    targetT60 = DataUtil.getRandomT60Value();

    [augmentedEarlyRIR, augmentedRIR_DRR] = DRRAugmentationService.generateAugmentedRIR(h_air, air_info, targetDRR);
    [augmentedLateRIR, augmentedRIR_T60] = T60AugmentationService.generateAugmentedRIR(h_air, air_info, targetT60);

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

    rirVoice = conv(voiceData, h_air, 'same');

    [augmentedSpeechNoise, augmentedSpeechPure] = SpeechGeneratorService.generateAugmentedSpeech(augmentedRIR, voiceData, ptNoiseData, bgNoiseData);

    %converting t60 to integer (miliseconds)
    targetT60 = round(targetT60 * 100);

    % saving original voice
    DataUtil.saveAudioFile(voiceData, tfs, voiceInfo.name, [], [], [], [], []);
    % saving voice with original RIR
    DataUtil.saveAudioFile(rirVoice, tfs, voiceInfo.name, 'lecture', [], [], [], []);
    % saving voice with augmented RIR
    DataUtil.saveAudioFile(augmentedSpeechPure, tfs, voiceInfo.name, 'lecture', [], [], targetDRR, targetT60);
    % saving voice with augmented RIR and Noise
    DataUtil.saveAudioFile(augmentedSpeechNoise, tfs, voiceInfo.name, 'lecture', ptNoiseInfo.name, bgNoiseInfo.name, targetDRR, targetT60);
end


% TO DISCUSS: 

%   1 - Proper way to use Hann Window
%   R1 - peak of the Hann Window should match the peak of the Signal

%   2 - Fullband T60 can be calculated as a mean of the Subbands T60
%   R2 - This is fine

%   3 - Proper way to find the late-field onset time
%   R3 - This is fine (for the moment)

%   4 - Normalization on required functions (some values are too small for the augmented RIR)
%   R4 - Adding gain to the signal is fine



