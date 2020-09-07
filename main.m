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

targetDRR = 5;
targetT60 = 0.5;

[augmentedEarlyRIR, augmentedRIR_DRR] = DRRAugmentationService.generateAugmentedRIR(h_air, air_info, targetDRR);
[augmentedLateRIR, augmentedRIR_T60] = T60AugmentationService.generateAugmentedRIR(h_air, air_info, targetT60);

%--------------------------------------------------------------------------
% Loading speech "male_src_1" + noise "0030"
%--------------------------------------------------------------------------

speech_sp.name = 'male_src_1';
noise_sp.name = 'noise-free-sound-0030';
tfs = 48e3;

speech_sp.data = AudioUtil.loadAudio(speech_sp.name, Constants.SPEECH_LIBRARY_PATH, tfs);
noise_sp.data = AudioUtil.loadAudio(noise_sp.name, Constants.NOISE_LIBRARY_PATH, tfs);

SpeechGeneratorService.generateAugmentedSpeech(1,1,1);

% plot(h_air);
% figure();
% plot(augmentedRIR_T60);

% TO DISCUSS: 

%   1 - Proper way to use Hann Window
%   R1 - peak of the Hann Window should match the peak of the Signal

%   2 - Fullband T60 can be calculated as a mean of the Subbands T60
%   R2 - This is fine

%   3 - Proper way to find the late-field onset time
%   R3 - This is fine (for the moment)

%   4 - Normalization on required functions (some values are too small for the augmented RIR)
%   R4 - Adding gain to the signal is fine



