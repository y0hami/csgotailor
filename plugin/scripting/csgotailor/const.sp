#if defined _CSGOTAILOR_CONST_INCLUDED
  #endinput
#endif
#define _CSGOTAILOR_CONST_INCLUDED

// include the version definition, this is in a separate file so we can
// replace it from the global version file when compiling the plugin.
#include "version.sp"

#define DEFAULT_PREFIX          "[{LIGHT_GREEN}CS:GO Tailor{NORMAL}]"
#define MAX_PLAYERS             MAXPLAYERS + 1
#define FILE_PATH_DATA          "data/csgotailor/data.json"
#define FILE_PATH_CONFIG        "configs/csgotailor/config.json"
#define FILE_PATH_PERMISSIONS   "configs/csgotailor/permissions.json"

// char size constants
#define MAX_FILEPATH_SIZE               255
#define MAX_ERROR_SIZE                  255
#define MAX_ALIAS_COMMMAND_SIZE         64
#define MAX_STEAMID_SIZE                128
#define MAX_MENU_ITEM_SIZE              64
#define MAX_MENU_TITLE_SIZE             64
#define MAX_TEAM_KEY_SIZE               8
#define MAX_TEAM_NAME_SIZE              128
#define MAX_WEAPON_NAME_SIZE            128
#define MAX_KNIFE_NAME_SIZE             128
#define MAX_GLOVES_NAME_SIZE            128
#define MAX_STICKER_NAME_SIZE           128
#define MAX_STICKER_CAPSULE_NAME_SIZE   128
#define MAX_CLASSNAME_SIZE              255
#define MAX_NAMETAG_SIZE                20
#define MAX_PAINT_NAME_SIZE             128
#define MAX_WEAR_NAME_SIZE              32
#define MAX_WEAR_KEY_SIZE               8
#define MAX_MENU_KEY_SIZE               64
#define MAX_STICKER_DB_STRING_SIZE      660
#define MAX_STICKER_TEAM_KEY_SIZE       64
#define MAX_STICKER_TEAM_NAME_SIZE      128
#define MAX_STICKER_PLAYER_CODE_SIZE    64
#define MAX_STICKER_PLAYER_NAME_SIZE    128
#define MAX_STICKER_GEO_SIZE            4

// features
#define FEATURE_WEAPONS             "weapons"
#define FEATURE_KNIFES              "knifes"
#define FEATURE_GLOVES              "gloves"
#define FEATURE_STATTRAK            "stattrak"
#define FEATURE_NAMETAG             "nametag"
#define FEATURE_STICKERS            "stickers"
#define FEATURE_SPRAYS              "sprays"
#define FEATURE_AGENTS              "agents"
#define FEATURE_AGENTS_PATCHES      "agents.patches"
#define FEATURE_PROFILE_PIN         "profile.pin"
#define FEATURE_PROFILE_RANK        "profile.rank"
#define FEATURE_PROFILE_XPLEVEL     "profile.xplevel"
#define FEATURE_PROFILE_MUSICKIT    "profile.musickit"

// permissions
#define PERMISSION_USE                      "use"
#define PERMISSION_WEAPONS_SKIN             "weapons.skin"
#define PERMISSION_WEAPONS_WEAR             "weapons.wear"
#define PERMISSION_WEAPONS_SEED             "weapons.seed"
#define PERMISSION_WEAPONS_STATTRAK         "weapons.stattrak"
#define PERMISSION_WEAPONS_STATTRAK_RESET   "weapons.stattrak.reset"
#define PERMISSION_WEAPONS_NAMETAG          "weapons.nametag"
#define PERMISSION_WEAPONS_STICKERS         "weapons.stickers"
#define PERMISSION_KNIFES_CHANGE            "knifes.change"
#define PERMISSION_KNIFES_SKIN              "knifes.skin"
#define PERMISSION_KNIFES_WEAR              "knifes.wear"
#define PERMISSION_KNIFES_SEED              "knifes.seed"
#define PERMISSION_KNIFES_STATTRAK          "knifes.stattrak"
#define PERMISSION_KNIFES_STATTRAK_RESET    "knifes.stattrak.reset"
#define PERMISSION_KNIFES_NAMETAG           "knifes.nametag"
#define PERMISSION_GLOVES_CHANGE            "gloves.change"
#define PERMISSION_GLOVES_WEAR              "gloves.wear"
#define PERMISSION_GLOVES_SEED              "gloves.seed"
#define PERMISSION_AGENT_SKIN               "agent.skin"
#define PERMISSION_AGENT_PATCHES            "agent.patches"
#define PERMISSION_PROFILE_PIN              "profile.pin"
#define PERMISSION_PROFILE_RANK             "profile.rank"
#define PERMISSION_PROFILE_XPLEVEL          "profile.xplevel"
#define PERMISSION_PROFILE_MUSICKIT         "profile.musickit"
#define PERMISSION_SPRAYS                   "sprays"

// teams
#define TEAM_T      "T"
#define TEAM_CT     "CT"
#define TEAM_BOTH   "BOTH"

// menu types
#define MENU_TYPE_WEAPONS           "WEAPONS"
#define MENU_TYPE_KNIFE             "KNIFE"
#define MENU_TYPE_GLOVES            "GLOVES"
#define MENU_TYPE_STICKER_SEARCH    "STICKER_SEARCH"
