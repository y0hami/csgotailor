#if defined _CSGOTAILOR_CLASS_PLAYER_INCLUDED
  #endinput
#endif
#define _CSGOTAILOR_CLASS_PLAYER_INCLUDED

methodmap Player < JSON_Object {
  public static Player Get(int client) {
    return view_as<Player>(g_players[client]);
  }

  public static Player Register(int client) {
    Player player = new Player(client);
    g_players[client] = player;
    Player.FetchData(client);

    if (FeatureIsEnabled(FEATURE_STATTRAK)) {
      SDKHook(client, SDKHook_OnTakeDamageAlive, Hook_OnDamage);
    }
  }

  public static void Unregister(int client) {
    json_cleanup_and_delete(g_players[client]);
    g_waitingForWearValue[client] = false;
    g_waitingForSeedValue[client] = false;
    g_waitingForNametagValue[client] = false;

    if (FeatureIsEnabled(FEATURE_STATTRAK)) {
      SDKUnhook(client, SDKHook_OnTakeDamageAlive, Hook_OnDamage);
    }
  }

  public static void FetchData(int client) {
    Player player = Player.Get(client);

    JSON_Object playerWeapons = player.GetObject("weapons");
    json_cleanup_and_delete(playerWeapons);
    playerWeapons = new JSON_Object();
    playerWeapons.SetObject(TEAM_T, new JSON_Object());
    playerWeapons.SetObject(TEAM_CT, new JSON_Object());
    player.SetObject("weapons", playerWeapons);

    JSON_Object playerKnifes = player.GetObject("knifes");
    json_cleanup_and_delete(playerKnifes);
    playerKnifes = new JSON_Object();
    player.SetObject("knifes", playerKnifes);

    JSON_Object playerGloves = player.GetObject("gloves");
    json_cleanup_and_delete(playerGloves);
    playerGloves = new JSON_Object();
    player.SetObject("gloves", playerGloves);

    char steamId[MAX_STEAMID_SIZE];
    char teamKey[MAX_TEAM_KEY_SIZE];
    char classname[MAX_CLASSNAME_SIZE];
    char paintClassname[MAX_CLASSNAME_SIZE];
    char nametag[MAX_NAMETAG_SIZE];

    player.GetSteamID(steamId, sizeof(steamId));

    DBStatement stmt = DB_Query("\
    SELECT * FROM csgotailor_weapons \
      WHERE steamId = ? \
    ");
    DB_BindString(stmt, 0, steamId);

    if (DB_Execute(stmt)) {
      while (SQL_FetchRow(stmt)) {
        DB_FetchString(stmt, 1, teamKey, sizeof(teamKey));
        DB_FetchString(stmt, 2, classname, sizeof(classname));
        DB_FetchString(stmt, 3, paintClassname, sizeof(paintClassname));
        float wear = DB_FetchFloat(stmt, 4);
        int seed = DB_FetchInt(stmt, 5);
        int stattrakEnabled = DB_FetchInt(stmt, 6);
        int stattrakCount = DB_FetchInt(stmt, 7);
        DB_FetchString(stmt, 8, nametag, sizeof(nametag));

        char stickersString[MAX_STICKER_DB_STRING_SIZE];
        DB_FetchString(stmt, 9, stickersString, sizeof(stickersString));

        WeaponStickersCollection stickers = new WeaponStickersCollection(stickersString);

        playerWeapons.GetObject(teamKey).SetObject(classname, new PlayerWeapon(
          client,
          teamKey,
          classname,
          paintClassname,
          wear,
          seed,
          stattrakEnabled == 1,
          stattrakCount,
          nametag,
          stickers
        ));
      }
    }

    stmt = DB_Query("\
    SELECT * FROM csgotailor_knifes \
      WHERE steamId = ? \
    ");
    DB_BindString(stmt, 0, steamId);

    if (DB_Execute(stmt)) {
      while (SQL_FetchRow(stmt)) {
        DB_FetchString(stmt, 1, teamKey, sizeof(teamKey));
        DB_FetchString(stmt, 2, classname, sizeof(classname));
        DB_FetchString(stmt, 3, paintClassname, sizeof(paintClassname));
        float wear = DB_FetchFloat(stmt, 4);
        int seed = DB_FetchInt(stmt, 5);
        int stattrakEnabled = DB_FetchInt(stmt, 6);
        int stattrakCount = DB_FetchInt(stmt, 7);
        DB_FetchString(stmt, 8, nametag, sizeof(nametag));

        playerKnifes.SetObject(teamKey, new PlayerKnife(
          client,
          teamKey,
          classname,
          paintClassname,
          wear,
          seed,
          stattrakEnabled == 1,
          stattrakCount,
          nametag
        ));
      }
    }

    stmt = DB_Query("\
    SELECT * FROM csgotailor_gloves \
      WHERE steamId = ? \
    ");
    DB_BindString(stmt, 0, steamId);

    if (DB_Execute(stmt)) {
      while (SQL_FetchRow(stmt)) {
        DB_FetchString(stmt, 1, teamKey, sizeof(teamKey));
        DB_FetchString(stmt, 2, classname, sizeof(classname));
        DB_FetchString(stmt, 3, paintClassname, sizeof(paintClassname));
        float wear = DB_FetchFloat(stmt, 4);
        int seed = DB_FetchInt(stmt, 5);

        playerGloves.SetObject(teamKey, new PlayerGloves(
          client,
          teamKey,
          classname,
          paintClassname,
          wear,
          seed
        ));
      }
    }
  }

  public Player(int client) {
    JSON_Object self = new JSON_Object();

    self.SetInt("clientId", client);

    char steamId[MAX_STEAMID_SIZE];
    GetClientAuthId(client, AuthId_Steam2, steamId, sizeof(steamId), true);
    self.SetString("steamId", steamId);

    JSON_Object state = new JSON_Object();
    state.SetObject("menu", new JSON_Object());
    self.SetObject("state", state);

    return view_as<Player>(self);
  }

  public int GetClientID() {
    return this.GetInt("clientId");
  }

  public bool GetSteamID(char[] buffer, int bufferSize) {
    return this.GetString("steamId", buffer, bufferSize);
  }

  public JSON_Object GetState() {
    return this.GetObject("state");
  }

  public JSON_Object GetMenuState() {
    return this.GetState().GetObject("menu");
  }

  public PlayerWeapon GetWeapon(char[] teamKey, char[] classname) {
    return view_as<PlayerWeapon>(this.GetObject("weapons").GetObject(teamKey).GetObject(classname));
  }

  public bool HasWeapon(char[] teamKey, char[] classname) {
    PlayerWeapon weapon = this.GetWeapon(teamKey, classname);

    return weapon != null;
  }

  public PlayerKnife GetKnife(char[] teamKey) {
    return view_as<PlayerKnife>(this.GetObject("knifes").GetObject(teamKey));
  }

  public bool HasKnife(char[] teamKey) {
    PlayerKnife knife = this.GetKnife(teamKey);

    return knife != null;
  }

  public PlayerGloves GetGloves(char[] teamKey) {
    return view_as<PlayerGloves>(this.GetObject("gloves").GetObject(teamKey));
  }

  public bool HasGloves(char[] teamKey) {
    PlayerGloves gloves = this.GetGloves(teamKey);

    return gloves != null;
  }

  public bool OpenMenu(Menu menu) {
    return DisplayMenu(menu, this.GetClientID(), 0);
  }

  public bool OpenMenuAtLastItem(Menu menu) {
    return DisplayMenuAtItem(menu, this.GetClientID(), GetMenuSelectionPosition(), 0);
  }

  public bool GetTeam(char[] buffer, int bufferSize) {
    int clientTeam = GetClientTeam(this.GetClientID());

    if (clientTeam == 2) return strcopy(buffer, bufferSize, TEAM_T) > 0;
    if (clientTeam == 3) return strcopy(buffer, bufferSize, TEAM_CT) > 0;

    return false;
  }

  public void SetItemProps(int entity) {
    char classname[MAX_CLASSNAME_SIZE];
    if (ClassnameFromEntity(entity, classname, sizeof(classname))) {
      char team[MAX_TEAM_KEY_SIZE];
      this.GetTeam(team, sizeof(team));

      bool isKnife = IsKnife(entity);
      int paintDefIndex;
      float wear;
      int seed;
      bool stattrakEnabled;
      int stattrakCount;
      bool hasNametag;
      char nametag[MAX_NAMETAG_SIZE];

      if (isKnife) {
        if (!this.HasKnife(team)) return;

        char knifeClassname[MAX_CLASSNAME_SIZE];
        this.GetKnife(team).GetClassname(knifeClassname, sizeof(knifeClassname));

        if (!StrEqual(classname, knifeClassname)) return;

        PlayerKnife knife = this.GetKnife(team);

        paintDefIndex = knife.GetPaint().GetDefIndex();
        wear = knife.GetWear();
        seed = knife.GetSeed();
        stattrakEnabled = knife.IsStatTrakEnabled();
        stattrakCount = knife.GetStatTrakCount();
        hasNametag = knife.HasNametag();
        if (hasNametag) knife.GetNametag(nametag, sizeof(nametag));
      } else {
        if (!this.HasWeapon(team, classname)) return;

        PlayerWeapon weapon = this.GetWeapon(team, classname);

        paintDefIndex = weapon.GetPaint().GetDefIndex();
        wear = weapon.GetWear();
        seed = weapon.GetSeed();
        stattrakEnabled = weapon.IsStatTrakEnabled();
        stattrakCount = weapon.GetStatTrakCount();
        hasNametag = weapon.HasNametag();
        if (hasNametag) weapon.GetNametag(nametag, sizeof(nametag));
      }

      static int IDHigh = 16384;

      SetEntProp(entity, Prop_Send, "m_iItemIDLow", -1);
      SetEntProp(entity, Prop_Send, "m_iItemIDHigh", IDHigh++);

      SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", paintDefIndex);
      SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", wear);
      SetEntProp(entity, Prop_Send, "m_nFallbackSeed", seed);

      if (FeatureIsEnabled(FEATURE_STATTRAK)) {
        SetEntProp(entity, Prop_Send, "m_nFallbackStatTrak", stattrakEnabled ? stattrakCount : -1);

        if (isKnife) {
          SetEntProp(entity, Prop_Send, "m_iEntityQuality", 3);
        } else {
          SetEntProp(entity, Prop_Send, "m_iEntityQuality", stattrakEnabled ? 9 : 0);
        }
      }

      if (FeatureIsEnabled(FEATURE_NAMETAG) && hasNametag) {
        SetEntDataString(entity, FindSendPropInfo("CBaseAttributableItem", "m_szCustomName"), nametag, MAX_NAME_LENGTH);
      }

      SetEntProp(entity, Prop_Send, "m_iAccountID", GetSteamAccountID(this.GetClientID()));
      SetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity", this.GetClientID());
      SetEntPropEnt(entity, Prop_Send, "m_hPrevOwner", -1);

      if (!isKnife) {
        PlayerWeapon weapon = this.GetWeapon(team, classname);

        if (weapon.HasStickers()) {
          Address weaponAddress = GetEntityAddress(entity);

          if (weaponAddress != Address_Null) {
            Address econItemView = weaponAddress + view_as<Address>(gsdk_econItemOffset);

            bool updated = false;
            for (int i = 0; i < weapon.GetStickerSlots(); i++) {
              if (weapon.HasSticker(i + 1)) {
                updated = true;
                WeaponSticker sticker = weapon.GetSticker(i + 1);

                SetAttributeValue(econItemView, sticker.GetDefIndex(), "sticker slot %i id", i);
                SetAttributeValue(econItemView, sticker.GetWear(), "sticker slot %i wear", i);
              }
            }

            if (updated) {
              PTaH_ForceFullUpdate(this.GetClientID());
            }
          }
        }
      }
    }
  }

  public bool RefreshItem(const char[] classname) {
    int size = GetEntPropArraySize(this.GetClientID(), Prop_Send, "m_hMyWeapons");

    for (int i = 0; i < size; i++) {
      int weaponEntity = GetEntPropEnt(this.GetClientID(), Prop_Send, "m_hMyWeapons", i);
      bool isKnife = IsKnife(weaponEntity);

      char team[MAX_TEAM_KEY_SIZE];
      this.GetTeam(team, sizeof(team));

      if (isKnife && IsKnifeClass(classname)) {
        RemovePlayerItem(this.GetClientID(), weaponEntity);
        AcceptEntityInput(weaponEntity, "KillHierarchy");
        GivePlayerItem(this.GetClientID(), "weapon_knife");
        return true;
      }

      char weaponClassname[MAX_CLASSNAME_SIZE];
      if (!isKnife && ClassnameFromEntity(weaponEntity, weaponClassname, sizeof(weaponClassname)) &&
          StrEqual(classname, weaponClassname)) {
        RemovePlayerItem(this.GetClientID(), weaponEntity);
        AcceptEntityInput(weaponEntity, "KillHierarchy");

        if (this.HasWeapon(team, weaponClassname)) {
          int offset = FindDataMapInfo(this.GetClientID(), "m_iAmmo") + (GetEntProp(weaponEntity, Prop_Data, "m_iPrimaryAmmoType") * 4);
          int ammo = GetEntData(this.GetClientID(), offset);
          int clip = GetEntProp(weaponEntity, Prop_Send, "m_iClip1");
          int reserve = GetEntProp(weaponEntity, Prop_Send, "m_iPrimaryReserveAmmoCount");

          weaponEntity = GivePlayerItem(this.GetClientID(), weaponClassname);

          if (clip != -1) {
            SetEntProp(weaponEntity, Prop_Send, "m_iClip1", clip);
          }
          if (reserve != -1) {
            SetEntProp(weaponEntity, Prop_Send, "m_iPrimaryReserveAmmoCount", reserve);
          }
          if (offset != -1 && ammo != -1) {
            DataPack pack;
            CreateDataTimer(0.1, ReserveAmmoTimer, pack);
            pack.WriteCell(GetClientUserId(this.GetClientID()));
            pack.WriteCell(offset);
            pack.WriteCell(ammo);
          }
        }

        return true;
      }
    }

    return false;
  }

  public bool GiveGloves() {
    char team[MAX_TEAM_KEY_SIZE];
    this.GetTeam(team, sizeof(team));

    if (this.HasGloves(team)) {
      int entity = GetEntPropEnt(this.GetClientID(), Prop_Send, "m_hMyWearables");
      int activeWeapon = -1;

      if (IsPlayerAlive(this.GetClientID())) {
        activeWeapon = GetEntPropEnt(this.GetClientID(), Prop_Send, "m_hActiveWeapon");
        if (activeWeapon != -1) {
          SetEntPropEnt(this.GetClientID(), Prop_Send, "m_hActiveWeapon", -1);
        }
      }

      if (entity != -1) {
        AcceptEntityInput(entity, "KillHierarchy");
      }

      char temp[2];
      GetEntPropString(this.GetClientID(), Prop_Send, "m_szArmsModel", temp, sizeof(temp));
      if (temp[0]) {
        SetEntPropString(this.GetClientID(), Prop_Send, "m_szArmsModel", "");
      }

      entity = CreateEntityByName("wearable_item");
      if (entity != -1) {
        SetEntProp(entity, Prop_Send, "m_iItemIDLow", -1);

        PlayerGloves gloves = this.GetGloves(team);

        SetEntProp(entity, Prop_Send, "m_iItemDefinitionIndex", gloves.GetDefIndex());
        SetEntProp(entity, Prop_Send, "m_nFallbackPaintKit", gloves.GetPaint().GetDefIndex());
        SetEntPropFloat(entity, Prop_Send, "m_flFallbackWear", gloves.GetWear());
        SetEntProp(entity, Prop_Send, "m_nFallbackSeed", gloves.GetSeed());
        SetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity", this.GetClientID());
        SetEntPropEnt(entity, Prop_Data, "m_hParent", this.GetClientID());
        SetEntPropEnt(entity, Prop_Data, "m_hMoveParent", this.GetClientID());
        SetEntProp(entity, Prop_Send, "m_bInitialized", 1);

        DispatchSpawn(entity);

        SetEntPropEnt(this.GetClientID(), Prop_Send, "m_hMyWearables", entity);
        SetEntProp(this.GetClientID(), Prop_Send, "m_nBody", 1);
      }

      if (activeWeapon != -1) {
        DataPack pack;
        CreateDataTimer(0.1, GiveGlovesTimer, pack);
        pack.WriteCell(this.GetClientID());
        pack.WriteCell(activeWeapon);
      }
    }
  }
}

Action ReserveAmmoTimer(Handle timer, DataPack pack) {
  pack.Reset();

  int client = GetClientOfUserId(pack.ReadCell());
  int offset = pack.ReadCell();
  int ammo = pack.ReadCell();

  if (client > 0 && IsPlayer(client)) {
    SetEntData(client, offset, ammo, 4, true);
  }

  return Plugin_Continue;
}

Action GiveGlovesTimer(Handle timer, DataPack pack) {
  pack.Reset();

  int client = pack.ReadCell();
  int activeWeapon = pack.ReadCell();

  if (IsPlayer(client) && IsPlayerAlive(client)) {
    SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", activeWeapon);
  }

  return Plugin_Continue;
}
