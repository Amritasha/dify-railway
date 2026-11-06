# Dify on Railway

A production-shaped deployment of [Dify](https://dify.ai) 1.19.0 — the open-source
platform for building LLM apps, agents, RAG pipelines and workflows.

This is not a one-click wrapper around `docker-compose up`. Dify's compose file
makes three assumptions that quietly break on Railway, and the fixes are the
reason this repo exists.

## The three things that break, and why

### 1. `api` and `worker` share a storage directory

Dify's compose mounts the same `./volumes/app/storage` into both the API and the
worker. On Railway a volume attaches to exactly one service, so you get one of
two outcomes: a volume on the API and a worker that cannot read the files it is
meant to index, or no volume at all.

The second failure is worse than it sounds. With `KEY_PROVIDER_TYPE=local`,
Dify stores each workspace's RSA **private key** in that storage backend and uses
it to encrypt the model-provider credentials you save. Put that on an ephemeral
container filesystem and the next redeploy throws the key away — your saved API
keys are still in Postgres, now permanently undecryptable, and the console starts
reporting your provider credentials as invalid.

This template uses a **Railway bucket** (S3) for application storage, so the API,
the worker and the beat scheduler all read the same objects and the tenant keys
outlive a redeploy.

### 2. Everything binds IPv4

Railway's private network is IPv6-only. `gunicorn` defaults to `0.0.0.0`, and so
does Next.js, so both come up healthy and are then unreachable from nginx — a
green dashboard and a 502 in the browser. The API sets `DIFY_BIND_ADDRESS=::`
and the web service sets `HOSTNAME=::`.

### 3. nginx resolves its upstreams once

Dify's routing is not optional: `/console/api`, `/v1`, `/files` and `/e/` have to
reach three different services, so something has to sit in front. A plain
`proxy_pass http://api.railway.internal:5001` is resolved at startup and cached
forever, which means the gateway 502s the first time the API redeploys and gets a
new private address. The gateway here resolves through Railway's internal DNS
(`[fd12::10]`) on a one-second TTL, with the upstream held in a variable so nginx
re-resolves per request.

## Services

| Service | Image | What it does |
|---|---|---|
| `nginx` | built here | Public entrypoint; routes console, API, files and plugin webhooks |
| `web` | `langgenius/dify-web:1.19.0` | The console and the published app UI |
| `api` | `langgenius/dify-api:1.19.0` | REST API; owns database migrations |
| `worker` | same image, `MODE=worker` | Document indexing, embeddings, mail, scheduled workflows |
| `worker-beat` | same image, `MODE=beat` | Celery scheduler for periodic jobs |
| `plugin-daemon` | `dify-plugin-daemon:0.6.14` | Installs and runs model providers and tools |
| `sandbox` | `dify-sandbox:0.2.15` | Confined execution of workflow code nodes |
| `ssrf-proxy` | Alpine squid, built here | Blocks workflow HTTP requests aimed at your private network |
| `postgres` | `pgvector/pgvector:pg16` | App database, vector store, and the plugin daemon's database |
| `redis` | Railway Redis | Celery broker and cache |
| `Bucket` | Railway bucket | Uploaded files, generated files, tenant encryption keys |

Only the API runs migrations (`MIGRATION_ENABLED=true`); the worker and beat
have it off, because two containers running Alembic at once race on the same
version row.

## Why pgvector instead of a separate vector database

Dify supports Weaviate, Qdrant, Milvus and a dozen others. Each is another
service to pay for and keep alive. `pgvector` puts the embeddings in the Postgres
you already have, which is enough for a knowledge base of a few hundred thousand
chunks and removes a whole failure mode. The Postgres image here also creates the
`dify_plugin` database on first boot, which the plugin daemon needs and will not
create itself.

If you outgrow it, set `VECTOR_STORE` to another backend and point the matching
variables at it. Nothing else has to change.

## After you deploy

1. Open the public URL and create the admin account. **Do this immediately** —
   the setup page is open to whoever reaches it first.
2. Go to Settings → Model Provider and install a provider plugin (OpenAI,
   Anthropic, or an OpenAI-compatible gateway). The model list is empty until a
   plugin is installed; that is normal, not a broken deploy.
3. Add your API key to the provider.
4. Build something, then check the worker's logs once — document indexing is the
   first thing that exercises the bucket, so it is where a storage misconfiguration
   would show up.

## Things worth knowing

**The agent sandbox is not included.** Dify 1.19 ships `agent_backend` and a
`local_sandbox` that gives agents a shell. It expects Docker-level isolation and
its own private network segments, which Railway does not offer; running it without
that isolation would hand workflow authors a shell with reach into your project.
Code nodes still work through `sandbox`.

**KnowledgeFS is not included.** The five-worker KnowledgeFS pipeline is opt-in
even in Dify's own compose file and needs an image that bundles its engine.

**Plugin storage is on a volume.** Installed plugins live on the plugin daemon's
volume. It is small, and it is the one place where losing the disk means
reinstalling your providers.

**Costs.** Ten services is not a hobby deployment. The containers idle cheaply,
but this is a real stack; the model provider will still be the larger bill.

## Credits

Dify is built by [LangGenius](https://github.com/langgenius/dify) and licensed
under a modified Apache 2.0. This repository only contains the Railway-specific
configuration.
