#if defined _CSGOTAILOR_CLASS_WEAPON_STICKER_INCLUDED
  #endinput
#endif
#define _CSGOTAILOR_CLASS_WEAPON_STICKER_INCLUDED

methodmap WeaponSticker < Sticker {
  public WeaponSticker (int slot, char[] classname, float wear) {
    JSON_Object self = view_as<JSON_Object>(Sticker.Get(classname).DeepCopy());

    self.SetInt("slot", slot);
    self.SetFloat("wear", wear);

    return view_as<WeaponSticker>(self);
  }

  public float GetWear() {
    return this.GetFloat("wear");
  }

  public bool SetWear(float wear) {
    return this.SetFloat("wear", wear);
  }

  public int GetSlot() {
    return this.GetInt("slot");
  }
}
