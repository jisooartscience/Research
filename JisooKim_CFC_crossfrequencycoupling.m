clc;
clear;
close all;



exp_list={'individual', 'group'};
exp_date=190910;
for exp=1:2;

comodulograms_mice=zeros(63,39,2,8);

for tr=1:4;
    disp(['trial ' num2str(tr)]);
    
    
    for n=1:8;
    num_list=[3 5 6 9 12 13 19 20];

    disp(['mouse ' num2str(num_list(n))]);


    load(['E:\JEELAB\EEG\EEG_RECORDING\BBCI\' num2str(exp_date) '\' exp_list{exp} '\interpolation_A\t'  num2str(tr) '_TD' num2str(num_list(n)) '.mat']);



    dt=1/1024;
    EEG.times=dt:dt:dt*370000;

    step_t(1,1)=1;
    step_t(1,2)=find(EEG.times>120,1);

    step_t(2,1)=find(EEG.times>120,1);
    step_t(2,2)=find(EEG.times>180,1);

    step_t(3,1)=find(EEG.times>180,1);
    step_t(3,2)=find(EEG.times>240,1);

    step_t(4,1)=find(EEG.times>240,1);
    step_t(4,2)=370000;


    for step=1:4;
            disp(['step ' num2str(step)]);


            st=step_t(step,1);
            et=step_t(step,2);


            EEG.data=[];

            EEG.data(1,:)=A(2,[st:et]); % BLA
            EEG.data(2,:)=A(3,[st:et]); % PFC



            %% CFC
            % channel select
            comodulograms = [];
            warning off;
            for ch=1:2

                % time
                startt= 1; % start time (sec)
                endt= size(EEG.data,2)./1024; % end time (sec)
                fs=1024;

                lfp=EEG.data(ch, startt*fs:endt*fs-1);

                data_length=length(startt*fs:endt*fs-1);

                % Define the Amplitude- and Phase- Frequencies
                PhaseFreqVector=1:0.5:32;
                AmpFreqVector=10:5:200;
                PhaseFreq_BandWidth=1;
                AmpFreq_BandWidth=5;

                % For comodulation calculation (only has to be calculated once)
                nbin = 30;
                position=zeros(1,nbin); % this variable will get the beginning (not the center) of each phase bin (in rads)
                winsize = 2*pi/nbin;
                for j=1:nbin
                    position(j) = -pi+(j-1)*winsize;
                end

                % Do filtering and Hilbert transform on CPU
                clear Comodulogram AmpFreqTransformed PhaseFreqTransformed
                tic
                Comodulogram=single(zeros(length(PhaseFreqVector),length(AmpFreqVector)));
                AmpFreqTransformed = zeros(length(AmpFreqVector), data_length);
                PhaseFreqTransformed = zeros(length(PhaseFreqVector), data_length);

                for ii=1:length(AmpFreqVector)
                    Af1 = AmpFreqVector(ii);
                    Af2=Af1+AmpFreq_BandWidth;
            %         AmpFreq=eegfilt(lfp,fs,Af1,Af2); % just filtering
                    AmpFreq=zerofilt(lfp, Af1, Af2, fs);
                    AmpFreqTransformed(ii, :) = abs(hilbert(AmpFreq)); % getting the amplitude envelope
                end

                for jj=1:length(PhaseFreqVector)
                    Pf1 = PhaseFreqVector(jj);
                    Pf2 = Pf1 + PhaseFreq_BandWidth;
            %          PhaseFreq=eegfilt(lfp,fs,Pf1,Pf2); % this is just filtering
                    PhaseFreq=zerofilt(lfp,Pf1,Pf2,fs);
                    PhaseFreqTransformed(jj, :) = angle(hilbert(PhaseFreq)); % this is getting the phase time series
                end
                toc

                % Do comodulation calculation
                tic
                counter1=0;
                    for ii=1:length(PhaseFreqVector)
                        counter1=counter1+1;

                        Pf1 = PhaseFreqVector(ii);
                        Pf2 = Pf1+PhaseFreq_BandWidth;

                        counter2=0;
                        for jj=1:length(AmpFreqVector)
                            counter2=counter2+1;

                            Af1 = AmpFreqVector(jj);
                            Af2 = Af1+AmpFreq_BandWidth;
                            [MI,MeanAmp]=ModIndex_v2(PhaseFreqTransformed(ii, :), AmpFreqTransformed(jj, :), position);

                            comodulogram(counter1,counter2)=MI; %

                        end
                    end

                toc

                comodulograms(:,:,ch) = comodulogram;

            end

            comodulograms_mice(:,:,:,step)=comodulograms;

    end


     comodulograms_mice2(:,:,:,:,n)=comodulograms_mice;
     
    end

    comodulograms_mice3(:,:,:,:,:,tr)=comodulograms_mice2;
end

    comodulograms_mice4(:,:,:,:,:,:,exp)=comodulograms_mice3;

end

save('temp_comodulogram.mat', 'comodulograms', 'PhaseFreqVector', 'AmpFreqVector','comodulograms_mice4');


%% Plot

ch_list={'BLA', 'PFC'};

% comodulogrmas_mice_step
% 63 x 39 x 2 (ch) x 8 (mouse) x 4 (step) x 4 (trial) x 2 (exp)


for exp=1;
    comodulograms_mice_step2=comodulograms_mice_step(:,:,:,:,:,:,exp);
for step=4;

% 1, 2, ch(2) , mice(8), step(4), tr(4)
mean_comod= squeeze(mean(comodulograms_mice_step2,4));  % 8마리에 대한 mean
mean_comod2= squeeze(mean(mean_comod, 5));  % 4번 trial에 대한 mean

figure(12); set(gcf, 'Color', [1 1 1]);
set(gcf,'units','normalized','outerposition',[0 0.5 0.4 0.4]); hold off;    
for ch = 1:2;
    subplot(1,2,ch); hold off; 
%     comodulogram = comodulograms(:,:,ch);
    
    comodulogram=squeeze(mean_comod2(:,:,ch,step));
    %imagesc(PhaseFreqVector,AmpFreqVector,imgaussfilt(comodulogram',1) );% ,30,'lines','none')
    imagesc(PhaseFreqVector,AmpFreqVector,...
        imgaussfilt( imresize(comodulogram',4), 1) );% ,30,'lines','none')
    axis xy;
    ylim([10 150]);
    xlim([3.5 10.5]);
    caxis([0 0.000005]);
    colormap jet; cb=colorbar; ylabel(cb, 'MI (a.u.)');
    climvalue = caxis; caxis( [0 climvalue(2)])
    title([ { [ exp_list{exp} ' condition - step ' num2str(step) ] }, { ['Comodulogram (' ch_list{ch} ')' ] } ], 'FontSize',16);
    set(gca,'fontsize',14, 'LineWidth', 2, 'Box', 'off'); 
    xlabel('Phase Freq (Hz)', 'FontSize',14); 
    ylabel('Amptd Freq (Hz)', 'FontSize',14);
    
end

    
 status = mkdir(['E:\JEELAB\EEG\EEG_RESULT\BBCI\' num2str(exp_date) '\' exp_list{exp} '\CFC' ]);
fname=['E:\JEELAB\EEG\EEG_RESULT\BBCI\' num2str(exp_date) '\' exp_list{exp} '\CFC' ];
textname=[ 'step ' num2str(step) '_ch' num2str(ch)];
saveas(gca, fullfile(fname, textname), 'fig');
saveas(gca, fullfile(fname, textname), 'png');   
    
 
end
end





