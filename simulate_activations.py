# -*- coding: utf-8 -*-
"""
Created on Mon Dec 21 14:38:17 2020

@author: singhsr
"""

import scipy.io as sio
import numpy as np
import numpy.random as rand
import nibabel as nib

lh_retino = sio.loadmat('lh_retino.mat')

angle = lh_retino["angle"]
varea = lh_retino["varea"]

vis_areasI = varea > 0
vis_areas = varea[vis_areasI]
activations = np.zeros_like(angle)
rand_nums = rand.rand(np.size(vis_areas))*5
activations[vis_areasI] = rand_nums

savedir = 'T:/users/singhsr/MEG_Project2018/Light_Dark/simulation/cortical_model/'

nib.freesurfer.io.write_morph_data(savedir+'lh_rand_activations2',activations)

lh_onField = sio.loadmat(savedir+'lh_on_retino.mat')

on_angle = lh_onField["onAngle"] / (180/5)
on_eccen = lh_onField["onEccen"] / (88/5)

nib.freesurfer.io.write_morph_data(savedir+'lh_on_eccen', on_eccen)
nib.freesurfer.io.write_morph_data(savedir+'lh_on_angle', on_angle)

lh_offField = sio.loadmat(savedir+'lh_retino.mat')
off_angle = lh_offField["angle"] / (180/5)
off_eccen = lh_offField["eccen"] / (88/5)
nib.freesurfer.io.write_morph_data(savedir+'lh_off_eccen', off_eccen)
nib.freesurfer.io.write_morph_data(savedir+'lh_off_angle', off_angle)

