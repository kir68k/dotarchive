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

    lxc.enable = mkEnableOption "Enable LXC";

    libvirt.enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable libvirtd";
    };
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

    boot.kernelParams = ["intel_iommu=on"];
    boot.kernelModules = ["vfio" "vfio_iommu_type1" "vfio_pci" "vfio_virqfd"];
  };
}
