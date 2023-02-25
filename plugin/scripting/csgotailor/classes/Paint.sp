#if defined _CSGOTAILOR_CLASS_PAINT_INCLUDED
  #endinput
#endif
#define _CSGOTAILOR_CLASS_PAINT_INCLUDED

methodmap Paint < Item {
  public static Paint Get(char[] classname) {
    return view_as<Paint>(g_data.GetObject("paints").GetObject(classname));
  }

  public bool HasSeedPresets(char[] classname) {
    return this.HasKey("seeds") &&
      this.GetObject("seeds").HasKey(classname);
  }
}
