#if defined _CSGOTAILOR_INCLUDE_INCLUDED
  #endinput
#endif
#define _CSGOTAILOR_INCLUDE_INCLUDED

native void CST_Message(int client, const char[] format, any:...);

native void CST_MessageToAll(const char[] format, any:...);
