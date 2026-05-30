# dcp-contracts (Python)

Python pydantic v2 models for the DCP shared API contracts, generated from
[`openapi/dcp.yaml`](https://github.com/DCP-SA/dcp-contracts/blob/main/openapi/dcp.yaml).

Consumed by [`dcp-agent`](https://github.com/DCP-SA/dcp-agent).

```bash
pip install dcp-contracts
```

```python
from dcp_contracts import HeartbeatRequest, HeartbeatResponse
```

Do not edit `dcp_contracts/__init__.py` by hand — it is generated. Edit the spec
and run `./scripts/generate.sh` from the repo root.

See the [repository README](https://github.com/DCP-SA/dcp-contracts) for the full
workflow and versioning policy.
