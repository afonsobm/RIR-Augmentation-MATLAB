classdef T60AugmentationService
    methods(Static)

        % ### !!! NOTICE !!! ###
        % The "ITA-Toolbox" is required to execute the following methods
        % Visit this website for more information: "http://www.ita-toolbox.org/"
        function [augmentedLateRIR, augmentedRIR, t60FullBand, t60FullBandTarget] = generateAugmentedRIR(h_air, air_info, targetT60)
            
            % Transpose RIR if lines == 1
            szRIR = size(h_air);
            if szRIR(1) == 1 
                h_air = h_air.';
            end

            % Loading the RIR into the itaAudio format
            itaRIR = itaAudio(h_air, air_info.fs, 'time');

            % Estimating T60 parameter for the default subbands using the "ita_roomacoustics" function (following ISO 3382-1)
            [raParams, raFilteredSignals] = ita_roomacoustics( itaRIR, ...
                 'T20','T60', 'EDC', ...
                 'broadbandAnalysis', true, 'edcMethod', 'noCut');

            % Calculating fullband T60
            t60FullBand = raParams.T60.freqData;

            % Calculating required decay rates
            decayRateOriginal = T60AugmentationService.convertT60ToDecayRate(t60FullBand, air_info.fs);
            decayRateTarget = T60AugmentationService.convertT60ToDecayRate(targetT60, air_info.fs);

            % Retrieving late-field onset time
            % TODO: Verify if this way to get this parameter is acceptable
            lateOnsetTime = IRUtil.getDelaySizeFromRIR(h_air, Constants.DELAY_THRESHOLD) ...
                            + IRUtil.getWindowSize(air_info.fs, Constants.TOLERANCE_WINDOW);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % Generating augmented RIR
            [augmentedLateRIR, augmentedRIR] = T60AugmentationService.augmentLateIR(h_air, ...
            decayRateOriginal, ...
            decayRateTarget, ...
            lateOnsetTime, air_info.fs);

            szRIR = size(augmentedRIR);
            if szRIR(1) == 1 
                augmentedRIR = augmentedRIR.';
            end

            % Checking the result T60
            itaRIR = itaAudio(augmentedRIR, air_info.fs, 'time');
            [raParams, raFilteredSignals] = ita_roomacoustics( itaRIR, ...
                 'T20','T60', 'EDC', ...
                 'broadbandAnalysis', true, 'edcMethod', 'noCut');

            t60FullBandTarget = raParams.T60.freqData;
            
            szRIR = size(augmentedRIR);
            if (szRIR(1) > szRIR(2))
                augmentedRIR = augmentedRIR.';
                augmentedLateRIR = augmentedLateRIR.';
            end
        end

        function [augmentedLateRIRFB, augmentedRIRFB] = augmentLateIR(rirFB, decayRateFB, targetDecayRateFB, lateOnsetTime, fs)

            szRIR = size(rirFB);
            if (szRIR(2) > szRIR(1))
                rirFB = rirFB.';
            end

            augmentedRIRFB = rirFB;
            lateRIRFB = augmentedRIRFB(lateOnsetTime:end);

            t = (1:1:length(lateRIRFB(:,1))).';
            expAug = exp(((-t + lateOnsetTime)) * ((decayRateFB - targetDecayRateFB)/(decayRateFB * targetDecayRateFB)));
            augmentedLateRIRFB = (lateRIRFB(:,1) .* expAug);

            %augmentedLateRIRFB = augmentedRIRFB;
            %augmentedLateRIRFB(1:lateOnsetTime) = 0;
            augmentedRIRFB(lateOnsetTime:end) = augmentedLateRIRFB;
        end       

        function [decayRateSubBands, targetDecayRateSubBands] = calculateDecayRates(t60FullBand, t60SubBands, targetT60, fs)

            % Calculating estimated decay rates for each subband
            decayRateSubBands = T60AugmentationService.convertT60ToDecayRate(t60SubBands, fs);

            % Calculating desired decay rates for each subband
            drGamma = T60AugmentationService.convertT60ToDecayRate(targetT60, fs) / T60AugmentationService.convertT60ToDecayRate(t60FullBand, fs);
            targetDecayRateSubBands = drGamma * decayRateSubBands;
        end
        
        function dr = convertT60ToDecayRate(t60, fs)
            dr = t60 * 1/(log(1000)) * fs;
        end
    end
end