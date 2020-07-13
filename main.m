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

% Changing PWD to the main file and adding all subfolders to PATH
if(~isdeployed)
    folder = fileparts(which(mfilename));
    cd(folder);
    addpath(genpath(folder));
end

a = Constants.HANN_WINDOW_SIZE;

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


