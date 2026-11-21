rec {
  names = [
    "umbriel"
    "niri"
  ];

  # wayland-sessions .desktop Name= values for noctalia-greeter --session
  greeterSession = desktop:
    {
      niri = "Niri";
      umbriel = "Umbriel";
    }
    .${
      desktop
    };

  assertValid = desktop:
    if builtins.elem desktop names
    then desktop
    else builtins.throw "Unknown desktop '${desktop}'. Expected one of: ${builtins.concatStringsSep ", " names}";
}
