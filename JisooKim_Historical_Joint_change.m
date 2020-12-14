
% 이 코드의 목적은
% led_All_data에서
% Historical joint probability 구하는 것임
% 500 msec 기준으로 할것



clc;
clear;
close all;

% 
% load(['D:\EEG\joint_prob\led_all_sigma4.mat']);
load(['E:\JEELAB\EEG\EEG_RECORDING\BBCI\190910\group\led_all_sigma4.mat']);


% mouse 순서 : 3 5 6 9 12 13 19 20
% 바꿀 순서 : 3 19 12 5  . 20 9 6 13 (나름 계층 순서대로 배치해봄)
% 바꿀 순서 : 3 12 5 20 19 9 6 13
% 계층 순서대로 바꿈 @@@

% led_all_data
% 37000 x 8 mice x 4 trials
new_led_data(:,1,:)=led_all_data(:,1,:); % 3
new_led_data(:,2,:)=led_all_data(:,5,:); % 12
new_led_data(:,3,:)=led_all_data(:,2,:); % 5
new_led_data(:,4,:)=led_all_data(:,8,:); % 20
new_led_data(:,5,:)=led_all_data(:,7,:); % 19
new_led_data(:,6,:)=led_all_data(:,4,:); % 9
new_led_data(:,7,:)=led_all_data(:,3,:); % 6
new_led_data(:,8,:)=led_all_data(:,6,:); % 13







%%



dt=10/1024;
led_times=dt:dt:size(new_led_data,1)*dt;

tlist(1,1)=1;
% 0~120 / 120~180/ 180~240 / 240~360
tlist(1,2)=find(led_times>120,1);
tlist(2,1)=find(led_times>120,1);
tlist(2,2)=find(led_times>180,1);
tlist(3,1)=find(led_times>180,1);
tlist(3,2)=find(led_times>240,1);
tlist(4,1)=find(led_times>240,1);
tlist(4,2)=find(led_times>360,1);

% 총 길이 360초 37000개 , 1초에 약 100개
% window size = 10초 / moving window=1초
% 1~1000 / 101~1100 / 201~1200

for k=1:360;
    tlist(k,1)=100*(k-1)+1;
    tlist(k,2)=tlist(k,1)+999;
end

%% step별 led sum값에 대해서 normalization해주는 단계임!!!
% 1) 첫번째 step에 대해서 나눠주고
% 2) 두번째로는 각각의 step길이가 다르므로 이걸 normalization해줌!! (Step2랑 step3은 2배 해주기)

for step=1:360;
    for tr=1:4;
        for m=1:8;
            
         led(step,m,tr)=sum(new_led_data([tlist(step,1):tlist(step,2)],m,tr));
    
        end
    end
end


for tr=1:4;
    for m=1:8;
        for step=1:360;

                norm_led(step,m,tr)=led(step,m,tr)./led(1,m,tr);

        end
    end
end



