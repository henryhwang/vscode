FROM node:lts AS compiler

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

COPY --from=compiler /vscode/package.json .
COPY --from=compiler /vscode/out ./out
COPY --from=compiler /vscode/scripts ./scripts
COPY --from=compiler /vscode/extensions ./extensions
COPY --from=compiler /vscode/src/vs ./src/vs
COPY --from=compiler /vscode/remote/web ./remote/web
COPY --from=compiler /vscode/resources ./resources
COPY --from=compiler /vscode/node_modules/opn ./node_modules/opn
COPY --from=compiler /vscode/node_modules/vscode-minimist ./node_modules/vscode-minimist
COPY --from=compiler /vscode/node_modules/is-wsl ./node_modules/is-wsl

FROM node:lts-alpine

WORKDIR /vscode

COPY --from=copyfiles /vscode .

EXPOSE 8081

CMD yarn web \
         --port 8081
