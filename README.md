# For all scenarios (IMPORTANT: ORDER IS CRUCIAL)

## Cluster configurations - defining cluster (before of all, kubectl and minikube must be installed)

minikube delete
minikube start --cpus=5 --memory=8192 --vm-driver hyperv --kubernetes-version=v1.16.10
# minikube start --cpus=5 --memory=8192 --hyperv-virtual-switch "newNetwork" --vm-driver hyperv --kubernetes-version=v1.16.10


spec:
  containers:
  - name: private-reg-container-name
    image: <your-private-image>
  imagePullSecrets:
  - name: regcred

#---------------------------------------------------#---------------------------------------------------
## creating environment: Configuration A - Always - delete and re-create the Cluster
kubectl apply -f ./Evaluation-ZNN/VersionC-WithFailureManagerMetaController/MetaController/priorityObjectsK8s/
kubectl apply -k ./Evaluation-ZNN/tools/monitoring/
kubectl apply -k ./Evaluation-ZNN/VersionA-Monolithic/TargetSystem/kube-znn/overlay/default/
kubectl apply -f ./Evaluation-ZNN/tools/nginxc-ingress/
kubectl apply -k ./Evaluation-ZNN/VersionA-Monolithic/kubow/overlay/kube-znn
kubectl apply -f ./Evaluation-ZNN/VersionC-WithFailureManagerMetaController/MicroControllers/tailored_based/k8s/
kubectl apply -k ./Evaluation-ZNN/tools/k6/

kubectl delete -k ./Evaluation-ZNN/tools/monitoring/
kubectl delete -k ./Evaluation-ZNN/VersionA-Monolithic/TargetSystem/kube-znn/overlay/default/
kubectl delete -f ./Evaluation-ZNN/tools/nginxc-ingress/
kubectl delete -k ./Evaluation-ZNN/VersionA-Monolithic/kubow/overlay/kube-znn
kubectl delete -k ./Evaluation-ZNN/tools/k6/
#---------------------------------------------------#---------------------------------------------------
## creating environment: Configuration B - Always - delete and re-create the Cluster
kubectl apply -f ./Evaluation-ZNN/VersionC-WithFailureManagerMetaController/MetaController/priorityObjectsK8s/
kubectl apply -k ./Evaluation-ZNN/tools/monitoring/
kubectl apply -k ./Evaluation-ZNN/VersionB-Microcontrollers/TargetSystem/kube-znn/overlay/default/
kubectl apply -f ./Evaluation-ZNN/tools/nginxc-ingress/
kubectl apply -k ./Evaluation-ZNN/VersionB-Microcontrollers/fidelitya_microcontroller/kubow/overlay/kube-znn/
kubectl apply -k ./Evaluation-ZNN/VersionB-Microcontrollers/scalabilitya_microcontroller/kubow/overlay/kube-znn/
kubectl apply -k ./Evaluation-ZNN/VersionB-Microcontrollers/fidelityb_microcontroller/kubow/overlay/kube-znn/
kubectl apply -k ./Evaluation-ZNN/VersionB-Microcontrollers/scalabilityb_microcontroller/kubow/overlay/kube-znn/
kubectl apply -f ./Evaluation-ZNN/VersionC-WithFailureManagerMetaController/MicroControllers/tailored_based/k8s/
kubectl apply -k ./Evaluation-ZNN/tools/k6/

kubectl delete -k ./Evaluation-ZNN/tools/monitoring/
kubectl delete -k ./Evaluation-ZNN/VersionB-Microcontrollers/TargetSystem/kube-znn/overlay/default/
kubectl delete -f ./Evaluation-ZNN/tools/nginxc-ingress/
kubectl delete -k ./Evaluation-ZNN/VersionB-Microcontrollers/fidelitya_microcontroller/kubow/overlay/kube-znn/
kubectl delete -k ./Evaluation-ZNN/VersionB-Microcontrollers/scalabilitya_microcontroller/kubow/overlay/kube-znn/
kubectl delete -k ./Evaluation-ZNN/tools/k6/


#---------------------------------------------------#---------------------------------------------------


