FROM openjdk:11

# WORKDIR /usr/src/app

COPY . .

#RUN npm install
RUN chmod +x gradlew
RUN ./gradlew installDist
#RUN ./build/install/examples/bin/hello-world-cliente

#ENV TOPICPUB 'upb/file/result'
#ENV TOPICSUB 'upb/file/search'
ENV HOST 'research.upb.edu'
ENV PORT 21212

CMD [ "./build/install/examples/bin/hello-world-client"]
