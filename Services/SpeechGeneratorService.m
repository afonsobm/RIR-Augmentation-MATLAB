classdef SpeechGeneratorService
    methods(Static)
        function [augmentedSpeechNoise, augmentedSpeechPure] = generateAugmentedSpeech(voiceSample, RIR, pointNoiseSample, backgroundNoiseSample)
            
            % Convolving pure voice sample with Augmented RIR
            augmentedSpeechNoise = conv(voiceSample, RIR, 'same');
            augmentedSpeechPure = augmentedSpeechNoise;

            if (~isempty(pointNoiseSample))
                augmentedSpeechNoise = SpeechGeneratorService.pointNoiseAdd(augmentedSpeechNoise, pointNoiseSample);
            end

            if (~isempty(backgroundNoiseSample))
                augmentedSpeechNoise = SpeechGeneratorService.backgroundNoiseAdd(augmentedSpeechNoise, backgroundNoiseSample);
            end
        end

        function speechWithNoise = pointNoiseAdd(voiceSample, pointNoiseSample)
            speechWithNoise = voiceSample;
        end

        function speechWithNoise = backgroundNoiseAdd(voiceSample, backgroundNoiseSample)
            
            % Matching the sizes of the Voice Sample with the Background Noise
            %backgroundNoiseSample = stretchAudio(backgroundNoiseSample, length(backgroundNoiseSample)/length(voiceSample));
            if (length(backgroundNoiseSample) > length(voiceSample))
                backgroundNoiseSample = backgroundNoiseSample(1:length(voiceSample));
            elseif (length(backgroundNoiseSample) < length(voiceSample))
                pads = zeros(1,length(voiceSample) - length(backgroundNoiseSample));
                backgroundNoiseSample = [backgroundNoiseSample pads];
            end

            % Calculates SNR Alpha Scaling Coefficient
            snrAlpha = SpeechGeneratorService.calculateSNRAlpha(voiceSample, backgroundNoiseSample);
            
            speechWithNoise = voiceSample + backgroundNoiseSample * snrAlpha;

        end

        function snrAlpha = calculateSNRAlpha(voiceSample, noiseSample)

            % Randomly Select a SNR value within the desired range
            targetSNR = randi([Constants.LOW_SNR_VALUE, Constants.HIGH_SNR_VALUE],1);

            % !!!!!!!!!!!!!! THIS IS DUMB, WILL CHANGE LATER !!!!!!!!!!!!!!!!!!
            snrAlpha = 0;
            snrValue = 0;
            while (abs(targetSNR - snrValue) > 0.01)
                snrAlpha = snrAlpha + 1e-4;
                
                adjustedNoise = noiseSample * snrAlpha;
                voiceWithNoise = voiceSample + adjustedNoise;

                snrValue = snr(voiceWithNoise, adjustedNoise)
            end
            %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        end
    end
end