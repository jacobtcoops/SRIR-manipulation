function [outputSRIR, Fs] = NESWtoOmni(northFileName, eastFileName,...
    southFileName, westFileName)
% NEWStoOmni    sums and normalises SRIR inputs
%   function takes the file names (including relative paths) of SRIRs 
%   recorded from a single source-receiver combination with four source 
%   orientations
%   these are summed and normalised to simulate the SRIR for an
%   onmidirectional source
%   this will work for any number of channels, provided they are the same
%   for each audio file
%   INPUTS
%       northFileName       file name and relative path for the north SRIR
%       eastFileName        file name and relative path for the east SRIR
%       southFileName       file name and relative path for the south SRIR
%       westFileName        file name and relative path for the west SRIR
%   OUTPUTS
%       outputSRIR            output SRIR stored as a matrix
%       Fs                  sample rate for SRIR

    % load in requried audio files
    [north, Fs] = audioread(northFileName);
    [east, FsE] = audioread(eastFileName);
    [south, FsS] = audioread(southFileName);
    [west, FsW] = audioread(westFileName);

    % check sample rates all match
    if FsE ~= Fs || FsS ~= Fs || FsW ~= Fs
        error('Error: Sample rates of audio files do not match.');
    end

    % check number of channels match
    if width(north) ~= width(east) || width(north) ~= width(south) || ...
        width(north) ~= width(west)
        error('Error: Audio files have different numbers of channels.');
    end

    % check length of files match
    if length(north) ~= length(east) || length(north) ~= length(south) || ...
        length(north) ~= length(west)
        error('Error: Audio files lengths do not match.');
    end

    % sum audio
    outputSRIR = north + south + east + west;
end