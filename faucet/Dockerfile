FROM ubuntu:20.04 AS builder
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies required for Flutter
RUN apt-get update && apt-get install -y \
    git \
    curl \
    unzip \
    xz-utils \
    libglu1-mesa

WORKDIR /builder

# Install fvm. Root is needed for running in Docker
# https://fvm.app/documentation/getting-started/installation#install-script-features
RUN export FVM_ALLOW_ROOT=true && \ 
    curl -fsSL https://fvm.app/install.sh | bash 

COPY .fvmrc .

COPY sail_ui/ ./sail_ui
COPY faucet/ ./faucet

WORKDIR /builder/faucet

RUN fvm use --force
RUN fvm flutter pub get --enforce-lockfile
RUN fvm flutter build web --dart-define=FAUCET_BASE_URL=/api --release

FROM nginx:alpine
COPY --from=builder /builder/faucet/build/web /usr/share/nginx/html
