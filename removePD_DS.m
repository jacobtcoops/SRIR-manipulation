function outputSRIRsExported = removePD_DS(processedSRIRPath, exportedSRIRPath)
%outputSRIRsExported    removes the pre-delay, direct sound and reverberant  
%                       sound from an SRIR
%   function takes a path and processes all SRIRs in that path to remove 
%   the pre-delay, direct sound and reverberant sound
%   function shifts the direct sound to time zero and sets the amplitude of
%   the following 0.5 ms to zero
%   it then applies a 1 ms Hanning window
%   for the first audio file only, it will also generate a reverberant 
%   sound SRIR 
%   INPUTS
%       processedSRIRPath    the relative path for the pre-processed SRIRs
%       exportedSRIRPath     the relative path for the output SRIRs
%   OUTPUTS
%       outputSRIRsExported  SRIRs with direct sound and pre-delay removed
    
    % add in required paths
    %   add in processed audio files to project
    addpath(processedSRIRPath);
    %   add in directory to export audio files to
    addpath(exportedSRIRPath);
  
    % place all .wav files in structs
    fileStruct = dir(fullfile(processedSRIRPath, '*.wav'));

    % for each file in the folder
    for i = 1: length(fileStruct)
        % read in SIR and sample rate
        [SRIR, Fs] = audioread(strcat(processedSRIRPath, fileStruct(i).name));

        % calculate length of SIR in samples
        SRIRLengthSamples = length(SRIR);
        
        % Hanning window
        %   2 ms length; 1 ms half window length
        winLenSec = 0.002;
        winLenSamp = Fs*winLenSec;
        hanningWindow = hann(winLenSamp, 'periodic');
        halfHannWinInc = hanningWindow(1: winLenSamp/2, :);
        
        halfHannWinDec = hanningWindow(winLenSamp/2 + 1 : end, :);

        % detect peak
        [~, peakTimeSample] = max(abs(SRIR(:, 1)), [], 'all');

        % approximate the start time by subtracting 1 ms from the peak
        onsetTime = 0.001;
        startTimeSample = peakTimeSample - onsetTime*Fs;

        % remove samples before this time
        shortenedSRIR = SRIR(startTimeSample: SRIRLengthSamples, :);

        % create arrays with multipliers for the reverberant sound
        offsetTime = 0.0005;
        DSLenSec = offsetTime + onsetTime;
        DSLenSamp = DSLenSec*Fs;

        ERLenSec = 0.08 - DSLenSec - winLenSec;
        ERLenSamp = ERLenSec*Fs;

        ERMultipliers = vertcat(zeros(DSLenSamp, 1), halfHannWinInc,...
            ones(ERLenSamp, 1), halfHannWinDec, ...
            zeros(length(shortenedSRIR) - (winLenSamp/2) - ERLenSamp - ...
            (winLenSamp/2) - DSLenSamp, 1));

        % Multiply by the SRIRs
        ERSRIR = shortenedSRIR .* ERMultipliers;
        
        % Write audio output
        fileNameSplit = split(fileStruct(i).name, '.');
        outputFileName = strcat(fileNameSplit{1}, '_ER.wav');
        audiowrite(strcat(exportedSRIRPath, outputFileName), ERSRIR, Fs, 'BitsPerSample', 24);
        
        % store SRIR in struct
        outputSRIRsExported{i} = ERSRIR;

        % create a reverberant sound SRIR for the first SRIR only
        if (i == 1)
            RSMultipliers = vertcat(zeros(DSLenSamp + winLenSamp/2 + ERLenSamp, 1), halfHannWinInc,...
                ones(length(shortenedSRIR) - (winLenSamp/2) - ERLenSamp - (winLenSamp/2) - DSLenSamp, 1));
            RSSIR = shortenedSRIR .* RSMultipliers;

            outputFileName_RS = strcat(fileNameSplit{1}, '_RS.wav');
            audiowrite(strcat(exportedSRIRPath, outputFileName_RS), RSSIR, Fs, 'BitsPerSample', 24);

            % Plot W channel input and output waveform for comparison
%             figure
%             subplot(3, 1, 1);
%             waveformplot(strcat(processedSIRPath, fileStruct(i).name));
%             xlim([startTimeSample/Fs, 0.1 + startTimeSample/Fs]);
%             ylim([-.5,.5]);
%             subplot(3, 1, 2);
%             waveformplot(strcat(exportedSIRPath, outputFileName));
%             xlim([0, 0.1]);
%             ylim([-.5,.5]);
%             subplot(3, 1, 3);
%             waveformplot(strcat(exportedSIRPath, outputFileName_RS));
%             xlim([0, 0.1]);
%             ylim([-.5,.5]);
        end

    end
end