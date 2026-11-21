{
  flake.modules.nixos.user-workstation =
    { config, lib, ... }:
    let
      user = config.workstation.username;
      avatarSrc = ../../avatar.jpg;
    in
    {
      users.users.${user} = {
        isNormalUser = true;
        description = user;
        extraGroups = [
          "wheel"
          "networkmanager"
          "video"
          "audio"
          "input"
          "uinput"
          "render"
        ]
        ++ lib.optional (config.hardware.i2c.enable or false) "i2c";
      };

      systemd.tmpfiles.rules = [
        "d /var/lib/AccountsService/icons 0755 root root -"
        "d /var/lib/AccountsService/users 0755 root root -"
        "C+ /var/lib/AccountsService/icons/${user} 0644 root root - ${avatarSrc}"
        "f+ /var/lib/AccountsService/users/${user} 0644 root root - [User]\\nIcon=/var/lib/AccountsService/icons/${user}\\nSession=\\nXSession=\\n"
      ];
    };
}
