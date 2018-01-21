# Raspit-compute-image

WRF-ARW Weather forecast compute image for SW France

## Content

* PYR2/ : 1-stage 0.5deg GFS initialized 6km grid
* PYR3/ : 1-stage 0.25deg GFS initialized 3km grid
* Docker-rasp-wrfv3/ : Generic wrfv3 rasp dockerfile
* Docker-raspit-compute-image-prod/ : dockerfile of a "production" image derived from the above

## How to build (optional)

```
git clone maximepiton/Raspit-compute-image
cd Raspit-compute-image/Docker-rasp-wrfv3
wget http://rasp-uk.uk/SOFTWARE/WRFV3.x/raspGM.tgz
wget http://rasp-uk.uk/SOFTWARE/WRFV3.x/raspGM-bin.tgz
wget http://rasp-uk.uk/SOFTWARE/WRFV3.x/rangs.tgz
docker build -t rasp-wrfv3 .
cd ../
docker build -t raspit-compute-image-prod -f Docker-raspit-compute-image-prod/Dockerfile .
```

## How to setup a development environment

```
# To use an FTP server to store output files :
docker run -it \
    -e "FTP_ENDPOINT=user:pass@server:port" \
    -e "DEV_ENV=y" \
    -v path_to_Raspit-compute-image:/root/rasp/Raspit-compute-image \
    rasp-wrfv3
# To use Google Cloud Storage to store output files :
docker run -it \
    -e "GCS_BUCKET=bucket_name" \
    -e "DEV_ENV=y" \
    -v path_to_Raspit-compute-image:/root/rasp/Raspit-compute-image \
    rasp-wrfv3
```

## How to use at production

```
docker run -e "FTP_ENDPOINT=user:pass@server:port" --rm raspit-compute-image-prod
# or
docker run -e "GCS_BUCKET=bucket_name" --rm raspit-compute-image-prod
```


## Based on

This is based on [RASP](http://www.drjack.info/RASP/), a WRF-ARW forecast distribution by Dr Jack and greatly inspired by [Rasp docker scripts](https://github.com/wargoth/rasp-docker-script) by V. Mayamsin
