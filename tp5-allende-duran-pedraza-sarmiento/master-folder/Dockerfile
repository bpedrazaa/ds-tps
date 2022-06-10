FROM node:latest

WORKDIR /usr/src/app

COPY package*.json ./

RUN npm install

COPY . .

ENV TOPICPUB 'upb/file/result'
ENV TOPICSUB 'upb/file/search'
ENV HOST 'research.upb.edu'
ENV PORT 21212

CMD [ "node", "masterSC.js" ]