#if defined _CSGOTAILOR_MENU_LOADOUT_INCLUDED
  #endinput
#endif
#define _CSGOTAILOR_MENU_LOADOUT_INCLUDED

public Menu CreateMenu_Loadout_TeamSelect(int client) {
  Menu menu = new Menu(MenuHandler_Loadout_TeamSelect);
  menu.ExitBackButton = true;
  menu.SetTitle("Loadout > Choose Team");

  menu.AddItem("#T", "Terrorists", ITEMDRAW_DEFAULT);
  menu.AddItem("#CT", "Counter-Terrorists", ITEMDRAW_DEFAULT);

  return menu;
}

public int MenuHandler_Loadout_TeamSelect (Menu menu, MenuAction action, int client, int selectedItem) {
  Player player = Player.Get(client);

  if (action == MenuAction_Select) {
    char option[32];
    menu.GetItem(selectedItem, option, sizeof(option));

    if (StrEqual(option, "#T")) {
      player.GetMenuState().SetString("team", TEAM_T);
    } else if (StrEqual(option, "#CT")) {
      player.GetMenuState().SetString("team", TEAM_CT);
    }

    player.OpenMenu(CreateMenu_Loadout_Main(client));
  } else if (action == MenuAction_Cancel) {
    if (selectedItem == MenuCancel_ExitBack) {
      player.OpenMenu(CreateMenu_Main(client));
    }
  } else if (action == MenuAction_End) {
    delete menu;
  }

  return 0;
}

public Menu CreateMenu_Loadout_Main(int client) {
  Player player = Player.Get(client);
  char selectedTeam[MAX_TEAM_KEY_SIZE];
  char selectedTeamName[MAX_TEAM_NAME_SIZE];
  player.GetMenuState().GetString("team", selectedTeam, sizeof(selectedTeam));
  TeamKeyToName(selectedTeam, selectedTeamName, sizeof(selectedTeamName));

  Menu menu = new Menu(MenuHandler_Loadout_Main);
  menu.ExitBackButton = true;
  menu.SetTitle("Loadout > %s", selectedTeamName);

  if (FeatureIsEnabled(FEATURE_WEAPONS)) {
    menu.AddItem("#weapons", "Weapons", CanUseWeapons(client) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
  }

  if (FeatureIsEnabled(FEATURE_KNIFES)) {
    menu.AddItem("#knife", "Knife", CanUseKnifes(client) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
  }

  if (FeatureIsEnabled(FEATURE_GLOVES)) {
    menu.AddItem("#gloves", "Gloves", CanUseGloves(client) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
  }

  return menu;
}

public int MenuHandler_Loadout_Main (Menu menu, MenuAction action, int client, int selectedItem) {
  if (action == MenuAction_Select) {
    char option[32];
    menu.GetItem(selectedItem, option, sizeof(option));

    Player player = Player.Get(client);

    if (StrEqual(option, "#weapons")) {
      player.GetMenuState().SetString("type", MENU_TYPE_WEAPONS);
      player.OpenMenu(CreateMenu_Weapons_Select(client));
    } else if (StrEqual(option, "#knife")) {
      player.GetMenuState().SetString("type", MENU_TYPE_KNIFE);
      player.OpenMenu(CreateMenu_Knife_Main(client));
    } else if (StrEqual(option, "#gloves")) {
      player.GetMenuState().SetString("type", MENU_TYPE_GLOVES);
      player.OpenMenu(CreateMenu_Gloves_Main(client));
    }
  } else if (action == MenuAction_Cancel) {
    if (selectedItem == MenuCancel_ExitBack) {
      Player.Get(client).OpenMenu(CreateMenu_Loadout_TeamSelect(client));
    }
  } else if (action == MenuAction_End) {
    delete menu;
  }

  return 0;
}
