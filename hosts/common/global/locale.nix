{ lib, ... }:
{
  i18n = {
    defaultLocale = lib.mkDefault "en_US.UTF-8";
    supportedLocales = lib.mkDefault [ "en_US.UTF-8/UTF-8" ];
  };
  console.keyMap = lib.mkDefault "us";
  time.timeZone = lib.mkDefault "America/New_York";
}
