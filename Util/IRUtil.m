classdef IRUtil
    methods (Static)
        function earlyIR = earlyResponseRIR(ir_data, fs, threshold, tolerance)

            earlyResponseData = ir_data;
            sampleWindowSize = ceil((fs * tolerance)/1000);
            delaySize = find(abs(earlyResponseData) > threshold);
            delaySize = delaySize(1);
            
            earlyResponseData(1 : (delaySize - sampleWindowSize) - 1) = 0;
            earlyResponseData((delaySize + sampleWindowSize) + 1 : end) = 0;
            
            earlyIR = earlyResponseData;
        end

        function lateIR = lateResponseRIR(ir_data, fs, threshold, tolerance)

            lateResponseData = ir_data;
            sampleWindowSize = ceil((fs * tolerance)/1000);
            delaySize = find(abs(lateResponseData) > threshold);
            delaySize = delaySize(1);
            
            lateResponseData((delaySize - sampleWindowSize):(delaySize + sampleWindowSize)) = 0;
            
            lateIR = lateResponseData;
        end
    end
end