# dcp-contracts

Single source of truth for API contracts between the three DCP production repos:

- [`dcp-platform`](https://github.com/DCP-SA/dcp-platform) — backend + dcp.sa site + agent gateway
- [`dcp-agent`](https://github.com/DCP-SA/dcp-agent) — provider-machine brain
- [`dcp-desktop`](https://github.com/DCP-SA/dcp-desktop) — Tauri installer

Define the shape once here. All clients consume generated types. Drift between server and client = caught at build time, not in production.

## Repo layout

```
dcp-contracts/
├── openapi/
│   └── dcp.yaml              # OpenAPI 3.1 spec — the source of truth
├── packages/
│   ├── ts/                   # @dcp-sa/contracts (TypeScript, for dcp-platform + dcp-desktop)
│   └── python/               # dcp_contracts (Python, for dcp-agent)
├── scripts/
│   └── generate.sh           # regen all packages from openapi/dcp.yaml
└── .github/workflows/        # validate spec + diff-check + publish on tag
```

## Workflow

1. Need a new endpoint or schema change? Edit `openapi/dcp.yaml`.
2. Run `./scripts/generate.sh` → regenerates `packages/ts/` and `packages/python/`.
3. Commit. CI validates the spec, regenerates, fails the build if anything in `packages/` is stale (proves the generator stayed in sync).
4. Tag a release (`vX.Y.Z`). Release workflow publishes both `@dcp-sa/contracts@X.Y.Z` to npm and `dcp-contracts==X.Y.Z` to PyPI.
5. Open PRs in `dcp-platform`, `dcp-agent`, `dcp-desktop` to bump the pinned version.

## Versioning

Semver. **Breaking schema changes require a major bump** and a coordinated PR train across all 3 consumers.

- MAJOR: removed field, renamed field, type-narrowed an existing field
- MINOR: added field (optional), added endpoint
- PATCH: docs / examples / non-schema cleanup

## Consumers — usage

### TypeScript (`dcp-platform`, `dcp-desktop`)

```bash
npm install @dcp-sa/contracts@^1.0.0
```

```ts
import type { HeartbeatRequest, HeartbeatResponse } from "@dcp-sa/contracts";
```

### Python (`dcp-agent`)

```bash
pip install dcp-contracts==1.0.0
```

```python
from dcp_contracts import HeartbeatRequest, HeartbeatResponse
```

## Generation

`./scripts/generate.sh` uses:
- [`openapi-typescript`](https://github.com/openapi-ts/openapi-typescript) for TS types
- [`datamodel-code-generator`](https://github.com/koxudaxi/datamodel-code-generator) for Python pydantic models

No runtime code is in this repo — only spec + generated types. Keep it that way.
