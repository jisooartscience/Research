A=readtable('C:\Users\jisoo\Desktop\USB_Path\HDD_4TB\JEELAB\EEG\EEG_RECORDING\BBCI\180529\t7_G12.txt','HeaderLines',1,'Delimiter','\t')
MyArray=table2array(A);
EEG.data=MyArray.';
EEG.data=EEG.data*5000/32767
addpath hb_sptools
chanList = 1:4;

%% making data format
for chanIdx = chanList
    EEG.srate=1000;
    numberofdata=numel(EEG.data)/4 -1 ;
    duration = numberofdata/1000 ;
    EEG.times=0:1/EEG.srate:duration;
end

%% EEG Raw
figure(20);
for chanIdx = chanList
    subplot( 4, 1, chanIdx); hold off;
    plot( EEG.times, EEG.data( chanIdx, : ), 'k' )
    xlim([ EEG.times(1), EEG.times(end)] );
end

%% Smoothing
figure(22);
for chanIdx = chanList
    subplot( 1, 4, chanIdx); hold off;
    
    x = EEG.data( chanIdx, : );
    plotOption = false;
    [y_fft,x_fft] = positiveFFT( x, EEG.srate, plotOption );
    y_fft_real = abs( real( y_fft ) );
    
    smooth_N = 100;
    
    plot( x_fft, smooth( y_fft_real, smooth_N) ) ;
    xlim([0 150]);
end



%% PSD calculation

% Spectrogram
calc_option = 'cPSD';
chan_list = 1:4;
win_size = 1024*2;
t_resolution = 0.5;


EEG=hb_spectrogram( EEG, calc_option, chan_list, win_size, t_resolution );


%% plot beta average

figure(20);
freq_band=[40:56]; %beta(19 26)= [40 56],  %theta(6 10) = [14 23]
dat_pwr=abs( EEG.PSD.data( :, :, 4))' .^2;
dat_pwr_freq=dat_pwr(freq_band, :);
dat_avrg1= mean(dat_pwr_freq)

subplot(3,1,1); plot(EEG.PSD.t, dat_avrg1);
title(['time trace of Beta(19~26Hz)']); xlabel('Time(sec)'); ylabel('Power')


figure(20);
freq_band=[14:23]; %beta(19 26)= [40 56],  %theta(6 10) = [14 23]
dat_pwr=abs( EEG.PSD.data( :, :, 4))' .^2;
dat_pwr_freq=dat_pwr(freq_band, :);
dat_avrg2= mean(dat_pwr_freq)

subplot(3,1,2); plot(EEG.PSD.t, dat_avrg2);
title(['time trace of Theta(6~10Hz)']); xlabel('Time(sec)'); ylabel('Power')


figure(20);
dat_division=dat_avrg1./dat_avrg2
subplot(3,1,3); plot(EEG.PSD.t, dat_division);
title(['Beta/Theta']); xlabel('Time(sec)'); ylabel('Ratio')


% %time_10sec_average
% 
% figure(30);
% t_incr=10
% dat_timeavrg=[];
% t_factor=1:100;
% 
% for tIdx = t_factor;
%     t_window = (t_incr*(tIdx-1)+1 : t_incr*tIdx );
%     new_time(1,tIdx)=(EEG.PSD.t(tIdx*t_incr));
%     dat_timeavrg(1,tIdx)=mean(dat_avrg(t_incr*(tIdx-1)+1:t_incr*tIdx));
%     plot(new_time, dat_timeavrg);
%     
% end


% 
% %% moving
% 
% t_incr=1;
% t_factor=1:1000;
% x_limt=[0 450]; y_limt=[0 1000];
% 
% for tIdx=t_factor;
%     show_window = [1:100];
% end






