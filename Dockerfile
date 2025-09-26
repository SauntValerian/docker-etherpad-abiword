# Use Node.js LTS as base image
FROM node:18-bullseye

# Set working directory
WORKDIR /opt/etherpad-lite

# Install system dependencies including Abiword and X11 virtual framebuffer
RUN apt-get update && apt-get install -y \
    # Essential build tools
    build-essential \
    python3 \
    make \
    g++ \
    git \
    curl \
    # Abiword and dependencies for headless operation
    abiword \
    xvfb \
    xauth \
    # Additional dependencies for document processing
    libxml2-dev \
    libxslt1-dev \
    # Clean up apt cache to reduce image size
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Clone Etherpad repository
RUN git clone --branch master https://github.com/ether/etherpad-lite.git .

# Install Node.js dependencies
RUN npm install --no-audit --no-fund

# Create a virtual display script for headless Abiword
RUN echo '#!/bin/bash\n\
# Start Xvfb (X Virtual Framebuffer) for headless operation\n\
Xvfb :99 -screen 0 1024x768x24 -ac +extension GLX +render -noreset &\n\
export DISPLAY=:99\n\
# Wait a moment for Xvfb to start\n\
sleep 2\n\
# Start Etherpad\n\
exec "$@"' > /opt/start-etherpad.sh \
    && chmod +x /opt/start-etherpad.sh

# Set display environment variable for headless operation
ENV DISPLAY=:99

# Create etherpad user for security
RUN useradd --system --create-home --home-dir /opt/etherpad-lite etherpad \
    && chown -R etherpad:etherpad /opt/etherpad-lite

# Switch to etherpad user
USER etherpad

# Expose port 9001 (default Etherpad port)
EXPOSE 9001

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:9001/ || exit 1

# Use the startup script as entrypoint
ENTRYPOINT ["/opt/start-etherpad.sh"]

# Default command to start Etherpad
CMD ["node", "src/node/server.js"]
