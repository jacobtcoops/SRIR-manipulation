function waveformplot(filename)
% plots the waveform of the first channel of input file specfiied by
% filename
[x,fs] = audioread(filename);
x = x(:,1);
% calculate the time step (t) and calculate time axis of the plot

t = 1/fs;
L = length(x);
timeaxis = (0:L-1)*t;

% plot the waveform against the time axis

plot(timeaxis,x,'k');
xlabel('Time (s)');
ylabel ('Amplitude');
title(strcat(filename,{' - '},'Waveform'), 'Interpreter', 'none');
axis([0 max(timeaxis) -1.1 1.1]);
grid on
end