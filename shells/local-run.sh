#!/usr/bin/bash

sudo systemctl start mysql.service
cp local-env .env
python3 manage.py runserver

