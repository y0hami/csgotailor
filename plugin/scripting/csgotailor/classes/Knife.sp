#if defined _CSGOTAILOR_CLASS_KNIFE_INCLUDED
  #endinput
#endif
#define _CSGOTAILOR_CLASS_KNIFE_INCLUDED

methodmap Knife < Item {
  public static Knife Get(char[] classname) {
    return view_as<Knife>(g_data.GetObject("knifes").GetObject(classname));
  }

  public PaintCollection GetPaints() {
    return new PaintCollection(view_as<JSON_Array>(this.GetObject("paints")));
  }
}
