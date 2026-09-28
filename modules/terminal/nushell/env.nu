# Nushell Environment Configuration
$env.STARSHIP_SHELL = "nu"

# Inject full NixOS system and user binary paths into PATH
let nix_paths = [
  "/run/wrappers/bin"
  ($env.HOME | path join ".nix-profile/bin")
  $"/etc/profiles/per-user/($env.USER)/bin"
  "/run/current-system/sw/bin"
]

$env.PATH = (
  $env.PATH
  | split row (char esep)
  | prepend $nix_paths
  | uniq
)
