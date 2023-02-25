#if defined _CSGOTAILOR_DATA_INCLUDED
  #endinput
#endif
#define _CSGOTAILOR_DATA_INCLUDED

void Setup_Data() {
  json_cleanup_and_delete(g_data);
  g_data = ReadJsonFile(FILE_PATH_DATA);

  PrintToServer("");
  PrintToServer(" CS:GO Tailor");
  PrintToServer("");
  PrintToServer(" Loaded data:");
  PrintToServer("  Weapons: %d", g_data.GetObject("weapons").Iterate());
  PrintToServer("  Knifes: %d", g_data.GetObject("knifes").Iterate());
  PrintToServer("  Gloves: %d", g_data.GetObject("gloves").Iterate());
  PrintToServer("  Paints: %d", g_data.GetObject("paints").Iterate());
  PrintToServer("  Stickers: %d", g_data.GetObject("stickers").GetObject("stickers").Iterate());
  PrintToServer("  Agent Models: %d", g_data.GetObject("agents").Iterate());
  PrintToServer("  Agent Patches: %d", g_data.GetObject("patches").GetObject("patches").Iterate());
  PrintToServer("  Music Kits: %d", g_data.GetObject("music_kits").Iterate());
  PrintToServer("  Pins: %d", g_data.GetObject("pins").Iterate());
  PrintToServer("  Ranks: %d", g_data.GetObject("ranks").Iterate());
  PrintToServer("  XP Levels: %d", g_data.GetObject("xp_levels").Iterate());
  PrintToServer("  Sprays: %d", g_data.GetObject("sprays").Iterate());
  PrintToServer("");

  json_cleanup_and_delete(g_config);
  g_config = ReadJsonFile(FILE_PATH_CONFIG);

  json_cleanup_and_delete(g_defIndexMap);
  g_defIndexMap = new JSON_Object();

  JSON_Object obj = g_data.GetObject("weapons");
  int length = obj.Iterate();
  int keyLength = 0;
  char classname[MAX_CLASSNAME_SIZE];
  char defIndex[12];

  for (int i = 0; i < length; i++) {
    keyLength = obj.GetKeySize(i);
    char[] key = new char[keyLength];
    obj.GetKey(i, key, keyLength);

    obj.GetObject(key).GetString("classname", classname, sizeof(classname));
    IntToString(obj.GetObject(key).GetInt("defIndex"), defIndex, sizeof(defIndex));

    g_defIndexMap.SetString(defIndex, classname);
  }

  obj = g_data.GetObject("knifes");
  length = obj.Iterate();
  for (int i = 0; i < length; i++) {
    keyLength = obj.GetKeySize(i);
    char[] key = new char[keyLength];
    obj.GetKey(i, key, keyLength);

    obj.GetObject(key).GetString("classname", classname, sizeof(classname));
    IntToString(obj.GetObject(key).GetInt("defIndex"), defIndex, sizeof(defIndex));

    g_defIndexMap.SetString(defIndex, classname);
  }

  obj = g_data.GetObject("gloves");
  length = obj.Iterate();
  for (int i = 0; i < length; i++) {
    keyLength = obj.GetKeySize(i);
    char[] key = new char[keyLength];
    obj.GetKey(i, key, keyLength);

    obj.GetObject(key).GetString("classname", classname, sizeof(classname));
    IntToString(obj.GetObject(key).GetInt("defIndex"), defIndex, sizeof(defIndex));

    g_defIndexMap.SetString(defIndex, classname);
  }

  g_defIndexMap.WriteToFile("defIndexMap.json", JSON_ENCODE_PRETTY);
}
