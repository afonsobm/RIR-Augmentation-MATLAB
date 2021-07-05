classdef SpeechGeneratorService
    methods(Static)
        function [augmentedSpeechNoise, augmentedSpeechPure, targetSNR] = generateAugmentedSpeech(RIR, voiceSample, pointNoiseSample, backgroundNoiseSample)
            
            % Convolving pure voice sample with Augmented RIR
            %augmentedSpeechNoise = conv(voiceSample, RIR, 'same');
            augmentedSpeechNoise = conv(voiceSample, RIR, 'full');
            augmentedSpeechPure = augmentedSpeechNoise;

            % Randomly Select a SNR value within the desired range
            targetSNR = randi([Constants.LOW_SNR_VALUE, Constants.HIGH_SNR_VALUE],1);

            if (~isempty(pointNoiseSample))
                augmentedSpeechNoise = SpeechGeneratorService.pointNoiseAdd(augmentedSpeechNoise, RIR, pointNoiseSample, targetSNR);
            end

            if (~isempty(backgroundNoiseSample))
                augmentedSpeechNoise = SpeechGeneratorService.backgroundNoiseAdd(augmentedSpeechNoise, backgroundNoiseSample, targetSNR);
            end
        end

        function speechWithNoise = pointNoiseAdd(voiceSample, RIR, pointNoiseSample, targetSNR)
            
            % Convolving point noise sample with Augmented RIR
            %convNoiseSample = conv(pointNoiseSample, RIR, 'same');
            convNoiseSample = conv(pointNoiseSample, RIR, 'full');

            % Offset the noise to a random part of the voice sample
            initPos = randi([1 (length(voiceSample) - length(convNoiseSample))],1);
            endPos = initPos + length(convNoiseSample) - 1;
            zpPointNoiseSample = zeros(1, length(voiceSample));
            zpPointNoiseSample(initPos:endPos) = zpPointNoiseSample(initPos:endPos) + convNoiseSample;

            % Calculates SNR Alpha Scaling Coefficient
            snrAlpha = SpeechGeneratorService.calculateSNRAlpha(voiceSample, zpPointNoiseSample, targetSNR);

            speechWithNoise = voiceSample + (zpPointNoiseSample * snrAlpha);
        end

        function speechWithNoise = backgroundNoiseAdd(voiceSample, backgroundNoiseSample, targetSNR)
            
            % Matching the sizes of the Voice Sample with the Background Noise
            if (length(backgroundNoiseSample) > length(voiceSample))
                backgroundNoiseSample = backgroundNoiseSample(1:length(voiceSample));
            elseif (length(backgroundNoiseSample) < length(voiceSample))
                pads = zeros(1,length(voiceSample) - length(backgroundNoiseSample));
                backgroundNoiseSample = [backgroundNoiseSample pads];
            end

            % Calculates SNR Alpha Scaling Coefficient
            snrAlpha = SpeechGeneratorService.calculateSNRAlpha(voiceSample, backgroundNoiseSample, targetSNR);
            
            speechWithNoise = voiceSample + (backgroundNoiseSample * snrAlpha);
        end

        function snrAlpha = calculateSNRAlpha(voiceSample, noiseSample, targetSNR)

            % Randomly Select a SNR value within the desired range
            %targetSNR = randi([Constants.LOW_SNR_VALUE, Constants.HIGH_SNR_VALUE],1);
            disp('Calculating SNR Alpha');

            %%% TODO: !!!!!!!!!!!!!! THIS IS DUMB, BUT IT WORKS, WILL CHANGE LATER !!!!!!!!!!!!!!!!!!
            snrAlpha = 0;
            snrValue = 0;
            while (abs(targetSNR - snrValue) > 0.1)
                snrAlpha = snrAlpha + 1e-4;
                
                adjustedNoise = noiseSample * snrAlpha;
                voiceWithNoise = voiceSample + adjustedNoise;

                snrValue = snr(voiceWithNoise, adjustedNoise);
                difSNR = targetSNR - snrValue;
                disp(difSNR);
            end
            %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        end
    end
end