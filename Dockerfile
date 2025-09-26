# Etherpad with Abiword Support
FROM etherpad/etherpad:latest

# Switch to root to install packages
USER root

# Install Abiword and dependencies for headless operation
RUN apk update && \
    apk add --no-cache \
    abiword \
    ttf-liberation \
    ttf-dejavu \
    xvfb \
    xauth \
    dbus \
    fontconfig \
    && fc-cache -fv

# Create headless Abiword wrapper script
RUN echo '#!/bin/sh' > /usr/local/bin/abiword-headless && \
    echo 'export DISPLAY=:99' >> /usr/local/bin/abiword-headless && \
    echo 'Xvfb :99 -screen 0 1024x768x24 -ac +extension GLX +render -noreset &' >> /usr/local/bin/abiword-headless && \
    echo 'XVFB_PID=$!' >> /usr/local/bin/abiword-headless && \
    echo 'sleep 2' >> /usr/local/bin/abiword-headless && \
    echo 'abiword "$@"' >> /usr/local/bin/abiword-headless && \
    echo 'kill $XVFB_PID' >> /usr/local/bin/abiword-headless && \
    chmod +x /usr/local/bin/abiword-headless

# Switch back to etherpad user
USER etherpad

# Expose Etherpad port
EXPOSE 9001
