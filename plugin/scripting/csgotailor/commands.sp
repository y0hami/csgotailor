#if defined _CSGOTAILOR_COMMANDS_INCLUDED
  #endinput
#endif
#define _CSGOTAILOR_COMMANDS_INCLUDED

void Setup_Commands() {
  RegConsoleCmd("sm_tailor", Command_Tailor, "Open the tailor menu");
  RegConsoleCmd("sm_dump", Command_Dump, "Dump client data");

  // server commands
  RegConsoleCmd("cst_reload_data", Command_Console_ReloadData, "Reload data file");

  g_AliasCommands = new ArrayList();
  JSON_Array aliases = view_as<JSON_Array>(g_config.GetObject("commandAliases"));

  int length = aliases.Length;
  char command[MAX_ALIAS_COMMMAND_SIZE];
  for (int i = 0; i < length; i++) {
    aliases.GetString(i, command, sizeof(command));
    g_AliasCommands.PushString(command);

    char smCommand[255];
    Format(smCommand, sizeof(smCommand), "sm_%s", command);
    RegConsoleCmd(smCommand, Command_Tailor, "Alias command for sm_tailor");
  }
}

public Action Command_Tailor(int client, int args) {
  if (!CanUseMenu(client)) {
    CST_Message(client, "You don't have permission to use that command.");
    return Plugin_Handled;
  }

  Player.Get(client).OpenMenu(CreateMenu_Main(client));
  return Plugin_Handled;
}

public Action Command_Dump(int client, int args) {
  Player player = Player.Get(client);

  char path[MAX_FILEPATH_SIZE];
  GetFullPath("data/csgotailor/dumps/client.json", path, sizeof(path));

  player.WriteToFile(path, JSON_ENCODE_PRETTY);

  return Plugin_Handled;
}

public Action Command_Console_ReloadData(int client, int args) {
  Setup_Data();
  CST_Message(client, "Data reloaded.");
  return Plugin_Handled;
}
