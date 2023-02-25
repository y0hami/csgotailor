#if defined _CSGOTAILOR_CLASS_WEAPON_INCLUDED
  #endinput
#endif
#define _CSGOTAILOR_CLASS_WEAPON_INCLUDED

methodmap Weapon < Item {
  public static Weapon Get(char[] classname) {
    return view_as<Weapon>(g_data.GetObject("weapons").GetObject(classname));
  }

  public bool GetTeam(char[] buffer, int bufferSize) {
    char team[MAX_TEAM_KEY_SIZE];
    this.GetString("team", team, sizeof(team));

    if (StrEqual(team, "T")) return strcopy(buffer, bufferSize, TEAM_T) > 0;
    if (StrEqual(team, "CT")) return strcopy(buffer, bufferSize, TEAM_CT) > 0;
    if (StrEqual(team, "BOTH")) return strcopy(buffer, bufferSize, TEAM_BOTH) > 0;
    return false;
  }

  public void GetTeamName(char[] buffer, int bufferSize) {
    char teamKey[MAX_TEAM_KEY_SIZE];
    this.GetTeam(teamKey, sizeof(teamKey));
    TeamKeyToName(teamKey, buffer, bufferSize);
  }

  public bool TeamCanUse(char[] teamKey) {
    char weaponTeam[MAX_TEAM_KEY_SIZE];
    this.GetTeam(weaponTeam, sizeof(weaponTeam));

    if (StrEqual(weaponTeam, TEAM_BOTH)) return true;
    return StrEqual(weaponTeam, teamKey);
  }

  public int GetStickerSlots() {
    return this.GetInt("stickerSlots");
  }

  public PaintCollection GetPaints() {
    return new PaintCollection(view_as<JSON_Array>(this.GetObject("paints")));
  }
}