tr=1;
figure(1);
bar(norm_led(:,:,tr)');  



   
    
    
    
%% Historical joing probability 구하는 부분 !!!

% 먼저 일단은 겹치는 부분 다 구해서 sum한 다음에
% normalization은 그 다음에 하는거로 하자!!
hist_jp=zeros(8,8,4,360);
hist_jp2=zeros(8,8,4,360);
hist_jp3=zeros(8,8,4,360);
hist_jp4=zeros(8,8,4,360);


i_n=50;


for tr=1:4;
    for step=1:360;
        
        for m1=1:8;
          led_index=[];
          data1=new_led_data( [tlist(step,1):tlist(step,2)] ,m1,tr);
          led_index = find(data1==1);
                     
          if find(led_index>i_n,1)>1;
              led_index([1:find(led_index>i_n,1)])=[];
          else
              
          end
          
          led_index(find(led_index<51))=[];
              if length(led_index)>0;

                  for i=1:length(led_index);
                     index=led_index(i);

                     tlim=[index-i_n  index];   
                      for m2=1:8;
                          data2=new_led_data( [tlist(step,1):tlist(step,2)] ,m2,tr);

                          hist_jp(m1,m2,tr,step)= hist_jp(m1,m2,tr,step) + sum(data2(tlim));
                          % 여러 버전으로 시도해보기

                          hist_jp2(9-m1,m2,tr,step)= hist_jp2(9-m1,m2,tr,step) + sum(data2(tlim));

                          % 이거는 mouse3에서 발생한 확률로 나눠준것
                          hist_jp3(9-m1,m2,tr,step)=hist_jp2(9-m1,m2,tr,step)./led(step,m1,tr);

                          % 이거는 mouse3이랑 mouse4로도 나눈것 (normalizaiton)
                           hist_jp4(9-m1,m2,tr,step)=(hist_jp2(9-m1,m2,tr,step)./led(step,m1,tr))./led(step,m2,tr);

                      end

                  end

              elseif length(led_index)==0;
                  hist_jp(m1,m2,tr,step)=0;
                  hist_jp2(9-m1,m2,tr,step)=0;
                  hist_jp3(9-m1,m2,tr,step)=0;
                  hist_jp4(9-m1,m2,tr,step)=0;
                end
              
          end
              
        end
end
%     
%   save(['D:\EEG\joint_prob\norm3\' num2str(i_n) 'ms\hist_jp3'],'hist_jp3');
%   save(['D:\EEG\joint_prob\norm4\' num2str(i_n) 'ms\hist_jp4'],'hist_jp4');
  
  
    %%

% 
%   
%   % hist_jp, hist_jp
%   % 8 x 8 x 4 trial x 4 step
%   
%   close all;
%   for tr=1:4;
%   
%   
%     x=[1:1:8];
% 
%                 figure(2);
%                 set(gcf,'units','normalized','outerposition',[0 0.5 0.95 0.35]); 
% 
%                     for step=1:4;
% 
%                         subplot(1,4,step);
%                         dat=hist_jp3(:,:,tr,step);
%                         norm=3;
%                         if norm==3;
%                             cnum=0.15;
%                         elseif norm==4;
%                             cnum=0.001;
%                         end
%                         
%                         set(gca,'fontsize', 14);
% 
%                         imagesc(x,x,dat);
% 
%                         namesx = {'S'; 'M4'; 'M3'; 'M2'; 'M1';'D3';'D2'; 'D1';};
%                         namesy = {'D1'; 'D2'; 'D3'; 'M1'; 'M2';'M3';'M4'; 'S';};
% 
% %                         title([{['Trial ' num2str(tr) ' step ' num2str(step) ' freq ' num2str(frli(fn))  '-' num2str(frli(fn+1)) 'Hz ' exp_list{exp}]},{[ ch_list{ch} ' - mscoherence']}],'fontsize',20);
% %             %                 title([{['step ' num2str(step) ' freq ' num2str(frli(fn))  '-' num2str(frli(fn+1)) 'Hz ' exp_list{exp}]},{[ ch_list{ch} ' - mscoherence']}],'fontsize',20);
% %                         hold on;
% 
%                         set(gca,'xtick',[1:8],'xticklabel',namesx);
%                         set(gca,'ytick',[1:8],'yticklabel',namesy);
%                         colorbar;
%                         
%                         cmap = colormap(flipud(spring));
%                         caxis([0 cnum]);
%                         title([{['norm' num2str(norm) ' trial', num2str(tr), '  ' , num2str(i_n) ,'ms']},{['step', num2str(step)]}]);
% 
%                     end
%                     
% 
%                 status=mkdir(['D:\EEG\joint_prob\norm' num2str(norm) '\' num2str(i_n) 'ms']);
%                 saveas(gca, ['D:\EEG\joint_prob\norm' num2str(norm) '\' num2str(i_n) 'ms\trial' num2str(tr) ], 'fig');
%                 saveas(gca, ['D:\EEG\joint_prob\norm' num2str(norm) '\' num2str(i_n) 'ms\trial' num2str(tr) ], 'png');   
%                 
%                 
%   end
  

  


%%


  % hist_jp, hist_jp
  % 8 x 8 x 4 trial x 4 step
  
  mean_hist3=mean(hist_jp3,3);
  mean_hist4=mean(hist_jp4,4);


  % m1 이 현재이고
% m2가 과거에 500msec동안 발생한 것들
% m2가 영향을 주는 애고, m1이 영향을 받는 애!!


% 8,1 8,2 8,3 8,4 m1=8 m2

for step=1:360;
for m1=1:8;
        m1_degree(step,m1)=sum(mean_hist3(9-m1,:,step),2)- mean_hist3(9-m1,m1,step);
end
end
    
for step=1:360;
    for m2=1:8;
        m2_degree(step,m2)=sum(mean_hist3(:,m2,step),1)-mean_hist3(9-m2,m2,step);

    end
end


%%
deg_all=m2_degree;

figure(1); 
set(gcf,'color','white');

set(gca,'fontsize', 17); hold on;
set(gca,'linewidth',1.5); hold on;
b=bar(deg_all);
xlim([0.5 4.5]);
somenames={'Step 1','Step 2','Step 3','Step 4'};
set(gca,'xticklabel',somenames)


title(['Weighted degree of 8 mice'],'fontsize',24);
ylabel(['Weighted degree (a.u.)'],'fontsize', 20);
xlabel(['Experimental steps'],'fontsize', 20);

for k=1:8;
b(k).EdgeColor=[1 1 1];
end


% cmap = colormap(cool);
% for k = 1:8;
%     b.CData(k,:) = cmap(5*k,:);
% end

legend({'s','m4','m3','m2','m1','d3','d2','d1'},'fontsize',14);


% %%
% for k=1;
% b(k).FaceColor=[.51 .81 .99]; %surf
% b(k).FaceColor=[.79 .91 .97]; %surf
% 
% end
% 
% for k=2:5;
% b(k).FaceColor=[.48 .66 .87];
% b(k).FaceColor=[.53 .81 .91]; %surf
% 
% end
% 
% for k=6:8;
% b(k).FaceColor=[.27 .70 .88]; %surf
% end
% 

cmap = colormap(flipud(parula));
% spring

grid on;

%%
figure(3);
set(gcf,'color','white');


b2=bar(mean_group)
set(gca,'fontsize', 20); hold on;


somenames={'Step 1','Step 2','Step 3','Step 4'};
set(gca,'xticklabel',somenames)

mean_group(:,1)=deg_all(:,1);
mean_group(:,2)=mean(deg_all(:,[2:5]),2);
mean_group(:,3)=mean(deg_all(:,[6:8]),2);



title([{['Weighted degree according']},{' to social dominance'}],'fontsize',26);
ylabel(['Weighted degree (a.u.)'],'fontsize', 24)
xlabel(['Experimental steps'],'fontsize', 24);

legend({'subordinate','middle','dominant'},'fontsize',16,  'Location', 'eastoutside');


for k=1:3;
b2(k).EdgeColor=[1 1 1];
end


cmap = colormap(flipud(parula));
% spring

hold on;

grid on;

        %%
        


  
    x=[1:1:8];

                figure(4);
                set(gcf,'units','normalized','outerposition',[0 0.5 1 0.39]); 
set(gcf,'color','white');

set(gca,'fontsize', 17); hold on;

                    for step=1:4;

                       ax= subplot(1,4,step);
                  
                        dat=mean_hist3(:,:,step);
                        norm=3;
                        if norm==3;
                            cnum=0.15;
                            cnum=0.13;
                        elseif norm==4;
                            cnum=0.001;
                        end
                        
                        set(gca,'fontsize', 14);

                        imagesc(x,x,dat);

                        namesx = {'S'; 'M4'; 'M3'; 'M2'; 'M1';'D3';'D2'; 'D1';};
                        namesy = {'D1'; 'D2'; 'D3'; 'M1'; 'M2';'M3';'M4'; 'S';};
%                         namesx = {'s'; 'm4'; 'm3'; 'm2'; 'm1';'d3';'d2'; 'd1';};
%                         namesy = {'d1'; 'd2'; 'd3'; 'm1'; 'm2';'m3';'m4'; 's';};

%                         title([{['Trial ' num2str(tr) ' step ' num2str(step) ' freq ' num2str(frli(fn))  '-' num2str(frli(fn+1)) 'Hz ' exp_list{exp}]},{[ ch_list{ch} ' - mscoherence']}],'fontsize',20);
%             %                 title([{['step ' num2str(step) ' freq ' num2str(frli(fn))  '-' num2str(frli(fn+1)) 'Hz ' exp_list{exp}]},{[ ch_list{ch} ' - mscoherence']}],'fontsize',20);
%                         hold on;

                        set(gca,'xtick',[1:8],'xticklabel',namesx);
                        set(gca,'ytick',[1:8],'yticklabel',namesy);
                        colorbar;
%                         colormap hot;
                        
                        cmap = colormap((parula));
                        caxis([0.045 0.1]);
                   
                       
         set(gca,'fontsize', 17); hold on;
%           title([{['norm' num2str(norm) ' trial average - ' num2str(i_n) ,'ms']},{['Step', num2str(step)]}],'fontsize',30);
%           title(['Step ', num2str(step)],'fontsize',28);
set(gca,'linewidth',1.5); hold on;
set(gca,'XTickLabelRotation',45)

                    end
                         c=colorbar;
                    c.Label.String = 'Ratio';
                    hold on;

            saveas(gca, ['D:\EEG\joint_prob\norm' num2str(norm) '\' num2str(i_n) 'ms\trial_average' ], 'fig');
            saveas(gca, ['D:\EEG\joint_prob\norm' num2str(norm) '\' num2str(i_n) 'ms\trial_average' ], 'png');   

  
  



