#if defined _CSGOTAILOR_MENU_WEAPONS_INCLUDED
  #endinput
#endif
#define _CSGOTAILOR_MENU_WEAPONS_INCLUDED

public Menu CreateMenu_Weapons_Select(int client) {
  Player player = Player.Get(client);

  char selectedTeam[MAX_TEAM_KEY_SIZE];
  char selectedTeamName[MAX_TEAM_NAME_SIZE];
  player.GetMenuState().GetString("team", selectedTeam, sizeof(selectedTeam));
  TeamKeyToName(selectedTeam, selectedTeamName, sizeof(selectedTeamName));

  Menu menu = new Menu(MenuHandler_Weapons_Select);
  menu.ExitBackButton = true;
  menu.SetTitle("Loadout > %s > Choose Weapon", selectedTeamName);

  JSON_Object weapons = g_data.GetObject("weapons");
  int length = weapons.Iterate();
  int keyLength = 0;
  char name[MAX_WEAPON_NAME_SIZE];
  for (int i = 0; i < length; i++) {
    keyLength = weapons.GetKeySize(i);
    char[] key = new char[keyLength];
    weapons.GetKey(i, key, keyLength);

    Weapon weapon = Weapon.Get(key);

    if (weapon.TeamCanUse(selectedTeam)) {
      weapon.GetName(name, sizeof(name));
      menu.AddItem(key, name, ITEMDRAW_DEFAULT);
    }
  }

  return menu;
}

public int MenuHandler_Weapons_Select (Menu menu, MenuAction action, int client, int selectedItem) {
  if (action == MenuAction_Select) {
    char option[MAX_CLASSNAME_SIZE];
    menu.GetItem(selectedItem, option, sizeof(option));

    Player player = Player.Get(client);

    player.GetMenuState().SetObject("weapon", Weapon.Get(option).DeepCopy());

    player.OpenMenu(CreateMenu_Weapons_Main(client));
  } else if (action == MenuAction_Cancel) {
    if (selectedItem == MenuCancel_ExitBack) {
      Player.Get(client).OpenMenu(CreateMenu_Loadout_Main(client));
    }
  } else if (action == MenuAction_End) {
    delete menu;
  }

  return 0;
}

