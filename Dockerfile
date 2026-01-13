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
#Install postgresql-client to connect to the database
#Install build-base, postgresql-dev, and musl-dev to build the project inside "tmp-build-deps" virtual dependency package
#Install the dependencies from the requirements.txt file
#Remove the temporary requirements.txt file
#Remove the temporary build-deps virtual dependency package
#Create a new user to run the application
#User doesn't need a home directory
#Specify user name
RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    apk add  --update --no-cache postgresql-client && \
    apk add --update --no-cache --virtual .tmp-build-deps \
      build-base postgresql-dev musl-dev && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ $DEV = "true" ]; \
      then /py/bin/pip install -r /tmp/requirements.dev.txt ;  \
    fi && \
    rm -rf /tmp && \
    apk del .tmp-build-deps && \
    adduser \
        --disabled-password \
        --no-create-home \
        django-user

# Updates the environment variable to include the path to the virtual environment
ENV PATH="/py/bin:$PATH"

# Sets the user to the new user
USER django-user