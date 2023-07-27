#!/bin/sh

SUPERUSER_EMAIL=${DJANGO_SUPERUSER_EMAIL:-'admin@djangomail.com'}


# Django database migrations
python manage.py flush --no-input
python manage.py makemigrations --no-input
python manage.py migrate --no-input

# Create admin for Django app
python manage.py createsuperuser --email $SUPERUSER_EMAIL --no-input || true

# Create the staticfiles directory
python manage.py collectstatic --no-input