{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.ki.virtualisation;
in {
  options.ki.virtualisation = {
    enable = mkEnableOption "Enable virtualization options";

    # TODO should this be under virtualisation? IIRC Flatpak doesn't use as many virtualisation techniques as Snap or Docker.
    flatpak.enable = mkEnableOption "Enable Flatpak";

    lxc.enable = mkEnableOption "Enable LXC";

    libvirt = {
      enable = mkEnableOption "Enable libvirtd";

      isolateCpus = {
        enable = mkEnableOption "Isolate CPUs from the Linux scheduler and SMP balancing";
      };
    };

    docker.enable = mkEnableOption "Enable Docker";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      virt-manager
    ];
    boot.extraModprobeConfig = ''
      options kvm_intel nested=1
      options kvm ignore_msrs=1
      options kvm report_ignored_msrs=0
    '';
    virtualisation.lxc.enable = cfg.lxc.enable;

    virtualisation.docker.enable = cfg.docker.enable;

    virtualisation.libvirtd = mkIf cfg.libvirt.enable {
      enable = true;
      qemu = {
        swtpm.enable = true;
        verbatimConfig = ''
          remember_owner = 0
          user = "ki"
          group = "kvm"
          nvram = [
            "/nix/store/${pkgs.OVMF}/FV/OVMF.vd:/nix/store/${pkgs.OVMF}/FV/OVMF_VARS.fd"
          ]
        '';
        package = pkgs.qemu_full;
      };
    };

    services.flatpak.enable = cfg.flatpak.enable;

    boot.kernelParams =
      ["intel_iommu=on"]
      ++ (
        if (cfg.libvirt.isolateCpus.enable && config.ki.relativity.enable)
        then ["isolcpus=2,3,6,7"]
        else []
      );
    boot.kernelModules = ["vfio" "vfio_iommu_type1" "vfio_pci" "vfio_virqfd"];
  };
}
