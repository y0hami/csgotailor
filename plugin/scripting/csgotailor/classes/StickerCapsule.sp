#if defined _CSGOTAILOR_CLASS_STICKER_CAPSULE_INCLUDED
  #endinput
#endif
#define _CSGOTAILOR_CLASS_STICKER_CAPSULE_INCLUDED

methodmap StickerCapsule < Item {
  public static StickerCapsule Get(char[] classname) {
    return view_as<StickerCapsule>(g_data.GetObject("stickers").GetObject("capsules").GetObject(classname));
  }

  public StickerCollection GetStickers() {
    return new StickerCollection(view_as<JSON_Array>(this.GetObject("stickers")));
  }
}
