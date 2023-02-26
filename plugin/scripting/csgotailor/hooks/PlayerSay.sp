#if defined _CSGOTAILOR_HOOK_PLAYER_SAY_INCLUDED
  #endinput
#endif
#define _CSGOTAILOR_HOOK_PLAYER_SAY_INCLUDED

public Action Hook_OnPlayerSay(int client, const char[] command, int args) {
  if (!IsPlayer(client)) return Plugin_Continue;

  char message[255];
  GetCmdArgString(message, sizeof(message));
  StripQuotes(message);

  if (g_waitingForWearValue[client] ||
      g_waitingForSeedValue[client] ||
      g_waitingForNametagValue[client] ||
      g_waitingForSearchValue[client]) {

    Player player = Player.Get(client);

    char menuType[16];
    player.GetMenuState().GetString("type", menuType, sizeof(menuType));

    if (g_waitingForWearValue[client]) {
      g_waitingForWearValue[client] = false;

      if (StrEqual(message, "!cancel")) {
        CST_Message(client, "Custom wear value cancelled.");
      } else {
        float newWear;
        if ((newWear = StringToFloat(message)) < 0) {
          CST_Message(client, "Failed to set wear, %s is not a valid float value.", message);
        } else {
          if (newWear < 0.00) {
            CST_Message(client, "Can't set wear to a value less than 0.00");
          } else if (newWear > 1.00) {
            CST_Message(client, "Can't set wear to a value more than 1.00");
          } else {
            char selectedTeam[MAX_TEAM_KEY_SIZE];
            char selectedTeamName[MAX_TEAM_NAME_SIZE];
            player.GetMenuState().GetString("team", selectedTeam, sizeof(selectedTeam));
            TeamKeyToName(selectedTeam, selectedTeamName, sizeof(selectedTeamName));

            if (StrEqual(menuType, MENU_TYPE_WEAPONS)) {
              Weapon selectedWeapon = view_as<Weapon>(player.GetMenuState().GetObject("weapon"));
              char weaponClassname[MAX_CLASSNAME_SIZE];
              char weaponName[MAX_WEAPON_NAME_SIZE];
              selectedWeapon.GetClassname(weaponClassname, sizeof(weaponClassname));
              selectedWeapon.GetName(weaponName, sizeof(weaponName));

              PlayerWeapon tailoredWeapon = player.GetWeapon(selectedTeam, weaponClassname);
              tailoredWeapon.SetWear(newWear);

              char paintName[MAX_PAINT_NAME_SIZE];
              char wearName[MAX_WEAR_NAME_SIZE];
              tailoredWeapon.GetPaint().GetName(paintName, sizeof(paintName));
              GetWearName(newWear, wearName, sizeof(wearName));

              CST_Message(client, "Set wear to {ORANGE}%s{NORMAL} ({ORANGE}%f{NORMAL}) on {ORANGE}%s - %s{NORMAL}", wearName, newWear, weaponName, paintName);
              player.OpenMenu(CreateMenu_Weapons_Wear(client));
            } else if (StrEqual(menuType, MENU_TYPE_KNIFE)) {
              PlayerKnife tailoredKnife = player.GetKnife(selectedTeam);
              tailoredKnife.SetWear(newWear);

              char knifeName[MAX_KNIFE_NAME_SIZE];
              char wearName[MAX_WEAR_NAME_SIZE];
              tailoredKnife.GetName(knifeName, sizeof(knifeName));
              GetWearName(newWear, wearName, sizeof(wearName));

              CST_Message(client, "Set wear to {ORANGE}%s{NORMAL} ({ORANGE}%f{NORMAL}) on {ORANGE}%s{NORMAL}", wearName, newWear, knifeName);
              player.OpenMenu(CreateMenu_Knife_Wear(client));
            } else if (StrEqual(menuType, MENU_TYPE_GLOVES)) {
              PlayerGloves tailoredGloves = player.GetGloves(selectedTeam);
              tailoredGloves.SetWear(newWear);

              char wearName[MAX_WEAR_NAME_SIZE];
              GetWearName(newWear, wearName, sizeof(wearName));

              CST_Message(client, "Set wear to {ORANGE}%s{NORMAL} ({ORANGE}%f{NORMAL}) on {ORANGE}%s{NORMAL} gloves", wearName, newWear, selectedTeamName);
              player.OpenMenu(CreateMenu_Gloves_Wear(client));
            }
          }
        }
      }
    } else if (g_waitingForSeedValue[client]) {
      g_waitingForSeedValue[client] = false;

      if (StrEqual(message, "!cancel")) {
        CST_Message(client, "Custom seed value cancelled.");
      } else {
        int newSeed;
        if ((newSeed = StringToInt(message)) < 0) {
          CST_Message(client, "Failed to set seed, %s is not a valid integer value.", message);
        } else {
          if (newSeed < 0) {
            CST_Message(client, "Can't set seed to a value less than 0");
          } else if (newSeed > 10000) {
            CST_Message(client, "Can't set seed to a value more than 10,000");
          } else {
            char selectedTeam[MAX_TEAM_KEY_SIZE];
            char selectedTeamName[MAX_TEAM_NAME_SIZE];
            player.GetMenuState().GetString("team", selectedTeam, sizeof(selectedTeam));
            TeamKeyToName(selectedTeam, selectedTeamName, sizeof(selectedTeamName));

            if (StrEqual(menuType, MENU_TYPE_WEAPONS)) {
              Weapon selectedWeapon = view_as<Weapon>(player.GetMenuState().GetObject("weapon"));
              char weaponClassname[MAX_CLASSNAME_SIZE];
              char weaponName[MAX_WEAPON_NAME_SIZE];
              selectedWeapon.GetClassname(weaponClassname, sizeof(weaponClassname));
              selectedWeapon.GetName(weaponName, sizeof(weaponName));

              PlayerWeapon tailoredWeapon = player.GetWeapon(selectedTeam, weaponClassname);
              tailoredWeapon.SetSeed(newSeed);

              char paintName[MAX_PAINT_NAME_SIZE];
              tailoredWeapon.GetPaint().GetName(paintName, sizeof(paintName));

              CST_Message(client, "Set seed to {ORANGE}%d{NORMAL} on {ORANGE}%s - %s{NORMAL}", newSeed, weaponName, paintName);
              player.OpenMenu(CreateMenu_Weapons_Seed(client));
            } else if (StrEqual(menuType, MENU_TYPE_KNIFE)) {
              PlayerKnife tailoredKnife = player.GetKnife(selectedTeam);
              tailoredKnife.SetSeed(newSeed);

              char knifeName[MAX_KNIFE_NAME_SIZE];
              tailoredKnife.GetName(knifeName, sizeof(knifeName));

              CST_Message(client, "Set seed to {ORANGE}%d{NORMAL} on {ORANGE}%s{NORMAL}", newSeed, knifeName);
              player.OpenMenu(CreateMenu_Knife_Seed(client));
            } else if (StrEqual(menuType, MENU_TYPE_GLOVES)) {
              PlayerGloves tailoredGloves = player.GetGloves(selectedTeam);
              tailoredGloves.SetSeed(newSeed);

              CST_Message(client, "Set seed to {ORANGE}%d{NORMAL} on {ORANGE}%s{NORMAL} gloves", newSeed, selectedTeamName);
              player.OpenMenu(CreateMenu_Gloves_Seed(client));
            }
          }
        }
      }
    } else if (g_waitingForNametagValue[client]) {
      g_waitingForNametagValue[client] = false;

      if (StrEqual(message, "!cancel")) {
        CST_Message(client, "Custom nametag cancelled.");
      } else {
        if (strlen(message) > MAX_NAMETAG_SIZE) {
          CST_Message(client, "Failed to set nametag, {ORANGE}%s{NORMAL} is too long. Nametags can only be %d characters.", message, MAX_NAMETAG_SIZE);
        } else if (strlen(message) <= 0) {
          CST_Message(client, "Failed to set nametag. Nametag can't be empty.", message);
        } else {
          char selectedTeam[MAX_TEAM_KEY_SIZE];
          player.GetMenuState().GetString("team", selectedTeam, sizeof(selectedTeam));

          if (StrEqual(menuType, MENU_TYPE_WEAPONS)) {
            Weapon selectedWeapon = view_as<Weapon>(player.GetMenuState().GetObject("weapon"));
            char weaponClassname[MAX_CLASSNAME_SIZE];
            char weaponName[MAX_WEAPON_NAME_SIZE];
            selectedWeapon.GetClassname(weaponClassname, sizeof(weaponClassname));
            selectedWeapon.GetName(weaponName, sizeof(weaponName));

            PlayerWeapon tailoredWeapon = player.GetWeapon(selectedTeam, weaponClassname);
            tailoredWeapon.SetNametag(message);

            char paintName[MAX_PAINT_NAME_SIZE];
            tailoredWeapon.GetPaint().GetName(paintName, sizeof(paintName));

            CST_Message(client, "Set nametag to {ORANGE}%s{NORMAL} on {ORANGE}%s - %s{NORMAL}", message, weaponName, paintName);
            player.OpenMenu(CreateMenu_Weapons_Nametag(client));
          } else if (StrEqual(menuType, MENU_TYPE_KNIFE)) {
            PlayerKnife tailoredKnife = player.GetKnife(selectedTeam);
            tailoredKnife.SetNametag(message);

            char knifeName[MAX_KNIFE_NAME_SIZE];
            tailoredKnife.GetName(knifeName, sizeof(knifeName));

            CST_Message(client, "Set nametag to {ORANGE}%s{NORMAL} on {ORANGE}%s{NORMAL}", message, knifeName);
            player.OpenMenu(CreateMenu_Knife_Nametag(client));
          }
        }
      }
    } else if (g_waitingForSearchValue[client]) {
      g_waitingForSearchValue[client] = false;

      if (StrEqual(message, "!cancel")) {
        CST_Message(client, "Search cancelled.");
      } else {
        player.GetMenuState().SetString("searchQuery", message);
        player.OpenMenu(CreateMenu_Weapons_Stickers_Search(client));
      }
    }

    return Plugin_Handled;
  }

  return Plugin_Continue;
}