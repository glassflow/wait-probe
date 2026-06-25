FROM alpine:3.20
RUN apk add --no-cache netcat-openbsd
# Alpine's default user is root (UID 0). Declaring a numeric UID here means:
#   - Standard Kubernetes: kubelet sees UID 100 != 0, runAsNonRoot passes
#     with no runAsUser override needed in the pod spec.
#   - OpenShift restricted-v2 SCC (MustRunAsRange): no runAsUser in the pod
#     spec means OpenShift injects a UID from the namespace range freely.
USER 100
