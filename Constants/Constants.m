classdef Constants
    properties (Constant)

        % #################### GENERAL CONSTANTS ####################

        AIR_LIBRARY_PATH = '../DATABASES/AIR_LIB/';
        POINT_NOISE_LIBRARY_PATH = '../DATABASES/NOISE_LIB/PT/';
        BG_NOISE_LIBRARY_PATH = '../DATABASES/NOISE_LIB/BG/';
        SPEECH_LIBRARY_PATH = '../DATABASES/SPEECH_LIB/normal/';

        RESULTS_PATH = 'RESULTS/';

        % #################### DRR CONSTANTS ####################

        % defines the intensity of the impulse response which will represent when the audio reached the microfone in the recording
        DELAY_THRESHOLD = 0.01;

        % [miliseconds] defines the size of the tolerance window that will be used to retrieve the early/late impulse responses
        TOLERANCE_WINDOW = 2.5;

        % [miliseconds] defines the size of the Hann Window to calculate the DRR Alpha
        HANN_WINDOW_SIZE = 5;

        % [db] Lower bound of the desired DRR
        %LOW_DRR_VALUE = -6;
        LOW_DRR_VALUE = -6;

        % [db] Upper bound of the desired DRR
        %HIGH_DRR_VALUE = 18;
        HIGH_DRR_VALUE = 18;

        % #################### T60 CONSTANTS ####################

        % [seconds] Lower bound of the desired T60
        LOW_T60_VALUE = 1;

        % [seconds] Upper bound of the desired T60
        %HIGH_T60_VALUE = 1.5;
        HIGH_T60_VALUE = 3;

        % #################### SPEECH GEN CONSTANTS ####################

        % [db] Lower bound of the desired SNR
        %LOW_SNR_VALUE = -5;
        LOW_SNR_VALUE = 3;

        % [db] Upper bound of the desired SNR
        %HIGH_SNR_VALUE = 20;
        HIGH_SNR_VALUE = 30;

        
    end
end