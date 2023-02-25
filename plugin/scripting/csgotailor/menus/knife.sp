#if defined _CSGOTAILOR_MENU_KNIFE_INCLUDED
  #endinput
#endif
#define _CSGOTAILOR_MENU_KNIFE_INCLUDED

public Menu CreateMenu_Knife_Main(int client) {
  Player player = Player.Get(client);

  char selectedTeam[MAX_TEAM_KEY_SIZE];
  char selectedTeamName[MAX_TEAM_NAME_SIZE];
  player.GetMenuState().GetString("team", selectedTeam, sizeof(selectedTeam));
  TeamKeyToName(selectedTeam, selectedTeamName, sizeof(selectedTeamName));

  Menu menu = new Menu(MenuHandler_Knife_Main);
  menu.ExitBackButton = true;
  menu.SetTitle("Loadout > %s > Knife", selectedTeamName);

  bool hasKnife = player.HasKnife(selectedTeam);
  char itemText[MAX_MENU_ITEM_SIZE];

  if (hasKnife) {
    PlayerKnife tailoredKnife = player.GetKnife(selectedTeam);

    char knifeName[MAX_KNIFE_NAME_SIZE];
    char paintName[MAX_PAINT_NAME_SIZE];
    char wearKey[MAX_WEAR_KEY_SIZE];
    char stattrakText[16];
    char nametag[MAX_NAMETAG_SIZE];

    tailoredKnife.GetName(knifeName, sizeof(knifeName));
    tailoredKnife.GetPaint().GetName(paintName, sizeof(paintName));
    GetWearKey(tailoredKnife.GetWear(), wearKey, sizeof(wearKey));
    stattrakText = tailoredKnife.IsStatTrakEnabled() ? "ON" : "OFF";

    Format(itemText, sizeof(itemText), "Type [%s]", knifeName);
    menu.AddItem("#type", itemText, ITEMDRAW_DEFAULT);

    Format(itemText, sizeof(itemText), "Skin [%s]", paintName);
    menu.AddItem("#skin", itemText, CanUseKnifesSkin(client) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

    Format(itemText, sizeof(itemText), "Wear [%s]", wearKey);
    menu.AddItem("#wear", itemText, CanUseKnifesWear(client) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

    Format(itemText, sizeof(itemText), "Seed [%d]", tailoredKnife.GetSeed());
    menu.AddItem("#seed", itemText, CanUseKnifesSeed(client) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

    if (FeatureIsEnabled(FEATURE_STATTRAK)) {
      Format(itemText, sizeof(itemText), "StatTrak™ [%s]", stattrakText);
      menu.AddItem("#stattrak", itemText, CanUseKnifesStatTrak(client) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
    }

    if (FeatureIsEnabled(FEATURE_NAMETAG)) {
      if (tailoredKnife.HasNametag()) {
        tailoredKnife.GetNametag(nametag, sizeof(nametag));
        Format(itemText, sizeof(itemText), "Nametag [%s]", nametag);
      } else {
        Format(itemText, sizeof(itemText), "Nametag");
      }
      menu.AddItem("#nametag", itemText, CanUseKnifesNametag(client) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
    }
  } else {
    menu.AddItem("#type", "Choose Knife", ITEMDRAW_DEFAULT);
    menu.AddItem("#skin", "Skin", ITEMDRAW_DISABLED);
    menu.AddItem("#wear", "Wear", ITEMDRAW_DISABLED);
    menu.AddItem("#seed", "Seed", ITEMDRAW_DISABLED);

    if (FeatureIsEnabled(FEATURE_STATTRAK)) {
      menu.AddItem("#stattrak", "StatTrak™", ITEMDRAW_DISABLED);
    }

    if (FeatureIsEnabled(FEATURE_NAMETAG)) {
      menu.AddItem("#nametag", "Nametag", ITEMDRAW_DISABLED);
    }
  }

  return menu;
}

public int MenuHandler_Knife_Main (Menu menu, MenuAction action, int client, int selectedItem) {
  if (action == MenuAction_Select) {
    char option[MAX_MENU_KEY_SIZE];
    menu.GetItem(selectedItem, option, sizeof(option));

    Player player = Player.Get(client);

    if (StrEqual(option, "#type")) {
      player.OpenMenu(CreateMenu_Knife_Type(client));
    } else if (StrEqual(option, "#skin")) {
      player.OpenMenu(CreateMenu_Knife_Skins(client));
    } else if (StrEqual(option, "#wear")) {
      player.OpenMenu(CreateMenu_Knife_Wear(client));
    } else if (StrEqual(option, "#seed")) {
      player.OpenMenu(CreateMenu_Knife_Seed(client));
    } else if (StrEqual(option, "#stattrak")) {
      player.OpenMenu(CreateMenu_Knife_StatTrak(client));
    } else if (StrEqual(option, "#nametag")) {
      player.OpenMenu(CreateMenu_Knife_Nametag(client));
    }
  } else if (action == MenuAction_Cancel) {
    if (selectedItem == MenuCancel_ExitBack) {
      Player.Get(client).OpenMenu(CreateMenu_Loadout_Main(client));
    }
  } else if (action == MenuAction_End) {
    delete menu;
  }

  return 0;
}

public Menu CreateMenu_Knife_Type(int client) {
  Player player = Player.Get(client);

  char selectedTeam[MAX_TEAM_KEY_SIZE];
  char selectedTeamName[MAX_TEAM_NAME_SIZE];
  player.GetMenuState().GetString("team", selectedTeam, sizeof(selectedTeam));
  TeamKeyToName(selectedTeam, selectedTeamName, sizeof(selectedTeamName));

  bool hasKnife = player.HasKnife(selectedTeam);
  char currentKnifeClassname[MAX_CLASSNAME_SIZE];
  if (hasKnife) {
    PlayerKnife currentKnife = player.GetKnife(selectedTeam);
    currentKnife.GetClassname(currentKnifeClassname, sizeof(currentKnifeClassname));
  }

  Menu menu = new Menu(MenuHandler_Knife_Type);
  menu.ExitBackButton = true;
  menu.SetTitle("Loadout > %s > Knife > Type", selectedTeamName);

  menu.AddItem("DEFAULT", "Default", hasKnife ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

  JSON_Object knifes = g_data.GetObject("knifes");
  int length = knifes.Iterate();
  int keyLength = 0;
  char name[MAX_KNIFE_NAME_SIZE];
  bool enabled = true;
  for (int i = 0; i < length; i++) {
    keyLength = knifes.GetKeySize(i);
    char[] key = new char[keyLength];
    knifes.GetKey(i, key, keyLength);

    Knife knife = Knife.Get(key);
    knife.GetName(name, sizeof(name));

    enabled = true;
    if (hasKnife && StrEqual(currentKnifeClassname, key)) {
      enabled = false;
    }

    menu.AddItem(key, name, enabled ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
  }

  return menu;
}

public int MenuHandler_Knife_Type (Menu menu, MenuAction action, int client, int selectedItem) {
  if (action == MenuAction_Select) {
    char option[MAX_CLASSNAME_SIZE];
    menu.GetItem(selectedItem, option, sizeof(option));

    Player player = Player.Get(client);

    char selectedTeam[MAX_TEAM_KEY_SIZE];
    char selectedTeamName[MAX_TEAM_NAME_SIZE];
    player.GetMenuState().GetString("team", selectedTeam, sizeof(selectedTeam));
    TeamKeyToName(selectedTeam, selectedTeamName, sizeof(selectedTeamName));

    if (StrEqual(option, "DEFAULT")) {
      player.GetKnife(selectedTeam).Delete();

      CST_Message(client, "Removed {ORANGE}%s{NORMAL} knife", selectedTeamName);
    } else {
      PlayerKnife.ChangeType(client, selectedTeam, option);

      char knifeName[MAX_KNIFE_NAME_SIZE];
      Knife.Get(option).GetName(knifeName, sizeof(knifeName));

      CST_Message(client, "Changed {ORANGE}%s{NORMAL} knife to {ORANGE}%s{NORMAL}", selectedTeamName, knifeName);
    }

    player.OpenMenuAtLastItem(CreateMenu_Knife_Type(client));
  } else if (action == MenuAction_Cancel) {
    if (selectedItem == MenuCancel_ExitBack) {
      Player.Get(client).OpenMenu(CreateMenu_Knife_Main(client));
    }
  } else if (action == MenuAction_End) {
    delete menu;
  }

  return 0;
}

public Menu CreateMenu_Knife_Skins(int client) {
  Player player = Player.Get(client);

  char selectedTeam[MAX_TEAM_KEY_SIZE];
  char selectedTeamName[MAX_TEAM_NAME_SIZE];
  player.GetMenuState().GetString("team", selectedTeam, sizeof(selectedTeam));
  TeamKeyToName(selectedTeam, selectedTeamName, sizeof(selectedTeamName));

  PlayerKnife currentKnife = player.GetKnife(selectedTeam);
  char currentPaintClassname[MAX_CLASSNAME_SIZE];
  currentKnife.GetPaint().GetClassname(currentPaintClassname, sizeof(currentPaintClassname));
  bool knifeHasSkin = !StrEqual(currentPaintClassname, "DEFAULT");

  Menu menu = new Menu(MenuHandler_Knife_Skins);
  menu.ExitBackButton = true;
  menu.SetTitle("Loadout > %s > Knife > Skin", selectedTeamName);

  menu.AddItem("DEFAULT", "Vanilla", knifeHasSkin ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

  PaintCollection paints = currentKnife.GetPaints();
  char paintClassname[MAX_CLASSNAME_SIZE];
  char paintName[MAX_PAINT_NAME_SIZE];
  int length = paints.Length;
  for (int i = 0; i < length; i++) {
    Paint paint = view_as<Paint>(paints.Get(i));
    paint.GetClassname(paintClassname, sizeof(paintClassname));
    paint.GetName(paintName, sizeof(paintName));

    bool enabled = !StrEqual(paintClassname, currentPaintClassname);

    menu.AddItem(paintClassname, paintName, enabled ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
  }

  return menu;
}

public int MenuHandler_Knife_Skins (Menu menu, MenuAction action, int client, int selectedItem) {
  if (action == MenuAction_Select) {
    char option[MAX_CLASSNAME_SIZE];
    menu.GetItem(selectedItem, option, sizeof(option));

    Player player = Player.Get(client);

    char selectedTeam[MAX_TEAM_KEY_SIZE];
    char selectedTeamName[MAX_TEAM_NAME_SIZE];
    player.GetMenuState().GetString("team", selectedTeam, sizeof(selectedTeam));
    TeamKeyToName(selectedTeam, selectedTeamName, sizeof(selectedTeamName));

    PlayerKnife tailoredKnife = player.GetKnife(selectedTeam);

    char knifeName[MAX_KNIFE_NAME_SIZE];
    char paintName[MAX_PAINT_NAME_SIZE];
    tailoredKnife.GetName(knifeName, sizeof(knifeName));
    Paint.Get(option).GetName(paintName, sizeof(paintName));

    tailoredKnife.SetPaint(option);

    CST_Message(client, "Set {ORANGE}%s{NORMAL} skin to {ORANGE}%s{NORMAL} on {ORANGE}%s{NORMAL}", knifeName, paintName, selectedTeamName);
    player.OpenMenuAtLastItem(CreateMenu_Knife_Skins(client));
  } else if (action == MenuAction_Cancel) {
    if (selectedItem == MenuCancel_ExitBack) {
      Player.Get(client).OpenMenu(CreateMenu_Knife_Main(client));
    }
  } else if (action == MenuAction_End) {
    delete menu;
  }

  return 0;
}

public Menu CreateMenu_Knife_Wear(int client) {
  Player player = Player.Get(client);

  char selectedTeam[MAX_TEAM_KEY_SIZE];
  char selectedTeamName[MAX_TEAM_NAME_SIZE];
  player.GetMenuState().GetString("team", selectedTeam, sizeof(selectedTeam));
  TeamKeyToName(selectedTeam, selectedTeamName, sizeof(selectedTeamName));

  PlayerKnife tailoredKnife = player.GetKnife(selectedTeam);
  float wear = tailoredKnife.GetWear();
  char wearKey[MAX_WEAR_KEY_SIZE];
  char wearName[MAX_WEAR_NAME_SIZE];
  GetWearKey(wear, wearKey, sizeof(wearKey));
  GetWearName(wear, wearName, sizeof(wearName));

  Menu menu = new Menu(MenuHandler_Knife_Wear);
  menu.ExitBackButton = true;
  menu.SetTitle("Loadout > %s > Knife > Wear\n \n Current: %s\n Value: %f\n ", selectedTeamName, wearName, wear);

  menu.AddItem("#FN", "Factory New", StrEqual(wearKey, "FN") ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
  menu.AddItem("#MW", "Minimal Wear", StrEqual(wearKey, "MW") ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
  menu.AddItem("#FT", "Field-Tested", StrEqual(wearKey, "FT") ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
  menu.AddItem("#WW", "Well-Worn", StrEqual(wearKey, "WW") ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
  menu.AddItem("#BS", "Battle-Scarred\n ", StrEqual(wearKey, "BS") ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
  menu.AddItem("#custom", "Custom Value", ITEMDRAW_DEFAULT);

  return menu;
}

public int MenuHandler_Knife_Wear (Menu menu, MenuAction action, int client, int selectedItem) {
  if (action == MenuAction_Select) {
    char option[MAX_MENU_KEY_SIZE];
    menu.GetItem(selectedItem, option, sizeof(option));

    Player player = Player.Get(client);

    char selectedTeam[MAX_TEAM_KEY_SIZE];
    player.GetMenuState().GetString("team", selectedTeam, sizeof(selectedTeam));

    PlayerKnife tailoredKnife = player.GetKnife(selectedTeam);

    if (StrEqual(option, "#custom")) {
      g_waitingForWearValue[client] = true;
      CST_Message(client, "Enter the wear value you'd like to use in chat. Type !cancel to cancel.");
    } else {
      if (StrEqual(option, "#FN")) {
        tailoredKnife.SetWear(0.00);
      } else if (StrEqual(option, "#MW")) {
        tailoredKnife.SetWear(0.11);
      } else if (StrEqual(option, "#FT")) {
        tailoredKnife.SetWear(0.26);
      } else if (StrEqual(option, "#WW")) {
        tailoredKnife.SetWear(0.41);
      } else if (StrEqual(option, "#BS")) {
        tailoredKnife.SetWear(1.00);
      }

      char wearName[MAX_WEAR_NAME_SIZE];
      char knifeName[MAX_KNIFE_NAME_SIZE];
      GetWearName(tailoredKnife.GetWear(), wearName, sizeof(wearName));
      tailoredKnife.GetName(knifeName, sizeof(knifeName));

      CST_Message(client, "Set wear to {ORANGE}%s{NORMAL} on {ORANGE}%s{NORMAL}", wearName, knifeName);
      player.OpenMenuAtLastItem(CreateMenu_Knife_Wear(client));
    }
  } else if (action == MenuAction_Cancel) {
    if (selectedItem == MenuCancel_ExitBack) {
      Player.Get(client).OpenMenu(CreateMenu_Knife_Main(client));
    }
  } else if (action == MenuAction_End) {
    delete menu;
  }

  return 0;
}

public Menu CreateMenu_Knife_Seed(int client) {
  Player player = Player.Get(client);

  char selectedTeam[MAX_TEAM_KEY_SIZE];
  char selectedTeamName[MAX_TEAM_NAME_SIZE];
  player.GetMenuState().GetString("team", selectedTeam, sizeof(selectedTeam));
  TeamKeyToName(selectedTeam, selectedTeamName, sizeof(selectedTeamName));

  PlayerKnife tailoredKnife = player.GetKnife(selectedTeam);

  char knifeClassname[MAX_CLASSNAME_SIZE];
  tailoredKnife.GetClassname(knifeClassname, sizeof(knifeClassname));

  int seed = tailoredKnife.GetSeed();
  bool hasPresets = tailoredKnife.GetPaint().HasSeedPresets(knifeClassname);

  Menu menu = new Menu(MenuHandler_Knife_Seed);
  menu.ExitBackButton = true;
  menu.SetTitle("Loadout > %s > Knife > Seed\n \n Current Value: %d\n ", selectedTeamName, seed);

  menu.AddItem("#presets", "Presets", hasPresets ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
  menu.AddItem("#custom", "Custom Value", ITEMDRAW_DEFAULT);

  return menu;
}

public int MenuHandler_Knife_Seed (Menu menu, MenuAction action, int client, int selectedItem) {
  if (action == MenuAction_Select) {
    char option[MAX_MENU_KEY_SIZE];
    menu.GetItem(selectedItem, option, sizeof(option));

    if (StrEqual(option, "#custom")) {
      g_waitingForSeedValue[client] = true;
      CST_Message(client, "Enter the seed value you'd like to use in chat. Type !cancel to cancel.");
    } else if (StrEqual(option, "#presets")) {
      Player.Get(client).OpenMenu(CreateMenu_Knife_PresetSeeds(client));
    }
  } else if (action == MenuAction_Cancel) {
    if (selectedItem == MenuCancel_ExitBack) {
      Player.Get(client).OpenMenu(CreateMenu_Knife_Main(client));
    }
  } else if (action == MenuAction_End) {
    delete menu;
  }

  return 0;
}

public Menu CreateMenu_Knife_PresetSeeds(int client) {
  Player player = Player.Get(client);

  char selectedTeam[MAX_TEAM_KEY_SIZE];
  char selectedTeamName[MAX_TEAM_NAME_SIZE];
  player.GetMenuState().GetString("team", selectedTeam, sizeof(selectedTeam));
  TeamKeyToName(selectedTeam, selectedTeamName, sizeof(selectedTeamName));

  PlayerKnife tailoredKnife = player.GetKnife(selectedTeam);

  char knifeClassname[MAX_CLASSNAME_SIZE];
  tailoredKnife.GetClassname(knifeClassname, sizeof(knifeClassname));

  char currentSeed[16];
  IntToString(tailoredKnife.GetSeed(), currentSeed, sizeof(currentSeed));

  Menu menu = new Menu(MenuHandler_Knife_PresetSeeds);
  menu.ExitBackButton = true;
  menu.SetTitle("Loadout > %s > Knife > Seed > Presets", selectedTeamName);

  JSON_Array presets = view_as<JSON_Array>(tailoredKnife.GetPaint().GetObject("seeds").GetObject(knifeClassname));
  int length = presets.Length;
  char itemText[255];
  for (int i = 0; i < length; i++) {
    JSON_Object preset = presets.GetObject(i);

    char name[128];
    char value[16];
    preset.GetString("name", name, sizeof(name));
    IntToString(preset.GetInt("value"), value, sizeof(value));

    Format(itemText, sizeof(itemText), "%s [%s]", name, value);

    menu.AddItem(value, itemText, StrEqual(currentSeed, value) ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
  }

  return menu;
}

public int MenuHandler_Knife_PresetSeeds (Menu menu, MenuAction action, int client, int selectedItem) {
  if (action == MenuAction_Select) {
    char option[16];
    menu.GetItem(selectedItem, option, sizeof(option));

    Player player = Player.Get(client);

    char selectedTeam[MAX_TEAM_KEY_SIZE];
    player.GetMenuState().GetString("team", selectedTeam, sizeof(selectedTeam));

    PlayerKnife tailoredKnife = player.GetKnife(selectedTeam);

    char knifeName[MAX_KNIFE_NAME_SIZE];
    tailoredKnife.GetName(knifeName, sizeof(knifeName));

    tailoredKnife.SetSeed(StringToInt(option));

    CST_Message(client, "Set seed to {ORANGE}%s{NORMAL} on {ORANGE}%s{NORMAL}", option, knifeName);
    player.OpenMenuAtLastItem(CreateMenu_Knife_PresetSeeds(client));
  } else if (action == MenuAction_Cancel) {
    if (selectedItem == MenuCancel_ExitBack) {
      Player.Get(client).OpenMenu(CreateMenu_Knife_Seed(client));
    }
  } else if (action == MenuAction_End) {
    delete menu;
  }

  return 0;
}

public Menu CreateMenu_Knife_StatTrak(int client) {
  Player player = Player.Get(client);

  char selectedTeam[MAX_TEAM_KEY_SIZE];
  char selectedTeamName[MAX_TEAM_NAME_SIZE];
  player.GetMenuState().GetString("team", selectedTeam, sizeof(selectedTeam));
  TeamKeyToName(selectedTeam, selectedTeamName, sizeof(selectedTeamName));

  PlayerKnife tailoredKnife = player.GetKnife(selectedTeam);
  bool statTrakEnabled = tailoredKnife.IsStatTrakEnabled();
  int killCount = tailoredKnife.GetStatTrakCount();
  char status[8];
  status = statTrakEnabled ? "ON" : "OFF";

  Menu menu = new Menu(MenuHandler_Knife_StatTrak);
  menu.ExitBackButton = true;
  menu.SetTitle("Loadout > %s > Knife > StatTrak™\n \n StatTrak™: %s\n Kill Count: %d\n ", selectedTeamName, status, killCount);

  menu.AddItem("#toggle", statTrakEnabled ? "Disable StatTrak™" : "Enable StatTrak™", ITEMDRAW_DEFAULT);
  menu.AddItem("", "", ITEMDRAW_SPACER);
  menu.AddItem("", "", ITEMDRAW_SPACER);
  menu.AddItem("#reset", "Reset Kill Count", CanUseKnifesStatTrakReset(client) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

  return menu;
}

public int MenuHandler_Knife_StatTrak (Menu menu, MenuAction action, int client, int selectedItem) {
  if (action == MenuAction_Select) {
    char option[16];
    menu.GetItem(selectedItem, option, sizeof(option));

    Player player = Player.Get(client);

    char selectedTeam[MAX_TEAM_KEY_SIZE];
    player.GetMenuState().GetString("team", selectedTeam, sizeof(selectedTeam));

    PlayerKnife tailoredKnife = player.GetKnife(selectedTeam);

    char knifeName[MAX_KNIFE_NAME_SIZE];
    tailoredKnife.GetName(knifeName, sizeof(knifeName));

    if (StrEqual(option, "#toggle")) {
      tailoredKnife.SetStatTrak(!tailoredKnife.IsStatTrakEnabled());
      char toggleType[16];
      toggleType = tailoredKnife.IsStatTrakEnabled() ? "Enabled" : "Disabled";
      CST_Message(client, "StatTrak™ {ORANGE}%s{NORMAL} on {ORANGE}%s{NORMAL}", toggleType, knifeName);
    } else if (StrEqual(option, "#reset")) {
      tailoredKnife.ResetStatTrakCount();
      CST_Message(client, "StatTrak™ kill count reset on {ORANGE}%s{NORMAL}", knifeName);
    }

    player.OpenMenu(CreateMenu_Knife_StatTrak(client));
  } else if (action == MenuAction_Cancel) {
    if (selectedItem == MenuCancel_ExitBack) {
      Player.Get(client).OpenMenu(CreateMenu_Knife_Main(client));
    }
  } else if (action == MenuAction_End) {
    delete menu;
  }

  return 0;
}

public Menu CreateMenu_Knife_Nametag(int client) {
  Player player = Player.Get(client);

  char selectedTeam[MAX_TEAM_KEY_SIZE];
  char selectedTeamName[MAX_TEAM_NAME_SIZE];
  player.GetMenuState().GetString("team", selectedTeam, sizeof(selectedTeam));
  TeamKeyToName(selectedTeam, selectedTeamName, sizeof(selectedTeamName));

  PlayerKnife tailoredKnife = player.GetKnife(selectedTeam);
  char currentNametag[MAX_NAMETAG_SIZE];
  if (tailoredKnife.HasNametag()) {
    tailoredKnife.GetNametag(currentNametag, sizeof(currentNametag));
  } else {
    tailoredKnife.GetName(currentNametag, sizeof(currentNametag));
  }

  Menu menu = new Menu(MenuHandler_Knife_Nametag);
  menu.ExitBackButton = true;
  menu.SetTitle("Loadout > %s > Knife > Nametag\n \n Current:\n %s\n ", selectedTeamName, currentNametag);

  menu.AddItem("#set", "Set new nametag", ITEMDRAW_DEFAULT);
  menu.AddItem("#remove", "Remove nametag", ITEMDRAW_DEFAULT);

  return menu;
}

public int MenuHandler_Knife_Nametag (Menu menu, MenuAction action, int client, int selectedItem) {
  if (action == MenuAction_Select) {
    char option[16];
    menu.GetItem(selectedItem, option, sizeof(option));

    Player player = Player.Get(client);

    char selectedTeam[MAX_TEAM_KEY_SIZE];
    player.GetMenuState().GetString("team", selectedTeam, sizeof(selectedTeam));

    PlayerKnife tailoredKnife = player.GetKnife(selectedTeam);

    char knifeName[MAX_KNIFE_NAME_SIZE];
    tailoredKnife.GetName(knifeName, sizeof(knifeName));

    if (StrEqual(option, "#set")) {
      g_waitingForNametagValue[client] = true;
      CST_Message(client, "Enter the new nametag you'd like to use in chat. Type !cancel to cancel.");
    } else if (StrEqual(option, "#remove")) {
      tailoredKnife.SetNametag("");
      CST_Message(client, "Nametag removed on {ORANGE}%s{NORMAL}", knifeName);
      player.OpenMenu(CreateMenu_Knife_Nametag(client));
    }
  } else if (action == MenuAction_Cancel) {
    if (selectedItem == MenuCancel_ExitBack) {
      Player.Get(client).OpenMenu(CreateMenu_Knife_Main(client));
    }
  } else if (action == MenuAction_End) {
    delete menu;
  }

  return 0;
}
