#pragma newdecls required
#pragma semicolon 1
#pragma dynamic 2_500_000 // 2.5 MB
// Need to have 2.5MB for data files since they contain so much data

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

// dependencies
#include <json>
#include <PTaH>

#undef REQUIRE_EXTENSIONS
#include <sourcescramble>

// includes
#include "include/csgotailor.inc"

// plugin includes
#include "csgotailor/const.sp"
#include "csgotailor/globals.sp"
#include "csgotailor/cvars.sp"
#include "csgotailor/natives.sp"
#include "csgotailor/utils.sp"
#include "csgotailor/sdk.sp"
#include "csgotailor/data.sp"
#include "csgotailor/features.sp"
#include "csgotailor/permissions.sp"
#include "csgotailor/database.sp"
#include "csgotailor/classes/classes.sp"
#include "csgotailor/hooks/hooks.sp"
#include "csgotailor/menus/menus.sp"
#include "csgotailor/forwards/forwards.sp"
#include "csgotailor/commands.sp"

public Plugin myinfo = {
  name = "CSGO Tailor",
  author = "@y0hami",
  description = "Customize weapons, knifes, gloves, agents, stickers and everything else!",
  version = VERSION,
  url = "https://github.com/hammy2899/csgotailor"
};

public void OnPluginStart() {
  if(GetEngineVersion() != Engine_CSGO) {
    SetFailState("CSGO Tailor only works on CSGO servers.");
    return;
  }

  Setup_SDK();
  Setup_ConVars();
  Setup_Database();
  Setup_Data();
  Setup_Permissions();
  Setup_Hooks();
  Setup_Commands();

  // g_econItemOffset = FindSendPropOffset("CBaseCombatWeapon", "m_Item");

  for (int i = 1; i <= MaxClients; i++) {
    if (IsPlayer(i)) {
      Player.Register(i);
    }
  }
}
