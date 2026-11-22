# One place for the desktop's shared look. Umbriel, the Noctalia bar and panels,
# foot, GTK and the fonts all read from here. Ignored by import-tree (leading _).
{
  font = "Maple Mono NF";

  # Background translucency for the bar, panels, terminals and GTK apps: the
  # 80% Noctalia gives floating panels in its "soft" mode (shell.nix), so
  # everything matches them. Text and images stay opaque; the compositor blurs whatever
  # shows through.
  opacity = 0.8;

  # Moderate frosted glass (JaKooLit: size 6, 3 passes). Each pass halves the
  # image: much past 4-5 passes the wallpaper collapses into one flat color
  # and the glass looks solid instead of blurrier.
  blur = {
    passes = 3;
    radius = 6;
  };

  # Corner radius shared by windows and the bar.
  radius = 12;

  # Gap between windows; the floating bar is inset by the same amount.
  gap = 8;

  # Unfocused windows are darkened by this fraction; their transparency
  # matches the focused window's (opacity 1.0 = unchanged), so only the
  # shade tells them apart. Focus has no border or title bar.
  unfocusedDim = 0.1;
  unfocusedOpacity = 1.0;
}
