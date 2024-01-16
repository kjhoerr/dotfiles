---
title: Failure in '{{ github.workflow }}' workflow {{ date | date('YYYY-MM-DD') }}
assignees: kjhoerr
labels: bug
---
Failure occurred while testing system and home-manager configurations after updating flake inputs.

See workflow run: {{ env.WORKFLOW_JOB_URL }}
