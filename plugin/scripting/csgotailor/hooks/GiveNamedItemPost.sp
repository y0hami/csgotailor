#if defined _CSGOTAILOR_HOOK_GIVE_NAMED_ITEM_POST_INCLUDED
  #endinput
#endif
#define _CSGOTAILOR_HOOK_GIVE_NAMED_ITEM_POST_INCLUDED

void Hook_GiveNamedItemPost (
  int client,
  const char[] classname,
  const CEconItemView item,
  int entity,
  bool originIsNull,
  const float origin[3]
) {
  if (IsPlayer(client)) {
    if (IsKnifeClass(classname)) {
      EquipPlayerWeapon(client, entity);
    }

    Player.Get(client).SetItemProps(entity);
  }
}
