$env.STARSHIP_CONFIG = ($env.HOME | path join ".config/starship/starship.toml")
$env.EDITOR = "emacsclient -t -a 'emacs'"
$env.VISUAL = "emacsclient -c -a 'emacs'"

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

let cache_dir = ($env.HOME | path join ".cache")
mkdir ($cache_dir | path join "starship")
mkdir ($cache_dir | path join "carapace")

if (which starship | is-not-empty) {
    starship init nu | save -f ($cache_dir | path join "starship/init.nu")
}
if (which zoxide | is-not-empty) {
    zoxide init nushell | save -f ($env.HOME | path join ".zoxide.nu")
}
if (which carapace | is-not-empty) {
    $env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense'
    carapace _carapace nushell | save --force ($cache_dir | path join "carapace/init.nu")
}