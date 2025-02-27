FROM ubuntu:20.04 AS builder
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies required for Flutter
RUN apt-get update && apt-get install -y \
    git \
    curl \
    unzip \
    xz-utils \
    libglu1-mesa

# Install Flutter SDK (cloning the stable channel)
RUN git clone https://github.com/flutter/flutter.git /opt/flutter -b stable
ENV PATH="/opt/flutter/bin:/opt/flutter/bin/cache/dart-sdk/bin:/opt/flutter/bin:${PATH}"

WORKDIR /builder

COPY clients/sail_ui/ ./clients/sail_ui
COPY clients/faucet/ ./clients/faucet

WORKDIR /builder/clients/faucet

RUN flutter pub get --enforce-lockfile
RUN flutter build web --dart-define=FAUCET_BASE_URL=/api --release

FROM nginx:alpine
COPY --from=builder /builder/clients/faucet/build/web /usr/share/nginx/html
