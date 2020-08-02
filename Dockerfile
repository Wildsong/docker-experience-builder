FROM node:12
LABEL maintainer="Brian H Wilson brian@wildsong.biz"

ARG snapshot=ArcGISExperienceBuilder
USER node
WORKDIR /home/node
ADD --chown=node ${snapshot} .
WORKDIR /home/node/server

# react and acorn are peer dependencies so I install them explicitly
RUN npm install react && \
    npm install acorn && \
    npm install && npm audit fix

# I played around with doing a multistage build
# but it did not seem to buy me anything.

RUN mkdir -p src/public
VOLUME /home/node/server/src/public

WORKDIR /home/node
EXPOSE 3000/tcp
EXPOSE 3001/tcp
CMD ["node", "server/src/server.js"]
