class_name Gamespace extends Node3D

@onready var UnitSpawner_Node: MultiplayerSpawner = $"UnitSpawner"
@onready var BufSpawner_Node: MultiplayerSpawner = $"BufSpawner"
@onready var Unitry_Node: Node3D = $"Unitry"

const basemap_scene: PackedScene = preload("res://scenes/Maps/testmap.tscn")
func InitMultiplayer() -> void:
	if not GameData.isServer: return
	add_child(basemap_scene.instantiate(), true)

var _interval: float = 0
func _physics_process(delta: float) -> void:
	if not GameData.started: return
	
	_interval += delta
	if _interval >= 1.0:
		_interval -= 1.0
		_SlowTick()

func _SlowTick() -> void:
	if not GameData.isServer: return
	for key in GameData.playerDict:
		var player: Player = GameData.playerDict[key]
		if not is_instance_valid(player.unit_ref):
			var tibia: UnitTibia = GameData.tibiadict_unitry[&"og_firefist"]
			var config: UnitConfig = tibia.config_ref
			var unit_new: Unit = config.unit_scene.instantiate()
			unit_new.config_ref = config
			unit_new.tibia_ref = tibia
			unit_new.unitID = GameData.GetUniqueUnitID()
			unit_new.pilotID_ref = player.pilotID
			unit_new.unitidentifier = config.identifier
			unit_new.SetupHP(config.default_hp_max)
			unit_new.SetupLight(config.default_light_max)
			Unitry_Node.add_child(unit_new, true)

func AddUnitSceneAutoSpawn(path: String) -> void:
	UnitSpawner_Node.add_spawnable_scene(path)
func AddBufSceneAutoSpawn(path: String) -> void:
	BufSpawner_Node.add_spawnable_scene(path)

@rpc("any_peer", "call_local", "reliable")
func RequestPilotSeating(unitID: int) -> void:
	var playerID: int = multiplayer.get_remote_sender_id()
	var pilot: Pilot = GameData.playerDict.get(playerID) # Player = Pilot
	if not is_instance_valid(pilot): return
	
	var unit: Unit = GameData.unitDict.get(unitID)
	if is_instance_valid(unit): unit.Authority_SetNewPilot.rpc(pilot.pilotID)
