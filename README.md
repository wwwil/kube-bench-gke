# kube-bench-gke

Run kube-bench on Google Kubernetes Engine (GKE). This can only run on regular nodes as master nodes are not accessible in GKE.

```
$ kubectl apply -k ./kube-bench-gke
```

Results can be obtained from the logs of the kube-bench pod:

```
$ kubectl get all
NAME                   READY   STATUS      RESTARTS   AGE
pod/kube-bench-lsj79   0/1     Completed   0          7s

NAME                   COMPLETIONS   DURATION   AGE
job.batch/kube-bench   1/1           4s         7s

$ kubectl logs kube-bench-lsj79 > kube-bench.logs
```

This is based on the [kube-bench EKS job](https://github.com/aquasecurity/kube-bench/blob/master/job-eks.yaml) and [JSON config](https://github.com/aquasecurity/kube-bench/tree/master/cfg/1.11-json). The key difference is that that the `kubelet` config on GKE is located at `/home/kubernetes/kubelet-config.yaml`.

**This is still currently work in progress.** Some test still fail, and likely not all of them will be able to pass due to the restricted settings that GKE offer.