## creating environment: Configuration C - Always - delete and re-create the Cluster

kubectl apply -f ./Evaluation-ZNN/VersionC-WithFailureManagerMetaController/MetaController/priorityObjectsK8s/
kubectl apply -k ./Evaluation-ZNN/tools/monitoring/
kubectl apply -k ./Evaluation-ZNN/VersionC-WithFailureManagerMetaController/TargetSystem/kube-znn/overlay/default/
kubectl apply -f ./Evaluation-ZNN/tools/nginxc-ingress/
kubectl apply -k ./Evaluation-ZNN/VersionC-WithFailureManagerMetaController/MicroControllers/kubow_based/fidelitya_microcontroller/kubow/overlay/kube-znn/
kubectl apply -k ./Evaluation-ZNN/VersionC-WithFailureManagerMetaController/MicroControllers/kubow_based/scalabilitya_microcontroller/kubow/overlay/kube-znn/
kubectl apply -k ./Evaluation-ZNN/VersionC-WithFailureManagerMetaController/MicroControllers/kubow_based/fidelityb_microcontroller/kubow/overlay/kube-znn/
kubectl apply -k ./Evaluation-ZNN/VersionC-WithFailureManagerMetaController/MicroControllers/kubow_based/scalabilityb_microcontroller/kubow/overlay/kube-znn/
kubectl apply -f ./Evaluation-ZNN/VersionC-WithFailureManagerMetaController/MicroControllers/tailored_based/k8s/
kubectl apply -k ./Evaluation-ZNN/VersionC-WithFailureManagerMetaController/MetaController/kubow/overlay/controller_targetsystem/
kubectl apply -k ./Evaluation-ZNN/tools/k6/


kubectl delete -f ./Evaluation-ZNN/VersionC-WithFailureManagerMetaController/MetaController/priorityObjectsK8s/
kubectl delete -k ./Evaluation-ZNN/tools/monitoring/
kubectl delete -k ./Evaluation-ZNN/VersionC-WithFailureManagerMetaController/TargetSystem/kube-znn/overlay/default/
kubectl delete -f ./Evaluation-ZNN/tools/nginxc-ingress/
kubectl delete -k ./Evaluation-ZNN/VersionC-WithFailureManagerMetaController/MicroControllers/kubow_based/fidelitya_microcontroller/kubow/overlay/kube-znn/
kubectl delete -k ./Evaluation-ZNN/VersionC-WithFailureManagerMetaController/MicroControllers/kubow_based/scalabilitya_microcontroller/kubow/overlay/kube-znn/
kubectl delete -k ./Evaluation-ZNN/VersionC-WithFailureManagerMetaController/MicroControllers/kubow_based/fidelityb_microcontroller/kubow/overlay/kube-znn/
kubectl delete -k ./Evaluation-ZNN/VersionC-WithFailureManagerMetaController/MicroControllers/kubow_based/scalabilityb_microcontroller/kubow/overlay/kube-znn/
kubectl delete -f ./Evaluation-ZNN/VersionC-WithFailureManagerMetaController/MicroControllers/tailored_based/k8s/
kubectl delete -k ./Evaluation-ZNN/VersionC-WithFailureManagerMetaController/MetaController/kubow/overlay/controller_targetsystem/
kubectl delete -k ./Evaluation-ZNN/tools/k6/


#---------------------------------------------------#---------------------------------------------------

## Generating logs
kubectl logs pod/fidelitya-86748d8745-j9scv >> fidelitya1404.log
kubectl logs pod/scalabilitya-7cc9bfc6b8-66cj8 >> scalabilitya1404.log
pod=$(kubectl get pod | grep scalability | cut -b 1-29)
pod=$(kubectl get pod | grep fidelity | cut -b 1-29)

## Monitoring
while (1) {clear; kubectl get all; sleep 5}
while (1) {clear; kubectl describe deployment kube-znn; sleep 5}

### query prometheus in K8s
kubectl port-forward pod/prometheus-d4499d495-4bhxg 9090:9090

### Grafana
kubectl port-forward pod/grafana-b659fcdd9-r5sck 3000:3000

#---------------------------------------------------