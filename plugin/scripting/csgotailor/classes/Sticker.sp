#if defined _CSGOTAILOR_CLASS_STICKER_INCLUDED
  #endinput
#endif
#define _CSGOTAILOR_CLASS_STICKER_INCLUDED

methodmap Sticker < Item {
  public static Sticker Get(char[] classname) {
    return view_as<Sticker>(g_data.GetObject("stickers").GetObject("stickers").GetObject(classname));
  }
}
