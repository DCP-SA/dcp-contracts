#!/usr/bin/env bash
# Regenerate TypeScript + Python packages from openapi/dcp.yaml.
# Run from repo root: ./scripts/generate.sh

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SPEC="$ROOT/openapi/dcp.yaml"

if [ ! -f "$SPEC" ]; then
  echo "FATAL: $SPEC not found" >&2
  exit 1
fi

echo "→ Validating spec…"
npx --yes @redocly/cli@latest lint "$SPEC"

echo "→ Generating TypeScript types…"
mkdir -p "$ROOT/packages/ts/src"
npx --yes openapi-typescript@latest "$SPEC" -o "$ROOT/packages/ts/src/index.ts"

echo "→ Generating Python pydantic models…"
mkdir -p "$ROOT/packages/python/dcp_contracts"
npx --yes --package=@apidevtools/swagger-cli swagger-cli validate "$SPEC" >/dev/null

# datamodel-code-generator is Python; require it in the runtime env
if ! command -v datamodel-codegen >/dev/null 2>&1; then
  echo "FATAL: datamodel-codegen not on PATH. Install with: pip install datamodel-code-generator" >&2
  exit 1
fi
datamodel-codegen \
  --input "$SPEC" \
  --input-file-type openapi \
  --output "$ROOT/packages/python/dcp_contracts/__init__.py" \
  --target-python-version 3.10 \
  --use-standard-collections \
  --use-union-operator \
  --field-constraints

echo "✓ generated"
echo "  → packages/ts/src/index.ts"
echo "  → packages/python/dcp_contracts/__init__.py"
