classdef SpeechGeneratorService
    methods(Static)
        function [augmentedSpeechNoise, augmentedSpeechPure] = generateAugmentedSpeech(RIR, voiceSample, pointNoiseSample, backgroundNoiseSample)
            
            % Convolving pure voice sample with Augmented RIR
            augmentedSpeechNoise = conv(voiceSample, RIR, 'same');
            augmentedSpeechPure = augmentedSpeechNoise;

            if (~isempty(pointNoiseSample))
                augmentedSpeechNoise = SpeechGeneratorService.pointNoiseAdd(augmentedSpeechNoise, RIR, pointNoiseSample);
            end

            if (~isempty(backgroundNoiseSample))
                augmentedSpeechNoise = SpeechGeneratorService.backgroundNoiseAdd(augmentedSpeechNoise, backgroundNoiseSample);
            end
        end

        function speechWithNoise = pointNoiseAdd(voiceSample, RIR, pointNoiseSample)
            
            % Convolving point noise sample with Augmented RIR
            convNoiseSample = conv(pointNoiseSample, RIR, 'same');

            % Offset the noise to a random part of the voice sample
            initPos = randi([1 (length(voiceSample) - length(convNoiseSample))],1);
            endPos = initPos + length(convNoiseSample) - 1;
            zpPointNoiseSample = zeros(1, length(voiceSample));
            zpPointNoiseSample(initPos:endPos) = zpPointNoiseSample(initPos:endPos) + convNoiseSample;

            % Calculates SNR Alpha Scaling Coefficient
            snrAlpha = SpeechGeneratorService.calculateSNRAlpha(voiceSample, zpPointNoiseSample);

            speechWithNoise = voiceSample + (zpPointNoiseSample * snrAlpha);
        end

        function speechWithNoise = backgroundNoiseAdd(voiceSample, backgroundNoiseSample)
            
            % Matching the sizes of the Voice Sample with the Background Noise
            if (length(backgroundNoiseSample) > length(voiceSample))
                backgroundNoiseSample = backgroundNoiseSample(1:length(voiceSample));
            elseif (length(backgroundNoiseSample) < length(voiceSample))
                pads = zeros(1,length(voiceSample) - length(backgroundNoiseSample));
                backgroundNoiseSample = [backgroundNoiseSample pads];
            end

            % Calculates SNR Alpha Scaling Coefficient
            snrAlpha = SpeechGeneratorService.calculateSNRAlpha(voiceSample, backgroundNoiseSample);
            
            speechWithNoise = voiceSample + (backgroundNoiseSample * snrAlpha);
        end

        function snrAlpha = calculateSNRAlpha(voiceSample, noiseSample)

            % Randomly Select a SNR value within the desired range
            targetSNR = randi([Constants.LOW_SNR_VALUE, Constants.HIGH_SNR_VALUE],1);

            %%% TODO: !!!!!!!!!!!!!! THIS IS DUMB, BUT IT WORKS, WILL CHANGE LATER !!!!!!!!!!!!!!!!!!
            snrAlpha = 0;
            snrValue = 0;
            while (abs(targetSNR - snrValue) > 0.05)
                snrAlpha = snrAlpha + 1e-5;
                
                adjustedNoise = noiseSample * snrAlpha;
                voiceWithNoise = voiceSample + adjustedNoise;

                snrValue = snr(voiceWithNoise, adjustedNoise);
            end
            %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        end
    end
end