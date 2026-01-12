FROM python:3.9-alpine3.13
LABEL maintainer="laurafontsalvador@gmail.com"

ENV PYTHONUNBUFFERED 1 
# Tells Python not to buffer output to avoid delays in logging

COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./app /app
WORKDIR /app
EXPOSE 8000

ARG DEV=false
#Runs commands to create a new docker image, steps:
#Create new virtual environment to store the dependencies
#Upgrade pip to the latest version
#Install the dependencies from the requirements.txt file
#Remove the temporary requirements.txt file
#Create a new user to run the application
#User doesn't need a home directory
#Specify user name
RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ $DEV = "true" ]; \
      then /py/bin/pip install -r /tmp/requirements.dev.txt ;  \
    fi && \
    rm -rf /tmp && \
    adduser \
        --disabled-password \
        --no-create-home \
        django-user

# Updates the environment variable to include the path to the virtual environment
ENV PATH="/py/bin:$PATH"

# Sets the user to the new user
USER django-user