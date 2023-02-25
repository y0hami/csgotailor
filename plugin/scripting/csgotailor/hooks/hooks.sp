#if defined _CSGOTAILOR_HOOKS_INCLUDED
  #endinput
#endif
#define _CSGOTAILOR_HOOKS_INCLUDED

#include "PlayerConnected.sp"
#include "PlayerDisconnected.sp"
#include "PlayerSpawned.sp"
#include "PlayerSay.sp"
#include "OnDamage.sp"
#include "GiveNamedItemPre.sp"
#include "GiveNamedItemPost.sp"
#include "WeaponCanUsePre.sp"

void Setup_Hooks() {
  HookEvent("player_connect_full", Hook_OnPlayerConnected, EventHookMode_Post);
  HookEvent("player_disconnect", Hook_OnPlayerDisconnected, EventHookMode_Post);
  HookEvent("player_spawn", Hook_OnPlayerSpawned, EventHookMode_Pre);

  PTaH(PTaH_GiveNamedItemPre, Hook, Hook_GiveNamedItemPre);
  PTaH(PTaH_GiveNamedItemPost, Hook, Hook_GiveNamedItemPost);

  ConVar g_cvGameType = FindConVar("game_type");
  ConVar g_cvGameMode = FindConVar("game_mode");

  if (g_cvGameType.IntValue == 1 && g_cvGameMode.IntValue == 2) {
    PTaH(PTaH_WeaponCanUsePre, Hook, Hook_WeaponCanUsePre);
  }

  AddCommandListener(Hook_OnPlayerSay, "say");
  AddCommandListener(Hook_OnPlayerSay, "say2");
  AddCommandListener(Hook_OnPlayerSay, "say_team");
}
