# Overview

This repository is to create a docker image that contains STM32CubeIDE to build the firmwares.
The version of STM32CubeIDE is `1.8.0_11526_20211125_0815`

## Build

- Please first obtain the STM32CubeIDE installer `en.st-stm32cubeide_1.8.0_11526_20211125_0815_amd64.deb_bundle.sh.zip`
- Move the installer to this repository
- Build the docker image: `$ docker build ./ -t stm32cubeide_1.8.0_build_env`
- Add tag to the docker image: `$ docker tag 572547b9f4ab ghcr.io/ut-dragon-lab/stm32cubeide_1.8.0_build_env:latest`
- Push the docker image to Github Packages: `docker push ghcr.io/ut-dragon-lab/stm32cubeide_1.8.0_build_env`

## Usage

Please refer to https://github.com/ut-dragon-lab/Spinal_build_docker_image/pkgs/container/stm32cubeide_1.8.0_build_env

