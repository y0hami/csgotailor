#if defined _CSGOTAILOR_ON_PLUGIN_END_FORWARD_INCLUDED
  #endinput
#endif
#define _CSGOTAILOR_ON_PLUGIN_END_FORWARD_INCLUDED

public void OnPluginEnd() {
  for (int i = 1; i <= MaxClients; i++) {
    if (IsPlayer(i)) {
      Player.Unregister(i);
    }
  }
}
