# llama.cpp / Ollama Notes

Pocket Pets must work without an LLM. Dynamic pet lines are a final, optional
slice behind `OLLAMA_PET_LINES=true`.

Current findings:

- Dispersed Docker image docs include an SSH-enabled example based on
  `ghcr.io/ggml-org/llama.cpp:server-cuda`.
- The official llama.cpp server image exposes an OpenAI-compatible HTTP API, so
  it can be called directly as `/v1/chat/completions`.
- The existing Pocket Pets plan uses the Ollama chat API shape at `/api/chat`.
  Keep this as an implementation detail behind configuration, not as a core
  gameplay dependency.
- For the hackathon MVP, prefer canned `jido_character` expressions. If local
  inference is enabled, call only on feed/play/nap/choose/death/mood-change,
  never on the 2-second tick.

Open deployment question:

- If Dispersed supports only one container per Docker job, a combined Phoenix +
  llama.cpp image or a separate persistent inference job with an internal/public
  URL will be needed. Do not block the core Phoenix deployment on this.
