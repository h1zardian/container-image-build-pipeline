#!/bin/sh

# Exit the script with code 0 when encountering errors
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
echo "from django.contrib.auth import get_user_model; User = get_user_model(); User.objects.create_superuser('${DJANGO_SUPERUSER_EMAIL}', '${DJANGO_SUPERUSER_PASSWORD}') if not User.objects.filter(email='${DJANGO_SUPERUSER_EMAIL}').exists() else None" | python manage.py shell

# Create the staticfiles directory
python manage.py collectstatic --no-input

# Deploy django server
gunicorn console.wsgi:application --bind 0.0.0.0:8000
