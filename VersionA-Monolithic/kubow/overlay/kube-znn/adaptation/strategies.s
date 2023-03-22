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


//define boolean replicasOver = M.kubeZnnD.desiredReplicas > 7;  Esse deu certo
define boolean replicasOver = M.kubeZnnD.desiredReplicas >= M.kubeZnnD.maxReplicas;  // definindo para generico 4 e 10 replicas

strategy activateNoFailureRate [ NoFailureRate ] {  
  t0: (NoFailureRate) -> addHighScalabilityHighQuality() @[20000 /*ms*/] {
    t0a: (success) -> done;
  }   
  t1: (default) -> TNULL;
}

strategy activateLowFailureRate [ LowFailureRate && replicasOver ] {  
  t0: (LowFailureRate) -> activateLowScalabilityHighQuality() @[20000 /*ms*/] {
    t0a: (success) -> done;
  }      
  t1: (default) -> TNULL;
}


strategy activateHighFailureRate [ HighFailureRate ] {    
  t0: (HighFailureRate && replicasOver) -> addLowScalabilityLowQuality() @[20000 /*ms*/] {
    t0a: (success) -> done;
  }   
  t1: (default) -> TNULL;
}


/*
 * ----
 */
strategy ImproveSlo [ sloRed ] {
  t0: (sloRed && canAddReplica) -> addReplica() @[20000 /*ms*/] {
    t0a: (success) -> done;
  }
  t1: (sloRed && !canAddReplica) -> lowerFidelity() @[20000 /*ms*/] {
    t1a: (success) -> done;
  }
  t2: (default) -> TNULL;
}

/*
 * ----
 */
strategy ReduceCostImproveFidelity [ sloGreen ] {
  t0: (canRemoveReplica) -> removeReplica() @[20000 /*ms*/] {
    t0a: (success) -> done;
  }
  t1: (textMode || lowMode) -> raiseFidelity() @[20000 /*ms*/] {
    t1a: (success) -> done;
  }  
  t2: (default) -> TNULL;
}

/*
 * ----
 */
//strategy ImproveFidelity [ sloGreen && (textMode || lowMode) ] {
//  t0: (sloGreen && (textMode || lowMode)) -> raiseFidelity() @[20000 /*ms*/] {
//    t0a: (success) -> done;
//  }
//  t1: (default) -> TNULL;
//}
