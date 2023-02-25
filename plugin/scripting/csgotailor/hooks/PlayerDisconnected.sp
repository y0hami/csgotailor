#if defined _CSGOTAILOR_HOOK_PLAYER_DISCONNECTED_INCLUDED
  #endinput
#endif
#define _CSGOTAILOR_HOOK_PLAYER_DISCONNECTED_INCLUDED

Action Hook_OnPlayerDisconnected(Event event, const char[] name, bool dontBroadcast) {
  int userId = event.GetInt("userid");
  int client = GetClientOfUserId(userId);
  Player.Unregister(client);
  return Plugin_Continue;
}
