classdef DataUtil
    methods (Static)
        function success = saveAudioFile(audioData, fs, voiceName, roomName, ptNoiseName, bgNoiseName, drrValue, t60Value)
            success = true;

            filename = Constants.RESULTS_PATH;
            if (isempty(roomName) && isempty(ptNoiseName) && isempty(bgNoiseName) && isempty(drrValue) && isempty(t60Value))
                filename = strcat(filename, erase(voiceName, '.wav'), '_', 'og_voice');
            elseif (isempty(ptNoiseName) && isempty(bgNoiseName) && isempty(drrValue) && isempty(t60Value))
                filename = strcat(filename, erase(voiceName, '.wav'), '_', roomName, '_','og_rir');
            elseif (isempty(ptNoiseName) && isempty(bgNoiseName))
                filename = strcat(filename, erase(voiceName, '.wav'), '_', roomName, '_', ...
                 'tst', int2str(t60Value), '_', 'drr', int2str(drrValue), '_', 'aug_rir');
            else 
                filename = strcat(filename, erase(voiceName, '.wav'), '_', roomName, '_', ...
                 'tst', int2str(t60Value), '_', 'drr', int2str(drrValue), '_', ...
                 'ptN', erase(erase(ptNoiseName, '.wav'), 'noise-free-sound-'), '_', ...
                 'bgN', erase(erase(bgNoiseName, '.wav'), 'noise-free-sound-'), '_', ...
                 'aug_rir_noise');
            end
            
            audiowrite(strcat(filename, '.flac'), audioData, fs);
        end

        function randomDRR = getRandomDRRValue()
            randomDRR = randi([Constants.LOW_DRR_VALUE, Constants.HIGH_SNR_VALUE],1);
        end

        function randomT60 = getRandomT60Value()
            randomT60 = Constants.LOW_T60_VALUE + (Constants.HIGH_T60_VALUE - Constants.LOW_T60_VALUE) * rand;
            randomT60 = round(randomT60,2);
        end
    end    
end