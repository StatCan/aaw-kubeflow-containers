#!/bin/bash
# Stops script execution if a command has an error
set -e

if ! hash minio 2>/dev/null; then
python3 - <<EOF

import json
from selenium.webdriver.common.keys import Keys
from selenium import webdriver
import os.path
from selenium.webdriver.common.keys import Keys

with open('/vault/secrets/minio-standard-tenant-1.json') as f:
    d = json.load(f)
    accessKey= d["MINIO_ACCESS_KEY"]
    secretKey= d["MINIO_SECRET_KEY"]

driver = webdriver.Firefox(executable_path="/usr/bin/geckodriver")
driver.get("https://minio-standard-tenant-1.covid.cloud.statcan.ca/minio/login")

access_key= '//*[@id="accessKey"]'
secret_key= '//*[@id="secretKey"]'
submit_form= '/html/body/div[2]/div/div[1]/form/button'

driver.find_element_by_xpath(access_key).send_keys(accessKey)
driver.find_element_by_xpath(secret_key).send_keys(secretKey)
driver.find_element_by_name("password").send_keys(Keys.ENTER)

EOF

else
    echo "minio is already installed"
fi
