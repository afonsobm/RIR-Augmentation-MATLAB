classdef T60AugmentationService
    methods(Static)

        % ### !!! NOTICE !!! ###
        % The "ITA-Toolbox" is required to execute the following methods
        % Visit this website for more information: "http://www.ita-toolbox.org/"
        function [augmentedLateRIR, augmentedRIR] = generateAugmentedRIR(h_air, air_info, targetT60)
            
            % Loading the RIR into the itaAudio format
            itaRIR = itaAudio(h_air, air_info.fs, 'time');

            % Estimating T20 parameter for the default subbands using the "ita_roomacoustics" function (following ISO 3382-1)
            % (Since it is not always possible to properly estimate T60, we are estimating T20)
            [raParams, raFilteredSignals] = ita_roomacoustics( itaRIR, ...
                'T20', ...
                'freqRange', [20 20000], 'bandsPerOctave', 1, 'edcMethod', 'subtractNoise');

            % Calculating T60 for each subband
            t60SubBands = raParams.T20.freqData;
            t60SubBands(isnan(t60SubBands)) = 0;
            t60SubBands = t60SubBands * 3;

            % Calculating fullband T60
            % TODO: Verify if the fullband T60 can be simplified as a mean of the subband ones
            t60FullBand = mean(t60SubBands);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % Calculating required decay rates
            [decayRateSubBands, targetDecayRateSubBands] = T60AugmentationService.calculateDecayRates(t60FullBand, t60SubBands, targetT60, air_info.fs);

            % Retrieving late-field onset time
            % TODO: Verify if this way to get this parameter is acceptable
            lateOnsetTime = IRUtil.getDelaySizeFromRIR(h_air, air_info.fs, Constants.DELAY_THRESHOLD) ...
                            + IRUtil.getWindowSize(air_info.fs, Constants.TOLERANCE_WINDOW);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % Generating augmented RIR
            [augmentedLateRIR, augmentedRIR] = T60AugmentationService.augmentLateIR(raFilteredSignals, decayRateSubBands, targetDecayRateSubBands, lateOnsetTime);
        end

        function [augmentedLateRIR, augmentedRIR] = augmentLateIR(rirSubBands, decayRateSubBands, targetDecayRateSubBands, lateOnsetTime)

            %f = @(t) exp((-t + lateOnsetTime) * ())
        end

        function [decayRateSubBands, targetDecayRateSubBands] = calculateDecayRates(t60FullBand, t60SubBands, targetT60, fs)

            % Calculating estimated decay rates for each subband
            decayRateSubBands = convertT60ToDecayRate(t60SubBands, fs);

            % Calculating desired decay rates for each subband
            drGamma = convertT60ToDecayRate(targetT60, fs) / convertT60ToDecayRate(t60FullBand, fs);
            targetDecayRateSubBands = drGamma * decayRateSubBands;
        end
        
        function dr = convertT60ToDecayRate(t60, fs)
            dr = t60 * 1/(log(1000)) * fs;
        end
    end
end