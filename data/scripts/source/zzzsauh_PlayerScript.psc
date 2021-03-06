Scriptname zzzsauh_PlayerScript Extends ReferenceAlias

Actor Property PlayerRef Auto
Keyword Property ArmorHelmet Auto
Keyword Property ClothingHead Auto
Keyword Property ClothingCirclet Auto
Quest Property FollowerDetector Auto
Quest Property NPCDetector Auto
Spell Property ConfigSpell Auto
Spell Property NpcCloakAbility Auto
GlobalVariable Property sauhState Auto
GlobalVariable Property sauhNPCEffectState Auto
GlobalVariable Property sauhNPCEffectMethod Auto
GlobalVariable Property sauhLocsExclusion Auto
GlobalVariable Property sauhLocsInclusion Auto
GlobalVariable Property sauhVersion Auto
Bool Property bSKSE Auto Hidden
Form[] Property ItemList Auto Hidden
FormList property CityLocations auto
Int[] Property BlackList Auto Hidden
Int[] Property WhiteList Auto Hidden
GlobalVariable Property sauhCurrentLocState Auto
GlobalVariable Property sauhCurrentLocExcluded Auto
GlobalVariable Property sauhCurrentLocIncluded Auto
GlobalVariable Property sauhFollowersExclusion Auto
Race property DLC1VampireBeastRace Auto Hidden
Location Property DLC1VampireCastleLocation Auto Hidden
Location Property DLC1HunterHQLocation Auto Hidden
Location Property DLC2RavenRockLocation Auto Hidden

Event OnInit()
	ItemList = New Form[20]
	WhiteList = New Int[20]
	WhiteList[0] = 0x00000001 ;HEAD
	WhiteList[1] = 0x00000002 ;Hair
	WhiteList[2] = 0x00000800 ;LongHair
	WhiteList[3] = 0x00001000 ;Circlet
	WhiteList[4] = 0x00002000 ;Ears
	WhiteList[5] = 0x00004000 ;Unnamed
	WhiteList[6] = 0x00008000 ;Unnamed
	WhiteList[7] = 0x00010000 ;Unnamed
	WhiteList[8] = 0x00020000 ;Unnamed
	WhiteList[9] = 0x00040000 ;Unnamed
	WhiteList[10] = 0x00080000 ;Unnamed
	WhiteList[11] = 0x00400000 ;Unnamed
	WhiteList[12] = 0x00800000 ;Unnamed
	WhiteList[13] = 0x01000000 ;Unnamed
	WhiteList[14] = 0x02000000 ;Unnamed
	WhiteList[15] = 0x04000000 ;Unnamed
	WhiteList[16] = 0x08000000 ;Unnamed
	WhiteList[17] = 0x10000000 ;Unnamed
	WhiteList[18] = 0x20000000 ;Unnamed
	WhiteList[19] = 0x40000000 ;Unnamed
	BlackList = New Int[12]
	BlackList[0] = 0x00000004 ;Body
	BlackList[1] = 0x00000008 ;Hands
	BlackList[2] = 0x00000010 ;ForeArms
	BlackList[3] = 0x00000020 ;Amulet
	BlackList[4] = 0x00000040 ;Ring
	BlackList[5] = 0x00000080 ;Feet
	BlackList[6] = 0x00000100 ;Calves
	BlackList[7] = 0x00000200 ;Shield
	BlackList[8] = 0x00000400 ;TAIL
	BlackList[9] = 0x00100000 ;DecapitateHead
	BlackList[10] = 0x00200000 ;Decapitate
	BlackList[11] = 0x80000000 ;FX01
	sauhState.SetValue(1)
	If !PlayerRef.HasSpell(ConfigSpell)
		PlayerRef.AddSpell(ConfigSpell,False)
	EndIf
	OnPlayerLoadGame()
	Debug.notification("Auto Unequip Headgears Started")
	RegisterForSingleUpdate(1.0)
EndEvent

