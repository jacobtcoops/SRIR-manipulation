close all
clear

% convert third order files
ThirdOAIRsNormalised = ambisonicOmniConverter(  'Audio Files/Raw IRs/3OA/',...
                                                'Audio Files/Processed IRs/3OA/'    );

% remove pre-delay and direct sound from third order files
removePD_SeparateDSRF(   'Audio Files/Processed IRs/3OA/',...
                         'Audio Files/Exported IRs/3OA/'         );

% create config files for third order files
createMcfxConfigs('Audio Files/Exported IRs/3OA/');