#!/bin/bash

# without persistent storage
kubectl create deployment --image=jupyter/tensorflow-notebook:latest jupyter
kubectl get pods
kubectl logs jupyter-95bb6ffff-wb9r4 
kubectl port-forward jupyter-95bb6ffff-wb9r4 8888:8888

# with persistent storage
kubectl create deployment --image=jupyter/tensorflow-notebook:latest jupyter --dry-run -o yaml > /tmp/deploy.yaml
code-insiders /tmp/deploy.yaml
kubectl apply -f /tmp/deploy.yaml

# or
cat <<EOF > /tmp/deploy.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: jupyter
  name: jupyter
spec:
  replicas: 1
  selector:
    matchLabels:
      app: jupyter
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: jupyter
    spec:
      containers:
      - image: jupyter/tensorflow-notebook:latest
        name: tensorflow-notebook
        resources: {}
        volumeMounts:
        - name: persistent-storage
          mountPath: /home/jovyan/fsx
      volumes:
      - name: persistent-storage
        persistentVolumeClaim:
          claimName: fsx-claim
      securityContext:
        fsGroup: 100
status: {}
EOF

# workaround
cat <<EOF > /tmp/deploy.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: jupyter
  name: jupyter
spec:
  replicas: 1
  selector:
    matchLabels:
      app: jupyter
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: jupyter
    spec:
      initContainers:
      - image: busybox:1.28
        name: fsx-bug-fix
        resources: {}
        volumeMounts:
        - name: persistent-storage
          mountPath: /home/jovyan/fsx
        command: ['sh', '-c', "chmod 777 /home/jovyan/fsx"]
      containers:
      - image: jupyter/tensorflow-notebook:latest
        name: tensorflow-notebook
        resources: {}
        volumeMounts:
        - name: persistent-storage
          mountPath: /home/jovyan/fsx
      volumes:
      - name: persistent-storage
        persistentVolumeClaim:
          claimName: fsx-claim
      securityContext:
        fsGroup: 100
status: {}
EOF

kubectl apply -f /tmp/deploy.yaml
kubectl get pods
kubectl logs jupyter-795f49ddfd-4gsr4
kubectl port-forward jupyter-795f49ddfd-4gsr4  8888:8888