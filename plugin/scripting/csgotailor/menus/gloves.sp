#if defined _CSGOTAILOR_MENU_GLOVES_INCLUDED
  #endinput
#endif
#define _CSGOTAILOR_MENU_GLOVES_INCLUDED

public Menu CreateMenu_Gloves_Main(int client) {
  Player player = Player.Get(client);

  char selectedTeam[MAX_TEAM_KEY_SIZE];
  char selectedTeamName[MAX_TEAM_NAME_SIZE];
  player.GetMenuState().GetString("team", selectedTeam, sizeof(selectedTeam));
  TeamKeyToName(selectedTeam, selectedTeamName, sizeof(selectedTeamName));

  Menu menu = new Menu(MenuHandler_Gloves_Main);
  menu.ExitBackButton = true;
  menu.SetTitle("Loadout > %s > Gloves", selectedTeamName);

  bool hasGloves = player.HasGloves(selectedTeam);
  char itemText[MAX_MENU_ITEM_SIZE];

  if (hasGloves) {
    PlayerGloves tailoredGloves = player.GetGloves(selectedTeam);

    char glovesName[MAX_GLOVES_NAME_SIZE];
    char paintName[MAX_PAINT_NAME_SIZE];
    char wearKey[MAX_WEAR_KEY_SIZE];

    tailoredGloves.GetName(glovesName, sizeof(glovesName));
    tailoredGloves.GetPaint().GetName(paintName, sizeof(paintName));
    GetWearKey(tailoredGloves.GetWear(), wearKey, sizeof(wearKey));

    Format(itemText, sizeof(itemText), "Skin [%s | %s]", glovesName, paintName);
    menu.AddItem("#change", itemText, ITEMDRAW_DEFAULT);

    Format(itemText, sizeof(itemText), "Wear [%s]", wearKey);
    menu.AddItem("#wear", itemText, CanUseGlovesWear(client) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

    Format(itemText, sizeof(itemText), "Seed [%d]", tailoredGloves.GetSeed());
    menu.AddItem("#seed", itemText, CanUseGlovesSeed(client) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
  } else {
    menu.AddItem("#change", "Choose Gloves", ITEMDRAW_DEFAULT);
    menu.AddItem("#wear", "Wear", ITEMDRAW_DISABLED);
    menu.AddItem("#seed", "Seed", ITEMDRAW_DISABLED);
  }

  return menu;
}

public int MenuHandler_Gloves_Main (Menu menu, MenuAction action, int client, int selectedItem) {
  if (action == MenuAction_Select) {
    char option[MAX_MENU_KEY_SIZE];
    menu.GetItem(selectedItem, option, sizeof(option));

    Player player = Player.Get(client);

    if (StrEqual(option, "#change")) {
      player.OpenMenu(CreateMenu_Gloves_Type(client));
    } else if (StrEqual(option, "#wear")) {
      player.OpenMenu(CreateMenu_Gloves_Wear(client));
    } else if (StrEqual(option, "#seed")) {
      player.OpenMenu(CreateMenu_Gloves_Seed(client));
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

public Menu CreateMenu_Gloves_Type(int client) {
  Player player = Player.Get(client);

  char selectedTeam[MAX_TEAM_KEY_SIZE];
  char selectedTeamName[MAX_TEAM_NAME_SIZE];
  player.GetMenuState().GetString("team", selectedTeam, sizeof(selectedTeam));
  TeamKeyToName(selectedTeam, selectedTeamName, sizeof(selectedTeamName));

  bool hasGloves = player.HasGloves(selectedTeam);

  Menu menu = new Menu(MenuHandler_Gloves_Type);
  menu.ExitBackButton = true;
  menu.SetTitle("Loadout > %s > Gloves > Type", selectedTeamName);

  menu.AddItem("DEFAULT", "Default", hasGloves ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

  JSON_Object gloves = g_data.GetObject("gloves");
  int length = gloves.Iterate();
  int keyLength = 0;
  char name[MAX_GLOVES_NAME_SIZE];
  for (int i = 0; i < length; i++) {
    keyLength = gloves.GetKeySize(i);
    char[] key = new char[keyLength];
    gloves.GetKey(i, key, keyLength);

    Gloves glove = Gloves.Get(key);
    glove.GetName(name, sizeof(name));

    menu.AddItem(key, name, ITEMDRAW_DEFAULT);
  }

  return menu;
}

public int MenuHandler_Gloves_Type (Menu menu, MenuAction action, int client, int selectedItem) {
  if (action == MenuAction_Select) {
    char option[MAX_CLASSNAME_SIZE];
    menu.GetItem(selectedItem, option, sizeof(option));

    Player player = Player.Get(client);

    char selectedTeam[MAX_TEAM_KEY_SIZE];
    char selectedTeamName[MAX_TEAM_NAME_SIZE];
    player.GetMenuState().GetString("team", selectedTeam, sizeof(selectedTeam));
    TeamKeyToName(selectedTeam, selectedTeamName, sizeof(selectedTeamName));

    if (StrEqual(option, "DEFAULT")) {
      player.GetGloves(selectedTeam).Delete();

      CST_Message(client, "Removed {ORANGE}%s{NORMAL} gloves", selectedTeamName);
      player.OpenMenuAtLastItem(CreateMenu_Gloves_Type(client));
    } else {
      player.GetMenuState().SetObject("gloves", Gloves.Get(option));
      player.OpenMenu(CreateMenu_Gloves_Skins(client));
    }
  } else if (action == MenuAction_Cancel) {
    if (selectedItem == MenuCancel_ExitBack) {
      Player.Get(client).OpenMenu(CreateMenu_Gloves_Main(client));
    }
  } else if (action == MenuAction_End) {
    delete menu;
  }

  return 0;
}

public Menu CreateMenu_Gloves_Skins(int client) {
  Player player = Player.Get(client);

  char selectedTeam[MAX_TEAM_KEY_SIZE];
  char selectedTeamName[MAX_TEAM_NAME_SIZE];
  player.GetMenuState().GetString("team", selectedTeam, sizeof(selectedTeam));
  TeamKeyToName(selectedTeam, selectedTeamName, sizeof(selectedTeamName));

  Gloves selectedGloves = view_as<Gloves>(player.GetMenuState().GetObject("gloves"));

  Menu menu = new Menu(MenuHandler_Gloves_Skins);
  menu.ExitBackButton = true;
  menu.SetTitle("Loadout > %s > Gloves > Skin", selectedTeamName);

  PaintCollection paints = selectedGloves.GetPaints();
  char paintClassname[MAX_CLASSNAME_SIZE];
  char paintName[MAX_PAINT_NAME_SIZE];
  int length = paints.Length;
  for (int i = 0; i < length; i++) {
    Paint paint = view_as<Paint>(paints.Get(i));
    paint.GetClassname(paintClassname, sizeof(paintClassname));
    paint.GetName(paintName, sizeof(paintName));

    menu.AddItem(paintClassname, paintName, ITEMDRAW_DEFAULT);
  }

  return menu;
}

public int MenuHandler_Gloves_Skins (Menu menu, MenuAction action, int client, int selectedItem) {
  if (action == MenuAction_Select) {
    char option[MAX_CLASSNAME_SIZE];
    menu.GetItem(selectedItem, option, sizeof(option));

    Player player = Player.Get(client);

    char selectedTeam[MAX_TEAM_KEY_SIZE];
    char selectedTeamName[MAX_TEAM_NAME_SIZE];
    player.GetMenuState().GetString("team", selectedTeam, sizeof(selectedTeam));
    TeamKeyToName(selectedTeam, selectedTeamName, sizeof(selectedTeamName));

    Gloves selectedGloves = view_as<Gloves>(player.GetMenuState().GetObject("gloves"));

    char selectedGlovesClassname[MAX_CLASSNAME_SIZE];
    char glovesName[MAX_GLOVES_NAME_SIZE];
    char paintName[MAX_PAINT_NAME_SIZE];
    selectedGloves.GetClassname(selectedGlovesClassname, sizeof(selectedGlovesClassname));
    selectedGloves.GetName(glovesName, sizeof(glovesName));
    Paint.Get(option).GetName(paintName, sizeof(paintName));


    PlayerGloves.Change(client, selectedTeam, selectedGlovesClassname, option);

    CST_Message(client, "Set {ORANGE}%s{NORMAL} gloves to {ORANGE}%s | %s{NORMAL}", selectedTeamName, glovesName, paintName);
    player.OpenMenuAtLastItem(CreateMenu_Gloves_Skins(client));
  } else if (action == MenuAction_Cancel) {
    if (selectedItem == MenuCancel_ExitBack) {
      Player.Get(client).OpenMenu(CreateMenu_Gloves_Type(client));
    }
  } else if (action == MenuAction_End) {
    delete menu;
  }

  return 0;
}

public Menu CreateMenu_Gloves_Wear(int client) {
  Player player = Player.Get(client);

  char selectedTeam[MAX_TEAM_KEY_SIZE];
  char selectedTeamName[MAX_TEAM_NAME_SIZE];
  player.GetMenuState().GetString("team", selectedTeam, sizeof(selectedTeam));
  TeamKeyToName(selectedTeam, selectedTeamName, sizeof(selectedTeamName));

  PlayerGloves tailoredGloves = player.GetGloves(selectedTeam);
  float wear = tailoredGloves.GetWear();
  char wearKey[MAX_WEAR_KEY_SIZE];
  char wearName[MAX_WEAR_NAME_SIZE];
  GetWearKey(wear, wearKey, sizeof(wearKey));
  GetWearName(wear, wearName, sizeof(wearName));

  Menu menu = new Menu(MenuHandler_Gloves_Wear);
  menu.ExitBackButton = true;
  menu.SetTitle("Loadout > %s > Gloves > Wear\n \n Current: %s\n Value: %f\n ", selectedTeamName, wearName, wear);

  menu.AddItem("#FN", "Factory New", StrEqual(wearKey, "FN") ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
  menu.AddItem("#MW", "Minimal Wear", StrEqual(wearKey, "MW") ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
  menu.AddItem("#FT", "Field-Tested", StrEqual(wearKey, "FT") ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
  menu.AddItem("#WW", "Well-Worn", StrEqual(wearKey, "WW") ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
  menu.AddItem("#BS", "Battle-Scarred\n ", StrEqual(wearKey, "BS") ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
  menu.AddItem("#custom", "Custom Value", ITEMDRAW_DEFAULT);

  return menu;
}

public int MenuHandler_Gloves_Wear (Menu menu, MenuAction action, int client, int selectedItem) {
  if (action == MenuAction_Select) {
    char option[MAX_MENU_KEY_SIZE];
    menu.GetItem(selectedItem, option, sizeof(option));

    Player player = Player.Get(client);

    char selectedTeam[MAX_TEAM_KEY_SIZE];
    char selectedTeamName[MAX_TEAM_NAME_SIZE];
    player.GetMenuState().GetString("team", selectedTeam, sizeof(selectedTeam));
    TeamKeyToName(selectedTeam, selectedTeamName, sizeof(selectedTeamName));

    PlayerGloves tailoredGloves = player.GetGloves(selectedTeam);

    if (StrEqual(option, "#custom")) {
      g_waitingForWearValue[client] = true;
      CST_Message(client, "Enter the wear value you'd like to use in chat. Type !cancel to cancel.");
    } else {
      if (StrEqual(option, "#FN")) {
        tailoredGloves.SetWear(0.00);
      } else if (StrEqual(option, "#MW")) {
        tailoredGloves.SetWear(0.11);
      } else if (StrEqual(option, "#FT")) {
        tailoredGloves.SetWear(0.26);
      } else if (StrEqual(option, "#WW")) {
        tailoredGloves.SetWear(0.41);
      } else if (StrEqual(option, "#BS")) {
        tailoredGloves.SetWear(1.00);
      }

      char wearName[MAX_WEAR_NAME_SIZE];
      GetWearName(tailoredGloves.GetWear(), wearName, sizeof(wearName));

      CST_Message(client, "Set wear to {ORANGE}%s{NORMAL} on {ORANGE}%s{NORMAL} gloves", wearName, selectedTeamName);
      player.OpenMenuAtLastItem(CreateMenu_Gloves_Wear(client));
    }
  } else if (action == MenuAction_Cancel) {
    if (selectedItem == MenuCancel_ExitBack) {
      Player.Get(client).OpenMenu(CreateMenu_Gloves_Main(client));
    }
  } else if (action == MenuAction_End) {
    delete menu;
  }

  return 0;
}

public Menu CreateMenu_Gloves_Seed(int client) {
  Player player = Player.Get(client);

  char selectedTeam[MAX_TEAM_KEY_SIZE];
  char selectedTeamName[MAX_TEAM_NAME_SIZE];
  player.GetMenuState().GetString("team", selectedTeam, sizeof(selectedTeam));
  TeamKeyToName(selectedTeam, selectedTeamName, sizeof(selectedTeamName));

  PlayerGloves tailoredGloves = player.GetGloves(selectedTeam);

  char glovesClassname[MAX_CLASSNAME_SIZE];
  tailoredGloves.GetClassname(glovesClassname, sizeof(glovesClassname));

  int seed = tailoredGloves.GetSeed();
  bool hasPresets = tailoredGloves.GetPaint().HasSeedPresets(glovesClassname);

  Menu menu = new Menu(MenuHandler_Gloves_Seed);
  menu.ExitBackButton = true;
  menu.SetTitle("Loadout > %s > Gloves > Seed\n \n Current Value: %d\n ", selectedTeamName, seed);

  menu.AddItem("#presets", "Presets", hasPresets ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
  menu.AddItem("#custom", "Custom Value", ITEMDRAW_DEFAULT);

  return menu;
}

public int MenuHandler_Gloves_Seed (Menu menu, MenuAction action, int client, int selectedItem) {
  if (action == MenuAction_Select) {
    char option[MAX_MENU_KEY_SIZE];
    menu.GetItem(selectedItem, option, sizeof(option));

    if (StrEqual(option, "#custom")) {
      g_waitingForSeedValue[client] = true;
      CST_Message(client, "Enter the seed value you'd like to use in chat. Type !cancel to cancel.");
    } else if (StrEqual(option, "#presets")) {
      Player.Get(client).OpenMenu(CreateMenu_Gloves_PresetSeeds(client));
    }
  } else if (action == MenuAction_Cancel) {
    if (selectedItem == MenuCancel_ExitBack) {
      Player.Get(client).OpenMenu(CreateMenu_Gloves_Main(client));
    }
  } else if (action == MenuAction_End) {
    delete menu;
  }

  return 0;
}

public Menu CreateMenu_Gloves_PresetSeeds(int client) {
  Player player = Player.Get(client);

  char selectedTeam[MAX_TEAM_KEY_SIZE];
  char selectedTeamName[MAX_TEAM_NAME_SIZE];
  player.GetMenuState().GetString("team", selectedTeam, sizeof(selectedTeam));
  TeamKeyToName(selectedTeam, selectedTeamName, sizeof(selectedTeamName));

  PlayerGloves tailoredGloves = player.GetGloves(selectedTeam);

  char glovesClassname[MAX_CLASSNAME_SIZE];
  tailoredGloves.GetClassname(glovesClassname, sizeof(glovesClassname));

  char currentSeed[16];
  IntToString(tailoredGloves.GetSeed(), currentSeed, sizeof(currentSeed));

  Menu menu = new Menu(MenuHandler_Gloves_PresetSeeds);
  menu.ExitBackButton = true;
  menu.SetTitle("Loadout > %s > Gloves > Seed > Presets", selectedTeamName);

  JSON_Array presets = view_as<JSON_Array>(tailoredGloves.GetPaint().GetObject("seeds").GetObject(glovesClassname));
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

public int MenuHandler_Gloves_PresetSeeds (Menu menu, MenuAction action, int client, int selectedItem) {
  if (action == MenuAction_Select) {
    char option[16];
    menu.GetItem(selectedItem, option, sizeof(option));

    Player player = Player.Get(client);

    char selectedTeam[MAX_TEAM_KEY_SIZE];
    char selectedTeamName[MAX_TEAM_NAME_SIZE];
    player.GetMenuState().GetString("team", selectedTeam, sizeof(selectedTeam));
    TeamKeyToName(selectedTeam, selectedTeamName, sizeof(selectedTeamName));

    PlayerGloves tailoredGloves = player.GetGloves(selectedTeam);

    char glovesName[MAX_GLOVES_NAME_SIZE];
    tailoredGloves.GetName(glovesName, sizeof(glovesName));

    tailoredGloves.SetSeed(StringToInt(option));

    CST_Message(client, "Set seed to {ORANGE}%s{NORMAL} on {ORANGE}%s{NORMAL} gloves", option, selectedTeamName);
    player.OpenMenuAtLastItem(CreateMenu_Gloves_PresetSeeds(client));
  } else if (action == MenuAction_Cancel) {
    if (selectedItem == MenuCancel_ExitBack) {
      Player.Get(client).OpenMenu(CreateMenu_Gloves_Seed(client));
    }
  } else if (action == MenuAction_End) {
    delete menu;
  }

  return 0;
}
