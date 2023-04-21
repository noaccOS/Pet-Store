{
  description = "Phoenix project made to get in touch with Phoenix and REST APIs";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-22.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { self
    , nixpkgs
    , flake-utils
    }:

    flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs { inherit system; };
    in
    {
      devShells.default = pkgs.mkShell {
        packages = (with pkgs; [ elixir ]) ++
          pkgs.lib.optionals (pkgs.stdenv.isLinux) (with pkgs; [ gigalixir inotify-tools libnotify ]) ++ # Linux only
          pkgs.lib.optionals (pkgs.stdenv.isDarwin) (with pkgs; [ terminal-notifier ] ++ # macOS only
            (with pkgs.darwin.apple_sdk.frameworks; [ CoreFoundation CoreServices ]));

        shellHook = ''
          ${pkgs.elixir}/bin/mix --version
          ${pkgs.elixir}/bin/iex --version
        '';
      };
    });
}
