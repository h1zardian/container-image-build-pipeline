#!/bin/sh

# Exit the script with code 0 when encontering errors
set -e

SUPERUSER_EMAIL=${DJANGO_SUPERUSER_EMAIL:-'admin@djangomail.com'}


if [ "$DATABASE" = "postgres" ]
then
    echo "Waiting for postgres..."

    while ! nc -z $SQL_HOST $SQL_PORT; do
      sleep 0.1
    done

    echo "PostgreSQL started!"
fi


# Django database migrations
python manage.py flush --no-input
python manage.py makemigrations --no-input
python manage.py migrate --no-input

# Create admin for Django app
python manage.py createsuperuser --email $SUPERUSER_EMAIL --no-input || true

# # Create the staticfiles directory
python manage.py collectstatic --no-input

# Deploy django server
# python manage.py runserver 0.0.0.0:8000
gunicorn console.wsgi:application --bind 0.0.0.0:8000