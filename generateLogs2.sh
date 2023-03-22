#!/bin/bash

folderName=logsAllPodsManagers$(date +"%H%M%S")
mkdir $folderName
cd $folderName

 while true; do 
    pod=$(kubectl get pod | grep Running | grep scalabilitya | cut -b 1-29)
    echo "Generating data for pod: "$pod
    kubectl logs pod/${pod} > ${pod}.log

    pod=$(kubectl get pod | grep Running | grep fidelitya | cut -b 1-26)
    echo "Generating data for pod: "$pod
    kubectl logs pod/${pod} > ${pod}.log

    pod=$(kubectl get pod | grep Running | grep scalabilityb | cut -b 1-29)
    echo "Generating data for pod: "$pod
    kubectl logs pod/${pod} > ${pod}.log

    pod=$(kubectl get pod | grep Running | grep fidelityb | cut -b 1-26)
    echo "Generating data for pod: "$pod
    kubectl logs pod/${pod} > ${pod}.log   

    pod=$(kubectl get pod | grep Running | grep metacontroller | cut -b 1-37)
    echo "Generating data for pod: "$pod
    kubectl logs pod/${pod} > ${pod}.log   
	
    pod=$(kubectl get pod | grep Running | grep failuremonitor | cut -b 1-31)
    echo "Generating data for pod: "$pod
    kubectl logs pod/${pod} > ${pod}.log   	
	
    pod=$(kubectl get pod | grep Running | grep failuremanager | cut -b 1-31)
    echo "Generating data for pod: "$pod
    kubectl logs pod/${pod} > ${pod}.log   		
	
    :
    sleep 1; 
done