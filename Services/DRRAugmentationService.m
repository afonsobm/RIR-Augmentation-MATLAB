classdef DRRAugmentationService
    methods(Static)
        function [augmentedEarlyRIR, augmentedRIR] = generateAugmentedRIR(h_air, air_info, targetDRR)

            % Retrieving early/late responses
            earlyIR = IRUtil.earlyResponseRIR(h_air, air_info.fs, Constants.DELAY_THRESHOLD, Constants.TOLERANCE_WINDOW);
            lateIR = IRUtil.lateResponseRIR(h_air, air_info.fs, Constants.DELAY_THRESHOLD, Constants.TOLERANCE_WINDOW);

            drrOg = DRRAugmentationService.calculateDRR(earlyIR,lateIR);

            % Calculating Alpha Scalar to DRR
            drrAlpha = DRRAugmentationService.calculateAlpha(targetDRR, air_info.fs, earlyIR, lateIR);

            drrNew = DRRAugmentationService.calculateDRR(earlyIR * drrAlpha,lateIR);

            % Generating Augmented RIR
            augmentedEarlyRIR = earlyIR * drrAlpha;
            h_air(abs(augmentedEarlyRIR) > 0) = h_air(abs(augmentedEarlyRIR) > 0) * drrAlpha;
            augmentedRIR = h_air;
        end

        function drrAlpha = calculateAlpha(drr, fs, earlyIR, lateIR)
            
            % Generating Hann Windows and removing zeroes on earlyIR
            hannWindow = hann(ceil((fs * Constants.HANN_WINDOW_SIZE)/1000));
            hannWindow = transpose(hannWindow);

            %%% TODO: Verify if earlyIR_NP is correct to properly multiply hannWindow
            earlyIR_NP = earlyIR(abs(earlyIR) > 0);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % Prevent uneven sized arrays between hannWindow and earlyIR
            if (length(earlyIR_NP) > length(hannWindow))
                earlyIR_NP = earlyIR_NP(1:length(hannWindow));
            elseif (length(earlyIR_NP) < length(hannWindow))
                pads = zeros(1,length(hannWindow) - length(earlyIR_NP));
                earlyIR_NP = [earlyIR_NP pads];
            end

            % Calculating the maximum root of the quadratic equation to retrieve alpha
            coef = ones(1,3);
            coef(1) = sum((hannWindow.^2) .* (earlyIR_NP).^2);
            coef(2) = 2 * sum((1 - hannWindow) .* hannWindow .* (earlyIR_NP.^2));
            coef(3) = sum(((1 - hannWindow).^2) .* (earlyIR_NP.^2)) - (sum(lateIR.^2) * (10^(drr/10)));
            
            rt = roots(coef);
            drrAlpha = max(rt);
        end

        function drr = calculateDRR(earlyIR, lateIR)
            drr = 10 * log10(sum(earlyIR.^2)/sum(lateIR.^2));
        end

    end
end