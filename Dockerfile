# Build Etherpad with LibreOffice using official method

FROM alpine/git as source
RUN git clone --depth 1 https://github.com/ether/etherpad-lite.git /etherpad-lite

FROM node:18-alpine
WORKDIR /opt/etherpad-lite

# Copy source from git  
COPY --from=source /etherpad-lite .

# Install system dependencies
RUN apk add --no-cache shadow bash

# Set build argument for LibreOffice (official method)
ARG INSTALL_SOFFICE=true

# Install LibreOffice using official Etherpad build process
RUN if [ "$INSTALL_SOFFICE" = "true" ]; then \
    apk add --no-cache \
    libreoffice \
    ttf-liberation \
    ttf-dejavu \
    fontconfig \
    dbus \
    && fc-cache -fv; \
fi

# Create etherpad user (following official Dockerfile)
RUN groupadd --system etherpad && \
    useradd --system --gid etherpad --create-home etherpad

# Set ownership
RUN chown -R etherpad:etherpad /opt/etherpad-lite

# Install Node.js dependencies
USER etherpad
RUN npm ci --only=production

# Switch back to root for final setup
USER root

# Copy the official settings template
RUN if [ -f settings.json.docker ]; then cp settings.json.docker settings.json; fi

# Set final user and working directory
USER etherpad
WORKDIR /opt/etherpad-lite

EXPOSE 9001

# Use the standard Etherpad startup
CMD ["node", "src/node/server.js"]

# Alternative: Simpler approach using official image
# FROM etherpad/etherpad:latest
# USER root
# RUN apk add --no-cache libreoffice ttf-liberation ttf-dejavu fontconfig dbus && fc-cache -fv
# USER etherpad
