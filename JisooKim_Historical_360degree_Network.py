# -*- coding: utf-8 -*-
"""
Created on Fri Nov  8 00:41:37 2019

@author: jisoo
"""

import numpy as np
from scipy import stats
import seaborn as sns


import matplotlib.pyplot as plt
import scipy.io
import networkx as nx
import os
import wntr

exp_date=190910
expNames=['individual', 'group']
expNames_number=1
exp=1

mat= scipy.io.loadmat("E:/JEELAB/EEG/EEG_ANALYSIS/MATLAB/js_BBCI/2019_SFN/codes/joint_prob/norm3/50ms/hist_jp3_360.mat")
coherence=mat['hist_jp3']


mat= scipy.io.loadmat("E:/JEELAB/EEG/EEG_ANALYSIS/MATLAB/js_BBCI/2019_SFN/codes/joint_prob/norm3/50ms/deg_all_360.mat")
deg_all=mat['deg_all']

def createFolder(directory):
    try:
        if not os.path.exists(directory):
            os.makedirs(directory)
    except OSError:
        print ('Error: Creating directory. ' +  directory)
 
dt=10/1024
time_list=np.arange(0,37000)*dt
 # % hist_jp, hist_jp
 # % 8 x 8 x 4 trial x 4 step
 
 

 # % hist_jp, hist_jp
 # % 8 x 8 x 4 trial x 360 step

