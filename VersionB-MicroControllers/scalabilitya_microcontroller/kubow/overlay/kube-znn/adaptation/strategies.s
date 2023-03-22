module kubow.strategies;
import model "KubeZnnSystem:Acme" { KubeZnnSystem as M, KubernetesFam as K };
import lib "tactics.s";

define boolean highMode = M.kubeZnnD.replicasHigh > 0;

define boolean sloRed = M.kubeZnnS.slo <= 0.95;
define boolean sloGreen = M.kubeZnnS.slo >= 0.99;

define boolean canAddReplica = M.kubeZnnD.maxReplicas > M.kubeZnnD.desiredReplicas;
define boolean canRemoveReplica = M.kubeZnnD.minReplicas < M.kubeZnnD.desiredReplicas;

define boolean NoFailureRate = M.failureManagerS.cpufailure == 0.0;
define boolean LowFailureRate = M.failureManagerS.cpufailure > 0.0 && M.failureManagerS.cpufailure <= 0.5;
define boolean HighFailureRate = M.failureManagerS.cpufailure > 0.5;

define boolean IsScalabilityb = M.scalabilitybD.desiredReplicas > 0;

/*
 * ----
 */
strategy ImproveSlo [ canAddReplica && sloRed ] {
  t0: (sloRed && canAddReplica) -> addReplica() @[20000 /*ms*/] {
    t0a: (success) -> done;
  }
  t1: (default) -> TNULL;
}

/*
 * ----
 */
strategy ReduceCost [ sloGreen ] {
  t0: (sloGreen && canRemoveReplica) -> removeReplica() @[20000 /*ms*/] {
    t0a: (success) -> done;
  }
  t1: (default) -> TNULL;
}

strategy deactivateScalabilityB [ NoFailureRate && (!canAddReplica || IsScalabilityb) ] {  
  t0: (NoFailureRate && (!canAddReplica || IsScalabilityb)) -> removeLowScalability() {
    t0a: (success) -> done;
  }   
  t1: (default) -> TNULL;
}

strategy activateScalabilityB [ LowFailureRate || HighFailureRate ] {  
  t0: (LowFailureRate || HighFailureRate) -> addLowScalability() {
    t0a: (success) -> done;
  }      
  t1: (default) -> TNULL;
}