Event OnPlayerLoadGame()
	bSKSE = bCheckSKSE()
	DLC1VampireBeastRace = Game.GetFormFromFile(0x283a, "Dawnguard.esm") as Race
	DLC1HunterHQLocation = Game.GetFormFromFile(0x4c1f, "Dawnguard.esm") as Location
	DLC1VampireCastleLocation = Game.GetFormFromFile(0x4c20, "Dawnguard.esm") as Location
	DLC2RavenRockLocation = Game.GetFormFromFile(0x143b9, "Dragonborn.esm") as Location
	If sauhVersion.GetValue() < getCurrentVersion()
		Update()
	EndIf
	RegisterForAnimationEvent(PlayerRef,"WeaponDraw")
	RegisterForAnimationEvent(PlayerRef,"WeaponSheathe")
EndEvent

Event OnUpdate()
	If sauhNPCEffectState.GetValue() == 1
		FollowerDetector.Start()
		Utility.Wait(1.0)
		FollowerDetector.Stop()
		Int i = 0
		While !FollowerDetector.IsStopped() && i < 50
			Utility.Wait(0.1)
			i += 1
		EndWhile
		RegisterForSingleUpdate(4.0)
	ElseIf sauhNPCEffectState.GetValue() == 2
		If sauhCurrentLocState.GetValueInt()
			If sauhNPCEffectMethod.GetValue()
				NPCDetector.Start()
				Utility.Wait(1.0)
				NPCDetector.Stop()
				Int i = 0
				While !NPCDetector.IsStopped() && i < 50
					Utility.Wait(0.1)
					i += 1
				EndWhile
			Else
				PlayerRef.AddSpell(NpcCloakAbility,False)
				Utility.Wait(1.0)
				PlayerRef.RemoveSpell(NpcCloakAbility)
			EndIf
		Else
			SendModEvent("AuhOtherNpcEffectStop")
			If !sauhFollowersExclusion.GetValue()
				FollowerDetector.Start()
				Utility.Wait(1.0)
				FollowerDetector.Stop()
				Int i = 0
				While !FollowerDetector.IsStopped() && i < 50
					Utility.Wait(0.1)
					i += 1
				EndWhile
			EndIf
		EndIf
		RegisterForSingleUpdate(4.0)
	EndIf
EndEvent

Event OnRaceSwitchComplete()
	If DLC1VampireBeastRace && ( PlayerRef.GetRace() == DLC1VampireBeastRace )
		GoToState("Waiting")
	Else
		GoToState("Resetting")
	EndIf
EndEvent

Event OnLocationChange(Location akOldLoc, Location akNewLoc)
	If sauhNPCEffectState.GetValue() == 2
		UpdateLocState(akNewLoc)
	EndIf
EndEvent

Function updateLocState(Location akLoc)
	sauhCurrentLocIncluded.SetValueInt(bIsLocIncluded(akLoc) As Int)
	sauhCurrentLocExcluded.SetValueInt(bIsCurLocExcluded() As Int)
	sauhCurrentLocState.SetValue((sauhCurrentLocIncluded.GetValue() && !sauhCurrentLocExcluded.GetValue()) As Int)
EndFunction

Event OnAnimationEvent(ObjectReference akSource, String asEventName)
	If akSource == PlayerRef
		If asEventName == "WeaponDraw"
			GoToState("Equipping")
		ElseIf asEventName == "WeaponSheathe"
			GoToState("Unequipping")
		EndIf
	EndIf
