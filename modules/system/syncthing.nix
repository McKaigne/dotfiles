# Syncthing keeps the PARA folders identical on hyde and castor, continuously,
# whenever both are on Tailscale (an offline machine catches up when it comes
# back). /etc/nixos syncs both ways too, git history included, so work done
# on either machine is kept; work on one machine at a time, or Syncthing keeps
# both versions as .sync-conflict files. Files the other machine replaces or
# deletes are kept 14 days in each folder's .stversions (trash can).
# Peer to peer over Tailscale only: no global discovery, no relays.
# Each machine's identity key lives in ~/.local/state/syncthing (not in the
# store); the IDs below are their public halves.
let
  devices = {
    hyde = "DGEOLLU-2C7K56D-TH5APDM-OGWSRQN-X3OYFJN-NGSCPGE-JXP65HJ-DKNL6AW";
    castor = "24FF3EJ-72TZYCG-SWJTCRJ-T2MYUYR-3BLSQLD-NOJ25RK-U3M3G3C-KTBR7A2";
  };
  folders = ["Projects" "Areas" "Resources" "Archive"];

  # Build output and caches are regenerated on each machine; syncing them
  # would only churn. (?d) lets Syncthing delete them with their parent.
  ignores = ''
    (?d).direnv
    (?d)build
    (?d)result
    (?d)result-*
    (?d).cache
    (?d)node_modules
    (?d)target
    (?d)__pycache__
  '';
in {
  nixos.base = {
    config,
    lib,
    ...
  }: let
    user = config.workstation.username;
    home = config.users.users.${user}.home;
    peers = lib.removeAttrs devices [config.workstation.hostname];
  in {
    services.syncthing = {
      enable = true;
      inherit user;
      group = config.users.users.${user}.group;
      dataDir = home;
      configDir = "${home}/.local/state/syncthing";
      overrideDevices = true;
      overrideFolders = true;
      settings = {
        devices =
          lib.mapAttrs (name: id: {
            inherit id;
            addresses = ["tcp://${name}:22000"];
          })
          peers;
        folders = lib.mapAttrs (_: folder:
          folder
          // {
            devices = lib.attrNames peers;
            versioning = {
              type = "trashcan";
              params.cleanoutDays = "14";
            };
          }) ({
            nixos = {
              id = "nixos";
              path = "/etc/nixos";
            };
          }
          // lib.genAttrs folders (name: {
            id = lib.toLower name;
            path = "${home}/${name}";
          }));
        options = {
          globalAnnounceEnabled = false;
          localAnnounceEnabled = false;
          relaysEnabled = false;
          natEnabled = false;
          urAccepted = -1;
        };
      };
    };
    networking.firewall.interfaces."tailscale0".allowedTCPPorts = [22000];

    home-manager.sharedModules = [
      {
        home.file = lib.listToAttrs (map (name: lib.nameValuePair "${name}/.stignore" {text = ignores;}) folders);
      }
    ];
  };
}
