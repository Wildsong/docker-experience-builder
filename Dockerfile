FROM node:12
LABEL maintainer="Brian H Wilson brian@wildsong.biz"

USER node
WORKDIR /home/node

ARG snapshot
ADD --chown=node ${snapshot} .
RUN unzip ${snapshot} && \
    rm ${snapshot}

WORKDIR /home/node/ArcGISExperienceBuilder/server/

# react and acorn are peer dependencies so I install them explicitly
RUN npm install react && \
    npm install acorn && \
    npm install && npm audit fix

RUN mkdir -p src/public
#VOLUME /home/node/server/src/public

EXPOSE 3000/tcp
EXPOSE 3001/tcp

WORKDIR /home/node/ArcGISExperienceBuilder
ENTRYPOINT ["node", "server/src/server.js"]
