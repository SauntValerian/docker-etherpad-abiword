# Build Etherpad with Abiword support using official method
FROM etherpad/etherpad:latest

# Set build argument to install Abiword
ARG INSTALL_ABIWORD=true

# Switch to root for installation
USER root

# Install Abiword using the official Etherpad method
RUN if [ "$INSTALL_ABIWORD" = "true" ]; then \
    apk update && \
    apk add --no-cache \
    abiword \
    abiword-plugin-command \
    ttf-liberation \
    ttf-dejavu \
    xvfb \
    dbus \
    fontconfig \
    && fc-cache -fv; \
fi

# Create startup script that runs Xvfb in background
RUN echo '#!/bin/sh' > /usr/local/bin/start-etherpad.sh && \
    echo 'export DISPLAY=:99' >> /usr/local/bin/start-etherpad.sh && \
    echo 'Xvfb :99 -screen 0 1024x768x24 -ac +extension GLX +render -noreset &' >> /usr/local/bin/start-etherpad.sh && \
    echo 'sleep 2' >> /usr/local/bin/start-etherpad.sh && \
    echo 'cd /opt/etherpad-lite && node src/node/server.js' >> /usr/local/bin/start-etherpad.sh && \
    chmod +x /usr/local/bin/start-etherpad.sh

# Switch back to etherpad user
USER etherpad

# Expose port
EXPOSE 9001

# Use our startup script
CMD ["/usr/local/bin/start-etherpad.sh"]
