# Provide additional permissions to an user

IBM Cloud private (and Kubernetes) comes with a RBAC mechanism. So the users of the platform have some permissions, depending of their profiles.
If, for some functional reasons, you need to grant additional permissions to an user, it is possible by using roles (`clusterroles` or `roles) and binding (`clusterrolebindings` and `rolebindings`).

In this entry, I cover the functional case where
a developer needs to push images in the ICp image registry but have no other permissions on ICp platform except the view.

1. Create an user with `viewer` profile.
![Users from team view](./images/rbac_add_priviledges_1.png)
  The sample in this page is base on an user `tadeveloper` who is member of `teama` and has namespece `nsta` as resources.

2. Create a file describing the new `clusterroles` providing additional priviledges.
  ```
  kind: ClusterRole
  apiVersion: rbac.authorization.k8s.io/v1
  metadata:
    name: icp:develop
    labels:
      kubernetes.io/bootstrapping: rbac-defaults
  rules:
  - apiGroups: ["icp.ibm.com"]
    resources: ["images"]
    verbs: ["create", "get", "list", "patch", "update", "watch"]

  ```
  The new cluster role,named `icp:develop` provide permission on images (ìmages.icp.ibm.come) except `delete permissions

3. Create the new `clusterroles`.
```
kubectl apply -f developer-clusterroles.yaml
```
4. Check the `clusterroles`.
```
kubectl get clusterroles
```
![clusterroles list](./images/rbac_add_priviledges_2.png)

5. Create the role binding for `tadeveloper`on clusterroles `icp:develop`.
```
kubectl create rolebinding icp:teama:developer --clusterrole=icp:develop --user=https://mycluster.icp:9443/oidc/endpoint/OP#tadeveloper --namespace=nsta
```
  The name of user is not the id used for the login but the oidc endpoint name. In this sample, tadeveloper has, as name, `https://mycluster.icp:9443/oidc/endpoint/OP#tadeveloper`.

6. Check the role binding on your target namespace.
```
kubectl describe rolebindings icp:teama:developer -n nsta
```
![role description](./images/rbac_add_priviledges_8.png)

7. verify that `tadeveloper` could now push images on the ICp image registry.
![pushing images](./images/rbac_add_priviledges_7.png)

Basically, as tadeveloper was created as a viewer, he could not initially push images to the registry. But by binding him to the `icp:develop` cluster role in his namespace `nsta`, he could now push images to namespace `nsta`.
User taviewer could not push image as the user is not bind to the clusterrole `icp:develop`


In this sample, I created a cluster roles in order to be able to reuse this role in several in namespace across the cluster. But the binding is done at role level in order to limit the new permissions to the target namespace. If, in another namespace, I need similar `icp:develop` permissions, I could do the binding at the new namespace level.  
