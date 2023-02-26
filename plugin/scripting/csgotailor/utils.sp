#if defined _CSGOTAILOR_UTILS_INCLUDED
  #endinput
#endif
#define _CSGOTAILOR_UTILS_INCLUDED

void GetFullPath(char[] file, char[] buffer, int bufferSize) {
  BuildPath(Path_SM, buffer, bufferSize, file);
}

JSON_Object ReadJsonFile(char[] path) {
  char fullPath[256];
  GetFullPath(path, fullPath, sizeof(fullPath));
  return json_read_from_file(fullPath, JSON_DECODE_ORDERED_KEYS);
}

bool IsPlayer(int client) {
  return client > 0 && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client)
    && !IsFakeClient(client) && !IsClientSourceTV(client);
}

void TeamKeyToName(char[] teamKey, char[] buffer, int bufferSize) {
  if (StrEqual(teamKey, TEAM_T)) {
    strcopy(buffer, bufferSize, "Terrorists");
  } else if (StrEqual(teamKey, TEAM_CT)) {
    strcopy(buffer, bufferSize, "Counter-Terrorists");
  } else if (StrEqual(teamKey, TEAM_BOTH)) {
    strcopy(buffer, bufferSize, "Both Teams");
  }
}

int RandomSeed() {
  return GetRandomInt(0, 10000);
}

bool GetWearKey(float wear, char[] buffer, int bufferSize) {
  if (wear >= 0 && wear < 0.07) return strcopy(buffer, bufferSize, "FN") > 0;
  if (wear >= 0.07 && wear < 0.15) return strcopy(buffer, bufferSize, "MW") > 0;
  if (wear >= 0.15 && wear < 0.38) return strcopy(buffer, bufferSize, "FT") > 0;
  if (wear >= 0.38 && wear < 0.45) return strcopy(buffer, bufferSize, "WW") > 0;
  if (wear >= 0.45 && wear <= 1.00) return strcopy(buffer, bufferSize, "BS") > 0;
  return false;
}

bool GetWearName(float wear, char[] buffer, int bufferSize) {
  char text[8];
  GetWearKey(wear, text, sizeof(text));

  if (StrEqual(text, "FN")) return strcopy(buffer, bufferSize, "Factory New") > 0;
  if (StrEqual(text, "MW")) return strcopy(buffer, bufferSize, "Minimal Wear") > 0;
  if (StrEqual(text, "FT")) return strcopy(buffer, bufferSize, "Field-Tested") > 0;
  if (StrEqual(text, "WW")) return strcopy(buffer, bufferSize, "Well-Worn") > 0;
  if (StrEqual(text, "BS")) return strcopy(buffer, bufferSize, "Battle-Scarred") > 0;
  return false;
}

bool IsKnifeClass(const char[] classname) {
  if ((StrContains(classname, "knife") > -1 &&
      strcmp(classname, "weapon_knifegg") != 0) ||
      StrContains(classname, "bayonet") > -1) {
    return true;
  }
  return false;
}

bool IsKnife(int entity) {
  char classname[MAX_CLASSNAME_SIZE];
  ClassnameFromEntity(entity, classname, sizeof(classname));

  return IsKnifeClass(classname);
}

int GetDefIndexFromEntity(int entity) {
  return GetEntProp(entity, Prop_Send, "m_iItemDefinitionIndex");
}

bool ClassnameFromEntity(int entity, char[] buffer, int bufferSize) {
  if (entity <= -1) return false;

  char key[12];
  IntToString(GetDefIndexFromEntity(entity), key, sizeof(key));

  return g_defIndexMap.GetString(key, buffer, bufferSize);
}

bool IsValidWeapon(int entity) {
  if (entity > 4096 && entity != INVALID_ENT_REFERENCE) {
    entity = EntRefToEntIndex(entity);
  }

  if (!IsValidEdict(entity) || !IsValidEntity(entity) || entity == -1) return false;

  char classname[MAX_CLASSNAME_SIZE];
  GetEdictClassname(entity, classname, sizeof(classname));

  return StrContains(classname, "weapon_") == 0;
}

