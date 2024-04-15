# Use the official Python base image
FROM python:3.12-alpine

# Set the working directory in the container
WORKDIR /app

# Copy the Poetry configuration files to the working directory
COPY backend/pyproject.toml .

# Install Poetry
RUN pip install poetry

# Install project dependencies using Poetry
RUN poetry config virtualenvs.create false \
    && poetry install --no-dev

# Copy the application code to the working directory
COPY backend .

# Create temporal database for test
RUN poetry run alembic upgrade head

# Expose the port on which the FastAPI server will run
EXPOSE 8000

# Create directory for socket file
RUN mkdir -p /var/data/backend

# Run the FastAPI server using Gunicorn
CMD ["gunicorn", "--bind", "unix://var/data/backend/server.sock", "app.main:app", "--worker-class", "uvicorn.workers.UvicornWorker", "--workers", "2"]