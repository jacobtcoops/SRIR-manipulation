function removePD_GenerateDSRF(processedSRIRPath, exportedSRIRPath)

% DESCRIPTION NEEDS UPDATING
%outputIRsExported  removes the pre-delay from an SRIR and splits the
%                   direct sound and reverberant field
%   function takes a path and processes all SRIRs in that path to remove the
%   pre-delay and split into two SRIRs of the same length, one containing
%   only the direct sound, and the other containing only the reverberant
%   field
%   INPUTS
%       processedSRIRPath   the relative path for the pre-processed SRIRs
%       exportedSRIRPath    the relative path for the output SRIRs
    
    % add in required paths
    %   add in processed audio files to project
    addpath(processedSRIRPath);
    %   add in directory to export audio files to
    addpath(exportedSRIRPath);
  
    % place all .wav files in structs
    fileStruct = dir(fullfile(processedSRIRPath, '*.wav'));

    % for each file in the folder
    for i = 1: length(fileStruct)
        % read in SRIR and sample rate
        [SRIR, Fs] = audioread(strcat(processedSRIRPath, fileStruct(i).name));

        % calculate length of SRIR in samples
        SRIRLengthSamples = length(SRIR);
        
        % Hanning window
        %   2 ms length; 1 ms half window length
        winLenSec = 0.002;
        winLenSamp = Fs*winLenSec;
        hanningWindow = hann(winLenSamp, 'periodic');
        %   increasing and decreasing windows
        halfHannWinInc = hanningWindow(1: winLenSamp/2, :);
        halfHannWinDec = hanningWindow(winLenSamp/2 + 1 : end, :);
        halfWinLenSamp = length(halfHannWinInc);

        % detect peak
        [~, peakTimeSample] = max(abs(SRIR(:, 1)), [], 'all', 'linear');

        % approximate the start time by subtracting 1 ms from the peak
        onsetTime = 0.001;
        startTimeSample = peakTimeSample - onsetTime*Fs;

        % remove samples before this time
        shortenedSRIR = SRIR(startTimeSample: SRIRLengthSamples, :);

        % create arrays with multipliers for the direct sound reverberant 
        % field
        holdTime = 0.001;
        DSLenSamp = holdTime*Fs;
        DSMultipliers = vertcat(ones(DSLenSamp, 1), halfHannWinDec, zeros(length(shortenedSRIR) - halfWinLenSamp - DSLenSamp, 1));
        RFMultipliers = 1 - DSMultipliers;

        % Uncomment below to plot multipliers
        % figure
        % plot(DSMultipliers);
        % xlim([0 200]);

        % Multiply by the SRIRs
        DSSRIR = shortenedSRIR .* DSMultipliers;
        RFSRIR = shortenedSRIR .* RFMultipliers;
        
        % Write audio output
        fileNameSplit = split(fileStruct(i).name, '.');
        outputFileName_DS = strcat(fileNameSplit{1}, '_DS.wav');
        audiowrite(strcat(exportedSRIRPath, outputFileName_DS), DSSRIR, Fs, 'BitsPerSample', 24);
        outputFileName_RF = strcat(fileNameSplit{1}, '_RF.wav');
        audiowrite(strcat(exportedSRIRPath, outputFileName_RF), RFSRIR, Fs, 'BitsPerSample', 24);

        % Plot W channel input and output waveform for comparison for the
        % first SRIR only
        if (i == 1)
            figure
            subplot(3, 1, 1);
            waveformplot(strcat(processedSRIRPath, fileStruct(i).name));
            xlim([startTimeSample/Fs, 0.1 + startTimeSample/Fs]);
            ylim([-.5,.5]);
            subplot(3, 1, 2);
            waveformplot(strcat(exportedSRIRPath, outputFileName_DS));
            xlim([0, 0.1]);
            ylim([-.5,.5]);
            subplot(3, 1, 3);
            waveformplot(strcat(exportedSRIRPath, outputFileName_RF));
            xlim([0, 0.1]);
            ylim([-.5,.5]);
        end

    end
end