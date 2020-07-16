classdef IRUtil
    methods (Static)
        function earlyIR = earlyResponseRIR(ir_data, fs, threshold, tolerance)

            earlyResponseData = ir_data;
            sampleWindowSize = IRUtil.getWindowSize(fs, tolerance);
            delaySize = IRUtil.getDelaySizeFromRIR(earlyResponseData, threshold);
            
            earlyResponseData(1 : (delaySize - sampleWindowSize) - 1) = 0;
            earlyResponseData((delaySize + sampleWindowSize) + 1 : end) = 0;
            
            earlyIR = earlyResponseData;
        end

        function lateIR = lateResponseRIR(ir_data, fs, threshold, tolerance)

            lateResponseData = ir_data;            
            sampleWindowSize = IRUtil.getWindowSize(fs, tolerance);
            delaySize = IRUtil.getDelaySizeFromRIR(lateResponseData, threshold);
            
            lateResponseData((delaySize - sampleWindowSize):(delaySize + sampleWindowSize)) = 0;
            
            lateIR = lateResponseData;
        end

        function delaySize = getDelaySizeFromRIR(ir_data, threshold)
            delaySize = find(abs(ir_data) > threshold);
            delaySize = delaySize(1);
        end

        function windowSize = getWindowSize(fs, tolerance)
            windowSize = ceil((fs * tolerance)/1000);
        end
    end
end