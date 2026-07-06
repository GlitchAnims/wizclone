extends Node

var Stronghold_Node: Stronghold = null
var Gamespace_Node: Gamespace = null
var VisualManagement_Node: VisualManagement = null
#var Graphical2DNode: Graphical2D = null

#var MainmenuNode: MainMenu = null

const connectmenuScene: PackedScene = preload("res://scenes/Menus/connectmenu_scene.tscn")
var ConnectMenuNode: ConnectMenu = null
#var PauseMenuNode: PauseMenu = null
#var CombatHUDNode: CombatHUD = null

var started: bool = false
var isServer: bool = false
var isDedicated: bool = false

var rayquery_wall: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(Vector3.ZERO, Vector3.ZERO, 0b0010)

var configlist_unitry: Array[UnitConfig] = []
var configlist_cards: Array[CardConfig] = []
var tibialist_unitry: Array[UnitTibia] = []
var tibialist_cards: Array[CardTibia] = []
var tibiadict_unitry: Dictionary[StringName, UnitTibia] = {}
var tibiadict_cards: Dictionary[StringName, CardTibia] = {}

func ActualizeConfigLists(extracards: Array[CardConfig]) -> void:
	configlist_cards.clear()
	for card_config in extracards:
		configlist_cards.push_back(card_config)
	
	for unit_config in configlist_unitry:
		for card_config in unit_config.cardconfig_default_list:
			if !configlist_cards.has(card_config): configlist_cards.push_back(card_config)


func ActualizeTibiaList() -> void:
	tibialist_unitry.clear()
	tibiadict_unitry.clear()
	tibialist_cards.clear()
	tibiadict_cards.clear()
	
	var unitcount: int = configlist_unitry.size()
	for i in unitcount:
		var config: UnitConfig = configlist_unitry[i]
		var new_tibia: UnitTibia = UnitTibia.new(config, i)
		tibialist_unitry.push_back(new_tibia)
		tibiadict_unitry[config.identifier] = new_tibia
	
	var cardcount: int = configlist_cards.size()
	for i in cardcount:
		var config: CardConfig = configlist_cards[i]
		var new_cardtibia: CardTibia = CardTibia.new(config, i)
		tibialist_cards.push_back(new_cardtibia)
		tibiadict_cards[config.identifier] = new_cardtibia

signal sig_updatehandvisual

var unitDict: Dictionary[int, Unit] = {}
var pilotDict: Dictionary[int, Pilot] = {}
var playerDict: Dictionary[int, Player] = {}

var pilotID_counter: int = 0
func GetUniquePilotID() -> int:
	pilotID_counter += 1
	return pilotID_counter

var unitID_counter: int = 0
func GetUniqueUnitID() -> int:
	unitID_counter += 1
	return unitID_counter
