#if defined _CSGOTAILOR_HOOK_PLAYER_SPAWNED_INCLUDED
  #endinput
#endif
#define _CSGOTAILOR_HOOK_PLAYER_SPAWNED_INCLUDED

Action Hook_OnPlayerSpawned(Event event, const char[] name, bool dontBroadcast) {
  int client = GetClientOfUserId(event.GetInt("userid"));

  if (IsPlayer(client)) {
    Player.Get(client).GiveGloves();
    return Plugin_Handled;
  }

  return Plugin_Continue;
}
