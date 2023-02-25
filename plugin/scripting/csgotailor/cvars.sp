#if defined _CSGOTAILOR_CVARS_INCLUDED
  #endinput
#endif
#define _CSGOTAILOR_CVARS_INCLUDED

ConVar g_ConVar_DatabaseConfigName;
ConVar g_ConVar_MessagePrefix;

void Setup_ConVars() {
  g_ConVar_DatabaseConfigName = CreateConVar("sm_csgotailor_database", "csgotailor", "The database configuration to use");
  g_ConVar_MessagePrefix = CreateConVar("sm_csgotailor_prefix", DEFAULT_PREFIX, "Chat message prefix");

  AutoExecConfig(true, "csgotailor");
}
