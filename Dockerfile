# DO NOT USE THIS FOR RUNNING CONTAINERS PLEASE

# it's a one-off image used just to build the release, not for running it
# the layers are just added onto each other (this final image is HUGE)

FROM aksdhgfkj/elixir

ARG DO_TOKEN

ENV DIGITALOCEAN_TOKEN=${DO_TOKEN}
ENV MIX_ENV=prod
ENV APP_NAME=example

COPY mix.lock .
COPY mix.exs .
RUN mix deps.get --only prod

COPY config ./config
RUN mix deps.compile

COPY lib ./lib
COPY rel ./rel
RUN mix compile
RUN mix release --warnings-as-errors --verbose --env=prod

CMD RELEASE_DIR=`ls -d _build/prod/rel/$APP_NAME/releases/*/` && \
    mv "$RELEASE_DIR/$APP_NAME.tar.gz" /export
