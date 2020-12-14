# -*- coding: utf-8 -*-
"""
Created on Mon Aug 19 03:42:35 2019

@author: jisoo

fft function

"""

import matplotlib.pyplot as plt
import numpy as np
import math
import scipy.io
import os
import pandas as pd

def createFolder(directory):
    try:
        if not os.path.exists(directory):
            os.makedirs(directory)
    except OSError:
        print ('Error: Creating directory. ' +  directory)
 




exp_date=200722

mouseNames=['A','B','C','D','TB','TD','MM']
mouseName_number=6

expNames=['single', 'group']
expNames_number=1


folder_name="E:/JEELAB/EEG/EEG_RECORDING/BBCI/" + str(exp_date) + '_' + expNames[expNames_number]

for p in range (0,8): # mouse list number (0,8)
    
   # mouse_list=np.array([3, 5, 6, 9, 12, 13, 18, 19, 20])
    # mouse_list=np.array([3, 9, 12, 13])
  #  mouse_list=np.array([3, 6, 18, 19, 20])
    #mouse_list=np.array([3, 5, 6, 9, 12, 13, 19, 20])
    mouse_list=np.array([1,2,3,4,5,6,7,8])

    mousenum=mouse_list[p]
 
    
    for trialnum in range (1,5):   # trial number (1,5)

            print('FFT calculating ' + str(exp_date) + ' ' +\
                  mouseNames[mouseName_number-1] + ' ' + str(mousenum)\
                  + ' trial' + str(trialnum))
  

# + '/' + expNames[expNames_number]
        
        
        
            mat = scipy.io.loadmat(folder_name  + '/interpolation_A/t'\
                                   + str(trialnum) + '_' + mouseNames[mouseName_number-1]\
                                   + str(mousenum) + '.mat')
            all_data=mat['A']
            
            
            for chanIdx in range (0,1):
                print(chanIdx)
                #chanIdx=2 # BE careful!!!!!
                
                win_size=256
                srate=1024
                freq_cut=srate//2
                dt=1/srate
                mov_size=10
                
                hann=np.hanning(win_size)
                eeg_data=all_data[chanIdx,:]
                
                
                D_len=((len(eeg_data)-256)//mov_size)
                
                
                dtt=dt*10
                eeg_time=np.arange(0,len(eeg_data))*dt
                eeg_fft_time=np.arange(0,D_len)*dtt
                
                eeg_fft=np.zeros((int(win_size/2), D_len))
                #eeg_fft_pfc=np.zeros((int(win_size/2), D_len))
                eeg_fft_amyg=np.zeros((int(win_size/2), D_len))
                
                for kk in range(0,D_len):
                
                    if kk==(D_len//10):
                        print('10% complete')
                    elif kk==(D_len//2):
                        print('50% complete')
                    
                    
                    winsize_data=eeg_data[mov_size*kk : mov_size*kk+256]
                    hann_data=hann*winsize_data
                    
                    NFFT= win_size # length of signal
                    k=np.arange(NFFT)
                    f0=k*srate/NFFT    # single sied frequency range
                    f0=f0[range(math.trunc(NFFT))] # single sied frequency range
                    
                    Y=np.fft.fft(hann_data)/NFFT   # fft computing and normaliation
                    Y=Y[range(math.trunc(NFFT/2))] 
                    amplitude_Hz = 2*abs(Y)
                    phase_ang = np.angle(Y)*180/np.pi
                    
                    eeg_fft[:,kk]=amplitude_Hz
                    
                    
                    if chanIdx==1:
                        eeg_fft_pfc=eeg_fft
                    elif chanIdx==0:
                        eeg_fft_amyg=eeg_fft
                
            print(' Complete ! ')   
            
            #  '/' + expNames[expNames_number] + 
            
   
            folder = folder_name + '/fft'
            createFolder(folder)
                            
                            #  '/' + expNames[expNames_number] 
            
            from scipy import io
            data={'eeg_fft_amyg':eeg_fft_amyg, 'eeg_fft_time':eeg_fft_time, 'f0':f0, 'eeg_time' : eeg_time }
            io.savemat(folder_name + '/fft/t' \
                       + str(trialnum) + '_' + mouseNames[mouseName_number-1]\
                       + str(mousenum) + '.mat',data)
            
            

            
           
        
        
print('FINISH')
    



"""

# specific frequency
freq_band=np.array([24, 56, 60, 300])

f1=np.where(f0>=freq_band[0])
f2=np.where(f0>=freq_band[1])
f3=np.where(f0>=freq_band[2])
f4=np.where(f0>=freq_band[3])

f1_v=f1[0][0]
f2_v=f2[0][0]
f3_v=f3[0][0]
f4_v=f4[0][0]



# cut fft data as interested frequency band
Gamma_data=eeg_fft[f1_v:f2_v,:]
High_data=eeg_fft[f3_v:f4_v,:]

Gamma_mean_data=Gamma_data.mean(axis=0)
High_all_mean=High_data.mean()

plt.plot(eeg_fft_time, Gamma_mean_data)
plt.plot(eeg_time, all_data[3,:])




"""






