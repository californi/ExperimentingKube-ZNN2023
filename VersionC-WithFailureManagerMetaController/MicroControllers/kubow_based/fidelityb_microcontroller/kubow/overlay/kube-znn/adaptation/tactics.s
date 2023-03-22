module kubow.strategies;
import model "KubeZnnSystem:Acme" { KubeZnnSystem as M, KubernetesFam as K };

define boolean textMode = M.kubeZnnD.replicasTexta > 0 || M.kubeZnnD.replicasTextb > 0;
define boolean lowMode = M.kubeZnnD.replicasLowa > 0 || M.kubeZnnD.replicasLowb > 0;
define boolean highMode = M.kubeZnnD.replicasHigha > 0 || M.kubeZnnD.replicasHighb > 0;

define string highModeImage = "cmendes/znn:200k";
define string lowModeImage = "cmendes/znn:100k";
define string textModeImage = "cmendes/znn:20k";


define boolean isStable = M.kubeZnnD.stability == 0;

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

