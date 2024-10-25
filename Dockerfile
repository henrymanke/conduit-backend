## Stage 1: Base Image with dependencies
FROM python:3.6-slim as base

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Install dependencies for Python and the necessary system tools
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    gcc \
    python3-dev \
    musl-dev \
    libpq-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create and set the working directory
WORKDIR /usr/src/app

# Copy the requirements file and install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

## Stage 2: Application Build
FROM base as build

# Set the working directory
WORKDIR /usr/src/app

# Copy the application code to the container
COPY . .

# Set execute permissions for entrypoint.sh
RUN chmod +x /usr/src/app/entrypoint.sh

## Stage 3: Final Image (minimal, without build tools)
FROM python:3.6-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Install runtime dependencies (to ensure Django is available)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Create and set the working directory
WORKDIR /usr/src/app

# Copy only necessary files from the build stage
COPY --from=build /usr/src/app /usr/src/app

# Expose the application port (Django's default is 8000)
EXPOSE 8000

# Set the default entrypoint for the container
ENTRYPOINT ["/usr/src/app/entrypoint.sh"]

#PROD
# Use Gunicorn as the production server
# CMD ["gunicorn", "--bind", "0.0.0.0:8000", "conduit.wsgi:application"]
