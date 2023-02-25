#if defined _CSGOTAILOR_HOOK_WEAPON_CAN_USE_PRE_INCLUDED
  #endinput
#endif
#define _CSGOTAILOR_HOOK_WEAPON_CAN_USE_PRE_INCLUDED

Action Hook_WeaponCanUsePre (int client, int weapon, bool &pickup) {
  if (IsKnife(weapon) && IsPlayer(client)) {
    pickup = true;
    return Plugin_Changed;
  }

  return Plugin_Continue;
}
