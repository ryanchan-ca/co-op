# Set Up Environment
export FREESURFER_HOME=/Applications/freesurfer
source $FREESURFER_HOME/SetUpFreeSurfer.sh

export SUBJECTS_DIR=/Volumes/BCMHARI/Projects/HOTEL-project/Stubbs_imaging/CAM-CAN/T1s_to_edit

# Load surfaces and volumes on FreeSurfer
freeview -v mri/brainmask.mgz \
mri/wm.mgz:colormap=heat:opacity=0.4 \
-f surf/lh.white:edgecolor=blue \
surf/lh.pial:edgecolor=red \
surf/rh.white:edgecolor=blue \
surf/rh.pial:edgecolor=red