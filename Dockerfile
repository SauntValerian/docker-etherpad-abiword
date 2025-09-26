# Use the official Etherpad image as base
FROM etherpad/etherpad:latest

# Switch to root to install system packages
USER root

# Update package lists and install Abiword and dependencies
RUN apt-get update && \
    apt-get install -y \
    abiword \
    fonts-liberation \
    fonts-dejavu-core \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Switch back to etherpad user
USER etherpad

# Copy custom settings if you have them (optional)
COPY settings.json /opt/etherpad-lite/settings.json

# Expose the default Etherpad port
EXPOSE 9001

# Use the default Etherpad startup command
CMD ["node", "node_modules/ep_etherpad-lite/node/server.js"]
