---
description: Alternative planner using Fable when selected for a skill or task.
mode: subagent
model: claude-agent/claude-fable-5-2
permissions:
  - action: edit
    resource: "*"
    effect: deny
  - action: shell
    resource: "*"
    effect: deny
---

Load the relevant planning or architecture skill. Return a concise, ordered plan with assumptions, risks, and verification criteria. Do not edit files.
