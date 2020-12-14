A=readtable('D:\JEELAB\EEG\EEG_RECORDING\BBCI\180529\t7_F11.txt','HeaderLines',1,'Delimiter','\t')
behaviort7= xlsread('D:\JEELAB\EEG\EEG_RECORDING\BBCI\180529\behavior_t7',1)
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

% ������� wavelet�� ���� data format
Signal = EEG.data(1,:)';        % data 
TimeScale = EEG.times;      % time 
N = duration;      % length of data
Fs = EEG.srate;            % sampling rate
minfreq = 1;        % min freq of analysis 
maxfreq = 100;       % max freq of analysis
t=EEG.times

% parameters for wavelet transform 
dt = 1/Fs;        
NumVoices = 32;
a0 = 2^(1/NumVoices);
wavCenterFreq = 5/(2*pi);  %bump center freq
minscale = wavCenterFreq/(maxfreq*dt);
maxscale = wavCenterFreq/(minfreq*dt);
minscale = floor(NumVoices*log2(minscale));
maxscale = ceil(NumVoices*log2(maxscale));
scales = a0.^(minscale:maxscale).*dt;

cwtSignal = cwtft({Signal,dt},'wavelet','morl','scales',scales);
cwtSignal.frequencies = scal2frq(cwtSignal.scales, 'morl');    %  only morl & mexh work 




%% wavelet draw spectrogram 
[x,y]=meshgrid(TimeScale,cwtSignal.frequencies);
z=abs(cwtSignal.cfs);

close all; 
subplot(9, 9, 1:54); 
surf(x,y,z); 
colormap jet;
caxis([ 300 500] );
shading interp
view(0,90); 
% imagesc(x,y,z); 
% hcb=colorbar;
% title(hcb,'Magnitude')
ylabel('Freq (Hz)', 'fontsize',14) ; % y-axis label
% xlabel('Time (sec)','fontsize',14); % x-axis label
title(['Magnitude Scalogram - HPC'], 'fontsize', 16);
set(gca,'XTick',[0:5:600]); ylim([0 50]);


%% find power of specific frequency
% ������ frequency�� ���� power���� ã����
freq_data=[];
for sf=1:100;
    index= find(cwtSignal.frequencies> sf & cwtSignal.frequencies <sf+2);
    freq_data(sf,:)=mean(z(index,:));
end

%% wavelet���� ���� �����ͷ� behavior �м��ϱ�
% ������ �޺κ� �ڸ���
freq_data=freq_data(:,[1:43000]);

% �ൿ���� ������ ������ �����ֱ�
corravrg=[]; %25������ �ൿ��

modified_bhv=[]; %�ð��� 0.5�� �������� 500�� ������ (������ ������ ���߱�����)
for mb=1:86;
    for mb2=[(mb-1)*500+1:mb*500];
        modified_bhv(mb2,:)=behaviort7(mb,:);
    end
end

%% Behavior spectrogram
% Ư���ൿ�� ���ؼ�! frequency�� ���� power�� ��ȭ �׷����� �׷�����

bIdx=4; % �� �м����� behavior �����ֱ�

s_bhv=modified_bhv(:,bIdx);
corr_all=[];

tfactor=[1:43000];
for tIdx=tfactor;
    corr_all(:,tIdx)=freq_data(:,tIdx).* s_bhv(tIdx,1)';
end

corr_sum=sum(corr_all,2);

figure(3);
plot(corr_sum); hold on; xlabel('Frequency(Hz)')


% %% Power change with Diverse Behaviors
% 
% corr_all2=[];
% for fIdx=1:100;
%     for bIdx=1:25;
%         corr_all2(:,tIdx,bIdx)=modified_bhv(:,bIdx).*freq_data(fIdx,:)';
%     end
% end


%% Opposite Behavior spectogram
% Ư���ൿ�� ���� ������ frequency�� ���� power�� ��ȭ �׸���
s_bhv(s_bhv==0)=9;
s_bhv(s_bhv==1)=0;
s_bhv(s_bhv==9)=1;
o_bhv=s_bhv;
s_bhv=modified_bhv(:,bIdx);   % behavior ������� ��������

tfactor=[1:43000];
for tIdx=tfactor;
    corr_all_oposite(:,tIdx)=freq_data(:,tIdx).* o_bhv(tIdx,1)';
end

corr_sum_opposite=sum(corr_all_oposite,2);

figure(3);
plot(corr_sum,'b'); hold on;
plot(corr_sum_opposite, 'r'); legend('Attached','Detached'); hold on; 
xlim([1 40]);
xlabel('Freq (Hz)', 'fontsize',14);
ylabel('Voltage (\muV)','fontsize',14);





