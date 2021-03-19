# -*- coding: utf-8 -*-
"""
Created on Tue Dec 15 14:59:48 2020

@author: singhsr
"""

import neuropythy as ny
import numpy as np
import scipy.io as sio

ny.config['freesurfer_subject_paths'] = ['T:\\users\\singhsr\\MEG_Project2018\\MRI\\my_recons']

sub = ny.freesurfer_subject('lilac4')

(lh_retino, rh_retino) = ny.vision.predict_retinotopy(sub)

lh_retino = ny.as_retinotopy(lh_retino,'standard')
lh_retino = ny.as_retinotopy(lh_retino,'standard')


savedir = 'T:/users/singhsr/MEG_Project2018/Light_Dark/simulation/cortical_model/'

sio.savemat(savedir+'lh_retino_standard.mat',lh_retino)
sio.savemat(savedir+'rh_retino_standard.mat',rh_retino)
