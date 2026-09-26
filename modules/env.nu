
$env.ENV_CONVERSIONS = {
  "PATH": {
    from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
    to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
  }
  "Path": {
    from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
    to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
  }
}

$env.PATH = (
  $env.PATH?
  | default []
  | split row (char esep)
  | prepend [
      "/run/wrappers/bin"
      $"/home/pollux/.nix-profile/bin"
      "/etc/profiles/per-user/pollux/bin"
      "/run/current-system/sw/bin"
      "/home/pollux/.local/bin"
    ]
  | uniq
)

$env.EDITOR = "hx"
$env.VISUAL = "hx"
