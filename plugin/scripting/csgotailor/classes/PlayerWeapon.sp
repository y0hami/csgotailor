#if defined _CSGOTAILOR_CLASS_PLAYER_WEAPON_INCLUDED
  #endinput
#endif
#define _CSGOTAILOR_CLASS_PLAYER_WEAPON_INCLUDED

methodmap PlayerWeapon < Weapon {
  public static PlayerWeapon ChangePaint(
    int client,
    char[] teamKey,
    char[] classname,
    char[] paintClassname
  ) {
    Player player = Player.Get(client);

    PlayerWeapon weapon;

    if (player.HasWeapon(teamKey, classname)) {
      weapon = player.GetWeapon(teamKey, classname);
      weapon.SetPaint(paintClassname);
    } else {
      weapon = new PlayerWeapon(
        client,
        teamKey,
        classname,
        paintClassname,
        0.00,
        RandomSeed(),
        false,
        0,
        "",
        new WeaponStickersCollection("")
      );

      player.GetObject("weapons").GetObject(teamKey).SetObject(classname, weapon);
      weapon.Update();
    }

    return weapon;
  }

  public PlayerWeapon(
    int client,
    char[] teamKey,
    char[] classname,
    char[] paintClassname,
    float wear,
    int seed,
    bool stattrakEnabled,
    int stattrakCount,
    char[] nametag,
    WeaponStickersCollection stickers
  ) {
    PlayerWeapon self = view_as<PlayerWeapon>(Weapon.Get(classname).DeepCopy());

    self.SetInt("clientId", client);
    self.SetString("team", teamKey);
    self.SetString("paintClassname", paintClassname);
    self.SetFloat("wear", wear);
    self.SetInt("seed", seed);
    self.SetBool("stattrakEnabled", stattrakEnabled);
    self.SetInt("stattrakCount", stattrakCount);
    self.SetString("nametag", nametag);
    self.SetObject("stickers", stickers);

    return view_as<PlayerWeapon>(self);
  }

  public int GetClientID() {
    return this.GetInt("clientId");
  }

  public bool Update(bool refresh = true) {
    this.SyncDB();

    char classname[MAX_CLASSNAME_SIZE];
    this.GetClassname(classname, sizeof(classname));

    return refresh ? Player.Get(this.GetClientID()).RefreshItem(classname) : true;
  }

  public bool SyncDB() {
    Player player = Player.Get(this.GetClientID());

    char steamId[MAX_STEAMID_SIZE];
    char teamKey[MAX_TEAM_KEY_SIZE];
    char classname[MAX_CLASSNAME_SIZE];
    char paintClassname[MAX_CLASSNAME_SIZE];
    char nametag[MAX_NAMETAG_SIZE];
    char stickersString[MAX_STICKER_DB_STRING_SIZE];

    player.GetSteamID(steamId, sizeof(steamId));
    this.GetTeam(teamKey, sizeof(teamKey));
    this.GetClassname(classname, sizeof(classname));
    this.GetPaint().GetClassname(paintClassname, sizeof(paintClassname));
    this.GetNametag(nametag, sizeof(nametag));
    this.GetStickers().AsDBString(stickersString, sizeof(stickersString));

    DBStatement stmt = DB_Query("\
    INSERT INTO csgotailor_weapons \
      (steamId, team, classname, paint, wear, seed, stattrak, stattrakCount, nametag, stickers) \
      VALUES \
      (?, ?, ?, ?, ?, ?, ?, ?, ?, ?) \
    ON DUPLICATE KEY UPDATE \
      paint           = VALUES(paint), \
      wear            = VALUES(wear), \
      seed            = VALUES(seed), \
      stattrak        = VALUES(stattrak), \
      stattrakCount   = VALUES(stattrakCount), \
      nametag         = VALUES(nametag), \
      stickers        = VALUES(stickers); \
    ");

    DB_BindString(stmt, 0, steamId);
    DB_BindString(stmt, 1, teamKey);
    DB_BindString(stmt, 2, classname);
    DB_BindString(stmt, 3, paintClassname);
    DB_BindFloat(stmt, 4, this.GetWear());
    DB_BindInt(stmt, 5, this.GetSeed());
    DB_BindInt(stmt, 6, this.IsStatTrakEnabled() ? 1 : 0);
    DB_BindInt(stmt, 7, this.GetStatTrakCount());
    DB_BindString(stmt, 8, nametag);
    DB_BindString(stmt, 9, stickersString);

    return DB_Execute(stmt);
  }

  public bool Delete() {
    Player player = Player.Get(this.GetClientID());

    char steamId[MAX_STEAMID_SIZE];
    char teamKey[MAX_TEAM_KEY_SIZE];
    char classname[MAX_CLASSNAME_SIZE];

    player.GetSteamID(steamId, sizeof(steamId));
    this.GetTeam(teamKey, sizeof(teamKey));
    this.GetClassname(classname, sizeof(classname));

    player.GetObject("weapons").GetObject(teamKey).GetObject(classname).Cleanup();
    player.GetObject("weapons").GetObject(teamKey).Remove(classname);

    DBStatement stmt = DB_Query("\
    DELETE FROM csgotailor_weapons \
      WHERE \
        steamId = ? \
        AND \
        classname = ? \
        AND \
        team = ? ");
    DB_BindString(stmt, 0, steamId);
    DB_BindString(stmt, 1, classname);
    DB_BindString(stmt, 2, teamKey);

    return DB_Execute(stmt);
  }

  public bool GetTeam(char[] buffer, int bufferSize) {
    return this.GetString("team", buffer, bufferSize);
  }

  public Paint GetPaint() {
    char paintClassname[MAX_CLASSNAME_SIZE];
    this.GetString("paintClassname", paintClassname, sizeof(paintClassname));
    return Paint.Get(paintClassname);
  }

  public bool SetPaint(char[] paintClassname) {
    this.SetString("paintClassname", paintClassname);
    return this.Update();
  }

  public float GetWear() {
    return this.GetFloat("wear");
  }

  public bool SetWear(float wear) {
    this.SetFloat("wear", wear);
    return this.Update();
  }

  public int GetSeed() {
    return this.GetInt("seed");
  }

  public bool SetSeed(int seed) {
    this.SetInt("seed", seed);
    return this.Update();
  }

  public bool IsStatTrakEnabled() {
    return this.GetBool("stattrakEnabled");
  }

  public bool SetStatTrak(bool enabled) {
    this.SetBool("stattrakEnabled", enabled);
    return this.Update();
  }

  public int GetStatTrakCount() {
    return this.GetInt("stattrakCount", 0);
  }

  public bool SetStatTrakCount(int count, bool refresh = false) {
    this.SetInt("stattrakCount", count);
    return this.Update(refresh);
  }

  public bool ResetStatTrakCount() {
    return this.SetStatTrakCount(0);
  }

  public bool GetNametag(char[] buffer, int bufferSize) {
    return this.GetString("nametag", buffer, bufferSize);
  }

  public bool SetNametag(char[] nametag) {
    this.SetString("nametag", nametag);
    return this.Update();
  }

  public bool HasNametag() {
    char nametag[MAX_NAMETAG_SIZE];
    this.GetNametag(nametag, sizeof(nametag));

    return !StrEqual(nametag, "");
  }

  public WeaponStickersCollection GetStickers() {
    WeaponStickersCollection stickers;
    this.GetValue("stickers", stickers);
    return stickers;
  }

  public bool HasStickers() {
    return this.HasSticker(1) ||
      this.HasSticker(2) ||
      this.HasSticker(3) ||
      this.HasSticker(4) ||
      this.HasSticker(5)
  }

  public WeaponSticker GetSticker(int slot) {
    return this.GetStickers().GetSlot(slot);
  }

  public bool HasSticker(int slot) {
    return this.GetStickers().HasSlot(slot);
  }

  public bool RemoveSticker(int slot) {
    this.GetStickers().RemoveSticker(slot);
    return this.Update();
  }

  public bool SetSticker(int slot, char[] classname, float wear) {
    this.GetStickers().SetSlot(slot, classname, wear);
    return this.Update();
  }

  public bool SetStickerWear(int slot, float wear) {
    this.GetStickers().GetSlot(slot).SetWear(wear);
    return this.Update();
  }
}
