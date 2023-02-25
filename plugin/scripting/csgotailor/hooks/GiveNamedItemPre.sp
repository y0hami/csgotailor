#if defined _CSGOTAILOR_HOOK_GIVE_NAMED_ITEM_PRE_INCLUDED
  #endinput
#endif
#define _CSGOTAILOR_HOOK_GIVE_NAMED_ITEM_PRE_INCLUDED

Action Hook_GiveNamedItemPre (
  int client,
  char classname[64],
  CEconItemView &item,
  bool &ignoredCEconItemView,
  bool &originIsNull,
  float origin[3]
) {
  if (IsPlayer(client)) {
    Player player = Player.Get(client);

    char team[MAX_TEAM_KEY_SIZE];
    player.GetTeam(team, sizeof(team));

    if (player.HasKnife(team) && IsKnifeClass(classname)) {
      ignoredCEconItemView = true;
      player.GetKnife(team).GetClassname(classname, sizeof(classname));

      return Plugin_Changed;
    }
  }

  return Plugin_Continue;
}
