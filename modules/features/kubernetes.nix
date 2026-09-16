{
  flake.modules.homeManager.kubernetes = { pkgs, ... }: {
    home.packages = with pkgs; [
      kubectl
      krew
      kubectx
      kubectl-neat
      kubectl-tree
      kubectl-df-pv
      kubectl-view-secret
      kubelogin
      stern
      k9s
      kubernetes-helm
      helmfile
      kustomize
      kubeconform
      kubeseal
      openshift
      kind
      minikube
      talosctl
      cilium-cli
      fluxcd
      argocd
    ];
    # Common plugins are pinned above. krew remains available for additional
    # plugins; no network-dependent installation runs during activation.
  };
}
