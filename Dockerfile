FROM node:lts

WORKDIR /vscode

RUN apt-get update && apt-get install -y \
    libx11-dev \
    libxkbfile-dev \
    libsecret-1-dev \
    fakeroot \
    rpm
    
RUN git clone https://github.com/henryhwang/vscode.git .

RUN yarn

RUN yarn compile

EXPOSE 8081

CMD yarn web \
         --port 8081
