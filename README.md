# Raspit-backend

WRF-ARW Weather forecast service for SW France

## Content

* PYR2/ : 1-stage 0.5deg GFS initialized 6km grid
* PYR3/ : 1-stage 0.25deg GFS initialized 3km grid
* Docker-rasp-wrfv3/ : Generic wrfv3 rasp dockerfile
* Docker-raspit-backend-prod/ : dockerfile of a "production" image derived from the above

## How to build (optional)

```
git clone maximepiton/Raspit-backend
cd Docker-rasp-wrfv3
curl -SL http://rasp-uk.uk/SOFTWARE/WRFV3.x/raspGM.tgz
curl -SL http://rasp-uk.uk/SOFTWARE/WRFV3.x/raspGM-bin.tgz
curl -SL http://rasp-uk.uk/SOFTWARE/WRFV3.x/rangs.tgz
docker build -t rasp-wrfv3 .
cd ../
docker build -t raspit-backend-prod -f Docker-raspit-backend-prod/Dockerfile .
```

## How to setup a development environment

```
git clone maximepiton/Raspit-backend
docker run -it -e "FTP_ENDPOINT=user:pass@server:port" -e "DEV_ENV=y" -v path_to_Raspit-backend:/root/rasp/Raspit-backend maximepiton/rasp-wrfv3
```

## How to use at production

```
docker run -e "FTP_ENDPOINT=user:pass@server:port" --rm maximepiton/raspit-backend-prod
```


## Based on

This is based on [RASP](http://www.drjack.info/RASP/), a WRF-ARW forecast distribution by Dr Jack and greatly inspired by [Rasp docker scripts](https://github.com/wargoth/rasp-docker-script) by V. Mayamsin
