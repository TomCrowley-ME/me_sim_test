%2nd order butter(2,0.0.60) -3 dB cutoff at 0.60 of sample nyquist frequency (30.0 hz of 50 hz (nyquist of 100 hz sample rate)

sample_test_time = 1/2000;

imh_accel_response_num=[0.391335772501769         0.782671545003537         0.391335772501769]; 
imh_accel_response_den=[1         0.369527377351241         0.195815712655833];

imh_gyro_response_num=[0.391335772501769         0.782671545003537         0.391335772501769];
imh_gyro_response_den=[1         0.369527377351241         0.195815712655833];

imh_accel_response_num=1;
imh_accel_response_den=1;

imh_gyro_response_num=1;
imh_gyro_response_den=1;

    mhn_gyro_noise_spec = 0.03; %deg/sqrt(sec), SDI500
    mhn_gyro_noise_spec = 0.5*(30e-3); %deg/sqrt(sec), MIRU 
    mhn_gyro_noise_spec = 0.15/60; %deg/sqrt(sec), STIM-300 0.15 deg/sqrt(hr)

    mhn_gyro_bias_spec =  10; %deg/hr SDI500
    mhn_gyro_bias_spec =  4; %deg/hr MIRU
    mhn_gyro_bias_spec =  0.5; %deg/hr STIM-300
    
    mhn_accel_noise_spec = 200e-6;  % g/sqrt(hz) SDI500
    mhn_accel_noise_spec = 30e-6;  % g/sqrt(hz) MIRU
    mhn_accel_noise_spec = (0.07/3600)/9.8;  % g/sqrt(hz) STIM-300

    mhn_accel_bias_spec =  0.36/9.8; % 0.36 m/s/hour SDI500
    mhn_accel_bias_spec =  0.7/9.8; % 0.7 m/s/hour MIRU
    mhn_accel_bias_spec =  0.05e-3*9.8; % 0.05 (mg over hour)  m/s/hour STIM-300

mhn_gyro_noise_sigma = (mhn_gyro_noise_spec*pi/180) / sqrt(mhn_dt);

mhn_gyro_bias_noise_source = sqrt(2/(mhn_dt* mhn_correlation_time)) * (mhn_gyro_bias_spec*(pi/180)/3600) ;

mhn_acel_noise_sigma = (mhn_accel_noise_spec*9.8) / sqrt(mhn_dt);

mhn_accel_bias_noise_source = sqrt(2/(mhn_dt*mhn_correlation_time)) * (mhn_accel_bias_spec*9.8/3600);


mhn_accel_noise_v = mhn_acel_noise_sigma*[1 1 1 1 1 1 1 1]; 
mhn_gyro_noise_v = mhn_gyro_noise_sigma*[1 1 1]  

mhn_accel_bias_noise_v = mhn_accel_bias_noise_source*[1 1 1 1 1 1 1 1] 
mhn_gyro_bias_noise_v  = mhn_gyro_bias_noise_source*[1 1 1];
