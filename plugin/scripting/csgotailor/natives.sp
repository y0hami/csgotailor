#if defined _CSGOTAILOR_NATIVES_INCLUDED
  #endinput
#endif
#define _CSGOTAILOR_NATIVES_INCLUDED

static char __ColorNames[][] = {
  "{NORMAL}", "{DARK_RED}",    "{PINK}",      "{GREEN}",
  "{YELLOW}", "{LIGHT_GREEN}", "{LIGHT_RED}", "{GRAY}",
  "{ORANGE}", "{LIGHT_BLUE}",  "{DARK_BLUE}", "{PURPLE}"
};

static char __ColorCodes[][] = {
  "\x01", "\x02", "\x03", "\x04",
  "\x05", "\x06", "\x07", "\x08",
  "\x09", "\x0B", "\x0C", "\x0E"
};

void Colorize(char[] msg, int size, bool stripColor = false) {
  for (int i = 0; i < sizeof(__ColorNames); i++) {
    if (stripColor) {
      ReplaceString(msg, size, __ColorNames[i], "");
    } else {
      ReplaceString(msg, size, __ColorNames[i], __ColorCodes[i]);
    }
  }
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) {
  CreateNative("CST_Message", Native_Message);
  CreateNative("CST_MessageToAll", Native_MessageToAll);

  MarkNativeAsOptional("MemoryBlock.MemoryBlock");
  MarkNativeAsOptional("MemoryBlock.Address.get");

  RegPluginLibrary("csgotailor");
  return APLRes_Success;
}

public int Native_Message(Handle plugin, int numParams) {
  int client = GetNativeCell(1);
  if (client != 0 && (!IsClientConnected(client) || !IsClientInGame(client))) {
    return 0;
  }

  char buffer[1024];
  int bytesWritten = 0;
  SetGlobalTransTarget(client);
  FormatNativeString(0, 2, 3, sizeof(buffer), bytesWritten, buffer);

  char prefix[64];
  g_ConVar_MessagePrefix.GetString(prefix, sizeof(prefix));

  char finalMsg[1024];
  if (StrEqual(prefix, "")) {
    Format(finalMsg, sizeof(finalMsg), " %s", buffer);
  } else {
    Format(finalMsg, sizeof(finalMsg), "%s %s", prefix, buffer);
  }

  if (client == 0) {
    Colorize(finalMsg, sizeof(finalMsg), true);
    PrintToConsole(client, finalMsg);
  } else if (IsClientInGame(client)) {
    Colorize(finalMsg, sizeof(finalMsg));
    PrintToChat(client, finalMsg);
  }

  return 0;
}

public int Native_MessageToAll(Handle plugin, int numParams) {
  char prefix[64];
  g_ConVar_MessagePrefix.GetString(prefix, sizeof(prefix));
  char buffer[1024];
  int bytesWritten = 0;

  for (int i = 0; i <= MaxClients; i++) {
    if (i != 0 && (!IsClientConnected(i) || !IsClientInGame(i))) {
      continue;
    }

    SetGlobalTransTarget(i);
    FormatNativeString(0, 1, 2, sizeof(buffer), bytesWritten, buffer);

    char finalMsg[1024];
    if (StrEqual(prefix, "")) {
      Format(finalMsg, sizeof(finalMsg), " %s", buffer);
    } else {
      Format(finalMsg, sizeof(finalMsg), "%s %s", prefix, buffer);
    }

    if (i != 0) {
      Colorize(finalMsg, sizeof(finalMsg));
      PrintToChat(i, finalMsg);
    } else {
      Colorize(finalMsg, sizeof(finalMsg), false);
      PrintToConsole(i, finalMsg);
    }
  }

  return 0;
}
