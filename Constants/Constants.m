classdef Constants
    properties (Constant)

        % #################### GENERAL CONSTANTS ####################

        AIR_LIBRARY_PATH = '../AIR_LIB/';

        % #################### DRR CONSTANTS ####################

        % defines the intensity of the impulse response which will represent when the audio reached the microfone in the recording
        DELAY_THRESHOLD = 0.001;

        % [miliseconds] defines the size of the tolerance window that will be used to retrieve the early/late impulse responses
        TOLERANCE_WINDOW = 2.5;

        % [miliseconds] defines the size of the Hann Window to calculate the DRR Alpha
        HANN_WINDOW_SIZE = 5;

        % #################### T60 CONSTANTS ####################
        
    end
end