#if defined _CSGOTAILOR_HOOK_PLAYER_CONNECTED_INCLUDED
  #endinput
#endif
#define _CSGOTAILOR_HOOK_PLAYER_CONNECTED_INCLUDED

Action Hook_OnPlayerConnected(Event event, const char[] name, bool dontBroadcast) {
  int userId = event.GetInt("userid");
  int client = GetClientOfUserId(userId);
  Player.Register(client);
  return Plugin_Continue;
}
