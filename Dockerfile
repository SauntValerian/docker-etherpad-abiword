# Simple approach: Use official image + add LibreOffice
FROM etherpad/etherpad:latest

USER root

ARG INSTALL_SOFFICE=true

# Install LibreOffice for document exports  
RUN apk add --no-cache \
    libreoffice \
    ttf-liberation \
    ttf-dejavu \
    fontconfig \
    dbus \
    && fc-cache -fv

USER etherpad

EXPOSE 9001

# Alternative: Build from source (more complex, use if you need absolute latest)
#
# FROM alpine/git as source
# RUN git clone --depth 1 https://github.com/ether/etherpad-lite.git /etherpad-lite
# 
# FROM node:18-alpine
# WORKDIR /opt/etherpad-lite
# COPY --from=source /etherpad-lite .
# RUN apk add --no-cache shadow bash
# 
# ARG INSTALL_SOFFICE=true
# RUN if [ "$INSTALL_SOFFICE" = "true" ]; then \
#     apk add --no-cache libreoffice ttf-liberation ttf-dejavu fontconfig dbus && fc-cache -fv; \
# fi
# 
# RUN groupadd --system etherpad && useradd --system --gid etherpad --create-home etherpad
# RUN chown -R etherpad:etherpad /opt/etherpad-lite
# USER etherpad
# RUN npm install --only=production
# USER root
# RUN if [ -f settings.json.docker ]; then cp settings.json.docker settings.json; fi
# USER etherpad
# CMD ["node", "src/node/server.js"]
