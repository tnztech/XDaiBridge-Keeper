# Use an official Node.js 16 LTS runtime as a parent image
FROM ghcr.io/foundry-rs/foundry

# Set the working directory to /app
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY . /app

# Install dependencies and set up the environment
RUN apk --no-cache add npm curl bash make && \
    npm install -g pm2 && \
    forge update

SHELL ["/bin/bash", "-c"]

# Define the command to start the KeeperOperator script
CMD ["make run-keeper"]
