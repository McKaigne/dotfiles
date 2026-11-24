{
  flake.modules.nixos."user-workstation" = {config, ...}: let
    user = config.workstation.username;
    avatar = ../../../avatar.jpg;
  in {
    users.groups.i2c = {};

    users.users.${user} = {
      isNormalUser = true;
      description = user;
      extraGroups = [
        "networkmanager"
        "wheel"
        "video"
        "audio"
        "render"
        "i2c"
        "bluetooth"
      ];
    };

    # Account avatar for the greeter and Noctalia.
    systemd.tmpfiles.rules = [
      "d /var/lib/AccountsService/icons 0755 root root -"
      "d /var/lib/AccountsService/users 0755 root root -"
      "C+ /var/lib/AccountsService/icons/${user} 0644 root root - ${avatar}"
      "f+ /var/lib/AccountsService/users/${user} 0644 root root - [User]\\nIcon=/var/lib/AccountsService/icons/${user}\\nSession=\\nXSession=\\n"
    ];
  };
}
