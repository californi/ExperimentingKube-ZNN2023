module kubow.strategies;
import model "KubeZnnSystem:Acme" { KubeZnnSystem as M, KubernetesFam as K };

define boolean isStable = M.kubeZnnD.stability == 0;
define boolean canRemoveReplica = M.kubeZnnD.minReplicas < M.kubeZnnD.desiredReplicas;

define boolean NoFailureRate = M.failureManagerS.cpufailure == 0.0;
define boolean LowFailureRate = M.failureManagerS.cpufailure > 0.0 && M.failureManagerS.cpufailure <= 0.5;
define boolean HighFailureRate = M.failureManagerS.cpufailure > 0.5;


tactic addHighScalability() {
  int futureReplicasScalabilitya = M.scalabilityaD.desiredReplicas + 1;
  condition {
    (NoFailureRate);
  }
  action {
    if(M.scalabilityaD.desiredReplicas == 0){
      M.scaleUp(M.scalabilityaD, 1);
    }
  }
  effect {
    (futureReplicasScalabilitya == M.scalabilityaD.desiredReplicas);
  }
}

tactic removeHighScalability() {
  int futureReplicasScalabilitya = M.scalabilityaD.desiredReplicas - 1;
  condition {
    (LowFailureRate || HighFailureRate);
  }
  action {
    if(M.scalabilityaD.desiredReplicas > 0){
      M.scaleDown(M.scalabilityaD, 1);
    }
  }
  effect {
    (futureReplicasScalabilitya == M.scalabilityaD.desiredReplicas);
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
    if(M.kubeZnnD.desiredReplicas > M.kubeZnnD.maxReplicas){
      M.scaleDown(M.kubeZnnD, 9);
    }
    if(M.kubeZnnD.maxReplicas > M.kubeZnnD.desiredReplicas){
      M.scaleDown(M.kubeZnnD, 1);
    }
  }
  effect @[10000] {
    futureReplicas == M.kubeZnnD.desiredReplicas || M.kubeZnnD.desiredReplicas <= M.kubeZnnD.maxReplicas;
  }
}

tactic adjustReplicas(){
  int scalingDown = M.kubeZnnD.desiredReplicas - 1;
  condition {
    M.kubeZnnD.maxReplicas < M.kubeZnnD.desiredReplicas;
  }
  action {
    M.scaleDown(M.kubeZnnD, scalingDown);
  }
  effect @[50000] {
    M.kubeZnnD.maxReplicas > M.kubeZnnD.desiredReplicas;
  }

}