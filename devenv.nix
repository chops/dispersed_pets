{ pkgs, config, ... }:

{
  languages.elixir = {
    enable = true;
    package = pkgs.elixir_1_19;
  };

  packages = with pkgs; [
    git
    jq
    curl
    docker-client
    (if stdenv.isDarwin then fswatch else inotify-tools)
  ];

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
