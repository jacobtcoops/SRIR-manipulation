function createMcfxConfigs(SRIRPath)
%createMcfxConfigs  creates config files for SRIRs for use in mcfx 
%                   convolver plugin
%   creates config files for use with 1 input
%   INPUTS
%       SRIRPath     relative path for SRIRs

    % create list of files
    wavlist = dir(fullfile(SRIRPath, '*.wav'));

    % for each file in directory
    for i = 1:size(wavlist,1)
    
        % indicate which file is being processed
        disp(['Processing: ' wavlist(i).name ' ...'])
    
        name = extractBefore(wavlist(i).name,'.wav');
        inchannels = 1; % because it's an impulse response of a single sound source
    
        % save config file
        % http://www.angelofarina.it/X-MCFX.htm
        % https://github.com/kronihias/mcfx/blob/d28fd44347b085a9b36855e7a371812b19f4ee95/CONVOLVER_CONFIG_HOWTO.txt#L30
        % /impulse/packedmatrix <inchannels> <gain> <delay> <offset> <length> <filename>
    
        header = "# /impulse/packedmatrix <inchannels> <gain> <delay> <offset> <length> <filename>";
        confstr = string(['/impulse/packedmatrix ' num2str(inchannels) ' 1 0 0 0 ' name '.wav']);
        lines = [header confstr];
        writelines(lines,[SRIRPath name '.conf'])
end