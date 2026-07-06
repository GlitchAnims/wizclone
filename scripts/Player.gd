class_name Player extends Pilot

@export var playerID: int = 0

@export var isReady: bool = false
var password: int = -1

var mousePos_old: Vector2 = Vector2.ZERO

func _ready_pilot():
	GameData.playerDict.set(playerID, self)
	if multiplayer.multiplayer_peer.get_unique_id() != playerID: return
	ClientData.thisPlayer = self

func _physics_process_pilot(_delta: float) -> void:
	if multiplayer.multiplayer_peer.get_unique_id() != playerID: return
	var hasControl: bool = is_instance_valid(unit_ref)
	
	#if hasControl:
	#	if not unit_ref.mainCamera.is_current(): unit_ref.mainCamera.set_current(true)
	#else: if not GameData.TestCameraNode.is_current(): GameData.TestCameraNode.set_current(true)
	
	var intent_new: int = 0
	
	var north: bool = Input.is_action_pressed("ACT_North")
	var west: bool = Input.is_action_pressed("ACT_West")
	var south: bool = Input.is_action_pressed("ACT_South")
	var east: bool = Input.is_action_pressed("ACT_East")
	
	if north: intent_new |= (1 << ClientData.P_FLAG.north)
	if west: intent_new |= (1 << ClientData.P_FLAG.west)
	if south: intent_new |= (1 << ClientData.P_FLAG.south)
	if east: intent_new |= (1 << ClientData.P_FLAG.east)
	if Input.is_action_pressed("ACT_Q"): intent_new |= (1 << ClientData.P_FLAG.actQ)
	if Input.is_action_pressed("ACT_E"): intent_new |= (1 << ClientData.P_FLAG.actE)
	if Input.is_action_pressed("ACT_Space"): intent_new |= (1 << ClientData.P_FLAG.jump)
	if Input.is_action_pressed("ACT_Crouch"): intent_new |= (1 << ClientData.P_FLAG.crouch)
	
	var m1: bool = Input.is_action_pressed("M1")
	var m2: bool = Input.is_action_pressed("M2")
	
	if m1: intent_new |= (1 << ClientData.P_FLAG.m1)
	if m2: intent_new |= (1 << ClientData.P_FLAG.m2)
	if Input.is_action_pressed("ACT_Shift"): intent_new |= (1 << ClientData.P_FLAG.shift)
	
	if GameData.isServer: Authority_SendControlsToAll.rpc(mouse_worldPos, intent_new)
	else: SendControlsToServer.rpc_id(1, mouse_worldPos, intent_new)

@rpc("call_remote", "any_peer", "unreliable_ordered", 2)
func SendControlsToServer(mouse_worldPos_new: Vector3, intent_new: int) -> void:
	Authority_SendControlsToAll.rpc(mouse_worldPos_new, intent_new)

@rpc("call_local", "authority", "unreliable_ordered", 2)
func Authority_SendControlsToAll(mouse_worldPos_new: Vector3, intent_new: int) -> void:
	mouse_worldPos = mouse_worldPos_new
	intent = intent_new

func _exit_tree():
	GameData.playerDict.erase(playerID)
	GameData.pilotDict.erase(pilotID)
