# kube-bench-gke

Run kube-bench on Google Kubernetes Engine (GKE).

**This is currently just a proof of concept.** Most tests are not yet implemented in a way that accounts for differences in how GKE works. They may give false positives and negatives. This has been developed while investigating use of kube-bench to run custom test suites on GKE. There are currently no plans to convert the existing CIS checks, but the repo is open for collaboration if this is of interest to anyone.

## nodes

This is based on the [kube-bench EKS job](https://github.com/aquasecurity/kube-bench/blob/master/job-eks.yaml) and [JSON config](https://github.com/aquasecurity/kube-bench/tree/master/cfg/1.11-json). The key difference is that that the `kubelet` config on GKE is located at `/home/kubernetes/kubelet-config.yaml`.

## master

Checking the master on GKE is not conventionally possible using kube-bench as it's not possible to access the master nodes.

## deploying

From inside the `kube-bench-gke/` directory deploy the Jobs using Kustomize:

```
$ kubectl apply -k .
```

Results can be obtained from the logs of each kube-bench pod:

```
$ kubectl get all
NAME                          READY   STATUS      RESTARTS   AGE
pod/kube-bench-node-lsj79     0/1     Completed   0          7s

NAME                          COMPLETIONS   DURATION   AGE
job.batch/kube-bench-node     1/1           4s         7s

$ kubectl logs kube-bench-node-lsj79 > kube-bench-node.logs
```
