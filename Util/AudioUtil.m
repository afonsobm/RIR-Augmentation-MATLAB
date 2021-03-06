classdef AudioUtil
    methods(Static)
        function audiofile = loadAudio(filename, libpath, fs)

            oldFolder = pwd;
            if (exist(libpath) && ~isempty(libpath))
                cd(libpath);
            end

            %filename = [filename,'.wav'];
            if ~(exist(filename,'file'))
                cd(oldFolder);
                error('AudioUtil.loadAudio: file <%s> does not exist\n',filename);
            end

            [audiofile, fs_file] = audioread(filename);
            %--------------------------------------------------------------------------
            % Transpose
            %--------------------------------------------------------------------------
            if size(audiofile,1)~=1
                audiofile = audiofile';
            end
            %--------------------------------------------------------------------------
            % Resample if necessary
            %--------------------------------------------------------------------------
            if fs_file ~= fs
                audiofile = resample(audiofile, fs, fs_file);
            end
            
            cd(oldFolder);
        end

        function [audioFile, fileInfo] = loadRandomAudioSample(libpath, fs)

            % Selecting a random file from the library path
            libFiles = strcat(libpath, '*.wav');
            listFiles = dir(libFiles);
            randNb = randi([1 length(listFiles)],1);
            fileInfo = listFiles(randNb);

            audioFile = AudioUtil.loadAudio(fileInfo.name, libpath, fs);
        end
    end
end