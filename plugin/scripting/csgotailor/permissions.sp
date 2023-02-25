#if defined _CSGOTAILOR_PERMISSIONS_INCLUDED
  #endinput
#endif
#define _CSGOTAILOR_PERMISSIONS_INCLUDED

void Setup_Permissions() {
  json_cleanup_and_delete(g_permissions);
  g_permissions = ReadJsonFile(FILE_PATH_PERMISSIONS);
}

bool CheckPermission(int client, char[] permission) {
  char requiredFlagsString[AdminFlags_TOTAL];
  g_permissions.GetString(permission, requiredFlagsString, sizeof(requiredFlagsString));

  if (StrEqual(requiredFlagsString, "")) return true;

  int requiredFlags = ReadFlagString(requiredFlagsString);
  int clientFlags = GetUserFlagBits(client);

  return clientFlags & requiredFlags == requiredFlags;
}

bool CanUseMenu(int client) {
  return CheckPermission(client, "use");
}

/*
  Weapon feature checkers
*/

bool CanUseWeapons(int client) {
  if (!CanUseWeaponsSkin(client)) return false;

  return CanUseWeaponsSkin(client)
      || CanUseWeaponsWear(client)
      || CanUseWeaponsSeed(client)
      || CanUseWeaponsStatTrak(client)
      || CanUseWeaponsStatTrakReset(client)
      || CanUseWeaponsNametag(client)
      || CanUseWeaponsStickers(client);
}

bool CanUseWeaponsSkin(int client) {
  if (!FeatureIsEnabled(FEATURE_WEAPONS)) return false;
  if (!CheckPermission(client, PERMISSION_WEAPONS_SKIN)) return false;
  return true;
}

bool CanUseWeaponsWear(int client) {
  if (!FeatureIsEnabled(FEATURE_WEAPONS)) return false;
  if (!CheckPermission(client, PERMISSION_WEAPONS_WEAR)) return false;
  return true;
}

bool CanUseWeaponsSeed(int client) {
  if (!FeatureIsEnabled(FEATURE_WEAPONS)) return false;
  if (!CheckPermission(client, PERMISSION_WEAPONS_SEED)) return false;
  return true;
}

bool CanUseWeaponsStatTrak(int client) {
  if (!FeatureIsEnabled(FEATURE_WEAPONS)) return false;
  if (!FeatureIsEnabled(FEATURE_STATTRAK)) return false;
  if (!CheckPermission(client, PERMISSION_WEAPONS_STATTRAK)) return false;
  return true;
}

bool CanUseWeaponsStatTrakReset(int client) {
  if (!FeatureIsEnabled(FEATURE_WEAPONS)) return false;
  if (!FeatureIsEnabled(FEATURE_STATTRAK)) return false;
  if (!CheckPermission(client, PERMISSION_WEAPONS_STATTRAK_RESET)) return false;
  return true;
}

bool CanUseWeaponsNametag(int client) {
  if (!FeatureIsEnabled(FEATURE_WEAPONS)) return false;
  if (!FeatureIsEnabled(FEATURE_NAMETAG)) return false;
  if (!CheckPermission(client, PERMISSION_WEAPONS_NAMETAG)) return false;
  return true;
}

bool CanUseWeaponsStickers(int client) {
  if (!FeatureIsEnabled(FEATURE_WEAPONS)) return false;
  if (!FeatureIsEnabled(FEATURE_STICKERS)) return false;
  if (!CheckPermission(client, PERMISSION_WEAPONS_STICKERS)) return false;
  return true;
}


/*
  Knife feature checkers
*/

bool CanUseKnifes(int client) {
  if (!CanUseKnifesChange(client)) return false;

  return CanUseKnifesChange(client)
      || CanUseKnifesSkin(client)
      || CanUseKnifesWear(client)
      || CanUseKnifesSeed(client)
      || CanUseKnifesStatTrak(client)
      || CanUseKnifesStatTrakReset(client)
      || CanUseKnifesNametag(client)
}

bool CanUseKnifesChange(int client) {
  if (!FeatureIsEnabled(FEATURE_KNIFES)) return false;
  if (!CheckPermission(client, PERMISSION_KNIFES_CHANGE)) return false;
  return true;
}

bool CanUseKnifesSkin(int client) {
  if (!FeatureIsEnabled(FEATURE_KNIFES)) return false;
  if (!CheckPermission(client, PERMISSION_KNIFES_SKIN)) return false;
  return true;
}

