module kubow.strategies;
import model "KubeZnnSystem:Acme" { KubeZnnSystem as M, KubernetesFam as K };
import lib "tactics.s";

define boolean highMode = M.kubeZnnD.replicasHigh > 0;
define boolean textMode = M.kubeZnnD.replicasText > 0;
define boolean lowMode = M.kubeZnnD.replicasLow > 0;

define boolean sloRed = M.kubeZnnS.slo <= 0.95;
define boolean sloGreen = M.kubeZnnS.slo >= 0.99;

define boolean canAddReplica = M.kubeZnnD.maxReplicas > M.kubeZnnD.desiredReplicas;
define boolean canRemoveReplica = M.kubeZnnD.minReplicas < M.kubeZnnD.desiredReplicas;

define boolean NoFailureRate = M.failureManagerS.cpufailure == 0.0;
define boolean LowFailureRate = M.failureManagerS.cpufailure > 0.0 && M.failureManagerS.cpufailure <= 0.5;
define boolean HighFailureRate = M.failureManagerS.cpufailure > 0.5;


/*
 * ----
 */
strategy ImproveSlo [ sloRed ] {
  t0: (sloRed && !canAddReplica) -> lowerFidelity() @[20000 /*ms*/] {
    t0a: (success) -> done;
  }
  t1: (default) -> TNULL;
}


/*
 * ----
 */
strategy ImproveFidelity [ sloGreen ] {
  t0: (textMode || lowMode) -> raiseFidelity() @[20000 /*ms*/] {
    t0a: (success) -> done;
  }
  t1: (default) -> TNULL;
}


strategy deactivateFidelityB [ NoFailureRate || LowFailureRate ] {  
  t0: (NoFailureRate || LowFailureRate) -> removeLowQuality() {
    t0a: (success) -> done;
  }   
  t1: (default) -> TNULL;
}

strategy activateFidelityB [ HighFailureRate ] {  
  t0: (HighFailureRate) -> addLowQuality() {
    t0a: (success) -> done;
  }      
  t1: (default) -> TNULL;
}