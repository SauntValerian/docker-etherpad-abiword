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
    supervisor \
    && fc-cache -fv

# Create supervisor config to run Xvfb
RUN echo '[supervisord]' > /etc/supervisor/conf.d/supervisord.conf && \
    echo 'nodaemon=true' >> /etc/supervisor/conf.d/supervisord.conf && \
    echo 'user=root' >> /etc/supervisor/conf.d/supervisord.conf && \
    echo '' >> /etc/supervisor/conf.d/supervisord.conf && \
    echo '[program:xvfb]' >> /etc/supervisor/conf.d/supervisord.conf && \
    echo 'command=Xvfb :99 -screen 0 1024x768x24 -ac +extension GLX +render -noreset' >> /etc/supervisor/conf.d/supervisord.conf && \
    echo 'autorestart=true' >> /etc/supervisor/conf.d/supervisord.conf && \
    echo 'user=root' >> /etc/supervisor/conf.d/supervisord.conf && \
    echo '' >> /etc/supervisor/conf.d/supervisord.conf && \
    echo '[program:etherpad]' >> /etc/supervisor/conf.d/supervisord.conf && \
    echo 'command=node src/node/server.js' >> /etc/supervisor/conf.d/supervisord.conf && \
    echo 'directory=/opt/etherpad-lite' >> /etc/supervisor/conf.d/supervisord.conf && \
    echo 'user=etherpad' >> /etc/supervisor/conf.d/supervisord.conf && \
    echo 'environment=DISPLAY=":99"' >> /etc/supervisor/conf.d/supervisord.conf

# Expose Etherpad port
EXPOSE 9001

# Start supervisor to manage both Xvfb and Etherpad
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
