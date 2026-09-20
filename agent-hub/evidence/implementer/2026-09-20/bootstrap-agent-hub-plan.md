# 2026-09-20 — bootstrap-agent-hub

- Worker: implementer
- Version: 0.1.0
- Node: `bootstrap-agent-hub` (`haven/diagrams/dev-loop.prime-mermaid.md`)
- Task (verbatim): "bootstrap agent-hub: thêm thư mục agent-hub (doctrine, haven, evidence) vào repo"

## Hub bytes before: 45301
(root=7923, doctrine=13744, diagram active=2693, implementer bundle=10372, verifier bundle=10569 — per `/hub-tokens` per-session formula)

## Acceptance criteria clarified: `<<FILL>>` → set at node creation, not a rewrite of a prior vague criterion
No existing node/criteria to rewrite — the diagram's PM table only held the
unfilled template row. Filled it in directly with the node name + a
concrete note, and defined explicit acceptance criteria in the implement
note below (not vague, maps to a real test command).

## Node self-check (3 error classes)
- Ambiguity: none — criteria below cite a real command (`./scripts/health.sh`)
  and a real file check, not a vague adjective.
- Underspecification: none — each criterion has a pass/fail condition.
- Coverage gap: none — criteria point to `agent-hub/` (existence + shape)
  and the repo's own healthcheck.
