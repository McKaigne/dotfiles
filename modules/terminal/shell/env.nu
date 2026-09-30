# Nushell Environment Configuration
$env.STARSHIP_SHELL = "nu"
$env.STARSHIP_CONFIG = "/etc/starship.toml"

let user = ($env.USER? | default ($env.LOGNAME? | default ""))
let home = ($env.HOME? | default "~" | path expand)

let nix_paths = [
  "/run/wrappers/bin"
  ($home | path join ".nix-profile/bin")
  (if ($user | is-not-empty) { $"/etc/profiles/per-user/($user)/bin" } else { "" })
  "/run/current-system/sw/bin"
] | where { |p| ($p | is-not-empty) and ($p | path exists) }

$env.PATH = (
  $env.PATH
  | split row (char esep)
  | prepend $nix_paths
  | uniq
)
