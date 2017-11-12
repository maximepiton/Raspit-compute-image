#!/bin/bash

# Function that removes all the shit before and after each run
# Params : $1 : Domain
function sweep {
  cd /root/rasp/$1
  rm -f met_em.d* ; rm -f wrfout* ; rm -f met_em* ; rm -f UNGRIB:* ; rm -f wrfinput_* ; rm -f GRIB/* ; rm -f OUT/*
}

# Function that uploads output images to a ftp server or a GCS bucket, depending on USE_FTP env. var
# Params : $1 : Domain ; $2 : run date
function upload {
  if [[ -n "$FTP_ENDPOINT" ]]
  then
    # /!\ needs to be updated to store wrfout files
    echo "uploading "$1" to "$2
    lftp $FTP_ENDPOINT -e "cd hdd; cd OUT; mkdir "$2"; cd "$2"; mput /root/rasp/"$1"/OUT/*; quit"
  else
    echo "uploading "$1" to the raspit GCS bucket"
    gsutil rm -r gs://raspit/$(date --date="1 day ago" +%Y%m%d)
    gsutil -m cp /root/rasp/$1/OUT/* gs://raspit/$2/OUT/
    gsutil -m cp /root/rasp/$1/wrfout*d02*00:00 gs://raspit/$2/
  fi
}

# Function that copy a domain from the Raspit-compute-image folder (for development purposes only)
# Params : $1 : Domain
function cp_dev_domain {
  cd /root/rasp
  rm -rf $1 && mkdir $1  
  cp --preserve=links -r region.TEMPLATE/* $1/
  cp -r Raspit-compute-image/$1/* $1/
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

# FTP_ENDPOINT environment variable check. If not set, we will store the output data in a GCS bucket
[ -z "$FTP_ENDPOINT" ] && echo "FTP_ENDPOINT not set. Google cloud storage will be used.";

# Depending on the current hour, we will use 0Z or 12Z grib files from the ncep servers
currentHour=$(date -u +%H)
if [ $currentHour -lt 16 ]
then
  export MODEL_RUN=0
else
  export MODEL_RUN=12
fi
echo "Model run : "$MODEL_RUN"Z"

# We copy the GM & domain directories from our dev directory to the rasp directory if DEV_ENV is set
if [[ -n "$DEV_ENV" ]]
then
  echo "Development environment detected. Copying domains and GM folder from external volume..."
  cp_dev_domain PYR2
  cp_dev_domain PYR3
  cp -r Raspit-compute-image/GM /root/rasp/
else
  echo "Production environment detected. Domains should already be in the rasp directory"
fi

# Run launch
one_day_run PYR2 33
one_day_run PYR2 57
one_day_run PYR3 9
