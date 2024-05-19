import matplotlib.pyplot as plt
import numpy as np

datadir = '../data/'
with open(datadir + 'params.txt', 'r') as f:
    data = f.read().split('\n')
    ix = int(data[0])
    margin = int(data[1])
    size = int(data[2])
    print(ix,margin,size)

with open(datadir + 'nd.txt','r') as f:
    nd = int(f.read().split('\n')[0])
    
# read geometry
endian = '<'
x = np.zeros(ix*size)
for np0 in range(size):
    with open(datadir + 'x/x.'+str(np0).zfill(4)+'.dat','rb') as f:
        xl = np.fromfile(f,endian+'d',ix + 2*margin)
        x[np0*ix:(np0+1)*ix] = xl.reshape((ix + 2*margin),order='F')[margin:ix + margin]

plt.clf()        
qq = np.zeros(ix*size)
color = np.zeros(ix*size)
for n in range(0,nd+1):
    for np0 in range(size):
        color[np0*ix:(np0+1)*ix] = np0
        with open(datadir + 'qq/qq.'+str(np0).zfill(4)+'.'+str(n).zfill(4)+'.dat','rb') as f:
            qql = np.fromfile(f,endian+'d',ix + 2*margin)
            qq[np0*ix:(np0+1)*ix] = qql.reshape((ix + 2*margin),order='F')[margin:ix + margin]
            
    plt.scatter(x,qq,c=color,cmap='jet',vmin=0,vmax=size-1)
    plt.pause(0.02)
    if n != nd:
        plt.clf()