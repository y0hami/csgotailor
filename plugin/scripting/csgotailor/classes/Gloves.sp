#if defined _CSGOTAILOR_CLASS_GLOVES_INCLUDED
  #endinput
#endif
#define _CSGOTAILOR_CLASS_GLOVES_INCLUDED

methodmap Gloves < JSON_Object {
  public static Gloves Get(char[] classname) {
    return view_as<Gloves>(g_data.GetObject("gloves").GetObject(classname));
  }

  public int GetDefIndex() {
    return this.GetInt("defIndex");
  }

  public bool GetClassname(char[] buffer, int bufferSize) {
    return this.GetString("classname", buffer, bufferSize);
  }

  public bool GetName(char[] buffer, int bufferSize) {
    return this.GetString("name", buffer, bufferSize);
  }

  public PaintCollection GetPaints() {
    return new PaintCollection(view_as<JSON_Array>(this.GetObject("paints")));
  }
}
