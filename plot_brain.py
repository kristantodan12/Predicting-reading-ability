from visbrain.objects import RoiObj, ColorbarObj, SceneObj, SourceObj, BrainObj
from visbrain.io import download_file, path_to_visbrain_data, read_nifti
import numpy as np
from numpy import linalg as LA

CBAR_STATE = dict(cbtxtsz=12, txtcolor='black', txtsz=10., width=.1, cbtxtsh=3.,
                  rect=(-.3, -2., 1., 4.))

def draw_average_mode(order, mat='sc'):
    #Path of the connectivity matrices and computation of eigenmodes
    #Most of the processing are custom functions that are not here
    SC_path='../Data/MMP_SC_average.csv'
    FC_path='../Data/MMP_FC_pearson_average.csv'

    fc = np.genfromtxt(FC_path, delimiter=',')
    sc = np.genfromtxt(SC_path, delimiter=',')
    sc = adj2laplacian(sc)
    _, fc_modes = LA.eigh(fc)
    _, sc_modes = LA.eigh(sc)

    #Plot the fc or sc mode depending on the argument 'mat'
    if mat is 'fc':
        lh_mode = np.asarray(fc_modes[:180,order]).squeeze().tolist()
        rh_mode = np.asarray(fc_modes[180:,order]).squeeze().tolist()
    else:
        lh_mode = np.asarray(sc_modes[:180,order]).squeeze().tolist()
        rh_mode = np.asarray(sc_modes[180:,order]).squeeze().tolist()

    #Scene creation with a white background and a custom size
    sc = SceneObj(bgcolor='white', size=(1400, 700))
    lh_path = '../Data/Viz/lh.HCP-MMP1.annot'
    rh_path = '../Data/Viz/rh.HCP-MMP1.annot'
    #Creation of 3 BrainObj corresponding to the 3 views (left, above, right)
    b_obj = BrainObj('white', hemisphere='both', translucent=False)
    lh_obj = BrainObj('white', hemisphere='left', translucent=False)
    rh_obj = BrainObj('white', hemisphere='right', translucent=False)
    lh_list = b_obj.get_parcellates(lh_path)[['Labels']].values.tolist()
    rh_list = b_obj.get_parcellates(rh_path)[['Labels']].values.tolist()
    del lh_list[0]
    del rh_list[0]
    max_value = max(lh_mode+rh_mode)
    min_value = min(lh_mode+rh_mode)
    cbar_lim = (min_value,max_value) #values to plot the colorbar

    #Parcellize the 3 BrainObj with the data and parcellates from annot files
    b_obj.parcellize(lh_path, select=lh_list, hemisphere='left',
    cmap='jet', data=lh_mode, clim = cbar_lim)
    b_obj.parcellize(rh_path, select=rh_list, hemisphere='right',
    cmap='jet', data=rh_mode, clim = cbar_lim)
    lh_obj.parcellize(lh_path, select=lh_list, hemisphere='left',
    cmap='jet', data=lh_mode, clim = cbar_lim)
    rh_obj.parcellize(rh_path, select=rh_list, hemisphere='right',
    cmap='jet', data=rh_mode, clim = cbar_lim)

    #Add the 3 BrainObj and colorbar to the scene and generate the plot
    sc.add_to_subplot(lh_obj, row=0, col=0, rotate='left', zoom=.8,
                      title='Left', title_color='black')
    sc.add_to_subplot(b_obj, row=0, col=1, rotate='top', zoom=.8,
                      title='Top', title_color='black')
    sc.add_to_subplot(rh_obj, row=0, col=2, rotate='right', zoom=.8,
                      title='Right', title_color='black')
    cb_parr = ColorbarObj(b_obj, cblabel='Activation', **CBAR_STATE)
    sc.add_to_subplot(cb_parr, row=0, col=3, width_max=200)
    sc.preview()
