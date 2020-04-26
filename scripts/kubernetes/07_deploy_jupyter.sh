#!/bin/bash

kubectl create deployment --image=jupyter/tensorflow-notebook:latest jupyter
kubectl get pods
kubectl logs jupyter-744878d984-pm7fh
kubectl port-forward jupyter-744878d984-pm7fh 8888:8888