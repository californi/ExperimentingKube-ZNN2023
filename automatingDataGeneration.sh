
#!/bin/bash

i=1
until [ $i -gt 30 ]
do
	echo "Generating $i times."

    minikube delete
    minikube start --cpus=5 --memory=8192 --vm-driver hyperv --kubernetes-version=v1.16.10

    echo "Running approach A: "	

    kubectl create secret docker-registry regcred --docker-username=*** --docker-password=***** --docker-email=email -n default

    kubectl apply -f ./VersionC-WithFailureManagerMetaController/MetaController/priorityObjectsK8s/
    kubectl apply -k ./tools/monitoring/
    kubectl apply -k ./VersionA-Monolithic/TargetSystem/kube-znn/overlay/default/
    kubectl apply -f ./tools/nginxc-ingress/
    kubectl apply -k ./VersionA-Monolithic/kubow/overlay/kube-znn
    kubectl apply -f ./VersionC-WithFailureManagerMetaController/MicroControllers/tailored_based/k8s/
    


    watingPods=2

    while [ $watingPods -gt 1 ]; do
        watingPods=$(kubectl get pods | grep -c -v Running)

        echo "Waiting to run k6."
        :
    done

    echo "Deployment k6."

    kubectl apply -k ./tools/k6/

    watingPods=0
    while [ $watingPods = 0 ]; do
        watingPods=$(kubectl get pods | grep k6 | grep -c Running)
        echo "Waiting to run logs."
        :
    done

    #StartingRunning=StartingRunning$(date +"%H%M%S")
    #mkdir $StartingRunning
    

    python ./test/apptrackingupdatesznn/app2.py

    python ./test/apptrackingupdatesznn/generateSummary.py > summary-trace-znn.log     

    #intermediateRunning=intermediateRunning$(date +"%H%M%S")
    #mkdir $intermediateRunning
    
    #watingPodsRestauration=3
    #while [ $watingPodsRestauration -gt 2 ]; do
    #    watingPodsRestauration=$(kubectl get pods | grep znn | grep -c Running)
    #    echo "Wating to finish."
    #    :
    #done

    #FinishingRunning=FinishingRunning$(date +"%H%M%S")
    #mkdir $FinishingRunning


    folderName=generateLogs$(date +"%H%M%S")
    mkdir $folderName

    # move all txt files to foldername
    find ./*.log -exec mv {} $folderName/ \;

    minikube delete
	i=$(( i+1 ))
done