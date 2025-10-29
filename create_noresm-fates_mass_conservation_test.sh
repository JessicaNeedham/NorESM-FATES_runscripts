#!/bin/bash

export COMPSET='2000%CRUJRA2024_CLM60%FATES_SICE_SOCN_SROF_SGLC_SWAV_SESP'
export RES=f45_f45_mg37   #'ne30pg3_tn14' #  "ne16pg3_tn14"   # "f45_f45_mg37" # ne16pg3_tn14, #f19_g17, ne30pg3_tn14, f45_f45_mg37, ne16pg3_tn14
export MACH='betzy'
export PROJECT='nn9188k'

export USER='jessica'
export workpath='/cluster/work/users/jessica'


export TAG='noresm-fates-mass_conservation_devel'
export CASEROOT=$workpath/fates-cal-runs 
export CIMEROOT=$workpath/noresm-fates-cal/CTSM/cime/scripts

cd ${CIMEROOT}

export CIME_HASH=`git log -n 1 --pretty=%h`
export NorESM_CTSM_HASH=`(cd ../..;git log -n 1 --pretty=%h)`
export FATES_HASH=`(cd src/fates/;git log -n 1 --pretty=%h)`
export GIT_HASH=N${NorESM_CTSM_HASH}-F${FATES_HASH}	
export CASE_NAME=${CASEROOT}/${TAG}.${GIT_HASH}.`date +"%Y-%m-%d"`
# REMOVE EXISTING CASE DIRECTORY IF PRESENT 
rm -rf ${CASE_NAME}

./create_newcase --case=${CASE_NAME} --res=${RES} --compset=${COMPSET} --mach=${MACH} --project=${PROJECT} --run-unsupported

cd ${CASE_NAME}

./xmlchange STOP_N=20
./xmlchange STOP_OPTION=nyears
./xmlchange REST_N=10
./xmlchange REST_OPTION=nyears
./xmlchange RESUBMIT=0
./xmlchange DEBUG=FALSE

./xmlchange RUN_STARTDATE=2000-01-01
./xmlchange CLM_ACCELERATED_SPINUP=off

# For real runs
#./xmlchange --subgroup case.run JOB_WALLCLOCK_TIME=24:00:00
#./xmlchange --subgroup case.st_archive JOB_WALLCLOCK_TIME=00:30:00

# For debugging
./xmlchange JOB_WALLCLOCK_TIME=00:29:00
./xmlchange JOB_QUEUE=devel
./xmlchange NTASKS=128

./xmlchange RUNDIR=${CASE_NAME}/run
#./xmlchange EXEROOT=${CASE_NAME}/bld

./xmlchange EXEROOT=/cluster/work/users/jessica/fates-cal-runs/noresm-fates-mass_conservation.N77e76a761-F3012a954e.2025-10-28/bld
./xmlchange BUILD_COMPLETE=TRUE


cat >>  user_nl_clm <<EOF
fates_paramfile='/cluster/home/jessica/NorESM-fates-cal/paramfiles/fates_params_api.noresm_42.0.0_14pft__noresm_v28e.nc'
paramfile='/cluster/shared/noresm/inputdata/lnd/clm2/paramdata/ctsm60_params.200905_v25u.nc'
use_fates_sp=.false.
use_fates_nocomp=.true.
use_fates_fixed_biogeog=.true.
use_fates_luh=.true.
use_fates_lupft=.true.
fates_harvest_mode='luhdata_area'
use_fates_potentialveg=.false.
fluh_timeseries='/cluster/shared/noresm/inputdata/LU_data_CMIP7/LUH3_states_transitions_management.timeseries_4x5_hist_steadystate_2000_2025-10-09_cdf5.nc'
flandusepftdat='/cluster/shared/noresm/inputdata/LU_data_CMIP7/fates_landuse_pft_map_to_surfdata_4x5_hist_1850_16pfts_c241007_250522_cdf5.nc'
fates_spitfire_mode=1
hist_fincl1='TOTECOSYSC', 'TOTSOMC', 'TOTSOMC_1m', 'TLAI', 'FATES_GPP', 'FCO2', 
'FATES_NEP',  'TWS', 'H2OSNO', 'FSNO', 'FATES_VEGC_PF', 'FATES_VEGC_LU',
'FATES_NPLANT_PF', 'FATES_SECONDARY_AREA_ANTHRO_AP','FATES_SECONDARY_AREA_AP','FATES_PRIMARY_AREA_AP','FATES_HARVEST_WOODPROD_C_FLUX', 
'TOTCOLC', 'FATES_VEGC', 'TOTLITC', 'TOTSOMC', 'TOT_WOODPRODC', 'FATES_FRACTION', 'HR', 
'FATES_NPP', 'FATES_HET_RESP', 'FATES_GRAZING','FATES_FIRE_CLOSS', 'PROD100C_LOSS', 'PROD10C_LOSS', 'TOT_WOODPRODC_LOSS',
EOF




#cat >> user_nl_datm <<EOF
#taxmode = "cycle", "cycle", "cycle"
#EOF

./case.setup
#./case.build
./case.submit
 
