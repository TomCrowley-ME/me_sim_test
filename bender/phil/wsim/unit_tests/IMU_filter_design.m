%2nd order butter(2,0.01) -3 dB cutoff at 0.01 of sample nyquist frequency (0.5 hz of 50 hz (nyquist of 100 hz sample rate)
%2nd order butter(2,0.10) -3 dB cutoff at 0.10 of sample nyquist frequency (5.0 hz of 50 hz (nyquist of 100 hz sample rate)
%2nd order butter(2,0.20) -3 dB cutoff at 0.20 of sample nyquist frequency (10.0 hz of 50 hz (nyquist of 100 hz sample rate)
%2nd order butter(2,0.90) -3 dB cutoff at 0.90 of sample nyquist frequency (45.0 hz of 50 hz (nyquist of 100 hz sample rate)
%2nd order butter(2,0.95) -3 dB cutoff at 0.95 of sample nyquist frequency (47.5 hz of 50 hz (nyquist of 100 hz sample rate)
%2nd order butter(2,0.80) -3 dB cutoff at 0.80 of sample nyquist frequency (40.0 hz of 50 hz (nyquist of 100 hz sample rate)
%2nd order butter(2,0.0.60) -3 dB cutoff at 0.60 of sample nyquist frequency (30.0 hz of 50 hz (nyquist of 100 hz sample rate)
[b,a]=butter(2,0.01);
[b,a]=butter(2,0.10);
[b,a]=butter(2,0.90);
[b,a]=butter(2,0.95);
[b,a]=butter(2,0.20);
[b,a]=butter(2,0.80);
[b,a]=butter(2,0.60);
[b,a]=butter(2,0.01)
dataIn=randn(100,1);
dataOut = filter(b,a,dataIn);
% Magnitude and Phase Lag
freqz(b,a)
%Root Locus
fvtool(b,a,'Analysis','polezero')
figure;plot(dataIn,'linewidth',2);hold on;plot(dataOut,'linewidth',2);grid;title('filter response');xlabel('sample');ylabel('data');legend('unfiltered','filtered')
