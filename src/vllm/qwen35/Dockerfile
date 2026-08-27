ARG VLLM_VERSION=0.27.1

FROM vllm/vllm-openai:${VLLM_VERSION}

USER root

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    openssh-server \
    rsync \
    strace \
    lsof \
    psmisc \
    htop \
    sysstat \
    numactl \
    pciutils \
    iproute2 \
    dnsutils \
    curl \
    jq \
    less \
    tree \
    nano \
  && rm -rf /var/lib/apt/lists/* \
  && mkdir -p /run/sshd

EXPOSE 22 8000

COPY --chmod=755 entrypoint.sh /entrypoint.sh

ARG VERSION
ENV VERSION="${VERSION}"

ENTRYPOINT ["/entrypoint.sh"]