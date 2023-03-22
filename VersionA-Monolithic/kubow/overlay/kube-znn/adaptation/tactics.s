module kubow.strategies;
import model "KubeZnnSystem:Acme" { KubeZnnSystem as M, KubernetesFam as K };

define boolean textMode = M.kubeZnnD.replicasText > 0;
define boolean lowMode = M.kubeZnnD.replicasLow > 0;
define boolean highMode = M.kubeZnnD.replicasHigh > 0;

define string highModeImage1 = "cmendes/znn:800k";
define string lowModeImage1 = "cmendes/znn:600k";
define string textModeImage1 = "cmendes/znn:400k";

define string highModeImage2 = "cmendes/znn:200k";
define string lowModeImage2 = "cmendes/znn:100k";
define string textModeImage2 = "cmendes/znn:20k";

define boolean isStable = M.kubeZnnD.stability == 0;
define boolean canRemoveReplica = M.kubeZnnD.minReplicas < M.kubeZnnD.desiredReplicas;

define boolean NoFailureRate = M.failureManagerS.cpufailure == 0.0;
define boolean LowFailureRate = M.failureManagerS.cpufailure > 0.0 && M.failureManagerS.cpufailure <= 0.5;
define boolean HighFailureRate = M.failureManagerS.cpufailure > 0.5;

//define boolean replicasOver = M.kubeZnnD.desiredReplicas > 7;  Esse deu certo
define boolean replicasOver = M.kubeZnnD.desiredReplicas >= M.kubeZnnD.maxReplicas;  // definindo para generico 4 e 10 replicas

define boolean sloRed = M.kubeZnnS.slo <= 0.95;
define boolean sloGreen = M.kubeZnnS.slo >= 0.99;

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

tactic lowerFidelity() {
  condition {
    highMode || lowMode;
  }
  action {
    if (highMode) {
      M.rollOut(M.kubeZnnD, "znn", lowModeImage1);
    }
    if (lowMode) {
      M.rollOut(M.kubeZnnD, "znn", textModeImage1);
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
      M.rollOut(M.kubeZnnD, "znn", lowModeImage1);
    }
    if (lowMode) {
      M.rollOut(M.kubeZnnD, "znn", highModeImage1);
    }
  }
  effect @[10000] {
    highMode || lowMode;
  }
}


tactic activateLowScalabilityHighQuality(){
  condition {
    LowFailureRate && replicasOver;
  }
  action {
    M.scaleDown(M.kubeZnnD, M.kubeZnnD.desiredReplicas - 2);

    //lowerFidelity
    if (sloRed){
      if (highMode) {
        M.rollOut(M.kubeZnnD, "znn", lowModeImage1);
      }
      if (lowMode) {
        M.rollOut(M.kubeZnnD, "znn", textModeImage1);
      }
    }
    //raiseFidelity
    if(sloGreen){
      if (textMode) {
        M.rollOut(M.kubeZnnD, "znn", lowModeImage1);
      }
      if (lowMode) {
        M.rollOut(M.kubeZnnD, "znn", highModeImage1);
      }
    }
  }
  effect @[10000] {
    highMode || lowMode || textMode;
  }
}

tactic addLowScalabilityLowQuality() {
  condition {
    HighFailureRate && replicasOver;
  }
  action {

    M.scaleDown(M.kubeZnnD, M.kubeZnnD.desiredReplicas - 2);

    //lowerFidelity
    if (sloRed){
      if (highMode) {
        M.rollOut(M.kubeZnnD, "znn", lowModeImage2);
      }
      if (lowMode) {
        M.rollOut(M.kubeZnnD, "znn", textModeImage2);
      }
    }
    //raiseFidelity
    if(sloGreen){
      if (textMode) {
        M.rollOut(M.kubeZnnD, "znn", lowModeImage2);
      }
      if (lowMode) {
        M.rollOut(M.kubeZnnD, "znn", highModeImage2);
      }
    }
  }
  effect @[10000] {
    highMode || lowMode || textMode;
  }
}

tactic addHighScalabilityHighQuality() {
  condition {
    NoFailureRate;
  }
  action {  
    //lowerFidelity
    if (sloRed){
      if (highMode) {
        M.rollOut(M.kubeZnnD, "znn", lowModeImage1);
      }
      if (lowMode) {
        M.rollOut(M.kubeZnnD, "znn", textModeImage1);
      }
    }
    //raiseFidelity
    if(sloGreen){
      if (textMode) {
        M.rollOut(M.kubeZnnD, "znn", lowModeImage1);
      }
      if (lowMode) {
        M.rollOut(M.kubeZnnD, "znn", highModeImage1);
      }
    }
  }
  effect @[10000] {
    highMode || lowMode || textMode;
  }
}