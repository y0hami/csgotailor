#if defined _CSGOTAILOR_FEATURES_INCLUDED
  #endinput
#endif
#define _CSGOTAILOR_FEATURES_INCLUDED

bool FeatureIsEnabled(char[] flag) {
  JSON_Object features = g_config.GetObject("features");
  return features.GetBool(flag) == true;
}
