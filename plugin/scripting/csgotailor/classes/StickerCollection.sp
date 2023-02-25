#if defined _CSGOTAILOR_CLASS_STICKER_COLLECTION_INCLUDED
  #endinput
#endif
#define _CSGOTAILOR_CLASS_STICKER_COLLECTION_INCLUDED

methodmap StickerCollection < ArrayList {
  public StickerCollection(JSON_Array stickers) {
    ArrayList self = new ArrayList();

    char classname[MAX_CLASSNAME_SIZE];
    int length = stickers.Length;
    for (int i = 0; i < length; i++) {
      stickers.GetString(i, classname, sizeof(classname));
      self.Push(Sticker.Get(classname));
    }

    return view_as<StickerCollection>(self);
  }
}
