ARG VLLM_VERSION=0.27.1

FROM vllm/vllm-openai:${VLLM_VERSION}

COPY --chmod=755 entrypoint.sh /entrypoint.sh

ARG VERSION
ENV VERSION="${VERSION}"

ENTRYPOINT ["/entrypoint.sh"]