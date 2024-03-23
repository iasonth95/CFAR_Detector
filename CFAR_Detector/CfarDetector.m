% === 1. LOAD DATASET ===
load('../data/radar.mat');

% === 2. PLOT === 
Ts = 1e-3; % -- sampling time interval 
slow_time = (1:size(Data_out)*Ts); 
data_dB=20*log10(abs(Data_out)); % -- dB of the Amplitute

figure,
imagesc(slow_time,range,data_dB);
xlabel('slow time'), ylabel('range');

% === 3. range-Doppler map (RDM) === 
N_doppler = 512; 
freq = (-500:1000/(N_doppler+1):500); 
y = fftshift(fft(Data_out,512));
% make your plot here 
figure,
imagesc(freq,range,20*log10(abs(y')));
xlabel('frequency');
ylabel('range');

% A pulse-Doppler radar integrates pulses over time to compute the Doppler
% velocities. The stationary objects are not having any velocity and this is
% the reason of the spike at dopler-frequency 0. At the negative frequencies
% the objects are moving away but in positive frequencies the objects are
% moving towards the radar.

% === 4. 1D CFAR detection ===

% Power (square of magnitude) with respact to the range
% select one row data 
data = Data_out(40,:)'; 
data_sqr = abs(data);
data_sqr_sim = data_sqr.^2;
figure,
plot(range,data_sqr_sim);
xlabel('range');
ylabel('power');

p_data = data_sqr_sim;

% Cfar detector design
cfar = phased.CFARDetector('NumTrainingCells',20,'NumGuardCells',2);
exp_pfa = 10^(-4); % probability of false alarm
cfar.ThresholdFactor = 'Auto';
cfar.ProbabilityFalseAlarm = exp_pfa;
release(cfar);
cfar.ThresholdOutputPort = true;
cfar.ThresholdFactor = 'Auto';
cfar.NumTrainingCells = 200; % number of leading and lagging widnows

[x_detected,th] = cfar(p_data,1:length(p_data));

% Plot signals, threhold, and detections
figure;
plot(1:length(p_data),abs(p_data));
hold on 
plot(1:length(p_data), th);
plot(find(x_detected),p_data(x_detected),'o')
legend('Signal','Threshold','Detections','Location','Northeast')
xlabel('Time Index'),ylabel('Level')
legend("Position", [0.58003,0.72452,0.32508,0.2])
