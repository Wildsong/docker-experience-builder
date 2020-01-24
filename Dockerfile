FROM node:10
MAINTAINER Brian H Wilson "brian@wildsong.biz"

USER node
ADD --chown=node exb-beta-snapshot /home/node/

WORKDIR /home/node/server
RUN npm ci

# Make way for our widgets
WORKDIR /home/node
RUN mkdir extensions && \
    cd client && \
    rm -rf your-extensions && \
    ln -s ../extensions your-extensions

VOLUME /home/node/extensions
VOLUME /home/node/apps
EXPOSE 3000/tcp
EXPOSE 3001/tcp

WORKDIR /home/node/server
CMD node src/server
