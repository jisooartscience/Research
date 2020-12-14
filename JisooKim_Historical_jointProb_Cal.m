

%2019-12-02
%Jisoo Kim

clc;
clear;
close all;


load('F:\CBRAIN\EEG_ANALYSIS\MATLAB\2019_Nature_method\historical\led_data_stage.mat');
% led_data_stage
% 4 stages x 6144 times (60 s) x 8 mice x 4 trials
% time 간격 : 10/1024 s


% mouse 순서 : 3 5 6 9 12 13 19 20
% 바꿀 순서 : 3 19 12 5  . 20 9 6 13 (나름 계층 순서대로 배치해봄)
% 바꿀 순서 : 3 12 5 20 19 9 6 13
% 계층 순서대로 바꿈 @@@


new_led_data(:,:,1,:)=led_data_stage(:,:,1,:); % 3
new_led_data(:,:,2,:)=led_data_stage(:,:,5,:); % 12
new_led_data(:,:,3,:)=led_data_stage(:,:,2,:); % 5
new_led_data(:,:,4,:)=led_data_stage(:,:,8,:); % 20
new_led_data(:,:,5,:)=led_data_stage(:,:,7,:); % 19
new_led_data(:,:,6,:)=led_data_stage(:,:,4,:); % 9
new_led_data(:,:,7,:)=led_data_stage(:,:,3,:); % 6
new_led_data(:,:,8,:)=led_data_stage(:,:,6,:); % 13


%% step별 led sum값에 대해서 normalization해주는 단계임!!!
% 1) 첫번째 step에 대해서 나눠주고

% 4step, 8 mice, 4trial
led(:,:,:)=sum(new_led_data,2);


for tr=1:4;
    for m=1:8;
        for step=1:4;
                norm_led(step,m,tr)=led(step,m,tr)./led(1,m,tr);
        end
    end
end




for tr=1:4;
figure(1);
subplot(4,1,tr);
bar(norm_led(:,:,tr)');  
end


%% Historical joing probability 구하는 부분 !!!


hist_jp=zeros(8,8,4,4);
hist_jp2=zeros(8,8,4,4);
hist_jp3=zeros(8,8,4,4);
hist_jp4=zeros(8,8,4,4);


i_n=50;
% 50이면 500msec 정도라는 것임


for tr=1:4;
    for step=1:4;
        
        for m1=1:8;
          led_index=[];
          data1=squeeze(new_led_data(step ,:,m1,tr));
          led_index = find(data1==1);
                     
          if find(led_index>i_n,1)>1;
              led_index([1:find(led_index>i_n,1)])=[];
          else
              
          end
          
          for i=1:length(led_index);
             index=led_index(i);
             
             tlim=[index-i_n  index];   
              for m2=1:8;
                  data2=squeeze(new_led_data( step,: ,m2,tr));
                  
                  hist_jp(m1,m2,tr,step)= hist_jp(m1,m2,tr,step) + sum(data2(tlim));
                  
                  hist_jp2(9-m1,m2,tr,step)= hist_jp2(9-m1,m2,tr,step) + sum(data2(tlim));
                  
                  % 이거는 mouse3에서 발생한 확률로 나눠준것
                  hist_jp3(9-m1,m2,tr,step)=hist_jp2(9-m1,m2,tr,step)./led(step,m1,tr);
                  
                  % 이거는 mouse3이랑 mouse4로도 나눈것 (normalizaiton)
                   hist_jp4(9-m1,m2,tr,step)=(hist_jp2(9-m1,m2,tr,step)./led(step,m1,tr))./led(step,m2,tr);
                  
              end
              
          end
              
          end
              
        end
end


%%



  % hist_jp, hist_jp
  % 8 x 8 x 4 trial x 4 step
  mean_hist3=mean(hist_jp3,3);
  
  % m1 이 현재이고
% m2가 과거에 500msec동안 발생한 것들
% m2가 영향을 주는 애고, m1이 영향을 받는 애!!


for step=1:4;
    for m2=1:8;
        m2_degree(step,m2)=sum(mean_hist3(:,m2,step),1)-mean_hist3(9-m2,m2,step);

    end
end
deg_all=m2_degree;



save('F:\CBRAIN\data\historical\deg_all.mat','deg_all');
save('F:\CBRAIN\data\historical\hist_jp3.mat','hist_jp3');









