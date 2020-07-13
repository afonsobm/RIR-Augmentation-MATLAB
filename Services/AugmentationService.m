classdef AugmentationService
    methods(Static)
        function augmentedRIR = augmentRIR(h_air, air_info)
            
            earlyIR = IRUtil.earlyResponseRIR(h_air, air_info.fs, Constants.DELAY_THRESHOLD, Constants.TOLERANCE_WINDOW);
            lateIR = IRUtil.lateResponseRIR(h_air, air_info.fs, Constants.DELAY_THRESHOLD, Constants.TOLERANCE_WINDOW);

            augmentedRIR = earlyIR
        end
    end
end