# kube-bench-gke

Run kube-bench on Google Kubernetes Engine (GKE).

**This is currently just a proof of concept.** Most tests are not yet implemented in a way that accounts for differences in how GKE works. They may give false positives and negatives. This has been developed while investigating use of kube-bench to run custom test suites on GKE. There are currently no plans to convert the existing CIS checks, but the repo is open for collaboration if this is of interest to anyone.

## nodes

This is based on the [kube-bench EKS job](https://github.com/aquasecurity/kube-bench/blob/master/job-eks.yaml) and [JSON config](https://github.com/aquasecurity/kube-bench/tree/master/cfg/1.11-json). The key difference is that that the `kubelet` config on GKE is located at `/home/kubernetes/kubelet-config.yaml`.

## master

The master nodes of a GKE cluster are not accessible, so kube-bench cannot be run on them directly. Some master checks can be completed however by getting the cluster configuration as a YAML file and checking its values.

The configuration YAML is obtained by running running the `gke-describe.sh` script in an init container before the kube-bench container runs the master checks.

This init container uses the Google Cloud SDK image, and requires a GCP service account to be created with the cluster viewer role. The key for this service account can then be made available to the init container as a Kubernetes secret.

Run the following from inside the `kube-bench-gke/` directory before deploying the resources with Kustomize.

```
$ gcloud iam service-accounts create kube-bench-gke --display-name kube-bench-gke
$ gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member serviceAccount:kube-bench-gke@$PROJECT_ID.iam.gserviceaccount.com \
  --role roles/container.clusterViewer
$ gcloud iam service-accounts keys create key.json \
  --iam-account kube-bench-gke@$PROJECT_ID.iam.gserviceaccount.com
```

**Master tests do not currently work.** Most have not been changed to use the GKE configuration YAML. They may give false positives and negatives. The plan is to go through the tests and convert them:

- Some can be checked by looking at cluster configuration, which is fetched by an init container defined in `job-gke.yaml` using the script in `scripts/gke-describe.sh`.
- Some cannot be checked and are fixed GKE settings. In this case if the fixed setting is compliant the test can return a fixed pass, but should also point to GKE documentation that justifies the pass.
- Some cannot be checked and should therefore always give a warning and direct users to GKE documentation on how they can check the setting manually.

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
pod/kube-bench-master-z5bkp   0/1     Completed   0          7s

NAME                          COMPLETIONS   DURATION   AGE
job.batch/kube-bench-node     1/1           4s         7s
job.batch/kube-bench-master   1/1           2s         7s

$ kubectl logs kube-bench-node-lsj79 > kube-bench-node.logs
$ kubectl logs kube-bench-master-z5bkp > kube-bench-master.logs
```