EndEvent

Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
	Utility.Wait(0.2)
	If bIsArmor(akBaseObject)
		If PlayerRef.IsWeaponDrawn()
			If bIsHeadgear(akBaseObject)
				If ItemList.Find(akBaseObject) < 0
					Int i = ItemList.Find(None)
					If i > -1
						ItemList[i] = akBaseObject
					Else
						Int SlotMask = (akBaseObject As Armor).GetSlotMask()
						i = ItemList.Length
						Bool bBreak = False
						While i > 0 && !bBreak
							i-= 1
							If ItemList[i]
								Int ItemSlotMask = (ItemList[i] As Armor).GetSlotMask()
								Int j = WhiteList.Length
								While j > 0 && !bBreak
									j -= 1
									If ( Math.LogicalAnd(SlotMask, WhiteList[j]) == WhiteList[j] ) &&\ 
									( Math.LogicalAnd(ItemSlotMask, WhiteList[j]) == WhiteList[j] )
										ItemList[i] = akBaseObject
										bBreak = True
									EndIf
								EndWhile
							EndIf
						EndWhile
					EndIf
				EndIf
			EndIf
		Else
			Int SlotMask = (akBaseObject As Armor).GetSlotMask()
			Int i = ItemList.Length
			Bool bBreak = False
			While i > 0 && !bBreak
				i-= 1
				If ItemList[i]
					Int ItemSlotMask = (ItemList[i] As Armor).GetSlotMask()
					Int j = WhiteList.Length
					While j > 0 && !bBreak
						j -= 1
						If ( Math.LogicalAnd(SlotMask, WhiteList[j]) == WhiteList[j] ) &&\ 
						( Math.LogicalAnd(ItemSlotMask, WhiteList[j]) == WhiteList[j] )
							ItemList[i] = None
							bBreak = True
						EndIf
					EndWhile
				EndIf
			EndWhile
		EndIf
	EndIf
EndEvent

Event OnObjectUnequipped(Form akBaseObject, ObjectReference akReference)
	If PlayerRef.IsWeaponDrawn()
		Bool bBreak = False
		While !bBreak
			Int i = ItemList.Find(akBaseObject)
			If i > -1
				ItemList[i] = None
			Else
				bBreak = True
			EndIf
		EndWhile
	EndIf
EndEvent

State Waiting
	Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
	EndEvent
	Event OnObjectUnequipped(Form akBaseObject, ObjectReference akReference)
	EndEvent
	Event OnAnimationEvent(ObjectReference akSource, String asEventName)
	EndEvent
	Event OnRaceSwitchComplete()
		If PlayerRef.GetRace() != DLC1VampireBeastRace
			RegisterForAnimationEvent(PlayerRef,"WeaponDraw")
			RegisterForAnimationEvent(PlayerRef,"WeaponSheathe")
			GoToState("")
		EndIf
	EndEvent
EndState

State Resetting
	Event OnBeginState()
		ArrayClear(ItemList)
		RegisterHeadgears(PlayerRef)
		RegisterForAnimationEvent(PlayerRef,"WeaponDraw")
		RegisterForAnimationEvent(PlayerRef,"WeaponSheathe")
		GoToState("")
	EndEvent
	Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
	EndEvent
	Event OnObjectUnequipped(Form akBaseObject, ObjectReference akReference)
	EndEvent
	Event OnAnimationEvent(ObjectReference akSource, String asEventName)
	EndEvent
	Event OnRaceSwitchComplete()
	EndEvent
EndState

State Equipping
	Event OnBeginState()
		Int i = ItemList.Length
		While i > 0
			i -= 1
			If ItemList[i] 
				If PlayerRef.GetItemCount(ItemList[i] As Armor) > 0
					If bSKSE
						PlayerRef.EquipItemEx(ItemList[i])
					Else
						PlayerRef.EquipItem(ItemList[i], abSilent = True)
					EndIf
					Utility.Wait(0.2)
				Else
					ItemList[i] = None
				EndIf
			EndIf
		EndWhile
		GoToState("")
	EndEvent
	Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
	EndEvent
	Event OnObjectUnEquipped(Form akBaseObject, ObjectReference akReference)
	EndEvent
EndState

State Unequipping
	Event OnBeginState()
		Int i = ItemList.Length
		While i > 0
			i -= 1
			If ItemList[i]
				PlayerRef.UnequipItem(ItemList[i], abSilent = True)
				Utility.Wait(0.2)
			EndIf
		EndWhile
		GoToState("")
	EndEvent
	Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
	EndEvent
	Event OnObjectUnEquipped(Form akBaseObject, ObjectReference akReference)
	EndEvent
