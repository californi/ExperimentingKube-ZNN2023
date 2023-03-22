module kubow.strategies;
import model "KubeZnnSystem:Acme" { KubeZnnSystem as M, KubernetesFam as K };
import lib "tactics.s";

define boolean sloRed = M.kubeZnnS.slo <= 0.95;
define boolean sloGreen = M.kubeZnnS.slo >= 0.99;

define boolean canAddReplica = M.kubeZnnD.maxReplicas > M.kubeZnnD.desiredReplicas;
define boolean canRemoveReplica = M.kubeZnnD.minReplicas < M.kubeZnnD.desiredReplicas;

define boolean mismatchingReplicas = M.kubeZnnD.desiredReplicas > M.kubeZnnD.maxReplicas;

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


strategy AdjustDefaultReplicas [ mismatchingReplicas ] {
  t0: (mismatchingReplicas) -> adjustReplicas() @[60000 /*ms*/] {
    t0a: (success) -> done;
  }
  t1: (default) -> TNULL;
}