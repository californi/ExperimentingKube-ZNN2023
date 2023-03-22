module kubow.strategies;
import model "KubeZnnSystem:Acme" { KubeZnnSystem as M, KubernetesFam as K };

define boolean isStable = M.kubeZnnD.stability == 0;
define boolean canRemoveReplica = M.kubeZnnD.minReplicas < M.kubeZnnD.desiredReplicas;


define boolean NoFailureRate = M.failureManagerS.cpufailure == 0.0;
define boolean LowFailureRate = M.failureManagerS.cpufailure > 0.0 && M.failureManagerS.cpufailure <= 0.5;
define boolean HighFailureRate = M.failureManagerS.cpufailure > 0.5;

define boolean IsScalabilityb = M.scalabilitybD.desiredReplicas > 0;
define boolean canAddReplica = M.kubeZnnD.maxReplicas > M.kubeZnnD.desiredReplicas;

tactic addLowScalability() {
  int futureReplicasScalabilityb = M.scalabilitybD.desiredReplicas + 1;
  condition {
    (LowFailureRate || HighFailureRate);
  }
  action {
    if(M.scalabilitybD.desiredReplicas == 0){
      M.scaleUp(M.scalabilitybD, 1);
    }
  }
  effect {
    (futureReplicasScalabilityb == M.scalabilitybD.desiredReplicas);
  }
}

tactic removeLowScalability() {
  int futureReplicasScalabilityb = M.scalabilitybD.desiredReplicas - 1;
  condition {
    (NoFailureRate && (!canAddReplica || IsScalabilityb));
  }
  action {
    if(M.scalabilitybD.desiredReplicas > 0){
      M.scaleDown(M.scalabilitybD, 1);
    }
  }
  effect {
    (futureReplicasScalabilityb == M.scalabilitybD.desiredReplicas);
  }
}

tactic addReplica() {
  int futureReplicas = M.kubeZnnD.desiredReplicas + 1;
  condition {
    M.kubeZnnD.maxReplicas > M.kubeZnnD.desiredReplicas;
  }
  action {
    M.scaleUp(M.kubeZnnD, 1);
  }
  effect @[10000] {
    futureReplicas == M.kubeZnnD.desiredReplicas;
  }
}

tactic removeReplica() {
  int futureReplicas = M.kubeZnnD.desiredReplicas - 1;
  condition {
    isStable && canRemoveReplica;
  }
  action {
    M.scaleDown(M.kubeZnnD, 1);
  }
  effect @[10000] {
    futureReplicas == M.kubeZnnD.desiredReplicas;
  }
}