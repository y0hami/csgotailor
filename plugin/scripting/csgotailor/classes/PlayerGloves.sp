#if defined _CSGOTAILOR_CLASS_PLAYER_GLOVES_INCLUDED
  #endinput
#endif
#define _CSGOTAILOR_CLASS_PLAYER_GLOVES_INCLUDED

methodmap PlayerGloves < Item {
  public static PlayerGloves Change(
    int client,
    char[] teamKey,
    char[] classname,
    char[] paintClassname
  ) {
    Player player = Player.Get(client);

    if (player.HasGloves(teamKey)) {
      player.GetGloves(teamKey).Cleanup();
    }

    PlayerGloves gloves = new PlayerGloves(
      client,
      teamKey,
      classname,
      paintClassname,
      0.00,
      RandomSeed()
    );

    player.GetObject("gloves").SetObject(teamKey, gloves);
    gloves.Update();

    return gloves;
  }

  public PlayerGloves(
    int client,
    char[] teamKey,
    char[] classname,
    char[] paintClassname,
    float wear,
    int seed
  ) {
    PlayerGloves self = view_as<PlayerGloves>(Gloves.Get(classname).DeepCopy());

    self.SetInt("clientId", client);
    self.SetString("team", teamKey);
    self.SetString("paintClassname", paintClassname);
    self.SetFloat("wear", wear);
    self.SetInt("seed", seed);

    return view_as<PlayerGloves>(self);
  }

  public int GetClientID() {
    return this.GetInt("clientId");
  }

  public bool Update() {
    this.SyncDB();
    return Player.Get(this.GetClientID()).GiveGloves();
  }

  public bool SyncDB() {
    Player player = Player.Get(this.GetClientID());

    char steamId[MAX_STEAMID_SIZE];
    char teamKey[MAX_TEAM_KEY_SIZE];
    char classname[MAX_CLASSNAME_SIZE];
    char paintClassname[MAX_CLASSNAME_SIZE];

    player.GetSteamID(steamId, sizeof(steamId));
    this.GetTeam(teamKey, sizeof(teamKey));
    this.GetClassname(classname, sizeof(classname));
    this.GetPaint().GetClassname(paintClassname, sizeof(paintClassname));

    DBStatement stmt = DB_Query("\
    INSERT INTO csgotailor_gloves \
      (steamId, team, classname, paint, wear, seed) \
      VALUES \
      (?, ?, ?, ?, ?, ?) \
    ON DUPLICATE KEY UPDATE \
      classname     = VALUES(classname), \
      paint         = VALUES(paint), \
      wear          = VALUES(wear), \
      seed          = VALUES(seed); \
    ");

    DB_BindString(stmt, 0, steamId);
    DB_BindString(stmt, 1, teamKey);
    DB_BindString(stmt, 2, classname);
    DB_BindString(stmt, 3, paintClassname);
    DB_BindFloat(stmt, 4, this.GetWear());
    DB_BindInt(stmt, 5, this.GetSeed());

    return DB_Execute(stmt);
  }

  public bool Delete() {
    Player player = Player.Get(this.GetClientID());

    char steamId[MAX_STEAMID_SIZE];
    char teamKey[MAX_TEAM_KEY_SIZE];

    player.GetSteamID(steamId, sizeof(steamId));
    this.GetTeam(teamKey, sizeof(teamKey));

    player.GetObject("gloves").GetObject(teamKey).Cleanup();
    player.GetObject("gloves").Remove(teamKey);

    DBStatement stmt = DB_Query("\
    DELETE FROM csgotailor_gloves \
      WHERE \
        steamId = ? \
        AND \
        team = ? ");
    DB_BindString(stmt, 0, steamId);
    DB_BindString(stmt, 1, teamKey);

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
}
