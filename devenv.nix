{ pkgs, lib, config, ... }:

{
  languages.elixir = {
    enable = true;
    package = pkgs.beamPackages.elixir_1_19;
  };

  packages = with pkgs; [
    git
    jq
    curl
    docker-client
    (if stdenv.hostPlatform.isDarwin then fswatch else inotify-tools)
  ];

  # devenv 1.11.2 exports PC_CONFIG_FILES whenever the process manager is
  # process-compose, but only defines `configFile` when at least one process is
  # declared -- so a shell with no processes fails to evaluate. Upstream now
  # guards this on `hasProcesses`, but that fix is not in a tagged release yet.
  # Supplying devenv's own default unconditionally, at a lower priority than its
  # mkDefault, keeps evaluation working and still defers to devenv if processes
  # are added later. Drop once devenv > 1.11.2 is pinned in flake.nix.
  process.managers.process-compose.configFile = lib.mkOptionDefault
    ((pkgs.formats.yaml { }).generate "process-compose.yaml"
      config.process.managers.process-compose.settings);

  env = {
    MIX_HOME = "${config.devenv.state}/mix";
    HEX_HOME = "${config.devenv.state}/hex";
    ERL_AFLAGS = "-kernel shell_history enabled";
    PORT = "4000";
    PHX_HOST = "localhost";
  };

  enterShell = ''
    mix local.hex --if-missing --force
    mix local.rebar --if-missing --force

    echo ""
    echo "Elixir $(elixir --version | tail -1)"
    echo "Phoenix/Jido hackathon app"
    echo ""
    echo "Run 'mix setup' then 'mix phx.server'"
  '';
}
