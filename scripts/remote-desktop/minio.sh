#!/bin/bash
# Stops script execution if a command has an error
set -e

if ! hash minio 2>/dev/null; then
    cd /vault/secrets
    . minio-standard-tenant-1
    access_key=$MINIO_ACCESS_KEY
    secret_key=$MINIO_SECRET_KEY

    wget https://github.com/mozilla/geckodriver/releases/download/v0.28.0/geckodriver-v0.28.0-linux64.tar.gz
    sudo sh -c 'tar -x geckodriver -zf geckodriver-v0.28.0-linux64.tar.gz -O > /usr/bin/geckodriver'
    sudo chmod +x /usr/bin/geckodriver

    python - << EOF
    #!/usr/bin/python
    from selenium import webdriver
    
    driver = webdriver.FireFox(executable_path="/usr/bin/geckodriver")
    driver.get("https://minio-standard-tenant-1.covid.cloud.statcan.ca/minio/login")

    access_key= '//*[@id="accessKey"]'
    secret_key= '//*[@id="secretKey"]'
    submit_form= '//*[@id="root"]/div/div[1]/form/button'

    driver.find_element_by_xpath(access_key).send_keys($access_key)
    driver.find_element_by_xpath(secret_key).send_keys($secret_key)
    driver.find_element_by_xpath(submit_form).click()

    EOF
else
    echo "minio is already installed"
fi