bool CanUseKnifesWear(int client) {
  if (!FeatureIsEnabled(FEATURE_KNIFES)) return false;
  if (!CheckPermission(client, PERMISSION_KNIFES_WEAR)) return false;
  return true;
}

bool CanUseKnifesSeed(int client) {
  if (!FeatureIsEnabled(FEATURE_KNIFES)) return false;
  if (!CheckPermission(client, PERMISSION_KNIFES_SEED)) return false;
  return true;
}

bool CanUseKnifesStatTrak(int client) {
  if (!FeatureIsEnabled(FEATURE_KNIFES)) return false;
  if (!FeatureIsEnabled(FEATURE_STATTRAK)) return false;
  if (!CheckPermission(client, PERMISSION_KNIFES_STATTRAK)) return false;
  return true;
}

bool CanUseKnifesStatTrakReset(int client) {
  if (!FeatureIsEnabled(FEATURE_KNIFES)) return false;
  if (!FeatureIsEnabled(FEATURE_STATTRAK)) return false;
  if (!CheckPermission(client, PERMISSION_KNIFES_STATTRAK_RESET)) return false;
  return true;
}

bool CanUseKnifesNametag(int client) {
  if (!FeatureIsEnabled(FEATURE_KNIFES)) return false;
  if (!FeatureIsEnabled(FEATURE_NAMETAG)) return false;
  if (!CheckPermission(client, PERMISSION_KNIFES_NAMETAG)) return false;
  return true;
}


/*
  Gloves feature checkers
*/

bool CanUseGloves(int client) {
  if (!CanUseGlovesChange(client)) return false;

  return CanUseGlovesChange(client)
      || CanUseGlovesWear(client)
      || CanUseGlovesSeed(client)
}

bool CanUseGlovesChange(int client) {
  if (!FeatureIsEnabled(FEATURE_GLOVES)) return false;
  if (!CheckPermission(client, PERMISSION_GLOVES_CHANGE)) return false;
  return true;
}

bool CanUseGlovesWear(int client) {
  if (!FeatureIsEnabled(FEATURE_GLOVES)) return false;
  if (!CheckPermission(client, PERMISSION_GLOVES_WEAR)) return false;
  return true;
}

bool CanUseGlovesSeed(int client) {
  if (!FeatureIsEnabled(FEATURE_GLOVES)) return false;
  if (!CheckPermission(client, PERMISSION_GLOVES_SEED)) return false;
  return true;
}


/*
  Agent feature checkers
*/

bool CanUseAgents(int client) {
  if (!CanUseAgentSkin(client)) return false;

  return CanUseAgentSkin(client)
      || CanUseAgentPatches(client)
}

bool CanUseAgentSkin(int client) {
  if (!FeatureIsEnabled(FEATURE_AGENTS)) return false;
  if (!CheckPermission(client, PERMISSION_AGENT_SKIN)) return false;
  return true;
}

bool CanUseAgentPatches(int client) {
  if (!FeatureIsEnabled(FEATURE_AGENTS)) return false;
  if (!FeatureIsEnabled(FEATURE_AGENTS_PATCHES)) return false;
  if (!CheckPermission(client, PERMISSION_AGENT_PATCHES)) return false;
  return true;
}


/*
  Profile feature checkers
*/

bool CanUseProfilePin(int client) {
  if (!FeatureIsEnabled(FEATURE_PROFILE_PIN)) return false;
  if (!CheckPermission(client, PERMISSION_PROFILE_PIN)) return false;
  return true;
}

bool CanUseProfileRank(int client) {
  if (!FeatureIsEnabled(FEATURE_PROFILE_RANK)) return false;
  if (!CheckPermission(client, PERMISSION_PROFILE_RANK)) return false;
  return true;
}

bool CanUseProfileXPLevel(int client) {
  if (!FeatureIsEnabled(FEATURE_PROFILE_XPLEVEL)) return false;
  if (!CheckPermission(client, PERMISSION_PROFILE_XPLEVEL)) return false;
  return true;
}

bool CanUseProfileMusicKit(int client) {
  if (!FeatureIsEnabled(FEATURE_PROFILE_MUSICKIT)) return false;
  if (!CheckPermission(client, PERMISSION_PROFILE_MUSICKIT)) return false;
  return true;
}


/*
  Spray feature checker
*/

bool CanUseSprays(int client) {
  if (!FeatureIsEnabled(FEATURE_SPRAYS)) return false;
  if (!CheckPermission(client, PERMISSION_SPRAYS)) return false;
  return true;
}
