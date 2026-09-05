to run qwen3.8 with preserved thinking:

use responses api from vllm's open ai server. litellm supports responses, I setup My models as custom open AI. no config needed on litellm, should work oob. test with:

# Direct
curl http://vllm:8000/v1/responses ...

# Through LiteLLM
curl http://litellm:4000/v1/responses ...

now only need a supported frontend that sends responses requests instead of chat/completions. open hands has support for responses only in SDK mode (code) not web frontend, and even if it did, it doesn't stream.
open web ui has responses support in ui and streams, seems to fit, maybe bugs and needs testing.

ENABLE_RESPONSES_API_STATEFUL=true on open web ui potentially problematic, avoid until support lands in vllm and litellm. not needed, stay stateless.



Open WebUI

    ↓

input = complete conversation, including reasoning items

    ↓

LiteLLM /v1/responses

    ↓

vLLM /v1/responses

    ↓

Qwen3.8