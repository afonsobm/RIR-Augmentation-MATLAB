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
            speechWithNoise = voiceSample;
        end
    end
end