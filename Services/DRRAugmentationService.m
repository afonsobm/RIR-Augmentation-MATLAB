classdef DRRAugmentationService
    methods(Static)
        function [augmentedEarlyRIR, augmentedRIR, drrOg, drrNew] = generateAugmentedRIR(h_air, air_info, targetDRR)

            % Retrieving early/late responses
            earlyIR = IRUtil.earlyResponseRIR(h_air, air_info.fs, Constants.DELAY_THRESHOLD, Constants.TOLERANCE_WINDOW);
            lateIR = IRUtil.lateResponseRIR(h_air, air_info.fs, Constants.DELAY_THRESHOLD, Constants.TOLERANCE_WINDOW);

            drrOg = DRRAugmentationService.calculateDRR(earlyIR,lateIR);

            % Calculating Alpha Scalar to DRR
            [earlyIR_N,drrAlpha] = DRRAugmentationService.calculateAlpha(targetDRR, air_info.fs, earlyIR, lateIR);

            %drrNew = DRRAugmentationService.calculateDRR(earlyIR * drrAlpha,lateIR);
            drrNew = DRRAugmentationService.calculateDRR(earlyIR_N,lateIR);

           % Generating Augmented RIR
           augmentedEarlyRIR = earlyIR_N;
           %h_air(abs(augmentedEarlyRIR) > 0) = h_air(abs(augmentedEarlyRIR) > 0) * drrAlpha;
           augmentedRIR = earlyIR_N+lateIR;
        end

        function [earlyIR_N,drrAlpha] = calculateAlpha(drr, fs, earlyIR, lateIR)
            
            % Generating Hann Windows and removing zeroes on earlyIR
            hannWindow = hann(ceil((fs * Constants.HANN_WINDOW_SIZE)/1000));
            hannWindow = transpose(hannWindow);
            
            [aux,ind]=max(abs(earlyIR));
            
            Nw=length(hannWindow);
            earlyIR_NP = earlyIR;
            
            if Nw<2*ind
                pads = zeros(1,ceil(ind-Nw/2));
                hannWindow = [pads hannWindow];
            end
            
            Nw=length(hannWindow);
            if (length(earlyIR_NP) > Nw)
                pads = zeros(1,length(earlyIR_NP)-Nw);
                hannWindow = [hannWindow pads];
            end

            % Calculating the maximum root of the quadratic equation to retrieve alpha
            coef = ones(1,3);
            coef(1) = sum((hannWindow.^2) .* (earlyIR_NP).^2);
            coef(2) = 2 * sum((1 - hannWindow) .* hannWindow .* (earlyIR_NP.^2));
            coef(3) = sum(((1 - hannWindow).^2) .* (earlyIR_NP.^2)) - (sum(lateIR.^2) * (10^(drr/10)));
            
            rt = roots(coef);
            drrAlpha = max(rt);
            
            earlyIR_N=drrAlpha*(earlyIR_NP.*hannWindow)+earlyIR_NP.*(1-hannWindow);
        end

        function drr = calculateDRR(earlyIR, lateIR)
            drr = 10 * log10(sum(earlyIR.^2)/sum(lateIR.^2));
        end

    end
end