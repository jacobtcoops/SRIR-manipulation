function outputSRIRsNormalised = ambisonicOmniConverter(rawSRIRPath, processedSRIRPath)
%ambisonicOmniConverter     converts folder of SRIRs to omnidirectional
%   function takes in a path and converts groups of four SRIRs from a 
%   single source-receiver combination with 4 orientations to a single,
%   omnidirectional SRIR
%   this interfaces with the function NESWtoOmni.m
%   the resultant SRIRs are saved in the processedSRIRPath
%   INPUT
%       rawSRIRPath           relative path for raw SRIRs
%       processedSRIRPath     relative path for processed SRIRs
%   OUTPUT
%       outputIRsNormalised onmidirectional SRIRs that have been normalised
%                           relative to one another

    % add in required paths
    %   add in raw audio files to project
    addpath(rawSRIRPath);
    %   add in directory for processed audio files
    addpath(processedSRIRPath);
    
    % place all .wav files in structs
    fileStruct = dir(fullfile(rawSRIRPath,'*.wav'));
    
    % loop through audio files in groups of four
    %   this assumes appropriate naming of files (i.e. N, E, S and W are
    %   located together) and that no other files are present
    %   note:   some primitive error checking is present, however this is 
    %           by no means exhaustive
    for i = 1: length(fileStruct)/4
    
        % put file names in a matrix
        fileNames = [   fileStruct(4*(i-1)+1).name;...
                        fileStruct(4*(i-1)+2).name;...
                        fileStruct(4*(i-1)+3).name;...
                        fileStruct(4*(i-1)+4).name      ];
    
        % locate the north, east, south and west files and assign to
        % variables
        for k = 1: size(fileNames, 1)
                if fileNames(k, end - 8) == 'N'
                    northFileName = strcat(rawSRIRPath, fileNames(k, :));
                elseif fileNames(k, end - 8) == 'E'
                    eastFileName = strcat(rawSRIRPath, fileNames(k, :));
                elseif fileNames(k, end - 8) == 'S'
                    southFileName = strcat(rawSRIRPath, fileNames(k, :));
                elseif fileNames(k, end - 8) == 'W'
                    westFileName = strcat(rawSRIRPath, fileNames(k, :));
                else
                    % throw error if the file name does not have an 'N', 
                    % 'E', 'S' or 'W' in the expected location
                    error('File names not in the correct format.');
                end
        end
    
        % convert the audio file to omnidirectional
        [outputIRs{i}, Fs] = NESWtoOmni(    northFileName, eastFileName, ...
                                            southFileName, westFileName);
    end

    % find maximum peak across all SRIRs
    for j = 1: length(outputIRs)
        % array of maxima across the SRIRs
        maxima(j) = max(abs(outputIRs{j}), [], 'all');
    end
    maximum = max(maxima);

    % normalise SRIRs relative to the maximum peak across all of them
    for j = 1: length(outputIRs)
        outputSRIRsNormalised{j} = 0.99 * outputIRs{j}./maximum;
    end

    % write each SRIRs to an audio file
    for k = 1:length(fileStruct)
        % for each North SRIRs
        if fileStruct(k).name(end - 8) == 'N'
            % use this name to construct the name for the omnidirectional
            % SRIRs
            inputFileName = fileStruct(k).name;
            splitName = split(inputFileName, "N");
            outputFileName = strcat(processedSRIRPath, '/', splitName{1},...
                'Omni', splitName{2});

            % write each SRIRs to an audio file
            audiowrite( outputFileName, outputSRIRsNormalised{ceil(k/4)}, ...
                        Fs, 'BitsPerSample', 24);
        end
    end
end