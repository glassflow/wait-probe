# wait-probe

Minimal non-root probe image for Kubernetes and OpenShift init containers.

Built on `alpine:3.20` + `netcat-openbsd`. Uses `nc -z` for TCP port checks — purpose-built for the task, ~80KB vs the ~8MB curl equivalent. Runs as a **numeric UID** (`100`) to work correctly under both:

- **Standard Kubernetes** with [Pod Security Standards](https://kubernetes.io/docs/concepts/security/pod-security-standards/) `restricted` profile — the kubelet can validate that UID 100 ≠ 0 without a `runAsUser` override in the pod spec.
- **OpenShift `restricted-v2` SCC** (MustRunAsRange) — no `runAsUser` in the pod spec means OpenShift injects a UID from the namespace range freely, no conflict.

## Usage

```yaml
initContainers:
  - name: wait-for-postgres
    image: ghcr.io/glassflow/wait-probe:latest
    securityContext:
      runAsNonRoot: true
      seccompProfile:
        type: RuntimeDefault
    command:
      - sh
      - -c
      - |
        until nc -z postgres-host 5432; do
          echo "Waiting for postgres..."
          sleep 2
        done
```

Works for any TCP service (Postgres, NATS, Redis) without protocol-specific workarounds.

## Image

```
ghcr.io/glassflow/wait-probe:latest
```

Multi-arch: `linux/amd64`, `linux/arm64`.
