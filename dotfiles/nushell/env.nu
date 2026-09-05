# Nushell Environment Config File

$env.STARSHIP_CONFIG = ($env.HOME | path join ".config/starship/starship.toml")
$env.EDITOR = "nvim"

$env.ENV_CONVERSIONS = {
    "PATH": {
        from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
        to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
    }
}

$env.NU_LIB_DIRS = [
    ($nu.default-config-dir | path join 'scripts')
    ($nu.data-dir | path join 'completions')
]

$env.NU_PLUGIN_DIRS = [
    ($nu.default-config-dir | path join 'plugins')
]

use std "path add"
path add ($env.HOME | path join ".local/bin")
path add ($env.HOME | path join ".config/emacs/bin")

# Generate cache scripts safely if binaries exist
if (which starship | is-not-empty) {
    starship init nu | save -f ~/.cache/starship/init.nu
}
if (which zoxide | is-not-empty) {
    zoxide init nushell | save -f ~/.zoxide.nu
}
if (which carapace | is-not-empty) {
    $env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense'
    carapace _carapace nushell | save --force ~/.cache/carapace/init.nu
}
