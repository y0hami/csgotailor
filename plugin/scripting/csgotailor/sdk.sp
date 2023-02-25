void Setup_SDK() {
  Handle gameConfig = LoadGameConfigFile("csgotailor.games");

  if (gameConfig == null) {
    SetFailState("Game config wasn't loaded correctly.");
    return;
  }

  gsdk_ServerPlatform = view_as<ServerPlatform>(GameConfGetOffset(gameConfig, "ServerPlatform"));
  if (gsdk_ServerPlatform == OS_Mac || gsdk_ServerPlatform == OS_Unknown) {
    SetFailState("CSGOTailor is only supported on Linux and Windows.");
    return;
  }

  StartPrepSDKCall(SDKCall_Static);
  PrepSDKCall_SetFromConf(gameConfig, SDKConf_Signature, "ItemSystem");
  PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);

  Handle SDKItemSystem;
  if (!(SDKItemSystem = EndPrepSDKCall())) {
    SetFailState("Method \"ItemSystem\" was not loaded right.");
    return;
  }

  gsdk_pItemSystem = SDKCall(SDKItemSystem);
  if (gsdk_pItemSystem == Address_Null) {
    SetFailState("Failed to get \"ItemSystem\" pointer address.");
    return;
  }

  delete SDKItemSystem;
  gsdk_pItemSchema = gsdk_pItemSystem + view_as<Address>(4);

  StartPrepSDKCall(SDKCall_Raw);
  PrepSDKCall_SetFromConf(gameConfig, SDKConf_Signature, "CAttributeList::AddAttribute");
  PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);

  if (gsdk_ServerPlatform == OS_Windows) {
    PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
    PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
  }

  if (!(gsdk_SDKAddAttribute = EndPrepSDKCall())) {
    SetFailState("Method 'CAttributeList::AddAttribute' wasn't loaded correctly.");
    return;
  }

  if (gsdk_ServerPlatform == OS_Linux)
  {
    StartPrepSDKCall(SDKCall_Raw);
    PrepSDKCall_SetFromConf(gameConfig, SDKConf_Signature, "CEconItemSystem::GenerateAttribute");
    PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
    PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);
    PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);

    if (!(gsdk_SDKGenerateAttribute = EndPrepSDKCall())) {
      SetFailState("Method 'CEconItemSystem::GenerateAttribute' wasnt loaded correctly.");
      return;
    }
  }

  StartPrepSDKCall(SDKCall_Raw);
  PrepSDKCall_SetFromConf(gameConfig, SDKConf_Signature, "CEconItemSchema::GetAttributeDefinitionByName");
  PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
  PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);

  if (!(gsdk_SDKGetAttributeDefinitionByName = EndPrepSDKCall())) {
    SetFailState("Method 'CEconItemSchema::GetAttributeDefinitionByName' wasn't loaded correctly.");
    return;
  }

  // Get Offsets.
  FindGameConfOffset(gameConfig, gsdk_networkedDynamicAttributesOffset, "m_NetworkedDynamicAttributesForDemos");
  FindGameConfOffset(gameConfig, gsdk_attributeListReadOffset, "CAttributeList_Read");
  FindGameConfOffset(gameConfig, gsdk_attributeListCountOffset, "CAttributeList_Count");

  delete gameConfig;

  gsdk_econItemOffset = FindSendPropOffset("CBaseCombatWeapon", "m_Item");
}