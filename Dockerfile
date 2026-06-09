FROM curlimages/curl:latest
# curlimages/curl declares USER as the string "curl_user". Kubernetes requires
# a numeric UID to validate runAsNonRoot — it cannot verify a string username
# is non-root. Redeclaring with the numeric UID (100) means:
#   - Standard Kubernetes: kubelet sees UID 100 != 0, runAsNonRoot passes
#     with no runAsUser override needed in the pod spec.
#   - OpenShift restricted-v2 SCC (MustRunAsRange): no runAsUser in the pod
#     spec means OpenShift injects a UID from the namespace range freely.
# No other change — same curl binary, same capabilities, same image size.
USER 100
