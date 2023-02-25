#if defined _CSGOTAILOR_HOOK_PLAYER_SPAWNED_INCLUDED
  #endinput
#endif
#define _CSGOTAILOR_HOOK_PLAYER_SPAWNED_INCLUDED

Action Hook_OnPlayerSpawned(Event event, const char[] name, bool dontBroadcast) {
  int client = GetClientOfUserId(event.GetInt("userid"));

  int team = GetClientTeam(client);

  if (IsPlayer(client) && IsClientInGame(client) && IsPlayerAlive(client) && team == 2 || team == 3) {
    Player.Get(client).GiveGloves();
    return Plugin_Handled;
  }

  return Plugin_Continue;
}
