#!/bin/bash

# Function that removes all the shit before and after each run
# Params : $1 : Domain
function sweep {
  cd /root/rasp/$1
  rm -f met_em.d* ; rm -f wrfout* ; rm -f met_em* ; rm -f UNGRIB:* ; rm -f wrfinput_* ; rm -f GRIB/* ; rm -f OUT/*
}

# Function that uploads output images to a ftp servers
# Params : $1 : Domain ; $2 : run date
function upload {
  echo "uploading "$1" to "$2
  #lftp $FTP_ENDPOINT -e "cd hdd; cd OUT; mkdir "$2"; cd "$2"; mput /root/rasp/"$1"/OUT/*; quit"
}

# Function that copy a domain from the Raspit-backend folder (for development purposes only)
# Params : $1 : Domain
function cp_dev_domain {
  cd /root/rasp
  rm -rf $1 ; cp -r Raspit-backend/$1 . && mkdir $1/OUT && mkdir $1/LOG && mkdir $1/GRIB
  cp --preserve=links region.TEMPLATE/rasp.site.* $1/ && cp --preserve=links region.TEMPLATE/*.TBL $1/ && cp --preserve=links region.TEMPLATE/RRTM_DATA $1/
  cp --preserve=links region.TEMPLATE/ETAMPNEW_DATA.expanded_rain $1/
  cp $1/namelist.input $1/namelist.input.template && cp $1/namelist.wps $1/namelist.wps.template
}

# Function that does one run, corresponding to a certain domain and a certain day
# Params : $1 : Domain ; $2 : start_hour
function one_day_run {
  sweep $1
  export START_HOUR=$2
  cd /root/rasp
  echo "------------------------------------"
  echo "Running "$1" with START_HOUR="$2
  runGM $1
  echo $1" with START_HOUR="$2" done."
  upload $1 $(date --date=$((($2 / 24) + 1))" days" +%Y%m%d)
  sweep $1
}

# FTP_ENDPOINT environment variable must be set. Otherwise we quit.
[ -z "$FTP_ENDPOINT" ] && echo "FTP_ENDPOINT not set. Exiting..." && exit 1;

# Same for DEV_ENV
[ -z "$DEV_ENV" ] && echo "DEV_ENV not set. Exiting..." && exit 1;

# Depending on the current hour, we will use 0Z or 12Z grib files from the ncep servers
currentHour=$(date -u +%H)
if [ $currentHour -lt 16 ]
then
  export MODEL_RUN=0
else
  export MODEL_RUN=12
fi
echo "Model run : "$MODEL_RUN"Z"

# We copy the GM & domain directories from our dev directory to the rasp directory if DEV_ENV=y
if [[ ${DEV_ENV} -eq y ]]
then
  echo "Development environment detected. Copying domains and GM folder from external volume..."
  cp_dev_domain PYR2
  cp_dev_domain PYR3
  cp -r Raspit-backend/GM /root/rasp/
else
  echo "Production environment detected. Domains should already be in the rasp directory"
fi

# Run launch
one_day_run PYR2 33
one_day_run PYR2 57
one_day_run PYR3 9
