#if defined _CSGOTAILOR_HOOK_ON_DAMAGE_INCLUDED
  #endinput
#endif
#define _CSGOTAILOR_HOOK_ON_DAMAGE_INCLUDED

Action Hook_OnDamage(
  int victim,
  int &attacker,
  int &inflictor,
  float &damage,
  int &damageType,
  int &weapon,
  float damageForce[3],
  float damagePosition[3]
) {
  if (float(GetClientHealth(victim)) - damage > 0.0) return Plugin_Continue;
  if (!(damageType & DMG_SLASH) && !(damageType & DMG_BULLET)) return Plugin_Continue;
  if (!IsPlayer(attacker)) return Plugin_Continue;
  if (!IsValidWeapon(weapon)) return Plugin_Continue;

  int prevOwner;
  if ((prevOwner = GetEntPropEnt(weapon, Prop_Send, "m_hPrevOwner")) != INVALID_ENT_REFERENCE && prevOwner != attacker) return Plugin_Continue;

  Player player = Player.Get(attacker);

  char classname[MAX_CLASSNAME_SIZE];
  ClassnameFromEntity(weapon, classname, sizeof(classname));

  char team[MAX_TEAM_KEY_SIZE];
  player.GetTeam(team, sizeof(team));

  int count;

  if ((damageType & DMG_SLASH) && player.HasKnife(team) && player.GetKnife(team).IsStatTrakEnabled()) {
    PlayerKnife playerKnife = player.GetKnife(team);
    count = playerKnife.GetStatTrakCount() + 1;
    playerKnife.SetStatTrakCount(count);
  } else if ((damageType & DMG_BULLET) && player.HasWeapon(team, classname) && player.GetWeapon(team, classname).IsStatTrakEnabled()) {
    PlayerWeapon playerWeapon = player.GetWeapon(team, classname);
    count = playerWeapon.GetStatTrakCount() + 1;
    playerWeapon.SetStatTrakCount(count);
  }

  return Plugin_Continue;
}
