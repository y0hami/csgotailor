#if defined _CSGOTAILOR_CLASS_PLAYER_KNIFE_INCLUDED
  #endinput
#endif
#define _CSGOTAILOR_CLASS_PLAYER_KNIFE_INCLUDED

methodmap PlayerKnife < Knife {
  public static PlayerKnife ChangeType(
    int client,
    char[] teamKey,
    char[] classname
  ) {
    Player player = Player.Get(client);

    if (player.HasKnife(teamKey)) {
      player.GetKnife(teamKey).Cleanup();
    }

    PlayerKnife knife = new PlayerKnife(
      client,
      teamKey,
      classname,
      "DEFAULT",
      0.00,
      RandomSeed(),
      false,
      0,
      ""
    );

    player.GetObject("knifes").SetObject(teamKey, knife);
    knife.Update();
    player.RefreshItem(classname);

    return knife;
  }

  public PlayerKnife(
    int client,
    char[] teamKey,
    char[] classname,
    char[] paintClassname,
    float wear,
    int seed,
    bool stattrakEnabled,
    int stattrakCount,
    char[] nametag
  ) {
    PlayerKnife self = view_as<PlayerKnife>(Knife.Get(classname).DeepCopy());

    self.SetInt("clientId", client);
    self.SetString("team", teamKey);
    self.SetString("paintClassname", paintClassname);
    self.SetFloat("wear", wear);
    self.SetInt("seed", seed);
    self.SetBool("stattrakEnabled", stattrakEnabled);
    self.SetInt("stattrakCount", stattrakCount);
    self.SetString("nametag", nametag);

    return view_as<PlayerKnife>(self);
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

    player.GetSteamID(steamId, sizeof(steamId));
    this.GetTeam(teamKey, sizeof(teamKey));
    this.GetClassname(classname, sizeof(classname));
    this.GetPaint().GetClassname(paintClassname, sizeof(paintClassname));
    this.GetNametag(nametag, sizeof(nametag));

    DBStatement stmt = DB_Query("\
    INSERT INTO csgotailor_knifes \
      (steamId, team, classname, paint, wear, seed, stattrak, stattrakCount, nametag) \
      VALUES \
      (?, ?, ?, ?, ?, ?, ?, ?, ?) \
    ON DUPLICATE KEY UPDATE \
      classname       = VALUES(classname), \
      paint           = VALUES(paint), \
      wear            = VALUES(wear), \
      seed            = VALUES(seed), \
      stattrak        = VALUES(stattrak), \
      stattrakCount   = VALUES(stattrakCount), \
      nametag         = VALUES(nametag); \
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

    return DB_Execute(stmt);
  }

  public bool Delete() {
    Player player = Player.Get(this.GetClientID());

    char steamId[MAX_STEAMID_SIZE];
    char teamKey[MAX_TEAM_KEY_SIZE];

    player.GetSteamID(steamId, sizeof(steamId));
    this.GetTeam(teamKey, sizeof(teamKey));

    player.GetObject("knifes").GetObject(teamKey).Cleanup();
    player.GetObject("knifes").Remove(teamKey);

    DBStatement stmt = DB_Query("\
    DELETE FROM csgotailor_knifes \
      WHERE \
        steamId = ? \
        AND \
        team = ? ");
    DB_BindString(stmt, 0, steamId);
    DB_BindString(stmt, 1, teamKey);

    DB_Execute(stmt)
    return player.RefreshItem("weapon_knife");
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
}
