#if defined _CSGOTAILOR_MENU_MAIN_INCLUDED
  #endinput
#endif
#define _CSGOTAILOR_MENU_MAIN_INCLUDED

public Menu CreateMenu_Main(int client) {
  Menu menu = new Menu(MenuHandler_Main);
  menu.ExitButton = true;
  menu.SetTitle("CS:GO Tailor");

  bool enabled = false;

  if (FeatureIsEnabled(FEATURE_WEAPONS)
    || FeatureIsEnabled(FEATURE_KNIFES)
    || FeatureIsEnabled(FEATURE_GLOVES)) {
    enabled = CanUseWeapons(client)
      || CanUseKnifes(client)
      || CanUseGloves(client);

    menu.AddItem("#loadout", "Loadout", enabled ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
  }

  if (FeatureIsEnabled(FEATURE_AGENTS)) {
    enabled = CanUseAgents(client);

    menu.AddItem("#agent", "Agent", enabled ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
  }

  if (FeatureIsEnabled(FEATURE_SPRAYS)) {
    enabled = CanUseSprays(client);

    menu.AddItem("#spray", "Spray", enabled ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
  }

  if (FeatureIsEnabled(FEATURE_PROFILE_PIN)
    || FeatureIsEnabled(FEATURE_PROFILE_RANK)
    || FeatureIsEnabled(FEATURE_PROFILE_XPLEVEL)
    || FeatureIsEnabled(FEATURE_PROFILE_MUSICKIT)) {
    enabled = CanUseProfilePin(client)
      || CanUseProfileRank(client)
      || CanUseProfileXPLevel(client)
      || CanUseProfileMusicKit(client);

    menu.AddItem("#profile", "Profile Display", enabled ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
  }

  return menu;
}

public int MenuHandler_Main (Menu menu, MenuAction action, int client, int selectedItem) {
  if (action == MenuAction_Select) {
    char option[32];
    menu.GetItem(selectedItem, option, sizeof(option));

    Player player = Player.Get(client);

    if (StrEqual(option, "#loadout")) {
      player.OpenMenu(CreateMenu_Loadout_TeamSelect(client));
    } else if (StrEqual(option, "#agent")) {
    } else if (StrEqual(option, "#spray")) {
    } else if (StrEqual(option, "#profile")) {
    } else if (StrEqual(option, "#exit")) {
    }
  } else if (action == MenuAction_End) {
    delete menu;
  }

  return 0;
}