void FindGameConfOffset(Handle gameConfig, int &offset, char[] key) {
  if ((offset = GameConfGetOffset(gameConfig, key)) == -1) {
    SetFailState("Failed to get '%s' offset.", key);
  }
}

int FindSendPropOffset(char[] classname, char[] prop) {
  int offset;
  if ((offset = FindSendPropInfo(classname, prop)) < 1) {
    SetFailState("Failed t ofind prop '%s' on class '%s'", prop, classname);
  }
  return offset;
}

Address DereferencePointer(Address addr) {
  return view_as<Address>(LoadFromAddress(addr, NumberType_Int32));
}

int unsigned_compare(int a, int b) {
	if (a == b) return 0;

	if ((a >>> 31) == (b >>> 31)) {
		return ((a & 0x7FFFFFFF) > (b & 0x7FFFFFFF)) ? 1 : -1;
	}

	return ((a >>> 31) > (b >>> 31)) ? 1 : -1;
}

bool IsValidAddress(Address address) {
	static Address Address_MinimumValid = view_as<Address>(0x10000);
	if (address == Address_Null) {
		return false;
	}
	return unsigned_compare(view_as<int>(address), view_as<int>(Address_MinimumValid)) >= 0;
}

bool SetAttributeValue(Address econItemView, any attrValue, const char[] format, any ...) {
  char attr[255];
  VFormat(attr, sizeof(attr), format, 4);

  Address attributeDef = SDKCall(gsdk_SDKGetAttributeDefinitionByName, gsdk_pItemSchema, attr);
  if (attributeDef == Address_Null) return false;

  Address attributeList = econItemView + view_as<Address>(gsdk_networkedDynamicAttributesOffset);

  int attributeDefIndex = LoadFromAddress(attributeDef + view_as<Address>(0x8), NumberType_Int16);
  int attributeCount = LoadFromAddress(attributeList + view_as<Address>(gsdk_attributeListCountOffset), NumberType_Int32);
  Address attributeData = DereferencePointer(attributeList + view_as<Address>(gsdk_attributeListReadOffset));

  int k = 0;
  for (int i = 0; i < attributeCount; i++) {
    Address attribute = attributeData + view_as<Address>(k);

    int defIndex = LoadFromAddress(attribute + view_as<Address>(0x4), NumberType_Int16);
    if (defIndex == attributeDefIndex) {
      int value = LoadFromAddress(attribute + view_as<Address>(0x8), NumberType_Int32);
      if (value != attrValue) {
        StoreToAddress(attribute + view_as<Address>(0x8), attrValue, NumberType_Int32);
        return true;
      }
      return false;
    }

    k += 24;
  }

  if (gsdk_ServerPlatform == OS_Windows) {
    MemoryBlock block = new MemoryBlock(24);
    Address attribute = block.Address;

    if (IsValidAddress(attribute)) {
      StoreToAddress(attribute + view_as<Address>(0x4), attributeDefIndex, NumberType_Int16);
      StoreToAddress(attribute + view_as<Address>(0x8), attrValue, NumberType_Int32);
      StoreToAddress(attribute + view_as<Address>(0xC), attrValue, NumberType_Int32);
      StoreToAddress(attribute + view_as<Address>(0x10), 0, NumberType_Int32);
      StoreToAddress(attribute + view_as<Address>(0x14), 0, NumberType_Int8);

      SDKCall(gsdk_SDKAddAttribute, attributeList, DereferencePointer(econItemView + view_as<Address>(0xAC)), attribute);

      delete block;
      return true;
    }
  } else {
    Address attribute = SDKCall(gsdk_SDKGenerateAttribute, gsdk_pItemSystem, attributeDefIndex, view_as<float>(attrValue));
    if (IsValidAddress(attribute)) {
      SDKCall(gsdk_SDKAddAttribute, attributeList, attribute);
      return true;
    }
  }
  return false;
}
