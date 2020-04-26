Get ip address of pods:

```bash
kubectl get pods -o wide
```

View more useful information:

```bash
kubectl get all -o wide
```

Get the yaml config of a resources e.g. pod  `jupyter-6954b9cb48-hswbg`. This can be used as a template to create other pods:

```bash
kubectl get pod jupyter-6954b9cb48-hswbg  -o yaml
```

To find out what resources are avaiable:

```bash
kubectl api-resources
```

To figure out the versions of a resource:

```bash
kubectl api-resources
```

To figure out the config of a resource e.g. `deployments`:

```bash
kubectl explain deployments
kubectl explain deployments.spec.template
```

Convenient way to create yaml files as a template:

```bash
kubectl create deployment --image zeppelin/zeppelin zeppelin --dry-run -o yaml > /tmp/zeppelin.yaml
```

Describe a running resource e.g. pod:

```bash
kubectl describe pods zeppelin-pod 
```

Edit a running resource:

```bash
export EDITOR="code-insiders --wait"
kubectl edit pods zeppelin-pod 
``

