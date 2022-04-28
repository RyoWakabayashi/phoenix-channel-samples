FROM elixir:1.13.4

ENV NODE_VERSION 16.x

RUN curl -sL https://deb.nodesource.com/setup_${NODE_VERSION} | bash \
  && apt-get install -y nodejs

RUN npm install npm@latest yarn@latest -g

RUN mix local.hex --force \
  && mix archive.install hex phx_new --force \
  && mix local.rebar --force

COPY ./react_chat /app

WORKDIR /app

RUN mix deps.get

# RUN mix compile.phoenix

RUN cd assets && yarn install

EXPOSE 4000

CMD [ "mix", "phx.server" ]
