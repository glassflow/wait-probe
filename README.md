# wait-probe

Minimal non-root probe image for Kubernetes and OpenShift init containers.

A thin wrapper over [`curlimages/curl`](https://hub.docker.com/r/curlimages/curl) that redeclares the user as a **numeric UID** (`100`) instead of the string `curl_user`. This single change makes the image work correctly under both:

- **Standard Kubernetes** with [Pod Security Standards](https://kubernetes.io/docs/concepts/security/pod-security-standards/) `restricted` profile — the kubelet can validate that UID 100 ≠ 0 without a `runAsUser` override in the pod spec.
- **OpenShift `restricted-v2` SCC** (MustRunAsRange) — no `runAsUser` in the pod spec means OpenShift injects a UID from the namespace range freely, no conflict.

Without a numeric UID, Kubernetes rejects the container with:
```
container has runAsNonRoot and image has non-numeric user (curl_user), cannot verify user is non-root
```

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
        until (curl --silent --connect-timeout 2 --max-time 3 \
          "http://postgres-host:5432" >/dev/null 2>&1; [ $? -ne 7 ]); do
          echo "Waiting for postgres..."
          sleep 2
        done
```

The curl TCP probe uses exit code semantics: `7` = connection refused (not ready), anything else = TCP connection made (ready).

## Image

```
ghcr.io/glassflow/wait-probe:latest
```

Multi-arch: `linux/amd64`, `linux/arm64`.
