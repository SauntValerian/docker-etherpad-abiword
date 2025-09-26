# Build Etherpad with Abiword using the official method
FROM alpine/git as source
RUN git clone https://github.com/ether/etherpad-lite.git /etherpad-lite

FROM node:18-alpine
WORKDIR /opt/etherpad-lite

# Copy source from git
COPY --from=source /etherpad-lite .

# Install system dependencies for building
RUN apk add --no-cache shadow bash

# Set build argument to install Abiword
ARG INSTALL_ABIWORD=true

# Install Abiword if requested
RUN if [ "$INSTALL_ABIWORD" = "true" ]; then \
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

# Create etherpad user
RUN groupadd --system etherpad && \
    useradd --system --gid etherpad --create-home etherpad

# Set ownership
RUN chown -R etherpad:etherpad /opt/etherpad-lite

# Switch to etherpad user and install dependencies
USER etherpad
RUN npm ci --only=production

# Create X11 startup script
USER root
RUN echo '#!/bin/bash' > /start-etherpad.sh && \
    echo 'export DISPLAY=:99' >> /start-etherpad.sh && \
    echo 'Xvfb :99 -screen 0 1024x768x24 -ac +extension GLX +render -noreset &' >> /start-etherpad.sh && \
    echo 'sleep 3' >> /start-etherpad.sh && \
    echo 'exec su etherpad -c "cd /opt/etherpad-lite && node src/node/server.js"' >> /start-etherpad.sh && \
    chmod +x /start-etherpad.sh

USER etherpad
WORKDIR /opt/etherpad-lite

EXPOSE 9001

CMD ["/start-etherpad.sh"]
