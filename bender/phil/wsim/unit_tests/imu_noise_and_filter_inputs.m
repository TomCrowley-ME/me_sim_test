%2nd order butter(2,0.0.60) -3 dB cutoff at 0.60 of sample nyquist frequency (30.0 hz of 50 hz (nyquist of 100 hz sample rate)

imh_accel_response_num=1;
imh_accel_response_den=1;

imh_gyro_response_num=1;
imh_gyro_response_den=1;

imh_accel_response_num=[0.391335772501769         0.782671545003537         0.391335772501769]; 
imh_accel_response_den=[1         0.369527377351241         0.195815712655833];

imh_gyro_response_num=[0.391335772501769         0.782671545003537         0.391335772501769];
imh_gyro_response_den=[1         0.369527377351241         0.195815712655833];

mhn_gyro_noise_spec = 0.15; %deg/sqrt(sec), STIM-300
mhn_gyro_bias_spec =  250; %deg/hr STIM-300
mhn_accel_noise_spec = 6100e-6;  % 30 microG/sqrt(hz) STIM-300
mhn_accel_bias_spec =  0.18/9.8; % 0.49 m/s/hour STIM-300

mhn_gyro_noise_sigma = (mhn_gyro_noise_spec*pi/180) / sqrt(mhn_dt);

mhn_gyro_bias_noise_source = sqrt(2/(mhn_dt* mhn_correlation_time)) * (mhn_gyro_bias_spec*(pi/180)/3600) ;

mhn_acel_noise_sigma = (mhn_accel_noise_spec*9.8) / sqrt(mhn_dt);

mhn_accel_bias_noise_source = sqrt(2/(mhn_dt*mhn_correlation_time)) * (mhn_accel_bias_spec*9.8/3600);


mhn_accel_noise_v = mhn_acel_noise_sigma*[1 1 1 1 1 1 1 1]; 
mhn_gyro_noise_v = mhn_gyro_noise_sigma*[1 1 1];  

mhn_accel_bias_noise_v = mhn_accel_bias_noise_source*[1 1 1 1 1 1 1 1]; 
mhn_gyro_bias_noise_v  = mhn_gyro_bias_noise_source*[1 1 1];
