#if defined _CSGOTAILOR_CLASS_PAINT_COLLECTION_INCLUDED
  #endinput
#endif
#define _CSGOTAILOR_CLASS_PAINT_COLLECTION_INCLUDED

methodmap PaintCollection < ArrayList {
  public PaintCollection(JSON_Array paints) {
    ArrayList self = new ArrayList();

    char classname[MAX_CLASSNAME_SIZE];
    int length = paints.Length;
    for (int i = 0; i < length; i++) {
      paints.GetString(i, classname, sizeof(classname));

      self.Push(Paint.Get(classname));
    }

    return view_as<PaintCollection>(self);
  }
}
