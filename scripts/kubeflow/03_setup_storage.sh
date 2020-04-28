#!/bin/bash

cat <<EOF > /tmp/claim-kf.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: fsx-claim-kf
  namespace: anonymous
spec:
  accessModes:
    - ReadWriteMany
  storageClassName: fsx-sc
  resources:
    requests:
      storage: 1200Gi
EOF

kubectl apply -f /tmp/claim-kf.yaml