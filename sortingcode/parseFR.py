# -*- coding: utf-8 -*-
"""
Created on Mon Sep 30 10:43:51 2019

@author: Libra
"""

import h5py
import numpy as np
import pandas as pd
import re
import matplotlib.pyplot as plt

def trialAlign(trials,oneTS,sample):
    ta=np.array(trials)
    ts=ta[ta[:,1]==sample,:]
    oneTS=oneTS[np.bitwise_and(oneTS>=ts[0,0]-30000*5, oneTS<=(ts[-1,0]+30000*10))]
    TSidx=0
    tIdx=0;
    while TSidx<len(oneTS) and tIdx<len(ts):
        if oneTS[TSidx]<ts[tIdx,0]+8*30000:
            oneTS[TSidx]-=ts[tIdx,0]
            TSidx+=1
        else:
            tIdx+=1
    return oneTS
        


def parseFR(start,stop):
    ids=[]
    TS=[]
 
    with h5py.File('SPKTS.hdf5','r') as fs:
        idset=fs['ids']
        ids=np.array(idset, dtype='uint16')[0]
        TSset=fs['TS']
        TS=np.array(TSset,dtype='uint64')[0]
        
    trials=[]    
    with h5py.File('events.hdf5','r') as evtf:
        trials=evtf['trials']
        trials=np.array(trials,dtype='i4')
        
        
        
    unitInfo=pd.read_csv('cluster_info.tsv',sep='\t')
    heat4=[];
    heat8=[];
    for idx in range(unitInfo.shape[0]):
        wf=unitInfo.iloc[idx,8]=='good'
        freqStr=unitInfo.iloc[idx,7]
        matched=re.match(r'\d*\.\d*',freqStr)
        freq=float(matched.group())
        if freq>2.0 and wf:
            oneTSAll=(TS[ids==idx]).astype('int64')
            oneTS4=trialAlign(trials[range(start,stop),:],oneTSAll,4)
            oneTS8=trialAlign(trials[range(start,stop),:],oneTSAll,8)
            hist4=np.histogram(oneTS4,np.linspace(-60000,30000*6,num=33))[0]
            hist8=np.histogram(oneTS8,np.linspace(-60000,30000*6,num=33))[0]
            heat4.append(hist4)
            heat8.append(hist8)
    
    heat4=np.array(heat4)
    heat8=np.array(heat8)
    
    m4=np.mean(heat4[:,1:9],axis=1)
    std4=np.std(heat4[:,1:9],axis=1)
    std4[std4==0]=0.01
    m4n=np.divide(np.subtract(heat4.transpose(),m4.transpose()),std4.transpose())
    plt.figure(0,figsize=[15,15])
    plt.imshow(m4n.transpose()[:,4:29],cmap='jet',vmin=-6,vmax=6)
    
    m8=np.mean(heat8[:,1:9],axis=1)
    std8=np.std(heat8[:,1:9],axis=1)
    std8[std8==0]=0.01
    m8n=np.divide(np.subtract(heat8.transpose(),m8.transpose()),std8.transpose())
    plt.figure(1,figsize=[15,15])
    plt.imshow(m8n.transpose()[:,4:29],cmap='jet',vmin=-6,vmax=6)
    
    
            
            
            
            
            
        