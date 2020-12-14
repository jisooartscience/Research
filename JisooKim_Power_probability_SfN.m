
% 2019-10-16

% SFN 포스터 만들기 위해 수정함
% Power prbability 그리는 코드임 !!


clc;
clear;
close all;

% 예시 데이터 하나 들고옴
load('E:\JEELAB\EEG\EEG_RECORDING\BBCI\190910\individual\fft2\t2_TD6.mat');
freq_list=f0(1:1024);
time_list=eeg_fft_time(1:3700);


%%

% psd 데이터 불러오기
load('E:\JEELAB\EEG\EEG_RECORDING\BBCI\190910\individual\zscore_2ch\zscore_data.mat');

% all_eeg_modify  : 이거 파워값임!!! 
% 1024 x 3600 x 8 x 4 x 2


dat_mean=mean(all_eeg_modify(:,:,:,:,1),4);
dat_mean2=mean(dat_mean,3);

% dat_mean2=all_eeg_modify(:,:,3,2,1);

dat1= dat_mean2(:,[1:1000]);
dat2= dat_mean2(:,[1230:1800]);

EEG.PSD.f=freq_list;


freq_band= [24 56];
% t_flee=[76 130]; 
% t_flee=[1 100];
% 일단 이거 전체가 tail이긴 하지만 앞뒤 나눠서 살펴보자


% Beta만 걸러내기
f1=find(EEG.PSD.f>=freq_band(1),1);
f2=find(EEG.PSD.f>=freq_band(2),1);


% Amyg.alldata=(abs(squeeze(EEG.PSD.data(:,:,4)))).^2;
% 
% % 시간으로 나눠주기. on일때와 on아닐때로
% Beta.alldata=Amyg.alldata(:,[f1:f2]);
% Beta.on_data=real(Beta.alldata([t_flee(1).*10:t_flee(2).*10-1], :));
% Beta.off_data=real(Beta.alldata([5:t_flee(1).*10-1],:));


Beta.on_data=dat1([f1:f2],:)';
Beta.off_data=dat2([f1:f2],:)';





% 500msec(5개씩) 평균내기

len_on_data=(size(Beta.on_data,1)./5);
len_off_data=(size(Beta.off_data,1)./5);

for on=1:len_on_data;
    Beta.on_5mean(on,:)=mean(Beta.on_data([5*on-4:5*on],:));
end
for off=1:len_off_data;
    Beta.off_5mean(off,:)=mean(Beta.off_data([5*off-4:5*off],:));
end

Beta.on_final=mean(Beta.on_5mean,2);
Beta.off_final=mean(Beta.off_5mean,2);


%%

close all;
set(gcf,'units','normalized','outerposition',[0 0.4 0.3 0.6]); hold off;
set(gca,'fontsize', 24); hold on;
    set(gca,'linewidth',1.5)
    set(gcf,'color','white');

 figure(1);
 
    % [.36 .35 .73] curacao
    % [.36 .48 .58] lake huron
    % [.53 .81 .92] skyblue
    % [.53 .67 .88] blue cow (inner)
    %  [.36 .28 .55] (outer_edge)
    % [.09 .45 .80] dodgerblue3
    
    % [.91 .59 .48] darksalmon
    % [.92 .71 .77] strawberry smoothie
    % [.92 .37 .40] cherry
    
h1=histogram(Beta.on_final,2,'Facecolor', [0.16 0.32 0.75 ],'LineWidth', 1.3, 'FaceAlpha', 0.5, 'EdgeColor',[.09 .45 .80] ); hold on; grid on;
h2=histogram(Beta.off_final,2,'Facecolor',[.91 .59 .48],'LineWidth', 1.3, 'FaceAlpha', 0.8, 'EdgeColor', [.92 .37 .40]); hold on;
h1.Normalization = 'probability';
h1.BinWidth = 0.004;
h2.Normalization = 'probability';
h2.BinWidth = 0.004;
xlim([0.11 0.28]);
set(gca,'Xtick',[0:0.03:0.28])   


% 
% legend(['Fdd']);
% 
% title(['Power Probability of BLA    -' ,...
%     num2str(date) ' trial' num2str(trIdx) '-' mouseNames{mouseName_number} num2str(mIdx)'], 'fontsize', 18);
title(['Power probability of BLA'],'fontsize',32);
xlabel(['Power (a.u)'], 'fontsize', 28);
ylabel(['Probability'], 'fontsize', 28);
legend(' Baseline',' GBO activity');

% legend(['Flee (' num2str(t_flee(1)) '~' num2str(t_flee(2)) 'sec)'], ['tail (0~' num2str(t_flee(1)) 'sec)']);
% xlim([0, 45]);
% ylim([0, 0.3]);

hold on;

%%

% 확률분포 그래프 그리기
figure(1);
hold on;
x_on=Beta.on_final
% pd=fitdist(x_on, 'Normal')
pd=histfit(x_on,20);
m=mean(pd)
x_on_pdf = [0:0.001:1];
y=pdf(pd,x_on_pdf);

line(x_on_pdf,y./130, 'color','r', 'linewidth', 1.5);

hold on;
x_off=Beta.off_final
% pd2=fitdist(x_off, 'Normal')
pd2=histfit(x_off,20);
m2=mean(pd2)
x_off_pdf = [0:0.001:1];
y2=pdf(pd2,x_off_pdf);
line(x_off_pdf,y2, 'color',[0.16 0.32 0.75 ],'linewidth', 1.5);




% 20%구간 계산
X20on=real(icdf(pd,0.2));
Y20on=y(round(X20on*10));
m_Y20on=Y20on-0.003

plot([X20on, X20on],[0, m_Y20on],'k', 'linewidth', 2); hold on;
plot(X20on, m_Y20on,'ko', 'markersize', 5, 'MarkerEdgeColor','k','MarkerFaceColor','r'); hold on;
text(X20on-1,Y20on+0.00 ,['20%'],'fontsize',10,'fontweight','bold');
text(X20on-1,-0.002 ,[ num2str(round(X20on,2))],'fontsize',8,'fontweight', 'normal');

% 10% 구간 계산
X10on=real(icdf(pd,0.1));
Y10on=y(round(X10on*10));
m_Y10on=Y10on-0.002

hold on;
plot([X10on, X10on],[0, m_Y10on],'k', 'linewidth', 2); hold on;
plot(X10on, m_Y10on,'ko', 'markersize', 5, 'MarkerEdgeColor','k','MarkerFaceColor','r'); hold on;
text(X10on-1,Y10on+0.001 ,['10%'],'fontsize',10,'fontweight','bold' );
text(X10on-1,-0.002 ,[ num2str(round(X10on,2))],'fontsize',8,'fontweight','normal');













