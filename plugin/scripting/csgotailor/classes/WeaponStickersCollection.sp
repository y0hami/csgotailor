#if defined _CSGOTAILOR_CLASS_WEAPON_STICKERS_COLLECTION_INCLUDED
  #endinput
#endif
#define _CSGOTAILOR_CLASS_WEAPON_STICKERS_COLLECTION_INCLUDED

methodmap WeaponStickersCollection < JSON_Object {
  public WeaponStickersCollection (char[] dbStickerString) {
    JSON_Object self = new JSON_Object();

    char stickers[6][132];
    ExplodeString(dbStickerString, ";", stickers, sizeof(stickers), sizeof(stickers[]));

    for (int i = 0; i < sizeof(stickers); i++) {
      if (!StrEqual(stickers[i], "")) {
        char parts[3][128];
        ExplodeString(stickers[i], ":", parts, sizeof(parts), sizeof(parts[]));

        WeaponSticker sticker = new WeaponSticker(
          StringToInt(parts[0]),
          parts[1],
          StringToFloat(parts[2])
        );

        self.SetObject(parts[0], sticker);
      }
    }

    return view_as<WeaponStickersCollection>(self);
  }

  public bool AsDBString(char[] buffer, int bufferSize) {
    char dbString[MAX_STICKER_DB_STRING_SIZE];

    int length = this.Iterate();
    int keyLength = 0;
    for (int i = 0; i < length; i++) {
      keyLength = this.GetKeySize(i);
      char[] key = new char[keyLength];
      this.GetKey(i, key, keyLength);

      WeaponSticker sticker = view_as<WeaponSticker>(this.GetObject(key));

      char classname[MAX_CLASSNAME_SIZE];
      sticker.GetClassname(classname, sizeof(classname));
      float wear = sticker.GetWear();
      int slot = sticker.GetSlot();

      char part[132];
      Format(part, sizeof(part), ";%d:%s:%f", slot, classname, wear);

      StrCat(dbString, sizeof(dbString), part);
    }

    return strcopy(buffer, bufferSize, dbString) > 0;
  }

  public bool HasSlot(int slot) {
    if (slot < 1 || slot > 5) ThrowError("Invalid sticker slot provided. (slot: %d)", slot);

    char key[4];
    IntToString(slot, key, sizeof(key));

    return this.HasKey(key);
  }

  public WeaponSticker GetSlot(int slot) {
    if (slot < 1 || slot > 5) ThrowError("Invalid sticker slot provided. (slot: %d)", slot);

    char key[4];
    IntToString(slot, key, sizeof(key));

    return view_as<WeaponSticker>(this.GetObject(key));
  }

  public bool SetSlot(int slot, char[] classname, float wear) {
    if (slot < 1 || slot > 5) ThrowError("Invalid sticker slot provided. (slot: %d)", slot);

    char key[4];
    IntToString(slot, key, sizeof(key));

    if (this.HasSlot(slot)) {
      this.GetSlot(slot).Cleanup();
    }

    return this.SetObject(key, new WeaponSticker(slot, classname, wear));
  }

  public bool RemoveSticker(int slot) {
    if (slot < 1 || slot > 5) ThrowError("Invalid sticker slot provided. (slot: %d)", slot);

    char key[4];
    IntToString(slot, key, sizeof(key));

    if (this.HasSlot(slot)) {
      this.GetSlot(slot).Cleanup();
    }

    return this.Remove(key);
  }
}
