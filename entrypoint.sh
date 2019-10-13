#!/bin/bash

# 切换源
composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/

# 安装
composer clear
composer install -vvv

# TODO 运行脚本
# composer run-script XXXX