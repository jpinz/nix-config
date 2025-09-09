{ pkgs, ... }:
{
  # Import the new modular dashboard configuration
  imports = [
    ./dashboard
  ];
}
