# Use the official Etherpad image as base (Alpine Linux)
FROM etherpad/etherpad:latest

# Switch to root to install system packages
USER root

# Update package lists and install Abiword and dependencies using apk (Alpine's package manager)
RUN apk update && \
    apk add --no-cache \
    abiword \
    ttf-liberation \
    ttf-dejavu

# Switch back to etherpad user
USER etherpad

# Copy custom settings if you have them (optional)
# COPY settings.json /opt/etherpad-lite/settings.json

# Expose the default Etherpad port
EXPOSE 9001

# No CMD needed - use the base image's default startup command