public Menu CreateMenu_Weapons_Main(int client) {
  Player player = Player.Get(client);

  char selectedTeam[MAX_TEAM_KEY_SIZE];
  char selectedTeamName[MAX_TEAM_NAME_SIZE];
  player.GetMenuState().GetString("team", selectedTeam, sizeof(selectedTeam));
  TeamKeyToName(selectedTeam, selectedTeamName, sizeof(selectedTeamName));

  Weapon selectedWeapon = view_as<Weapon>(player.GetMenuState().GetObject("weapon"));
  char weaponClassname[MAX_CLASSNAME_SIZE];
  char weaponName[MAX_WEAPON_NAME_SIZE];
  selectedWeapon.GetClassname(weaponClassname, sizeof(weaponClassname));
  selectedWeapon.GetName(weaponName, sizeof(weaponName));

  Menu menu = new Menu(MenuHandler_Weapons_Main);
  menu.ExitBackButton = true;
  menu.SetTitle("Loadout > %s > %s", selectedTeamName, weaponName);

  bool hasTailoredWeapon = player.HasWeapon(selectedTeam, weaponClassname);
  char itemText[MAX_MENU_ITEM_SIZE];

  if (hasTailoredWeapon) {
    PlayerWeapon tailoredWeapon = player.GetWeapon(selectedTeam, weaponClassname);

    char paintName[MAX_PAINT_NAME_SIZE];
    char wearKey[MAX_WEAR_KEY_SIZE];
    char stattrakText[16];
    char nametag[MAX_NAMETAG_SIZE];

    tailoredWeapon.GetPaint().GetName(paintName, sizeof(paintName));
    GetWearKey(tailoredWeapon.GetWear(), wearKey, sizeof(wearKey));
    stattrakText = tailoredWeapon.IsStatTrakEnabled() ? "ON" : "OFF";

    Format(itemText, sizeof(itemText), "Skin [%s]", paintName);
    menu.AddItem("#skin", itemText, ITEMDRAW_DEFAULT);

    Format(itemText, sizeof(itemText), "Wear [%s]", wearKey);
    menu.AddItem("#wear", itemText, CanUseWeaponsWear(client) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

    Format(itemText, sizeof(itemText), "Seed [%d]", tailoredWeapon.GetSeed());
    menu.AddItem("#seed", itemText, CanUseWeaponsSeed(client) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

    if (FeatureIsEnabled(FEATURE_STATTRAK)) {
      Format(itemText, sizeof(itemText), "StatTrak™ [%s]", stattrakText);
      menu.AddItem("#stattrak", itemText, CanUseWeaponsStatTrak(client) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
    }

    if (FeatureIsEnabled(FEATURE_NAMETAG)) {
      if (tailoredWeapon.HasNametag()) {
        tailoredWeapon.GetNametag(nametag, sizeof(nametag));
        Format(itemText, sizeof(itemText), "Nametag [%s]", nametag);
      } else {
        Format(itemText, sizeof(itemText), "Nametag");
      }
      menu.AddItem("#nametag", itemText, CanUseWeaponsNametag(client) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
    }

    if (FeatureIsEnabled(FEATURE_STICKERS)) {
      menu.AddItem("#stickers", "Stickers", CanUseWeaponsStickers(client) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
    }
  } else {
    menu.AddItem("#skin", "Skin", ITEMDRAW_DEFAULT);
    menu.AddItem("#wear", "Wear", ITEMDRAW_DISABLED);
    menu.AddItem("#seed", "Seed", ITEMDRAW_DISABLED);

    if (FeatureIsEnabled(FEATURE_STATTRAK)) {
      menu.AddItem("#stattrak", "StatTrak™", ITEMDRAW_DISABLED);
    }

    if (FeatureIsEnabled(FEATURE_NAMETAG)) {
      menu.AddItem("#nametag", "Nametag", ITEMDRAW_DISABLED);
    }

    if (FeatureIsEnabled(FEATURE_STICKERS)) {
      menu.AddItem("#stickers", "Stickers", ITEMDRAW_DISABLED);
    }
  }

  return menu;
}

public int MenuHandler_Weapons_Main (Menu menu, MenuAction action, int client, int selectedItem) {
  if (action == MenuAction_Select) {
    char option[MAX_MENU_KEY_SIZE];
    menu.GetItem(selectedItem, option, sizeof(option));

    Player player = Player.Get(client);

    if (StrEqual(option, "#skin")) {
      player.OpenMenu(CreateMenu_Weapons_Skins(client));
    } else if (StrEqual(option, "#wear")) {
      player.OpenMenu(CreateMenu_Weapons_Wear(client));
    } else if (StrEqual(option, "#seed")) {
      player.OpenMenu(CreateMenu_Weapons_Seed(client));
    } else if (StrEqual(option, "#stattrak")) {
      player.OpenMenu(CreateMenu_Weapons_StatTrak(client));
    } else if (StrEqual(option, "#nametag")) {
      player.OpenMenu(CreateMenu_Weapons_Nametag(client));
    } else if (StrEqual(option, "#stickers")) {
      player.OpenMenu(CreateMenu_Weapons_Stickers_Main(client));
    }
  } else if (action == MenuAction_Cancel) {
    if (selectedItem == MenuCancel_ExitBack) {
      Player.Get(client).OpenMenu(CreateMenu_Weapons_Select(client));
    }
  } else if (action == MenuAction_End) {
    delete menu;
  }

  return 0;
}

public Menu CreateMenu_Weapons_Skins(int client) {
  Player player = Player.Get(client);

  char selectedTeam[MAX_TEAM_KEY_SIZE];
  char selectedTeamName[MAX_TEAM_NAME_SIZE];
  player.GetMenuState().GetString("team", selectedTeam, sizeof(selectedTeam));
  TeamKeyToName(selectedTeam, selectedTeamName, sizeof(selectedTeamName));

  Weapon selectedWeapon = view_as<Weapon>(player.GetMenuState().GetObject("weapon"));
  char weaponClassname[MAX_CLASSNAME_SIZE];
  char weaponName[MAX_WEAPON_NAME_SIZE];
  selectedWeapon.GetClassname(weaponClassname, sizeof(weaponClassname));
  selectedWeapon.GetName(weaponName, sizeof(weaponName));

  bool hasTailoredWeapon = player.HasWeapon(selectedTeam, weaponClassname);
  char currentPaintClassname[MAX_CLASSNAME_SIZE];
  if (hasTailoredWeapon) {
    PlayerWeapon currentWeapon = player.GetWeapon(selectedTeam, weaponClassname);
    currentWeapon.GetPaint().GetClassname(currentPaintClassname, sizeof(currentPaintClassname));
  }

  Menu menu = new Menu(MenuHandler_Weapons_Skins);
  menu.ExitBackButton = true;
  menu.SetTitle("Loadout > %s > %s > Skin", selectedTeamName, weaponName);

  menu.AddItem("DEFAULT", "Default", hasTailoredWeapon ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

  PaintCollection paints = selectedWeapon.GetPaints();
  char paintClassname[MAX_CLASSNAME_SIZE];
  char paintName[MAX_PAINT_NAME_SIZE];
  int length = paints.Length;
  for (int i = 0; i < length; i++) {
    Paint paint = view_as<Paint>(paints.Get(i));
    paint.GetClassname(paintClassname, sizeof(paintClassname));
    paint.GetName(paintName, sizeof(paintName));

    bool enabled = true;
    if (hasTailoredWeapon) enabled = !StrEqual(paintClassname, currentPaintClassname);

    menu.AddItem(paintClassname, paintName, enabled ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
  }

  return menu;
}

public int MenuHandler_Weapons_Skins (Menu menu, MenuAction action, int client, int selectedItem) {
  if (action == MenuAction_Select) {
    char option[MAX_CLASSNAME_SIZE];
    menu.GetItem(selectedItem, option, sizeof(option));

    Player player = Player.Get(client);

    char selectedTeam[MAX_TEAM_KEY_SIZE];
    char selectedTeamName[MAX_TEAM_NAME_SIZE];
    player.GetMenuState().GetString("team", selectedTeam, sizeof(selectedTeam));
    TeamKeyToName(selectedTeam, selectedTeamName, sizeof(selectedTeamName));

    Weapon selectedWeapon = view_as<Weapon>(player.GetMenuState().GetObject("weapon"));
    char weaponClassname[MAX_CLASSNAME_SIZE];
    char weaponName[MAX_WEAPON_NAME_SIZE];
    selectedWeapon.GetClassname(weaponClassname, sizeof(weaponClassname));
    selectedWeapon.GetName(weaponName, sizeof(weaponName));

    char paintName[MAX_PAINT_NAME_SIZE];

    if (StrEqual(option, "DEFAULT")) {
      player.GetWeapon(selectedTeam, weaponClassname).Delete();
      paintName = "Default";
    } else {
      Paint paint = Paint.Get(option);
      paint.GetName(paintName, sizeof(paintName));

      PlayerWeapon.ChangePaint(
        client,
        selectedTeam,
        weaponClassname,
        option
      );
    }

    CST_Message(client, "Set {ORANGE}%s{NORMAL} skin to {ORANGE}%s{NORMAL} on {ORANGE}%s{NORMAL}", weaponName, paintName, selectedTeamName);
    player.OpenMenuAtLastItem(CreateMenu_Weapons_Skins(client));
  } else if (action == MenuAction_Cancel) {
    if (selectedItem == MenuCancel_ExitBack) {
      Player.Get(client).OpenMenu(CreateMenu_Weapons_Main(client));
    }
  } else if (action == MenuAction_End) {
    delete menu;
  }

  return 0;
}

public Menu CreateMenu_Weapons_Wear(int client) {
  Player player = Player.Get(client);

  char selectedTeam[MAX_TEAM_KEY_SIZE];
  char selectedTeamName[MAX_TEAM_NAME_SIZE];
  player.GetMenuState().GetString("team", selectedTeam, sizeof(selectedTeam));
  TeamKeyToName(selectedTeam, selectedTeamName, sizeof(selectedTeamName));

  Weapon selectedWeapon = view_as<Weapon>(player.GetMenuState().GetObject("weapon"));
  char weaponClassname[MAX_CLASSNAME_SIZE];
  char weaponName[MAX_WEAPON_NAME_SIZE];
  selectedWeapon.GetClassname(weaponClassname, sizeof(weaponClassname));
  selectedWeapon.GetName(weaponName, sizeof(weaponName));

  PlayerWeapon tailoredWeapon = player.GetWeapon(selectedTeam, weaponClassname);
  float wear = tailoredWeapon.GetWear();
  char wearKey[MAX_WEAR_KEY_SIZE];
  char wearName[MAX_WEAR_NAME_SIZE];
  GetWearKey(wear, wearKey, sizeof(wearKey));
  GetWearName(wear, wearName, sizeof(wearName));

  Menu menu = new Menu(MenuHandler_Weapons_Wear);
  menu.ExitBackButton = true;
  menu.SetTitle("Loadout > %s > %s > Wear\n \n Current: %s\n Value: %f\n ", selectedTeamName, weaponName, wearName, wear);

  menu.AddItem("#FN", "Factory New", StrEqual(wearKey, "FN") ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
  menu.AddItem("#MW", "Minimal Wear", StrEqual(wearKey, "MW") ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
  menu.AddItem("#FT", "Field-Tested", StrEqual(wearKey, "FT") ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
  menu.AddItem("#WW", "Well-Worn", StrEqual(wearKey, "WW") ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
  menu.AddItem("#BS", "Battle-Scarred\n ", StrEqual(wearKey, "BS") ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
  menu.AddItem("#custom", "Custom Value", ITEMDRAW_DEFAULT);

  return menu;
}

public int MenuHandler_Weapons_Wear (Menu menu, MenuAction action, int client, int selectedItem) {
  if (action == MenuAction_Select) {
    char option[MAX_MENU_KEY_SIZE];
    menu.GetItem(selectedItem, option, sizeof(option));

    Player player = Player.Get(client);

    char selectedTeam[MAX_TEAM_KEY_SIZE];
    player.GetMenuState().GetString("team", selectedTeam, sizeof(selectedTeam));

    Weapon selectedWeapon = view_as<Weapon>(player.GetMenuState().GetObject("weapon"));
    char weaponClassname[MAX_CLASSNAME_SIZE];
    char weaponName[MAX_WEAPON_NAME_SIZE];
    selectedWeapon.GetClassname(weaponClassname, sizeof(weaponClassname));
    selectedWeapon.GetName(weaponName, sizeof(weaponName));

    PlayerWeapon tailoredWeapon = player.GetWeapon(selectedTeam, weaponClassname);

    if (StrEqual(option, "#custom")) {
      g_waitingForWearValue[client] = true;
      CST_Message(client, "Enter the wear value you'd like to use in chat. Type !cancel to cancel.");
    } else {
      if (StrEqual(option, "#FN")) {
        tailoredWeapon.SetWear(0.00);
      } else if (StrEqual(option, "#MW")) {
        tailoredWeapon.SetWear(0.11);
      } else if (StrEqual(option, "#FT")) {
        tailoredWeapon.SetWear(0.26);
      } else if (StrEqual(option, "#WW")) {
        tailoredWeapon.SetWear(0.41);
      } else if (StrEqual(option, "#BS")) {
        tailoredWeapon.SetWear(1.00);
      }

      char wearName[MAX_WEAR_NAME_SIZE];
      char paintName[MAX_PAINT_NAME_SIZE];
      GetWearName(tailoredWeapon.GetWear(), wearName, sizeof(wearName));
      tailoredWeapon.GetPaint().GetName(paintName, sizeof(paintName));

      CST_Message(client, "Set wear to {ORANGE}%s{NORMAL} on {ORANGE}%s - %s{NORMAL}", wearName, weaponName, paintName);
      player.OpenMenuAtLastItem(CreateMenu_Weapons_Wear(client));
    }
  } else if (action == MenuAction_Cancel) {
    if (selectedItem == MenuCancel_ExitBack) {
      Player.Get(client).OpenMenu(CreateMenu_Weapons_Main(client));
    }
  } else if (action == MenuAction_End) {
    delete menu;
  }

  return 0;
}

public Menu CreateMenu_Weapons_Seed(int client) {
  Player player = Player.Get(client);

  char selectedTeam[MAX_TEAM_KEY_SIZE];
  char selectedTeamName[MAX_TEAM_NAME_SIZE];
  player.GetMenuState().GetString("team", selectedTeam, sizeof(selectedTeam));
  TeamKeyToName(selectedTeam, selectedTeamName, sizeof(selectedTeamName));

  Weapon selectedWeapon = view_as<Weapon>(player.GetMenuState().GetObject("weapon"));
  char weaponClassname[MAX_CLASSNAME_SIZE];
  char weaponName[MAX_WEAPON_NAME_SIZE];
  selectedWeapon.GetClassname(weaponClassname, sizeof(weaponClassname));
  selectedWeapon.GetName(weaponName, sizeof(weaponName));

  PlayerWeapon tailoredWeapon = player.GetWeapon(selectedTeam, weaponClassname);
  int seed = tailoredWeapon.GetSeed();
  bool hasPresets = tailoredWeapon.GetPaint().HasSeedPresets(weaponClassname);

  Menu menu = new Menu(MenuHandler_Weapons_Seed);
  menu.ExitBackButton = true;
  menu.SetTitle("Loadout > %s > %s > Seed\n \n Current Value: %d\n ", selectedTeamName, weaponName, seed);

  menu.AddItem("#presets", "Presets", hasPresets ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
  menu.AddItem("#custom", "Custom Value", ITEMDRAW_DEFAULT);

  return menu;
}

public int MenuHandler_Weapons_Seed (Menu menu, MenuAction action, int client, int selectedItem) {
  if (action == MenuAction_Select) {
    char option[MAX_MENU_KEY_SIZE];
    menu.GetItem(selectedItem, option, sizeof(option));

    if (StrEqual(option, "#custom")) {
      g_waitingForSeedValue[client] = true;
      CST_Message(client, "Enter the seed value you'd like to use in chat. Type !cancel to cancel.");
    } else if (StrEqual(option, "#presets")) {
      Player.Get(client).OpenMenu(CreateMenu_Weapons_PresetSeeds(client));
    }
  } else if (action == MenuAction_Cancel) {
    if (selectedItem == MenuCancel_ExitBack) {
      Player.Get(client).OpenMenu(CreateMenu_Weapons_Main(client));
    }
  } else if (action == MenuAction_End) {
    delete menu;
  }

  return 0;
}

public Menu CreateMenu_Weapons_PresetSeeds(int client) {
  Player player = Player.Get(client);

  char selectedTeam[MAX_TEAM_KEY_SIZE];
  char selectedTeamName[MAX_TEAM_NAME_SIZE];
  player.GetMenuState().GetString("team", selectedTeam, sizeof(selectedTeam));
  TeamKeyToName(selectedTeam, selectedTeamName, sizeof(selectedTeamName));

  Weapon selectedWeapon = view_as<Weapon>(player.GetMenuState().GetObject("weapon"));
  char weaponClassname[MAX_CLASSNAME_SIZE];
  char weaponName[MAX_WEAPON_NAME_SIZE];
  selectedWeapon.GetClassname(weaponClassname, sizeof(weaponClassname));
  selectedWeapon.GetName(weaponName, sizeof(weaponName));

  PlayerWeapon tailoredWeapon = player.GetWeapon(selectedTeam, weaponClassname);
  char currentSeed[16];
  IntToString(tailoredWeapon.GetSeed(), currentSeed, sizeof(currentSeed));

  Menu menu = new Menu(MenuHandler_Weapons_PresetSeeds);
  menu.ExitBackButton = true;
  menu.SetTitle("Loadout > %s > %s > Seed > Presets", selectedTeamName, weaponName);

  JSON_Array presets = view_as<JSON_Array>(tailoredWeapon.GetPaint().GetObject("seeds").GetObject(weaponClassname));
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

public int MenuHandler_Weapons_PresetSeeds (Menu menu, MenuAction action, int client, int selectedItem) {
  if (action == MenuAction_Select) {
    char option[16];
    menu.GetItem(selectedItem, option, sizeof(option));

    Player player = Player.Get(client);

    char selectedTeam[MAX_TEAM_KEY_SIZE];
    player.GetMenuState().GetString("team", selectedTeam, sizeof(selectedTeam));

    Weapon selectedWeapon = view_as<Weapon>(player.GetMenuState().GetObject("weapon"));
    char weaponClassname[MAX_CLASSNAME_SIZE];
    char weaponName[MAX_WEAPON_NAME_SIZE];
    selectedWeapon.GetClassname(weaponClassname, sizeof(weaponClassname));
    selectedWeapon.GetName(weaponName, sizeof(weaponName));

    PlayerWeapon tailoredWeapon = player.GetWeapon(selectedTeam, weaponClassname);

    char paintName[MAX_PAINT_NAME_SIZE];
    tailoredWeapon.GetPaint().GetName(paintName, sizeof(paintName));

    tailoredWeapon.SetSeed(StringToInt(option));

    CST_Message(client, "Set seed to {ORANGE}%s{NORMAL} on {ORANGE}%s - %s{NORMAL}", option, weaponName, paintName);
    player.OpenMenuAtLastItem(CreateMenu_Weapons_PresetSeeds(client));
  } else if (action == MenuAction_Cancel) {
    if (selectedItem == MenuCancel_ExitBack) {
      Player.Get(client).OpenMenu(CreateMenu_Weapons_Seed(client));
    }
  } else if (action == MenuAction_End) {
    delete menu;
  }

  return 0;
}

public Menu CreateMenu_Weapons_StatTrak(int client) {
  Player player = Player.Get(client);

  char selectedTeam[MAX_TEAM_KEY_SIZE];
  char selectedTeamName[MAX_TEAM_NAME_SIZE];
  player.GetMenuState().GetString("team", selectedTeam, sizeof(selectedTeam));
  TeamKeyToName(selectedTeam, selectedTeamName, sizeof(selectedTeamName));

  Weapon selectedWeapon = view_as<Weapon>(player.GetMenuState().GetObject("weapon"));
  char weaponClassname[MAX_CLASSNAME_SIZE];
  char weaponName[MAX_WEAPON_NAME_SIZE];
  selectedWeapon.GetClassname(weaponClassname, sizeof(weaponClassname));
  selectedWeapon.GetName(weaponName, sizeof(weaponName));

  PlayerWeapon tailoredWeapon = player.GetWeapon(selectedTeam, weaponClassname);
  bool statTrakEnabled = tailoredWeapon.IsStatTrakEnabled();
  int killCount = tailoredWeapon.GetStatTrakCount();
  char status[8];
  status = statTrakEnabled ? "ON" : "OFF";

  Menu menu = new Menu(MenuHandler_Weapons_StatTrak);
  menu.ExitBackButton = true;
  menu.SetTitle("Loadout > %s > %s > StatTrak™\n \n StatTrak™: %s\n Kill Count: %d\n ", selectedTeamName, weaponName, status, killCount);

  menu.AddItem("#toggle", statTrakEnabled ? "Disable StatTrak™" : "Enable StatTrak™", ITEMDRAW_DEFAULT);
  menu.AddItem("", "", ITEMDRAW_SPACER);
  menu.AddItem("", "", ITEMDRAW_SPACER);
  menu.AddItem("#reset", "Reset Kill Count", CanUseWeaponsStatTrakReset(client) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);

  return menu;
}

public int MenuHandler_Weapons_StatTrak (Menu menu, MenuAction action, int client, int selectedItem) {
  if (action == MenuAction_Select) {
    char option[16];
    menu.GetItem(selectedItem, option, sizeof(option));

    Player player = Player.Get(client);

    char selectedTeam[MAX_TEAM_KEY_SIZE];
    player.GetMenuState().GetString("team", selectedTeam, sizeof(selectedTeam));

    Weapon selectedWeapon = view_as<Weapon>(player.GetMenuState().GetObject("weapon"));
    char weaponClassname[MAX_CLASSNAME_SIZE];
    char weaponName[MAX_WEAPON_NAME_SIZE];
    selectedWeapon.GetClassname(weaponClassname, sizeof(weaponClassname));
    selectedWeapon.GetName(weaponName, sizeof(weaponName));

    PlayerWeapon tailoredWeapon = player.GetWeapon(selectedTeam, weaponClassname);

    char paintName[MAX_PAINT_NAME_SIZE];
    tailoredWeapon.GetPaint().GetName(paintName, sizeof(paintName));

    if (StrEqual(option, "#toggle")) {
      tailoredWeapon.SetStatTrak(!tailoredWeapon.IsStatTrakEnabled());
      char toggleType[16];
      toggleType = tailoredWeapon.IsStatTrakEnabled() ? "Enabled" : "Disabled";
      CST_Message(client, "StatTrak™ {ORANGE}%s{NORMAL} on {ORANGE}%s - %s{NORMAL}", toggleType, weaponName, paintName);
    } else if (StrEqual(option, "#reset")) {
      tailoredWeapon.ResetStatTrakCount();
      CST_Message(client, "StatTrak™ kill count reset on {ORANGE}%s - %s{NORMAL}", weaponName, paintName);
    }

    player.OpenMenu(CreateMenu_Weapons_StatTrak(client));
  } else if (action == MenuAction_Cancel) {
    if (selectedItem == MenuCancel_ExitBack) {
      Player.Get(client).OpenMenu(CreateMenu_Weapons_Main(client));
    }
  } else if (action == MenuAction_End) {
    delete menu;
  }

  return 0;
}

public Menu CreateMenu_Weapons_Nametag(int client) {
  Player player = Player.Get(client);

  char selectedTeam[MAX_TEAM_KEY_SIZE];
  char selectedTeamName[MAX_TEAM_NAME_SIZE];
  player.GetMenuState().GetString("team", selectedTeam, sizeof(selectedTeam));
  TeamKeyToName(selectedTeam, selectedTeamName, sizeof(selectedTeamName));

  Weapon selectedWeapon = view_as<Weapon>(player.GetMenuState().GetObject("weapon"));
  char weaponClassname[MAX_CLASSNAME_SIZE];
  char weaponName[MAX_WEAPON_NAME_SIZE];
  selectedWeapon.GetClassname(weaponClassname, sizeof(weaponClassname));
  selectedWeapon.GetName(weaponName, sizeof(weaponName));

  PlayerWeapon tailoredWeapon = player.GetWeapon(selectedTeam, weaponClassname);
  char currentNametag[MAX_NAMETAG_SIZE];
  if (tailoredWeapon.HasNametag()) {
    tailoredWeapon.GetNametag(currentNametag, sizeof(currentNametag));
  } else {
    tailoredWeapon.GetName(currentNametag, sizeof(currentNametag));
  }

  Menu menu = new Menu(MenuHandler_Weapons_Nametag);
  menu.ExitBackButton = true;
  menu.SetTitle("Loadout > %s > %s > Nametag\n \n Current:\n %s\n ", selectedTeamName, weaponName, currentNametag);

  menu.AddItem("#set", "Set new nametag", ITEMDRAW_DEFAULT);
  menu.AddItem("#remove", "Remove nametag", ITEMDRAW_DEFAULT);

  return menu;
}

public int MenuHandler_Weapons_Nametag (Menu menu, MenuAction action, int client, int selectedItem) {
  if (action == MenuAction_Select) {
    char option[16];
    menu.GetItem(selectedItem, option, sizeof(option));

    Player player = Player.Get(client);

    char selectedTeam[MAX_TEAM_KEY_SIZE];
    player.GetMenuState().GetString("team", selectedTeam, sizeof(selectedTeam));

    Weapon selectedWeapon = view_as<Weapon>(player.GetMenuState().GetObject("weapon"));
    char weaponClassname[MAX_CLASSNAME_SIZE];
    char weaponName[MAX_WEAPON_NAME_SIZE];
    selectedWeapon.GetClassname(weaponClassname, sizeof(weaponClassname));
    selectedWeapon.GetName(weaponName, sizeof(weaponName));

    PlayerWeapon tailoredWeapon = player.GetWeapon(selectedTeam, weaponClassname);

    char paintName[MAX_PAINT_NAME_SIZE];
    tailoredWeapon.GetPaint().GetName(paintName, sizeof(paintName));

    if (StrEqual(option, "#set")) {
      g_waitingForNametagValue[client] = true;
      CST_Message(client, "Enter the new nametag you'd like to use in chat. Type !cancel to cancel.");
    } else if (StrEqual(option, "#remove")) {
      tailoredWeapon.SetNametag("");
      CST_Message(client, "Nametag removed on {ORANGE}%s - %s{NORMAL}", weaponName, paintName);
      player.OpenMenu(CreateMenu_Weapons_Nametag(client));
    }
  } else if (action == MenuAction_Cancel) {
    if (selectedItem == MenuCancel_ExitBack) {
      Player.Get(client).OpenMenu(CreateMenu_Weapons_Main(client));
    }
  } else if (action == MenuAction_End) {
    delete menu;
  }

  return 0;
}

public Menu CreateMenu_Weapons_Stickers_Main(int client) {
  Player player = Player.Get(client);

  char selectedTeam[MAX_TEAM_KEY_SIZE];
  char selectedTeamName[MAX_TEAM_NAME_SIZE];
  player.GetMenuState().GetString("team", selectedTeam, sizeof(selectedTeam));
  TeamKeyToName(selectedTeam, selectedTeamName, sizeof(selectedTeamName));

  Weapon selectedWeapon = view_as<Weapon>(player.GetMenuState().GetObject("weapon"));
  char weaponClassname[MAX_CLASSNAME_SIZE];
  char weaponName[MAX_WEAPON_NAME_SIZE];
  selectedWeapon.GetClassname(weaponClassname, sizeof(weaponClassname));
  selectedWeapon.GetName(weaponName, sizeof(weaponName));

  PlayerWeapon tailoredWeapon = player.GetWeapon(selectedTeam, weaponClassname);

  Menu menu = new Menu(MenuHandler_Weapons_Stickers_Main);
  menu.ExitBackButton = true;
  menu.SetTitle("Loadout > %s > %s > Stickers", selectedTeamName, weaponName);

  char itemText[255];
  char key[32];
  char currentSticker[MAX_STICKER_NAME_SIZE];
  int maxSlots = tailoredWeapon.GetStickerSlots();

  for (int i = 1; i <= maxSlots; i++) {
    Format(key, sizeof(key), "#slot%d", i);

    if (tailoredWeapon.HasSticker(i)) {
      tailoredWeapon.GetSticker(i).GetName(currentSticker, sizeof(currentSticker));
    } else {
      currentSticker = "None";
    }
    Format(itemText, sizeof(itemText), "Slot %d\n    %s", i, currentSticker);

    menu.AddItem(key, itemText, ITEMDRAW_DEFAULT);
  }

  menu.AddItem("", "", ITEMDRAW_SPACER);
  menu.AddItem("#all", "Apply to all slots", ITEMDRAW_DEFAULT);

  return menu;
}

public int MenuHandler_Weapons_Stickers_Main (Menu menu, MenuAction action, int client, int selectedItem) {
  if (action == MenuAction_Select) {
    char option[16];
    menu.GetItem(selectedItem, option, sizeof(option));

    Player player = Player.Get(client);

    if (StrEqual(option, "#all")) {
      player.GetMenuState().SetString("stickerSlot", "all");
      player.OpenMenu(CreateMenu_Weapons_Stickers_Collections(client));
    } else {
      ReplaceString(option, sizeof(option), "#slot", "", false);
      player.GetMenuState().SetString("stickerSlot", option);
      player.OpenMenu(CreateMenu_Weapons_Stickers_Slot(client));
    }
  } else if (action == MenuAction_Cancel) {
    if (selectedItem == MenuCancel_ExitBack) {
      Player.Get(client).OpenMenu(CreateMenu_Weapons_Main(client));
    }
  } else if (action == MenuAction_End) {
    delete menu;
  }

  return 0;
}

public Menu CreateMenu_Weapons_Stickers_Slot(int client) {
  Player player = Player.Get(client);

  char selectedTeam[MAX_TEAM_KEY_SIZE];
  char selectedTeamName[MAX_TEAM_NAME_SIZE];
  player.GetMenuState().GetString("team", selectedTeam, sizeof(selectedTeam));
  TeamKeyToName(selectedTeam, selectedTeamName, sizeof(selectedTeamName));

  Weapon selectedWeapon = view_as<Weapon>(player.GetMenuState().GetObject("weapon"));
  char weaponClassname[MAX_CLASSNAME_SIZE];
  char weaponName[MAX_WEAPON_NAME_SIZE];
  selectedWeapon.GetClassname(weaponClassname, sizeof(weaponClassname));
  selectedWeapon.GetName(weaponName, sizeof(weaponName));

  char stickerSlot[8];
  player.GetMenuState().GetString("stickerSlot", stickerSlot, sizeof(stickerSlot));
  int slotIndex = StringToInt(stickerSlot);

  PlayerWeapon tailoredWeapon = player.GetWeapon(selectedTeam, weaponClassname);

  Menu menu = new Menu(MenuHandler_Weapons_Stickers_Slot);
  menu.ExitBackButton = true;

  if (tailoredWeapon.HasSticker(slotIndex)) {
    WeaponSticker currentSticker = tailoredWeapon.GetSticker(slotIndex);

    char stickerName[MAX_STICKER_NAME_SIZE];
    currentSticker.GetName(stickerName, sizeof(stickerName));
    float currentWear = currentSticker.GetWear();

    menu.SetTitle("Loadout > %s > %s > Stickers > Slot %d\n \n Current: %s \n Wear: %f \n\n ", selectedTeamName, weaponName, slotIndex, stickerName, currentWear);

    menu.AddItem("#change", "Change Sticker", ITEMDRAW_DEFAULT);
    menu.AddItem("#scrape", "Scrape", ITEMDRAW_DEFAULT);
    menu.AddItem("#remove", "Remove", ITEMDRAW_DEFAULT);

  } else {
    menu.SetTitle("Loadout > %s > %s > Stickers > Slot %d", selectedTeamName, weaponName, slotIndex);

    menu.AddItem("#change", "Choose Sticker", ITEMDRAW_DEFAULT);
    menu.AddItem("#scrape", "Scrape", ITEMDRAW_DISABLED);
    menu.AddItem("#remove", "Remove", ITEMDRAW_DISABLED);
  }

  return menu;
}

public int MenuHandler_Weapons_Stickers_Slot (Menu menu, MenuAction action, int client, int selectedItem) {
  if (action == MenuAction_Select) {
    char option[16];
    menu.GetItem(selectedItem, option, sizeof(option));

    Player player = Player.Get(client);

    char selectedTeam[MAX_TEAM_KEY_SIZE];
    player.GetMenuState().GetString("team", selectedTeam, sizeof(selectedTeam));

    Weapon selectedWeapon = view_as<Weapon>(player.GetMenuState().GetObject("weapon"));
    char weaponClassname[MAX_CLASSNAME_SIZE];
    char weaponName[MAX_WEAPON_NAME_SIZE];
    selectedWeapon.GetClassname(weaponClassname, sizeof(weaponClassname));
    selectedWeapon.GetName(weaponName, sizeof(weaponName));

    char stickerSlot[8];
    player.GetMenuState().GetString("stickerSlot", stickerSlot, sizeof(stickerSlot));
    int slotIndex = StringToInt(stickerSlot);

    PlayerWeapon tailoredWeapon = player.GetWeapon(selectedTeam, weaponClassname);

    if (StrEqual(option, "#change")) {
      player.OpenMenu(CreateMenu_Weapons_Stickers_Collections(client));
    } else if (StrEqual(option, "#scrape")) {
      player.OpenMenu(CreateMenu_Weapons_Stickers_Scrape(client));
    } else if (StrEqual(option, "#remove")) {
      char paintName[MAX_PAINT_NAME_SIZE];
      tailoredWeapon.GetPaint().GetName(paintName, sizeof(paintName));

      tailoredWeapon.RemoveSticker(slotIndex);
      CST_Message(client, "Sticker at {ORANGE}slot %d{NORMAL} removed on {ORANGE}%s - %s{NORMAL}", slotIndex, weaponName, paintName);
      player.OpenMenu(CreateMenu_Weapons_Stickers_Slot(client));
    }
  } else if (action == MenuAction_Cancel) {
    if (selectedItem == MenuCancel_ExitBack) {
      Player.Get(client).OpenMenu(CreateMenu_Weapons_Stickers_Main(client));
    }
  } else if (action == MenuAction_End) {
    delete menu;
  }

  return 0;
}

public Menu CreateMenu_Weapons_Stickers_Collections(int client) {
  Player player = Player.Get(client);

  player.GetMenuState().Remove("capsule");
  player.GetMenuState().Remove("stickerTeam");
  player.GetMenuState().Remove("stickerPlayer");
  player.GetMenuState().Remove("searchQuery");

  char selectedTeam[MAX_TEAM_KEY_SIZE];
  char selectedTeamName[MAX_TEAM_NAME_SIZE];
  player.GetMenuState().GetString("team", selectedTeam, sizeof(selectedTeam));
  TeamKeyToName(selectedTeam, selectedTeamName, sizeof(selectedTeamName));

  Weapon selectedWeapon = view_as<Weapon>(player.GetMenuState().GetObject("weapon"));
  char weaponClassname[MAX_CLASSNAME_SIZE];
  char weaponName[MAX_WEAPON_NAME_SIZE];
  selectedWeapon.GetClassname(weaponClassname, sizeof(weaponClassname));
  selectedWeapon.GetName(weaponName, sizeof(weaponName));

  Menu menu = new Menu(MenuHandler_Weapons_Stickers_Collections);
  menu.ExitBackButton = true;
  menu.SetTitle("Loadout > %s > %s > Stickers > Collections", selectedTeamName, weaponName);

  menu.AddItem("#search", "Search", ITEMDRAW_DEFAULT);
  menu.AddItem("", "", ITEMDRAW_SPACER);
  menu.AddItem("#teams", "Team Stickers", ITEMDRAW_DEFAULT);
  menu.AddItem("#players", "Player Stickers", ITEMDRAW_DEFAULT);
  menu.AddItem("", "", ITEMDRAW_SPACER);

  JSON_Object capsules = g_data.GetObject("stickers").GetObject("capsules");
  char capsuleClassname[MAX_CLASSNAME_SIZE];
  char capsuleName[MAX_STICKER_CAPSULE_NAME_SIZE];
  int length = capsules.Iterate();
  int keyLength = 0;
  for (int i = 0; i < length; i++) {
    keyLength = capsules.GetKeySize(i);
    char[] key = new char[keyLength];
    capsules.GetKey(i, key, keyLength);

    StickerCapsule capsule = view_as<StickerCapsule>(capsules.GetObject(key));
    capsule.GetClassname(capsuleClassname, sizeof(capsuleClassname));
    capsule.GetName(capsuleName, sizeof(capsuleName));

    menu.AddItem(capsuleClassname, capsuleName, ITEMDRAW_DEFAULT);
  }

  return menu;
}

public int MenuHandler_Weapons_Stickers_Collections (Menu menu, MenuAction action, int client, int selectedItem) {
  if (action == MenuAction_Select) {
    char option[MAX_CLASSNAME_SIZE];
    menu.GetItem(selectedItem, option, sizeof(option));

    Player player = Player.Get(client);

    if (StrEqual(option, "#search")) {
      g_waitingForSearchValue[client] = true;
      CST_Message(client, "Enter your search query to find stickers. Type !cancel to cancel.");
      player.GetMenuState().SetString("type", MENU_TYPE_STICKER_SEARCH);
    } else if (StrEqual(option, "#teams")) {
      player.OpenMenu(CreateMenu_Weapons_Stickers_Teams(client));
    } else if (StrEqual(option, "#players")) {
      player.OpenMenu(CreateMenu_Weapons_Stickers_Players(client));
    } else {
      player.GetMenuState().SetObject("capsule", StickerCapsule.Get(option).DeepCopy());
      player.OpenMenu(CreateMenu_Weapons_Stickers_Capsule_Stickers(client));
    }
  } else if (action == MenuAction_Cancel) {
    if (selectedItem == MenuCancel_ExitBack) {
      Player.Get(client).OpenMenu(CreateMenu_Weapons_Stickers_Main(client));
    }
  } else if (action == MenuAction_End) {
    delete menu;
  }

  return 0;
}

public Menu CreateMenu_Weapons_Stickers_Capsule_Stickers(int client) {
  Player player = Player.Get(client);

  char selectedTeam[MAX_TEAM_KEY_SIZE];
  char selectedTeamName[MAX_TEAM_NAME_SIZE];
  player.GetMenuState().GetString("team", selectedTeam, sizeof(selectedTeam));
  TeamKeyToName(selectedTeam, selectedTeamName, sizeof(selectedTeamName));

  Weapon selectedWeapon = view_as<Weapon>(player.GetMenuState().GetObject("weapon"));
  char weaponClassname[MAX_CLASSNAME_SIZE];
  char weaponName[MAX_WEAPON_NAME_SIZE];
  selectedWeapon.GetClassname(weaponClassname, sizeof(weaponClassname));
  selectedWeapon.GetName(weaponName, sizeof(weaponName));

  StickerCapsule capsule = view_as<StickerCapsule>(player.GetMenuState().GetObject("capsule"));

  char capsuleName[MAX_STICKER_CAPSULE_NAME_SIZE];
  capsule.GetName(capsuleName, sizeof(capsuleName));

  Menu menu = new Menu(MenuHandler_Weapons_Stickers_SelectHandler);
  menu.ExitBackButton = true;
  menu.SetTitle("Loadout > %s > %s > Stickers > %s", selectedTeamName, weaponName, capsuleName);

  StickerCollection stickers = capsule.GetStickers();
  char stickerClassname[MAX_CLASSNAME_SIZE];
  char stickerName[MAX_STICKER_NAME_SIZE];
  int length = stickers.Length;
  for (int i = 0; i < length; i++) {
    Sticker sticker = view_as<Sticker>(stickers.Get(i));
    sticker.GetClassname(stickerClassname, sizeof(stickerClassname));
    sticker.GetName(stickerName, sizeof(stickerName));

    menu.AddItem(stickerClassname, stickerName, ITEMDRAW_DEFAULT);
  }

  return menu;
}

public int MenuHandler_Weapons_Stickers_SelectHandler (Menu menu, MenuAction action, int client, int selectedItem) {
  if (action == MenuAction_Select) {
    char option[MAX_CLASSNAME_SIZE];
    menu.GetItem(selectedItem, option, sizeof(option));

    Player player = Player.Get(client);

    char selectedTeam[MAX_TEAM_KEY_SIZE];
    player.GetMenuState().GetString("team", selectedTeam, sizeof(selectedTeam));

    Weapon selectedWeapon = view_as<Weapon>(player.GetMenuState().GetObject("weapon"));
    char weaponClassname[MAX_CLASSNAME_SIZE];
    char weaponName[MAX_WEAPON_NAME_SIZE];
    selectedWeapon.GetClassname(weaponClassname, sizeof(weaponClassname));
    selectedWeapon.GetName(weaponName, sizeof(weaponName));

    char stickerSlot[8];
    player.GetMenuState().GetString("stickerSlot", stickerSlot, sizeof(stickerSlot));
    int slotIndex = StringToInt(stickerSlot);

    PlayerWeapon tailoredWeapon = player.GetWeapon(selectedTeam, weaponClassname);

    char paintName[MAX_PAINT_NAME_SIZE];
    tailoredWeapon.GetPaint().GetName(paintName, sizeof(paintName));

    char stickerName[MAX_STICKER_NAME_SIZE];
    Sticker.Get(option).GetName(stickerName, sizeof(stickerName));

    if (StrEqual(stickerSlot, "all")) {
      int maxSlots = tailoredWeapon.GetStickerSlots();
      for (int i = 1; i <= maxSlots; i++) {
        tailoredWeapon.SetSticker(i, option, 0.00);
      }
      CST_Message(client, "All stickers set to {ORANGE}%s{NORMAL} on {ORANGE}%s - %s{NORMAL}", stickerName, weaponName, paintName);
    } else {
      tailoredWeapon.SetSticker(slotIndex, option, 0.00);
      CST_Message(client, "Sticker at {ORANGE}slot %d{NORMAL} set to {ORANGE}%s{NORMAL} on {ORANGE}%s - %s{NORMAL}", slotIndex, stickerName, weaponName, paintName);
    }

    if (player.GetMenuState().HasKey("capsule")) {
      player.OpenMenuAtLastItem(CreateMenu_Weapons_Stickers_Capsule_Stickers(client));
    } else if (player.GetMenuState().HasKey("stickerTeam")) {
      player.OpenMenuAtLastItem(CreateMenu_Weapons_Stickers_Teams_Stickers(client));
    } else if (player.GetMenuState().HasKey("stickerPlayer")) {
      player.OpenMenuAtLastItem(CreateMenu_Weapons_Stickers_Players_Stickers(client));
    } else if (player.GetMenuState().HasKey("searchQuery")) {
      player.OpenMenuAtLastItem(CreateMenu_Weapons_Stickers_Search(client));
    }
  } else if (action == MenuAction_Cancel) {
    if (selectedItem == MenuCancel_ExitBack) {
      Player player = Player.Get(client);

      if (player.GetMenuState().HasKey("capsule") || player.GetMenuState().HasKey("searchQuery")) {
        player.OpenMenu(CreateMenu_Weapons_Stickers_Collections(client));
      } else if (player.GetMenuState().HasKey("stickerTeam")) {
        player.OpenMenu(CreateMenu_Weapons_Stickers_Teams(client));
      } else if (player.GetMenuState().HasKey("stickerPlayer")) {
        player.OpenMenu(CreateMenu_Weapons_Stickers_Players(client));
      }
    }
  } else if (action == MenuAction_End) {
    delete menu;
  }

  return 0;
}

public Menu CreateMenu_Weapons_Stickers_Teams(int client) {
  Player player = Player.Get(client);

  char selectedTeam[MAX_TEAM_KEY_SIZE];
  char selectedTeamName[MAX_TEAM_NAME_SIZE];
  player.GetMenuState().GetString("team", selectedTeam, sizeof(selectedTeam));
  TeamKeyToName(selectedTeam, selectedTeamName, sizeof(selectedTeamName));

  Weapon selectedWeapon = view_as<Weapon>(player.GetMenuState().GetObject("weapon"));
  char weaponClassname[MAX_CLASSNAME_SIZE];
  char weaponName[MAX_WEAPON_NAME_SIZE];
  selectedWeapon.GetClassname(weaponClassname, sizeof(weaponClassname));
  selectedWeapon.GetName(weaponName, sizeof(weaponName));

  Menu menu = new Menu(MenuHandler_Weapons_Stickers_Teams);
  menu.ExitBackButton = true;
  menu.SetTitle("Loadout > %s > %s > Stickers > Teams", selectedTeamName, weaponName);

  JSON_Object teams = g_data.GetObject("stickers").GetObject("teams");
  int length = teams.Iterate();
  int keyLength = 0;
  char itemText[MAX_MENU_ITEM_SIZE];
  for (int i = 0; i < length; i++) {
    keyLength = teams.GetKeySize(i);
    char[] key = new char[keyLength];
    teams.GetKey(i, key, keyLength);

    JSON_Object team = teams.GetObject(key);

    char teamKey[MAX_STICKER_TEAM_KEY_SIZE];
    char teamName[MAX_STICKER_TEAM_NAME_SIZE];
    char teamGeo[MAX_STICKER_GEO_SIZE];
    team.GetString("key", teamKey, sizeof(teamKey));
    team.GetString("name", teamName, sizeof(teamName));
    team.GetString("geo", teamGeo, sizeof(teamGeo));

    Format(itemText, sizeof(itemText), "%s [%s]", teamName, teamGeo);
    menu.AddItem(teamKey, itemText, ITEMDRAW_DEFAULT);
  }

  return menu;
}

public int MenuHandler_Weapons_Stickers_Teams (Menu menu, MenuAction action, int client, int selectedItem) {
  if (action == MenuAction_Select) {
    char option[MAX_CLASSNAME_SIZE];
    menu.GetItem(selectedItem, option, sizeof(option));

    Player player = Player.Get(client);

    player.GetMenuState().SetString("stickerTeam", option);
    player.OpenMenu(CreateMenu_Weapons_Stickers_Teams_Stickers(client));
  } else if (action == MenuAction_Cancel) {
    if (selectedItem == MenuCancel_ExitBack) {
      Player.Get(client).OpenMenu(CreateMenu_Weapons_Stickers_Collections(client));
    }
  } else if (action == MenuAction_End) {
    delete menu;
  }

  return 0;
}

public Menu CreateMenu_Weapons_Stickers_Teams_Stickers(int client) {
  Player player = Player.Get(client);

  char selectedTeam[MAX_TEAM_KEY_SIZE];
  char selectedTeamName[MAX_TEAM_NAME_SIZE];
  player.GetMenuState().GetString("team", selectedTeam, sizeof(selectedTeam));
  TeamKeyToName(selectedTeam, selectedTeamName, sizeof(selectedTeamName));

  Weapon selectedWeapon = view_as<Weapon>(player.GetMenuState().GetObject("weapon"));
  char weaponClassname[MAX_CLASSNAME_SIZE];
  char weaponName[MAX_WEAPON_NAME_SIZE];
  selectedWeapon.GetClassname(weaponClassname, sizeof(weaponClassname));
  selectedWeapon.GetName(weaponName, sizeof(weaponName));

  char selectedStickerTeam[MAX_STICKER_TEAM_KEY_SIZE];
  player.GetMenuState().GetString("stickerTeam", selectedStickerTeam, sizeof(selectedStickerTeam));

  JSON_Object team = g_data.GetObject("stickers").GetObject("teams").GetObject(selectedStickerTeam);

  char stickerTeamName[MAX_STICKER_TEAM_NAME_SIZE];
  team.GetString("name", stickerTeamName, sizeof(stickerTeamName));

  Menu menu = new Menu(MenuHandler_Weapons_Stickers_SelectHandler);
  menu.ExitBackButton = true;
  menu.SetTitle("Loadout > %s > %s > Stickers > Teams > %s", selectedTeamName, weaponName, stickerTeamName);

  StickerCollection stickers = new StickerCollection(view_as<JSON_Array>(team.GetObject("stickers")));
  char stickerClassname[MAX_CLASSNAME_SIZE];
  char stickerName[MAX_STICKER_NAME_SIZE];
  int length = stickers.Length;
  for (int i = 0; i < length; i++) {
    Sticker sticker = view_as<Sticker>(stickers.Get(i));
    sticker.GetClassname(stickerClassname, sizeof(stickerClassname));
    sticker.GetName(stickerName, sizeof(stickerName));

    menu.AddItem(stickerClassname, stickerName, ITEMDRAW_DEFAULT);
  }

  return menu;
}

public Menu CreateMenu_Weapons_Stickers_Players(int client) {
  Player player = Player.Get(client);

  char selectedTeam[MAX_TEAM_KEY_SIZE];
  char selectedTeamName[MAX_TEAM_NAME_SIZE];
  player.GetMenuState().GetString("team", selectedTeam, sizeof(selectedTeam));
  TeamKeyToName(selectedTeam, selectedTeamName, sizeof(selectedTeamName));

  Weapon selectedWeapon = view_as<Weapon>(player.GetMenuState().GetObject("weapon"));
  char weaponClassname[MAX_CLASSNAME_SIZE];
  char weaponName[MAX_WEAPON_NAME_SIZE];
  selectedWeapon.GetClassname(weaponClassname, sizeof(weaponClassname));
  selectedWeapon.GetName(weaponName, sizeof(weaponName));

  Menu menu = new Menu(MenuHandler_Weapons_Stickers_Players);
  menu.ExitBackButton = true;
  menu.SetTitle("Loadout > %s > %s > Stickers > Players", selectedTeamName, weaponName);

  JSON_Object players = g_data.GetObject("stickers").GetObject("players");
  int length = players.Iterate();
  int keyLength = 0;
  char itemText[MAX_MENU_ITEM_SIZE];
  for (int i = 0; i < length; i++) {
    keyLength = players.GetKeySize(i);
    char[] key = new char[keyLength];
    players.GetKey(i, key, keyLength);

    JSON_Object stickerPlayer = players.GetObject(key);

    char playerCode[MAX_STICKER_PLAYER_CODE_SIZE];
    char playerName[MAX_STICKER_PLAYER_NAME_SIZE];
    char playerGeo[MAX_STICKER_GEO_SIZE];
    stickerPlayer.GetString("code", playerCode, sizeof(playerCode));
    stickerPlayer.GetString("name", playerName, sizeof(playerName));
    stickerPlayer.GetString("geo", playerGeo, sizeof(playerGeo));

    Format(itemText, sizeof(itemText), "%s [%s]", playerName, playerGeo);
    menu.AddItem(playerCode, itemText, ITEMDRAW_DEFAULT);
  }

  return menu;
}

public int MenuHandler_Weapons_Stickers_Players (Menu menu, MenuAction action, int client, int selectedItem) {
  if (action == MenuAction_Select) {
    char option[MAX_CLASSNAME_SIZE];
    menu.GetItem(selectedItem, option, sizeof(option));

    Player player = Player.Get(client);

    player.GetMenuState().SetString("stickerPlayer", option);
    player.OpenMenu(CreateMenu_Weapons_Stickers_Players_Stickers(client));
  } else if (action == MenuAction_Cancel) {
    if (selectedItem == MenuCancel_ExitBack) {
      Player.Get(client).OpenMenu(CreateMenu_Weapons_Stickers_Collections(client));
    }
  } else if (action == MenuAction_End) {
    delete menu;
  }

  return 0;
}

public Menu CreateMenu_Weapons_Stickers_Players_Stickers(int client) {
  Player player = Player.Get(client);

  char selectedTeam[MAX_TEAM_KEY_SIZE];
  char selectedTeamName[MAX_TEAM_NAME_SIZE];
  player.GetMenuState().GetString("team", selectedTeam, sizeof(selectedTeam));
  TeamKeyToName(selectedTeam, selectedTeamName, sizeof(selectedTeamName));

  Weapon selectedWeapon = view_as<Weapon>(player.GetMenuState().GetObject("weapon"));
  char weaponClassname[MAX_CLASSNAME_SIZE];
  char weaponName[MAX_WEAPON_NAME_SIZE];
  selectedWeapon.GetClassname(weaponClassname, sizeof(weaponClassname));
  selectedWeapon.GetName(weaponName, sizeof(weaponName));

  char selectedStickerPlayer[MAX_STICKER_PLAYER_CODE_SIZE];
  player.GetMenuState().GetString("stickerPlayer", selectedStickerPlayer, sizeof(selectedStickerPlayer));

  JSON_Object stickerPlayer = g_data.GetObject("stickers").GetObject("players").GetObject(selectedStickerPlayer);

  char stickerPlayerName[MAX_STICKER_PLAYER_NAME_SIZE];
  stickerPlayer.GetString("name", stickerPlayerName, sizeof(stickerPlayerName));

  Menu menu = new Menu(MenuHandler_Weapons_Stickers_SelectHandler);
  menu.ExitBackButton = true;
  menu.SetTitle("Loadout > %s > %s > Stickers > Players > %s", selectedTeamName, weaponName, stickerPlayerName);

  StickerCollection stickers = new StickerCollection(view_as<JSON_Array>(stickerPlayer.GetObject("stickers")));
  char stickerClassname[MAX_CLASSNAME_SIZE];
  char stickerName[MAX_STICKER_NAME_SIZE];
  int length = stickers.Length;
  for (int i = 0; i < length; i++) {
    Sticker sticker = view_as<Sticker>(stickers.Get(i));
    sticker.GetClassname(stickerClassname, sizeof(stickerClassname));
    sticker.GetName(stickerName, sizeof(stickerName));

    menu.AddItem(stickerClassname, stickerName, ITEMDRAW_DEFAULT);
  }

  return menu;
}

public Menu CreateMenu_Weapons_Stickers_Search(int client) {
  Player player = Player.Get(client);

  char selectedTeam[MAX_TEAM_KEY_SIZE];
  char selectedTeamName[MAX_TEAM_NAME_SIZE];
  player.GetMenuState().GetString("team", selectedTeam, sizeof(selectedTeam));
  TeamKeyToName(selectedTeam, selectedTeamName, sizeof(selectedTeamName));

  Weapon selectedWeapon = view_as<Weapon>(player.GetMenuState().GetObject("weapon"));
  char weaponClassname[MAX_CLASSNAME_SIZE];
  char weaponName[MAX_WEAPON_NAME_SIZE];
  selectedWeapon.GetClassname(weaponClassname, sizeof(weaponClassname));
  selectedWeapon.GetName(weaponName, sizeof(weaponName));

  char searchQuery[128];
  player.GetMenuState().GetString("searchQuery", searchQuery, sizeof(searchQuery));

  Menu menu = new Menu(MenuHandler_Weapons_Stickers_SelectHandler);
  menu.ExitBackButton = true;
  menu.SetTitle("Loadout > %s > %s > Stickers > Search > \"%s\"", selectedTeamName, weaponName, searchQuery);

  JSON_Object stickers = g_data.GetObject("stickers").GetObject("stickers");

  char stickerClassname[MAX_CLASSNAME_SIZE];
  char stickerName[MAX_STICKER_NAME_SIZE];
  int length = stickers.Iterate();
  int keyLength = 0;
  for (int i = 0; i < length; i++) {
    keyLength = stickers.GetKeySize(i);
    char[] key = new char[keyLength];
    stickers.GetKey(i, key, keyLength);

    Sticker sticker = view_as<Sticker>(stickers.GetObject(key));
    sticker.GetClassname(stickerClassname, sizeof(stickerClassname));
    sticker.GetName(stickerName, sizeof(stickerName));

    if (StrContains(stickerName, searchQuery, false) > -1) {
      menu.AddItem(stickerClassname, stickerName, ITEMDRAW_DEFAULT);
    }
  }

  return menu;
}

public Menu CreateMenu_Weapons_Stickers_Scrape(int client) {
  Player player = Player.Get(client);

  char selectedTeam[MAX_TEAM_KEY_SIZE];
  char selectedTeamName[MAX_TEAM_NAME_SIZE];
  player.GetMenuState().GetString("team", selectedTeam, sizeof(selectedTeam));
  TeamKeyToName(selectedTeam, selectedTeamName, sizeof(selectedTeamName));

  Weapon selectedWeapon = view_as<Weapon>(player.GetMenuState().GetObject("weapon"));
  char weaponClassname[MAX_CLASSNAME_SIZE];
  char weaponName[MAX_WEAPON_NAME_SIZE];
  selectedWeapon.GetClassname(weaponClassname, sizeof(weaponClassname));
  selectedWeapon.GetName(weaponName, sizeof(weaponName));

  char stickerSlot[8];
  player.GetMenuState().GetString("stickerSlot", stickerSlot, sizeof(stickerSlot));
  int slotIndex = StringToInt(stickerSlot);

  PlayerWeapon tailoredWeapon = player.GetWeapon(selectedTeam, weaponClassname);

  float currentWear = tailoredWeapon.GetSticker(slotIndex).GetWear();
  int currentScrapes = RoundToFloor((currentWear * 100) / 10);

  Menu menu = new Menu(MenuHandler_Weapons_Stickers_Scrape);
  menu.ExitBackButton = true;
  menu.SetTitle("Loadout > %s > %s > Stickers > Slot %d > Scrape\n \n Scrapes: %d\n Current Wear: %f\n\n ", selectedTeamName, weaponName, slotIndex, currentScrapes, currentWear);

  if (currentScrapes == 10) {
    menu.AddItem("#remove", "Remove Sticker", ITEMDRAW_DEFAULT);
  } else {
    menu.AddItem("#scrape", "Scrape", ITEMDRAW_DEFAULT);
  }

  menu.AddItem("#undo", "Undo scrape", currentScrapes == 0 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);

  return menu;
}

public int MenuHandler_Weapons_Stickers_Scrape (Menu menu, MenuAction action, int client, int selectedItem) {
  if (action == MenuAction_Select) {
    char option[16];
    menu.GetItem(selectedItem, option, sizeof(option));

    Player player = Player.Get(client);

    char selectedTeam[MAX_TEAM_KEY_SIZE];
    player.GetMenuState().GetString("team", selectedTeam, sizeof(selectedTeam));

    Weapon selectedWeapon = view_as<Weapon>(player.GetMenuState().GetObject("weapon"));
    char weaponClassname[MAX_CLASSNAME_SIZE];
    char weaponName[MAX_WEAPON_NAME_SIZE];
    selectedWeapon.GetClassname(weaponClassname, sizeof(weaponClassname));
    selectedWeapon.GetName(weaponName, sizeof(weaponName));

    char stickerSlot[8];
    player.GetMenuState().GetString("stickerSlot", stickerSlot, sizeof(stickerSlot));
    int slotIndex = StringToInt(stickerSlot);

    PlayerWeapon tailoredWeapon = player.GetWeapon(selectedTeam, weaponClassname);

    float currentWear = tailoredWeapon.GetSticker(slotIndex).GetWear();
    int currentScrapes = RoundFloat((currentWear * 100) / 10);

    char paintName[MAX_PAINT_NAME_SIZE];
    tailoredWeapon.GetPaint().GetName(paintName, sizeof(paintName));

    char stickerName[MAX_STICKER_NAME_SIZE];
    tailoredWeapon.GetSticker(slotIndex).GetName(stickerName, sizeof(stickerName));

    if (StrEqual(option, "#scrape")) {
      int newScrapes = currentScrapes + 1;
      float newWear = newScrapes * 0.1;

      tailoredWeapon.SetStickerWear(slotIndex, newWear);

      CST_Message(client, "Scraped sticker at {ORANGE}slot %d{NORMAL}, new wear {ORANGE}%f{NORMAL} ({ORANGE}%d scrapes{NORMAL})", slotIndex, newWear, newScrapes);
      player.OpenMenu(CreateMenu_Weapons_Stickers_Scrape(client));
    } else if (StrEqual(option, "#undo")) {
      int newScrapes = currentScrapes - 1;
      float newWear = newScrapes * 0.1;
      tailoredWeapon.SetStickerWear(slotIndex, newWear);

      CST_Message(client, "Undid scrape on sticker at {ORANGE}slot %d{NORMAL}, new wear {ORANGE}%f{NORMAL} ({ORANGE}%d scrapes{NORMAL})", slotIndex, newWear, newScrapes);
      player.OpenMenu(CreateMenu_Weapons_Stickers_Scrape(client));
    } else if (StrEqual(option, "#remove")) {
      tailoredWeapon.RemoveSticker(slotIndex);

      CST_Message(client, "Sticker at {ORANGE}slot %d{NORMAL} removed on {ORANGE}%s - %s{NORMAL}", slotIndex, weaponName, paintName);
      player.OpenMenu(CreateMenu_Weapons_Stickers_Main(client));
    }
  } else if (action == MenuAction_Cancel) {
    if (selectedItem == MenuCancel_ExitBack) {
      Player.Get(client).OpenMenu(CreateMenu_Weapons_Stickers_Slot(client));
    }
  } else if (action == MenuAction_End) {
    delete menu;
  }

  return 0;
}
