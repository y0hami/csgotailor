#if defined _CSGOTAILOR_CLASS_ITEM_INCLUDED
  #endinput
#endif
#define _CSGOTAILOR_CLASS_ITEM_INCLUDED

methodmap Item < JSON_Object {
  public int GetDefIndex() {
    return this.GetInt("defIndex");
  }

  public bool GetClassname(char[] buffer, int bufferSize) {
    return this.GetString("classname", buffer, bufferSize);
  }

  public bool GetName(char[] buffer, int bufferSize) {
    return this.GetString("name", buffer, bufferSize);
  }
}
