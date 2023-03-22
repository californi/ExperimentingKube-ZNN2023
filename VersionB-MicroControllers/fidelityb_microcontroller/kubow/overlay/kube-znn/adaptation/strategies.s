module kubow.strategies;
import model "KubeZnnSystem:Acme" { KubeZnnSystem as M, KubernetesFam as K };
import lib "tactics.s";

define boolean textMode = M.kubeZnnD.replicasTexta > 0 || M.kubeZnnD.replicasTextb > 0;
define boolean lowMode = M.kubeZnnD.replicasLowa > 0 || M.kubeZnnD.replicasLowb > 0;
define boolean highMode = M.kubeZnnD.replicasHigha > 0 || M.kubeZnnD.replicasHighb > 0;


define boolean sloRed = M.kubeZnnS.slo <= 0.95;
define boolean sloGreen = M.kubeZnnS.slo >= 0.99;


define boolean canAddReplica = M.kubeZnnD.maxReplicas > M.kubeZnnD.desiredReplicas;
define boolean canRemoveReplica = M.kubeZnnD.minReplicas < M.kubeZnnD.desiredReplicas;

define boolean NoFailureRate = M.failureManagerS.cpufailure == 0.0;
define boolean LowFailureRate = M.failureManagerS.cpufailure > 0.0 && M.failureManagerS.cpufailure <= 0.5;
define boolean HighFailureRate = M.failureManagerS.cpufailure > 0.5;


strategy deactivateFidelityA [ HighFailureRate ] {  
  t0: (HighFailureRate) -> removeHighQuality() {
    t0a: (success) -> done;
  }   
  t1: (default) -> TNULL;
}

strategy activateFidelityA [ NoFailureRate || LowFailureRate ] {  
  t0: (NoFailureRate || LowFailureRate) -> addHighQuality() {
    t0a: (success) -> done;
  }      
  t1: (default) -> TNULL;
}


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