#fig.clear()
for tr in range (0,4):
        
    for step in range (0,1): # (0,360)
        
        coherence6=coherence[:,:,tr,step]*500
        # each trials
        """
        coherence2=coherence.mean(axis=2)
        coherence6=coherence2[:,:,step]*700
        """
        
    
    #    G = nx.MultiGraph() #Create a graph object called G
        # G=wntr.network.graph.WntrMultiDiGraph()
        #G=nx.MultiDiGraph()
        # G = nx.MultiGraph()
        G=wntr.network.graph.WntrMultiDiGraph()
        node_list = ['S','M4','M3','M2','M1','D3','D2','D1']
        
              
        G.add_edge('S','M4',weight=coherence6[6,0]) #Karpov vs Kasparov
        G.add_edge('S','M3',weight=coherence6[5,0]) #Karpov vs Kramnik
        G.add_edge('S','M2',weight=coherence6[4,0]) #Karpov vs Anand
        G.add_edge('S','M1',weight=coherence6[3,0]) #Karpov vs Kasparov
        G.add_edge('S','D3',weight=coherence6[2,0]) #Karpov vs Kramnik
        G.add_edge('S','D2',weight=coherence6[1,0]) #Karpov vs Anand
        G.add_edge('S','D1',weight=coherence6[0,0]) #Karpov vs Kasparov
        
        
        G.add_edge('M4','S',weight=coherence6[7,1]) #Karpov vs Kramnik
        G.add_edge('M4','M3',weight=coherence6[5,1]) #Karpov vs Kramnik
        G.add_edge('M4','M2',weight=coherence6[4,1]) #Karpov vs Anand
        G.add_edge('M4','M1',weight=coherence6[3,1]) #Karpov vs Kasparov
        G.add_edge('M4','D3',weight=coherence6[2,1]) #Karpov vs Kramnik
        G.add_edge('M4','D2',weight=coherence6[1,1]) #Karpov vs Anand
        G.add_edge('M4','D1',weight=coherence6[0,1]) #Karpov vs Kasparov
        
        
        G.add_edge('M3','S',weight=coherence6[7,2]) #Karpov vs Anand
        G.add_edge('M3','M4',weight=coherence6[6,2]) #Karpov vs Anand
        G.add_edge('M3','M2',weight=coherence6[4,2]) #Karpov vs Anand
        G.add_edge('M3','M1',weight=coherence6[3,2]) #Karpov vs Kasparov
        G.add_edge('M3','D3',weight=coherence6[2,2]) #Karpov vs Kramnik
        G.add_edge('M3','D2',weight=coherence6[1,2]) #Karpov vs Anand
        G.add_edge('M3','D1',weight=coherence6[0,2]) #Karpov vs Kasparov
        
        
        G.add_edge('M2','S',weight=coherence6[7,3]) #Karpov vs Anand
        G.add_edge('M2','M4',weight=coherence6[6,3]) #Karpov vs Anand
        G.add_edge('M2','M3',weight=coherence6[5,3]) #Karpov vs Anand
        G.add_edge('M2','M1',weight=coherence6[3,3]) #Karpov vs Kasparov
        G.add_edge('M2','D3',weight=coherence6[2,3]) #Karpov vs Kramnik
        G.add_edge('M2','D2',weight=coherence6[1,3]) #Karpov vs Anand
        G.add_edge('M2','D1',weight=coherence6[0,3]) #Karpov vs Kasparov
       
        G.add_edge('M1','S',weight=coherence6[7,4]) #Karpov vs Kasparov
        G.add_edge('M1','M4',weight=coherence6[6,4]) #Karpov vs Kramnik
        G.add_edge('M1','M3',weight=coherence6[5,4]) #Karpov vs Anand
        G.add_edge('M1','M2',weight=coherence6[4,4]) #Karpov vs Kasparov
        G.add_edge('M1','D3',weight=coherence6[2,4]) #Karpov vs Kramnik
        G.add_edge('M1','D2',weight=coherence6[1,4]) #Karpov vs Anand
        G.add_edge('M1','D1',weight=coherence6[0,4]) #Karpov vs Kasparov
        
        
        G.add_edge('D3','S',weight=coherence6[7,5]) #Karpov vs Kasparov
        G.add_edge('D3','M4',weight=coherence6[6,5]) #Karpov vs Anand
        G.add_edge('D3','M3',weight=coherence6[5,5]) #Karpov vs Kasparov
        G.add_edge('D3','M2',weight=coherence6[4,5]) #Karpov vs Anand
        G.add_edge('D3','M1',weight=coherence6[3,5]) #Karpov vs Kasparov
        G.add_edge('D3','D2',weight=coherence6[1,5]) #Karpov vs Anand
        G.add_edge('D3','D1',weight=coherence6[0,5]) #Karpov vs Kasparov
        
        G.add_edge('D2','S',weight=coherence6[7,6]) #Karpov vs Anand
        G.add_edge('D2','M4',weight=coherence6[6,6]) #Karpov vs Kasparov
        G.add_edge('D2','M3',weight=coherence6[5,6]) #Karpov vs Anand
        G.add_edge('D2','M2',weight=coherence6[4,6]) #Karpov vs Kasparov
        G.add_edge('D2','M1',weight=coherence6[3,6]) #Karpov vs Anand
        G.add_edge('D2','D3',weight=coherence6[2,6]) #Karpov vs Kasparov
        G.add_edge('D2','D1',weight=coherence6[0,6]) #Karpov vs Kasparov
    
        G.add_edge('D1','S',weight=coherence6[7,7]) #Karpov vs Anand
        G.add_edge('D1','M4',weight=coherence6[6,7]) #Karpov vs Kasparov
        G.add_edge('D1','M3',weight=coherence6[5,7]) #Karpov vs Anand
        G.add_edge('D1','M2',weight=coherence6[4,7]) #Karpov vs Kasparov
        G.add_edge('D1','M1',weight=coherence6[3,7]) #Karpov vs Anand
        G.add_edge('D1','D3',weight=coherence6[2,7]) #Karpov vs Kasparov
        G.add_edge('D1','D2',weight=coherence6[1,7]) #Karpov vs Kasparov
    
        
        
        # degree 계산해서 degree값 뽑아내기!!
        
        deg_all2=deg_all*700
        
        G.add_node('S',weight=deg_all2[step,0]) #Karpov vs Kasparov
        G.add_node('M4',weight=deg_all2[step,1]) #Karpov vs Kasparov
        G.add_node('M3',weight=deg_all2[step,2]) #Karpov vs Kasparov
        G.add_node('M2',weight=deg_all2[step,3]) #Karpov vs Kasparov
        G.add_node('M1',weight=deg_all2[step,4]) #Karpov vs Kasparov
        G.add_node('D3',weight=deg_all2[step,5]) #Karpov vs Kasparov
        G.add_node('D2',weight=deg_all2[step,6]) #Karpov vs Kasparov
        G.add_node('D1',weight=deg_all2[step,7]) #Karpov vs Kasparov
    

        
        # nx.draw_shell(G)
                
        pos=nx.circular_layout(G) 
        #nx.draw_networkx_nodes(G,pos,node_color='lightblue',node_size=2000)
        
        labels = {}
        for node_name in node_list:
            labels[str(node_name)] =str(node_name)
        #nx.draw_networkx_labels(G,pos,labels,font_size=16)
        
        
        
        
        
        
        
        
        all_weights=[]
        
        for (node1, node2, data) in G.edges(data=True):
            all_weights.append(data['weight'])
        
        
        unique_weights=list(set(all_weights))
        
        #G.degree(weight='weight')
        
        
        
        plt.figure(1)
        fig = plt.gcf()
        fig.set_size_inches(6, 6)
      #  plt.figure(figsize=(6,6), dpi=100)
        # nx.draw_networkx_nodes(G,pos,node_color='lightblue',node_size=2000)
         
        nx.draw_networkx_labels(G,pos,labels,font_size=24)
        
    
    
       
        nx.draw_networkx_nodes(
            G, pos, node_color=[n[1]['weight']//2 for n in G.nodes(data=True)], node_shape='h',
            node_size=3000, cmap=plt.cm.Blues, alpha=1,
            vmin=0, vmax=350
                          )
        
        nx.draw_networkx_edges(
            G, pos, edge_color=[e[2]['weight'] for e in G.edges(data=True)], 
            width=[e[2]['weight']//30 for e in G.edges(data=True)], edge_cmap=plt.cm.Blues, edge_vmin=10, edge_vmax=70, alpha=0.8,
            arrows=True, arrowstyle='->', arrowsize=1, edge_colors='r', cmap=plt.cm.Blues,
        )
        
        cmap=plt.cm.Blues
    
        plt.axis('off')
        
        actual_time=round(time_list[100*(step)],1)
        plt.title('Trial ' + str(tr+1) + ' \n time : ' + str(actual_time) + ' s ~ ' + str(actual_time+10) + ' s',fontsize=25)
       
      
    
        # createFolder('D:/EEG/joint_prob/M2/norM3/50ms')
        plt.savefig('E:/JEELAB/EEG/EEG_RESULT/BBCI/190910/group/network/step360/trial' + str(tr+1) + '/step' + str(step+1).zfill(3), bbox_inches='tight')
        fig.clear()
        
        
        
        
        
        
        
        
        
        
        
        

#os.system("ffmpeg -f image2 -r 1/5 -i "E:/JEELAB/EEG/EEG_RESULT/BBCI/190910/group/network/step360/trial1/step%01d.png" -vcodec mpeg4 -y "E:/JEELAB/EEG/EEG_RESULT/BBCI/190910/group/network/step360/trial1/trial1.mp4")

os.system("ffmpeg -f image2 -r 1/5 -i .network/trial1/step%03d.png -vcodec mpeg4 -y .network/trial1.mp4")



import cv2
import os


# 이미지 불러와서 동영상 파일로 만드는 방법. opencv를 사용하면됨
# 여기에서 에러 났던 부분은, figure를 plot할 때 size를 맞췄다해도, 정확하게 사이즈가 같지 않아서
# 사이즈가 다르면 연결해서 비디오가 생기지가 않음.
# 그래서 여기서는 임시방편으로 title 제목크기를 줄여서 사이즈를 맞췄음.


for tr in range (0,4):
    image_folder = "E:/JEELAB/EEG/EEG_RESULT/BBCI/190910/group/network/step360/trial" + str(tr+1)
    video_name = 'E:/JEELAB/EEG/EEG_RESULT/BBCI/190910/group/network/step360/trial' +str(tr+1) + '.mp4'
    
    images = [img for img in os.listdir(image_folder) if img.endswith(".png")]
    frame = cv2.imread(os.path.join(image_folder, images[0]))
    height, width, layers = frame.shape
    
    video = cv2.VideoWriter(video_name, 0, 10, (width,height))
    
    #for image in images:
    
    #for k in range (0,360):
     #   image= images[k]
    for image in images:
        video.write(cv2.imread(os.path.join(image_folder, image)))
    
    cv2.destroyAllWindows()
    video.release()

# Define the codec and create VideoWriter object.The output is stored in 'outpy.avi' file.
# Define the fps to be equal to 10. Also frame size is passed.
 

# out = cv2.VideoWriter('outpy.avi',cv2.VideoWriter_fourcc('M','J','P','G'), 10, (width,height))











"""

import cv2
vidcap = cv2.VideoCapture('big_buck_bunny_720p_5mb.mp4')
success,image = vidcap.read()
count = 0
while success:
  cv2.imwrite("frame%d.jpg" % count, image)     # save frame as JPEG file      
  success,image = vidcap.read()
  print('Read a new frame: ', success)
  count += 1

"""






