FROM ghcr.io/actions/actions-runner@sha256:0cfdcc701ce933c6d243c6b0b2da767366dc9f2e99961d4c3754b0b78084cdda

USER root

RUN install -d -m 0755 /etc/apt/keyrings \
    && curl --fail --silent --show-error --location \
      https://packages.microsoft.com/keys/microsoft.asc \
      | gpg --dearmor --output /etc/apt/keyrings/microsoft.gpg \
    && chmod a+r /etc/apt/keyrings/microsoft.gpg \
    && printf '%s\n' \
      'Types: deb' \
      'URIs: https://packages.microsoft.com/repos/azure-cli/' \
      'Suites: noble' \
      'Components: main' \
      'Architectures: amd64' \
      'Signed-By: /etc/apt/keyrings/microsoft.gpg' \
      > /etc/apt/sources.list.d/azure-cli.sources \
    && apt-get update \
    && apt-get install --yes --no-install-recommends azure-cli gh python-is-python3 \
    && az extension add --name containerapp --system --yes \
    && rm -rf /var/lib/apt/lists/*

RUN curl --fail --location --output /tmp/node.tar.gz \
      https://nodejs.org/dist/v24.13.0/node-v24.13.0-linux-x64.tar.gz \
    && echo "6223aad1a81f9d1e7b682c59d12e2de233f7b4c37475cd40d1c89c42b737ffa8  /tmp/node.tar.gz" \
      | sha256sum --check \
    && tar --extract --gzip --file /tmp/node.tar.gz --directory /usr/local --strip-components 1 \
    && rm /tmp/node.tar.gz

COPY entrypoint.sh /usr/local/bin/cardmystic-runner-entrypoint
RUN chmod 0755 /usr/local/bin/cardmystic-runner-entrypoint

USER runner
RUN az bicep install

ENTRYPOINT ["/usr/local/bin/cardmystic-runner-entrypoint"]
