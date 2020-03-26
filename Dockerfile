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

COPY --from=compiler package.json .
COPY --from=compiler out ./out
COPY --from=compiler scripts ./scripts
COPY --from=compiler extensions ./extensions
COPY --from=compiler src/vs ./src/vs
COPY --from=compiler remote/web ./remote/web
COPY --from=compiler resources ./resources
COPY --from=compiler node_modules/opn ./node_modules/opn
COPY --from=compiler node_modules/vscode-minimist ./node_modules/vscode-minimist
COPY --from=compiler node_modules/is-wsl ./node_modules/is-wsl

FROM node:lts-alpine

WORKDIR /vscode

COPY --from=copyfiles /vscode .

EXPOSE 8081

CMD yarn web \
         --port 8081
