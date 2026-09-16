FROM ghcr.io/actions/actions-runner@sha256:0cfdcc701ce933c6d243c6b0b2da767366dc9f2e99961d4c3754b0b78084cdda

USER root

RUN apt-get update \
    && apt-get install --yes --no-install-recommends \
      build-essential ca-certificates gh iptables kmod openssh-client \
      python-is-python3 python3-venv xz-utils zip \
    && rm -rf /var/lib/apt/lists/* \
    && command -v dockerd \
    && command -v containerd

RUN curl --fail --location --output /usr/local/bin/dind \
      https://raw.githubusercontent.com/docker/docker/8d9e3502aba39127e4d12196dae16d306f76993d/hack/dind \
    && chmod 0755 /usr/local/bin/dind

RUN curl --fail --location --output /tmp/node.tar.gz \
      https://nodejs.org/dist/v24.13.0/node-v24.13.0-linux-x64.tar.gz \
    && echo "6223aad1a81f9d1e7b682c59d12e2de233f7b4c37475cd40d1c89c42b737ffa8  /tmp/node.tar.gz" \
      | sha256sum --check \
    && tar --extract --gzip --file /tmp/node.tar.gz --directory /usr/local --strip-components 1 \
    && rm /tmp/node.tar.gz

ARG PLAYWRIGHT_VERSION=1.61.1
RUN PLAYWRIGHT_BROWSERS_PATH=/opt/playwright \
      npx --yes playwright@${PLAYWRIGHT_VERSION} install --with-deps chromium \
    && chmod -R a+rX /opt/playwright \
    && rm -rf /var/lib/apt/lists/* /root/.npm

ENV RUNNER_TOOL_CACHE=/runner-cache/toolcache \
    AGENT_TOOLSDIRECTORY=/runner-cache/toolcache \
    DOTNET_INSTALL_DIR=/runner-cache/dotnet \
    PLAYWRIGHT_BROWSERS_PATH=/runner-cache/playwright \
    DOCKER_HOST=unix:///var/run/docker.sock

COPY entrypoint.sh /usr/local/bin/cardmystic-runner-entrypoint
RUN chmod 0755 /usr/local/bin/cardmystic-runner-entrypoint

ENTRYPOINT ["/usr/local/bin/cardmystic-runner-entrypoint"]