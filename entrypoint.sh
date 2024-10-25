#!/bin/bash

# Exit on any error
set -e

# Run migrations
echo "Running migrations..."
python manage.py migrate

#PROD
# Collect static files 
# echo "Collecting static files..."
# python manage.py collectstatic --noinput --no-post-process > /dev/null 2>&1 || {
#     echo "WARNING: Static file collection failed!"
# }

# Check if necessary environment variables are set
if [ -z "$DJANGO_SUPERUSER_EMAIL" ] || [ -z "$DJANGO_SUPERUSER_USERNAME" ]; then
    echo "Skipping superuser creation: environment variables DJANGO_SUPERUSER_EMAIL and DJANGO_SUPERUSER_USERNAME are not set."
else
    # Check if the superuser already exists using Django's ORM
    if python manage.py shell -c "from django.contrib.auth import get_user_model; User = get_user_model(); print(User.objects.filter(email='$DJANGO_SUPERUSER_EMAIL').exists())" | grep -q 'False'; then
        echo "Creating superuser..."
        # Try to create the superuser and handle errors
        if python manage.py createsuperuser --noinput --email "$DJANGO_SUPERUSER_EMAIL" --username "$DJANGO_SUPERUSER_USERNAME" 2>/dev/null; then
            echo "Superuser created successfully."
        else
            echo "WARNING: Superuser creation failed. User with email $DJANGO_SUPERUSER_EMAIL may already exist."
        fi
    else
        echo "WARNING: Superuser with email $DJANGO_SUPERUSER_EMAIL already exists."
    fi
fi

#PROD
# Run the command passed to the entrypoint (Gunicorn in this case)
# exec "$@"


# Run the Server
exec python manage.py runserver 0.0.0.0:8000
