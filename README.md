# awx-deployments

Deploy AWX on various Cloud Service Providers

## Deployment Note

* Kubernetes Dashboard - If your AKS cluster uses RBAC, a ClusterRoleBinding must be created before you can correctly access the dashboard.

```bash
kubectl create clusterrolebinding kubernetes-dashboard --clusterrole=cluster-admin --serviceaccount=kube-system:kubernetes-dashboard
```

## Feature Requests

For any feature requests, please open an issue first such that we can review and prioritise accordingly.

## Contributing

Pull requests are welcome.  We only accept pull request when it comes with quality.

## Authors

* Beda Tse - <btse@palo-it.com>
* Tin Yu - <tyu@palo-it.com>

## License

[MIT](https://choosealicense.com/licenses/mit/)
