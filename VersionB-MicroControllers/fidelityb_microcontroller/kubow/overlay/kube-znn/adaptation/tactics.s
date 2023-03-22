module kubow.strategies;
import model "KubeZnnSystem:Acme" { KubeZnnSystem as M, KubernetesFam as K };

define boolean textMode = M.kubeZnnD.replicasTexta > 0 || M.kubeZnnD.replicasTextb > 0;
define boolean lowMode = M.kubeZnnD.replicasLowa > 0 || M.kubeZnnD.replicasLowb > 0;
define boolean highMode = M.kubeZnnD.replicasHigha > 0 || M.kubeZnnD.replicasHighb > 0;

define string highModeImage = "cmendes/znn:200k";
define string lowModeImage = "cmendes/znn:100k";
define string textModeImage = "cmendes/znn:20k";

define boolean isStable = M.kubeZnnD.stability == 0;

define boolean NoFailureRate = M.failureManagerS.cpufailure == 0.0;
define boolean LowFailureRate = M.failureManagerS.cpufailure > 0.0 && M.failureManagerS.cpufailure <= 0.5;
define boolean HighFailureRate = M.failureManagerS.cpufailure > 0.5;

tactic addHighQuality() {
  int futureReplicasFidelitya = M.fidelityaD.desiredReplicas + 1;
  condition {
    (NoFailureRate || LowFailureRate);
  }
  action {
    if(M.fidelityaD.desiredReplicas == 0){
      M.scaleUp(M.fidelityaD, 1);
    }
  }
  effect {
    (futureReplicasFidelitya == M.fidelityaD.desiredReplicas);
  }
}

tactic removeHighQuality() {
  int futureReplicasFidelitya = M.fidelityaD.desiredReplicas - 1;
  condition {
    (HighFailureRate);
  }
  action {
    if(M.fidelityaD.desiredReplicas > 0){
      M.scaleDown(M.fidelityaD, 1);
    }
  }
  effect {
    (futureReplicasFidelitya == M.fidelityaD.desiredReplicas);
  }
}

tactic lowerFidelity() {
  condition {
    highMode || lowMode;
  }
  action {
    if (highMode) {
      M.rollOut(M.kubeZnnD, "znn", lowModeImage);
    }
    if (lowMode) {
      M.rollOut(M.kubeZnnD, "znn", textModeImage);
    }
  }
  effect @[10000] {
    lowMode;
  }
}

tactic raiseFidelity() {
  condition {
    isStable && (textMode || lowMode);
  }
  action {
    if (textMode) {
      M.rollOut(M.kubeZnnD, "znn", lowModeImage);
    }
    if (lowMode) {
      M.rollOut(M.kubeZnnD, "znn", highModeImage);
    }
  }
  effect @[10000] {
    highMode || lowMode;
  }
}

