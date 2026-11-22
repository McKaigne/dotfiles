# Android, prepared for Flutter and Kotlin: an SDK composed to match this
# Flutter's defaults (compile/target SDK 36, min 24, NDK 28.2.13676358, see
# flutter_tools/gradle/.../FlutterExtension.kt), so Gradle never tries to
# download into the read-only SDK; the emulator with an Android 36 image; and
# JDK 17 for the Android Gradle plugin. Create an emulator once with
#   avdmanager create avd -n pixel -k "system-images;android-36;google_apis;x86_64"
# then `flutter emulators --launch pixel`.
{
  nixos.base = {config, ...}: {
    nixpkgs.config.android_sdk.accept_license = true;
    # Hardware acceleration for the emulator.
    users.users.${config.workstation.username}.extraGroups = ["kvm"];
  };

  flake.modules.homeManager.development = {pkgs, ...}: let
    android = pkgs.androidenv.composeAndroidPackages {
      minPlatformVersion = "36";
      maxPlatformVersion = "36";
      buildToolsVersions = ["35.0.0" "36.0.0"];
      includeNDK = true;
      ndkVersions = ["28.2.13676358"];
      cmakeVersions = ["3.22.1"];
      includeEmulator = true;
      includeSystemImages = true;
      systemImageTypes = ["google_apis"];
      abiVersions = ["x86_64"];
    };
    sdk = "${android.androidsdk}/libexec/android-sdk";
  in {
    home.packages = [android.androidsdk pkgs.jdk17];
    home.sessionVariables = {
      ANDROID_HOME = sdk;
      ANDROID_SDK_ROOT = sdk;
      JAVA_HOME = pkgs.jdk17.home;
      # Gradle otherwise fetches its own aapt2 from Maven, which cannot run
      # on NixOS; use the SDK's.
      GRADLE_OPTS = "-Dorg.gradle.project.android.aapt2FromMavenOverride=${sdk}/build-tools/36.0.0/aapt2";
    };
  };
}