EndState

Bool Function bIsArmor(Form akBaseObject)
	Return akBaseObject && akBaseObject.GetType() == 26
EndFunction

Bool Function bIsHeadgear(Form akBaseObject)
	If akBaseObject.HasKeyWord(ArmorHelmet) || akBaseObject.HasKeyWord(ClothingHead) || akBaseObject.HasKeyWord(ClothingCirclet)
		Int SlotMask = (akBaseObject As Armor).GetSlotMask()
		Int i = BlackList.Length
		While i > 0
			i -= 1
			If Math.LogicalAnd(SlotMask, BlackList[i]) == BlackList[i]
				Return False
			EndIf
		EndWhile
		Return True
	EndIf
	Return False
EndFunction

Function ArrayClear(Form[] Arr)
	If Arr
		int i = Arr.Length
		While i > 0 
			i -= 1
			Arr[i] = None
		EndWhile
	EndIf
EndFunction

Function RegisterHeadgears(Actor akActor)
	If akActor
		Form akArmor
		Int i = WhiteList.Length
		Int j
		While i > 0
			i -= 1
			akArmor = akActor.GetWornForm(WhiteList[i])
			If bIsArmor(akArmor) && bIsHeadgear(akArmor)
				If ItemList.find(akArmor) < 0
					j = ItemList.Find(None)
					If j > -1
						ItemList[j] = akArmor
					EndIf
				EndIf
			EndIf
		EndWhile
	EndIf
EndFunction

Bool Function bCheckSKSE()
	Return ( SKSE.GetVersion() == 1 && SKSE.GetVersionRelease() >= 43 ) || ( SKSE.GetVersion() == 2 && SKSE.GetVersionRelease() >= 54 )
EndFunction

Float Function getBaseVersion()
	Return 1.0
EndFunction

Float Function getCurrentVersion()
	Return getBaseVersion() + 0.08
EndFunction

Function Update()
	sauhVersion.SetValue(getCurrentVersion())
	Debug.Trace("Auto Unequip Headgears updated to version " + getCurrentVersion())
EndFunction

Bool Function bIsLocIncluded(Location akLoc)
	Int iInclude = sauhLocsInclusion.GetValueInt()
	If iInclude
		Location CurrLoc = PlayerRef.GetCurrentLocation()
		If CurrLoc
			If iInclude == 2
				 If CurrLoc.HasKeyWordString("LocTypeHouse") || \
				 CurrLoc.HasKeyWordString("LocTypeDwelling") || \
				 CurrLoc.HasKeyWordString("LocTypeHabitation")
					Return True
				EndIf
			EndIf
			If DLC1VampireCastleLocation && ((CurrLoc == DLC1VampireCastleLocation) || CurrLoc.IsChild(DLC1VampireCastleLocation))
				Return True
			ElseIf DLC1HunterHQLocation && ((CurrLoc == DLC1HunterHQLocation) || CurrLoc.IsChild(DLC1HunterHQLocation))
				Return True
			ElseIf DLC2RavenRockLocation && ((CurrLoc == DLC2RavenRockLocation) || CurrLoc.IsChild(DLC2RavenRockLocation))
				Return True
			ElseIf  CityLocations.HasForm(CurrLoc) || CurrLoc.HasKeyWordString("LocTypeCity") || CurrLoc.HasKeyWordString("LocTypeTown")
				Return True
			Else
				Int i = CityLocations.GetSize()
				While i > 0
					i -= 1
					If CurrLoc.IsChild(CityLocations.GetAt(i) As Location)
						Return True
					EndIf
				EndWhile
			EndIf
		EndIf
		Return False
	EndIf
	Return True
EndFunction

Bool Function bIsCurLocExcluded()
	Int iExclude = sauhLocsExclusion.GetValueInt()
	If iExclude
		Return PlayerRef.IsInInterior() == (iExclude - 1) As Bool
	EndIf
	Return False
EndFunction
