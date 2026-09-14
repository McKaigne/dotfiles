let active_user = ($env.USER? | default "pollux")
let active_home = ($env.HOME? | default $"/home/($active_user)")

let system_bins = [
  "/run/wrappers/bin"
  "/run/current-system/sw/bin"
  $"/etc/profiles/per-user/($active_user)/bin"
  $"($active_home)/.nix-profile/bin"
  $"($active_home)/.local/bin"
  $"($active_home)/.cargo/bin"
]

let current_paths = (
  if ($env.PATH? | is-empty) {
    []
  } else if ($env.PATH | describe | str starts-with "list") {
    $env.PATH
  } else {
    $env.PATH | split row (char esep)
  }
)

$env.PATH = ($system_bins | append $current_paths | flatten | uniq)

# Dynamic Noctalia Starship Configuration Resolution
let cache_dir = $"($active_home)/.cache/noctalia"
let starship_cache = $"($cache_dir)/starship.toml"
let palette_file = $"($cache_dir)/starship-palette.toml"

if ($starship_cache | path exists) {
  $env.STARSHIP_CONFIG = $starship_cache
}