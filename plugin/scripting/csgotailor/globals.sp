#if defined _CSGOTAILOR_GLOBALS_INCLUDED
  #endinput
#endif
#define _CSGOTAILOR_GLOBALS_INCLUDED

Database g_database;
JSON_Object g_players[MAX_PLAYERS];
JSON_Object g_data;
JSON_Object g_defIndexMap;
JSON_Object g_permissions;
JSON_Object g_config;
ArrayList g_AliasCommands;
bool g_waitingForWearValue[MAX_PLAYERS] = { false, ... };
bool g_waitingForSeedValue[MAX_PLAYERS] = { false, ... };
bool g_waitingForNametagValue[MAX_PLAYERS] = { false, ... };
bool g_waitingForSearchValue[MAX_PLAYERS] = { false, ... };

// sdk globals
enum ServerPlatform {
	OS_Unknown = 0,
	OS_Windows,
	OS_Linux,
	OS_Mac
}
ServerPlatform gsdk_ServerPlatform;

Address gsdk_pItemSystem = Address_Null;
Address gsdk_pItemSchema = Address_Null;

Handle gsdk_SDKAddAttribute = null;
Handle gsdk_SDKGenerateAttribute = null;
Handle gsdk_SDKGetAttributeDefinitionByName = null;

int gsdk_networkedDynamicAttributesOffset = -1;
int gsdk_attributeListReadOffset = -1;
int gsdk_attributeListCountOffset = -1;
int gsdk_econItemOffset = -1;
