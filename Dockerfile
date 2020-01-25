FROM node:10
MAINTAINER Brian H Wilson "brian@wildsong.biz"

ARG snapshot

USER node
ADD --chown=node ${snapshot} /home/node/

# Install the node project
WORKDIR /home/node/server
RUN npm ci

# Make way for our widgets
#WORKDIR /home/node/extensions
#RUN cd client && \
#    rm -rf your-extensions && \
#    ln -s ../extensions your-extensions

RUN mkdir -p /home/node/server/src/public
VOLUME /home/node/server/src/public

EXPOSE 3000/tcp
EXPOSE 3001/tcp

WORKDIR /home/node
CMD node server/src/server.js
