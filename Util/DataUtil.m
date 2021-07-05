classdef DataUtil
    methods (Static)
        function success = saveAudioFile(audioData, fs, voiceName, roomName, distance, ptNoiseName, bgNoiseName, drrValue, t60Value, snrValue)
            success = true;

            filename = Constants.RESULTS_PATH;
            if (isempty(roomName) && isempty(distance) && isempty(ptNoiseName) && isempty(bgNoiseName) && isempty(drrValue) && isempty(t60Value) && isempty(snrValue))
                filename = strcat(filename, erase(voiceName, '.wav'), '_', 'og_voice');
            elseif (isempty(ptNoiseName) && isempty(bgNoiseName) && isempty(drrValue) && isempty(t60Value) && isempty(snrValue))
                filename = strcat(filename, erase(voiceName, '.wav'), '_', roomName, '_', 'dst', int2str(distance), '_','og_rir');
            elseif (isempty(ptNoiseName) && isempty(bgNoiseName) && isempty(snrValue))
                filename = strcat(filename, erase(voiceName, '.wav'), '_', roomName, '_', 'dst', int2str(distance), '_', ...
                 'tst', int2str(t60Value), '_', 'drr', int2str(drrValue), '_', 'aug_rir');
            else 
                filename = strcat(filename, erase(voiceName, '.wav'), '_', roomName, '_', 'dst', int2str(distance), '_', ...
                 'tst', int2str(t60Value), '_', 'drr', int2str(drrValue), '_', ...
                 'snr', int2str(snrValue), '_', ...
                 'ptN', erase(erase(ptNoiseName, '.wav'), 'noise-free-sound-'), '_', ...
                 'bgN', erase(erase(bgNoiseName, '.wav'), 'noise-free-sound-'), '_', ...
                 'aug_rir_noise');
            end
            
            audiowrite(strcat(filename, '.wav'), audioData, fs);
        end

        function success = saveRIRData(rirData, fs, isAug, roomName, distance, drrValue, t60Value)
            success = true;

            filename = Constants.RESULTS_PATH;
            if (isAug)
                filename = strcat(filename, 'aug', '_', roomName, '_', 'dst', int2str(distance), ...
                'tst', int2str(t60Value), '_', 'drr', int2str(drrValue), ...
                '.mat');
            else
                filename = strcat(filename, roomName, '_', 'dst', int2str(distance), ...
                'tst', int2str(t60Value), '_', 'drr', int2str(drrValue), ...
                '.mat');
            end

            %save(filename, rirData, '.mat');
            save(filename, 'rirData');
        end

        function [h_air, air_info] = loadRIR(exampleNb)

            if (exampleNb == 1)
                %--------------------------------------------------------------------------
                % Example 1
                %--------------------------------------------------------------------------
                % Binaural RIR of lecture room
                % Distance: 7.1m
                % With dummy head
                % left channel
                airpar.fs = 16e3;
                airpar.rir_type = 1;
                airpar.room = 4;
                airpar.channel = 1;
                airpar.head = 1;
                airpar.rir_no = 4;
                [h_air,air_info] = LoadAIR.loadAIR(airpar, Constants.AIR_LIBRARY_PATH);
            elseif (exampleNb == 2)
                %--------------------------------------------------------------------------
                % Example 2
                %--------------------------------------------------------------------------
                % Binaural RIR of Booth room
                % Distance: 1m
                % With dummy head
                % left channel
                airpar.fs = 16e3;
                airpar.rir_type = 1;
                airpar.room = 1;
                airpar.channel = 1;
                airpar.head = 1;
                airpar.rir_no = 2;
                [h_air,air_info] = LoadAIR.loadAIR(airpar, Constants.AIR_LIBRARY_PATH);
            elseif (exampleNb == 3)
                %--------------------------------------------------------------------------
                % Example 3
                %--------------------------------------------------------------------------
                % Binaural RIR of stairway room
                % Distance: 1m
                % With dummy head
                % left channel
                airpar.fs = 16e3;
                airpar.rir_type = 1;
                airpar.room = 5;
                airpar.channel = 1;
                airpar.head = 1;
                airpar.rir_no = 1;
                airpar.azimuth = 90;
                [h_air,air_info] = LoadAIR.loadAIR(airpar, Constants.AIR_LIBRARY_PATH);
            elseif (exampleNb == 4)
                %--------------------------------------------------------------------------
                % Example 4
                %--------------------------------------------------------------------------
                % Binaural RIR of office room
                % Distance: 2m
                % With dummy head
                % left channel
                airpar.fs = 16e3;
                airpar.rir_type = 1;
                airpar.room = 2;
                airpar.channel = 1;
                airpar.head = 1;
                airpar.rir_no = 2;
                [h_air,air_info] = LoadAIR.loadAIR(airpar, Constants.AIR_LIBRARY_PATH);
            elseif (exampleNb == 5)
                %--------------------------------------------------------------------------
                % Example 5
                %--------------------------------------------------------------------------
                % Binaural RIR of meeting room
                % Distance: 1.7m
                % With dummy head
                % left channel
                airpar.fs = 16e3;
                airpar.rir_type = 1;
                airpar.room = 3;
                airpar.channel = 1;
                airpar.head = 1;
                airpar.rir_no = 2;
                [h_air,air_info] = LoadAIR.loadAIR(airpar, Constants.AIR_LIBRARY_PATH);
            end
        end

        function randomDRR = getRandomDRRValue()
            randomDRR = randi([Constants.LOW_DRR_VALUE, Constants.HIGH_DRR_VALUE],1);
        end

        function randomT60 = getRandomT60Value()
            randomT60 = Constants.LOW_T60_VALUE + (Constants.HIGH_T60_VALUE - Constants.LOW_T60_VALUE) * rand;
            randomT60 = round(randomT60,2);
        end
    end    
end