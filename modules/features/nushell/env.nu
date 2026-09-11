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