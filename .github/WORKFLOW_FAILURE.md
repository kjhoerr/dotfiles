---
title: Failure in '{{ env.WORKFLOW_NAME }}' workflow {{ date | date('YYYY-MM-DD') }}
assignees: kjhoerr
labels: bug, build-failure
---
Failure occurred while testing system and home-manager configurations after updating flake inputs.

See workflow run: {{ env.WORKFLOW_JOB_URL }}
