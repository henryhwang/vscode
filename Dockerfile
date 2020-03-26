FROM node:lts

WORKDIR /vscode

RUN apt-get update && apt-get install -y \
    libx11-dev \
    libxkbfile-dev \
    libsecret-1-dev \
    fakeroot \
    rpm
    
COPY . .

RUN yarn

RUN yarn compile

FROM node:lts-alpine AS copyfiles

WORKDIR /vscode

COPY package.json .
COPY out ./out
COPY scripts ./scripts
COPY extensions ./extensions
COPY src/vs ./src/vs
COPY remote/web ./remote/web
COPY resources ./resources
COPY node_modules/opn ./node_modules/opn
COPY node_modules/vscode-minimist ./node_modules/vscode-minimist
COPY node_modules/is-wsl ./node_modules/is-wsl

FROM node:lts-alpine

WORKDIR /vscode

COPY --from=copyfiles /vscode .

EXPOSE 8081

CMD yarn web \
         --port 8081
