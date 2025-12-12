ARG NODE_VERSION=22.18.0
# --------------------
# Base Image (FIXED: Separate RUN steps for reliability)
# --------------------
FROM node:$NODE_VERSION-bullseye-slim AS base
WORKDIR /tmp

# 1. Install core system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    jq \
    libjemalloc2 \
    python3 \
    python3-pip \
    tar \
    git \
    rsync && \
    rm -rf /var/lib/apt/lists/*

# 2. Add Stripe repository key and source list
RUN apt-get update && \
    curl -s https://packages.stripe.dev/api/security/keypair/stripe-cli-gpg/public \
    | gpg --dearmor \
    | tee /usr/share/keyrings/stripe.gpg > /dev/null && \
    echo "deb [signed-by=/usr/share/keyrings/stripe.gpg] https://packages.stripe.dev/stripe-cli-debian-local stable main" \
    | tee -a /etc/apt/sources.list.d/stripe.list > /dev/null && \
    rm -rf /var/lib/apt/lists/*

# 3. Update index, install stripe, and final cleanup
RUN apt-get update && \
    apt-get install -y --no-install-recommends stripe && \
    rm -rf /var/lib/apt/lists/* && \
    apt clean
