FROM rust as builder
WORKDIR /tmp
RUN rustup target add x86_64-unknown-linux-gnu

RUN USER=root cargo new play
WORKDIR /tmp/play
COPY Cargo.toml Cargo.lock ./
RUN cargo build --release

COPY src ./src
RUN cargo install --target x86_64-unknown-linux-gnu --path .
RUN ldd /usr/local/cargo/bin/play | tr -s '[:blank:]' '\n' | grep '^/' | \
    xargs -I % sh -c 'mkdir -p $(dirname deps%); cp % deps%;'

FROM scratch
COPY --from=builder /tmp/play/deps /
WORKDIR /run
COPY --from=builder /usr/local/cargo/bin/play /run
Entrypoint ["./play"]
