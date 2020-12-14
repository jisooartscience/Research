function EEG=js_mirror_calibration2(exp_date,folder_name,mName,mousenum, trialnum, option1, option2, value_130);


Amyg=[]; Gamma=[]; data_to_plot=[]; Eta=[]; High=[]; Sigma=[]; pd=[]; EEG=[];

freq_band= [24 56 60 300];

fileName_number=2; 
        
    fileNames={'matfile','interpolation'}
    titleNames={'', 'interpolation'};
    
    
    mouseNames={'TD','C3', 'D2', 'TA1', 'TA3', 'TB1', 'TB3'};
    xscale=[60 300 250 300 30 15];
    yscale=[0.06 0.03 0.02 0.04 0.4 0.62];


    colorscale=[180 50 200 130; 100 60 100 80; 220 40 90 50; 100 60 100 80; 100 60 100 80;];
    chanNames={'HPC','PFC','MDT','BLA'};


    trIdx=trialnum;
    
    fname=[folder_name '\interpolation_A' ];
    textname=['t' num2str(trIdx) '_' mName num2str(mousenum) '.mat' ];
    load( [fname, '\' textname])
    
    cbrain_gamma=A(1,:);
    
    

    fname=[folder_name   '\fft' ];
    textname=['t' num2str(trIdx) '_' mName num2str(mousenum) '.mat' ];
    load( [fname, '\' textname])

EEG.psd.data=eeg_fft_amyg';
EEG.psd.t=eeg_fft_time;
EEG.psd.f=f0;
EEG.times=eeg_time;
    

    
%%

% 특정 freqeuncy band만 걸러내기
f1=find(EEG.psd.f>=freq_band(1),1);
f2=find(EEG.psd.f>=freq_band(2),1);
f3=find(EEG.psd.f>=freq_band(3),1);
f4=find(EEG.psd.f>=freq_band(4),1);


 % psd 돌린것 기준으로 관심대역 / 비관심대역 나누기
Amyg.alldata=abs(squeeze(EEG.psd.data(:,:)));
% 32~52Hz (관심대역)
Gamma.alldata=Amyg.alldata(:,[f1:f2]);
% 60~500Hz (비관심대역)
High.alldata=Amyg.alldata(:,[f3:f4]);



% Gamma frequency대역 부분 평균내기
% 1. 모든 freq에 대한 mean
Gamma.freq_mean=squeeze(mean(Gamma.alldata,2));



% High frequency대역 부분 평균내기
% 1. 모든 freq에 대한 mean
High.freq_mean=squeeze(mean(High.alldata,2));
% 2. 모든 time(10분)에 대한 mean
High.time_mean=squeeze(mean(High.freq_mean));


    
    %%
    
    
    % Normalized Gamma 구하기 = Gamma를 High평균값으로 나누기
    Gamma.norm_data=(Gamma.freq_mean)./(High.time_mean*130);
    
    switch(option1)
        case('highmean')
            Eta.alldata=Gamma.norm_data;
        case('no_highmean')
            Eta.alldata=Gamma.freq_mean;
    end
    
%     %%%%%%%%%%%%% 가운데를 기준으로 mirror data 만들기
    Eta.copy_data=[];
    Eta.copy_data2=[];
    Eta.reverse_data=[];    
    % copy data
    Eta.mean=mean(Eta.alldata);
    Eta.sort_data=sort(Eta.alldata);
    Eta.mean_idx=find(Eta.sort_data>Eta.mean,1);
    
    % 중간 데이터부터 끝까지 데이터 복사해두기
    for k=Eta.mean_idx:length(Eta.alldata);
        Eta.copy_data(k-Eta.mean_idx+1)=Eta.sort_data(k);
    end
    % reverse data 
    Eta.reverse_data=(-Eta.copy_data+Eta.mean*2);
  
    
    % 처음부터 중간 데이터까지 복사하기
    for k=1:Eta.mean_idx-2;
        Eta.copy_data2(k)=Eta.sort_data(k);
    end
    % reverse data2
    Eta.reverse_data2=(-Eta.copy_data2 +Eta.mean*2);
    
    Eta.mirror_data=horzcat(Eta.reverse_data, Eta.copy_data);
    Eta.mirror_data2=horzcat(Eta.reverse_data2, Eta.copy_data2);

    
    
    
    %%%%%%%%%%%%%%%% 몇 퍼센트만큼 자를지 정해주는 부분
    cut_percent=5;
    
    Eta.cut.sortdata=sort(Eta.mirror_data);
    Eta.cut.data_size=length(Eta.cut.sortdata);
    Eta.cut.cut_size=fix (round (Eta.cut.data_size * cut_percent./100)/2);

    % 정해준 퍼센트 벗어나는 outlier 제거하기
    Eta.cut.sortdata([Eta.cut.data_size - Eta.cut.cut_size+1 : Eta.cut.data_size])=[];
    Eta.cut.sortdata([1:Eta.cut.cut_size])=[];
    
    
    %%%%%%%%%%%%%%%% 몇 퍼센트만큼 자를지 정해주는 부분 
    Eta.cut.sortdata2=sort(Eta.mirror_data2);
    Eta.cut.data_size2=length(Eta.cut.sortdata2);
    Eta.cut.cut_size2=fix (round (Eta.cut.data_size2 * cut_percent./100)/2);

    % 정해준 퍼센트 벗어나는 outlier 제거하기
    Eta.cut.sortdata2([Eta.cut.data_size2 - Eta.cut.cut_size2+1 : Eta.cut.data_size2])=[];
    Eta.cut.sortdata2([1:Eta.cut.cut_size2])=[];
    
    

    %
    %%%%%%%%%%%%%% 여기부터는 그래프 히스토그램 plot하는 부분임
    close all;
    set(gca,'fontsize', 14); hold on;    
    
%     value_130=130;


    switch(option2)
        case('no_mirror')
            data_to_plot=(Gamma.freq_mean)*value_130;
        case('mirror')
            data_to_plot=(Eta.cut.sortdata')*value_130;
    end
    
    % 여기는 Normalized value 부분 plot하기
    subplot(1,1,1);
    pd = fitdist(data_to_plot,'Normal')
    x_on_pdf = [0:0.1:10];
    y=pdf(pd,x_on_pdf);
%     line(x_on_pdf,y, 'color','r', 'linewidth', 1.5); 
    hold on;
    
    
    h3=histogram(data_to_plot,50,'Facecolor', 'r'); hold on; grid on;
    h3.Normalization = 'probability';
    h3.BinWidth = 0.03;  %0.05
    title([{['mouse ' mName num2str(mousenum) ' trial' num2str(trIdx) ', average of high-freq : ' num2str(High.time_mean*value_130)]},{['Normalized value of BLA (' fileNames{fileName_number} ')']}], 'fontsize', 18);
    xlabel(['Magnitude (mV)'], 'fontsize', 16);
    ylabel(['Probability'], 'fontsize', 16);
    xlim([0.13 2.3]);
    ylim([0 0.08]);
%     xlim([0 1300]);


    
%     mean_finaldata=mean(mirror_Eta)b
%     std_finaldata=std(mirror_Eta)
    
    ylimit=[0 1800];
    Sigma.s1=real(icdf(pd,0.6826));
    plot([Sigma.s1,Sigma.s1],[0, ylimit(2)],'k--', 'linewidth', 1); hold on;
    
    Sigma.s2=real(icdf(pd,0.9544));
    plot([Sigma.s2,Sigma.s2],[0, ylimit(2)],'r--', 'linewidth', 1); hold on;  
    
    Sigma.s3=real(icdf(pd,0.9973));
    plot([Sigma.s3, Sigma.s3],[0, ylimit(2)],'b--', 'linewidth', 1); hold on;
    
    Sigma.s4=real(icdf(pd,0.999937));
    plot([Sigma.s4, Sigma.s4],[0, ylimit(2)],'g--', 'linewidth', 1); hold on;
    
    Sigma.s5=real(icdf(pd,0.9999994));
    plot([Sigma.s5, Sigma.s5],[0, ylimit(2)],'m--', 'linewidth', 1); hold on;
    
    Sigma.s6=real(icdf(pd,0.999999998));
    plot([Sigma.s6, Sigma.s6],[0, ylimit(2)],'c--', 'linewidth', 1); hold on;
   
%     suptitle(['mouse ' mName num2str(mousenum) ' trial' num2str(trIdx) ', average of high-freq : ' num2str(High.time_mean)]);
%     
    L(1)=plot(nan, nan, 'k-');
    L(2)=plot(nan,nan,'r-');
    L(3)=plot(nan,nan,'b-');
    L(4)=plot(nan,nan,'g-');
    L(5)=plot(nan,nan,'m-');
    L(6)=plot(nan,nan,'c-');
    legend(L,{['1\sigma : ' num2str(round(Sigma.s1,3))] ,['2\sigma : ' num2str(round(Sigma.s2,3))],...
        ['3\sigma : ' num2str(round(Sigma.s3,3))] , ['4\sigma : ' num2str(round(Sigma.s4,3))],...
        ['5\sigma : ' num2str(round(Sigma.s5,3))], ['6\sigma : ' num2str(round(Sigma.s6,3))]});
    
     Sigma.meanHigh=High.time_mean;

     %%

status = mkdir([folder_name '\calibration_' fileNames{fileName_number} '\' mName num2str(mousenum)]);
fname= [folder_name '\calibration_' fileNames{fileName_number} '\' mName num2str(mousenum)];
textname=['t' num2str(trIdx) '_' mName num2str(mousenum)];
saveas(gca, fullfile(fname, textname), 'fig');
saveas(gca, fullfile(fname, textname), 'jpg');
     


% Sigma.meanHigh 값을 저장하기 위한 코드임
        
status = mkdir([folder_name '\calibration']);
fname=[folder_name  '\calibration'];
textname=['Highmean_t' num2str(trIdx) '_' mName num2str(mousenum)];
save(fullfile(fname, textname),'Sigma');
end
    
    
    
    
    
    