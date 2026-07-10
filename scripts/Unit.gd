class_name Unit extends CharacterBody3D

@onready var RepulsionArea_Node: Area3D = $"RepulsionArea"

## Sync Var (Do not change this. Automatically determined by Server.)
@export_storage var unitID: int = -1
## Sync Var
@export_storage var pilotID_ref: int = -1
## Sync Var (Do not change this. Use [member UnitConfig.identifier] instead.)
@export_storage var unitidentifier: StringName = &""

var config_ref: UnitConfig = null
var tibia_ref: UnitTibia = null
var pilot_ref: Pilot = null
var standin_ref: Standin = null

## Called by Server when spawned, before adding as child to tree.
func Server_SetupForSpawn(tibia: UnitTibia, uniqueunitid: int) -> void:
	config_ref = tibia.config_ref
	tibia_ref = tibia
	unitID = uniqueunitid
	unitidentifier = config_ref.identifier
	SetupHP(config_ref.default_hp_max)
	SetupLight(config_ref.default_light_max)

## Sync Var (Do not change this. Use [member UnitConfig.default_hp_max] instead.)
@export_storage var hp_max: int = 1000
## Sync Var (Do not change this. Use [member UnitConfig.default_hp_max] instead.)
@export_storage var hp: int = 1000
## Auto-called by [method Unit.Server_SetupForSpawn]
func SetupHP(hp_max_new: int = 1000) -> void:
	hp_max = hp_max_new
	hp = hp_max_new

@export var sanity_enabled: bool = true
@export var sanity: int = 1000

@export var energy1_enabled: bool = false
@export_range(0,1000,1) var energy1: int = 1000
@export var energy2_enabled: bool = false
@export_range(0,1000,1) var energy2: int = 1000

var skill_list: Array[Skill] = []
var skill_selected: Skill = null
@export var skill_selected_i: int = 0
var skill_charge: float = 0.0
var skill_using: bool = false
var skill_backwards: bool = false
var skill_acting: bool = false

## Sync Var (Do not change this. Use [member UnitConfig.default_light_max] instead.)[br]
## Max Light. Synced by Server (infrequent).
@export_storage var light_max: int = 10
## Sync Var (Do not change this. Use [member UnitConfig.default_light_max] instead.)[br]
## Current Light. Synced by Server.
@export_storage var light: int = 5
## Auto-called by [method Unit.Server_SetupForSpawn]
func SetupLight(max_new: int = 10) -> void:
	light_max = max_new
	light = floor(float(max_new) / 2)


## Tibia ID list of Cards in Hand. Synced by Server.
@export_storage var pile_hand: PackedInt32Array = []
## Tibia ID list of Cards in Discard Pile. Synced by Server.
@export_storage var pile_discard: PackedInt32Array = []

## 0-1 float. Gain Light at 1.0 and reset.
var timer_light: float = 0.0
## 0-1 float. Draw Card at 1.0 and reset.
var timer_draw: float = 0.0

var _interval: float = 0
var fulltime: bool = false
var walkpacket: WalkPacket = WalkPacket.new()
var synctick: bool = false
var synced_this_tick: bool = false
var mouse_worldPos: Vector3 = Vector3.ZERO
var intent: int = 0


# Stat Increases. NEVER substract ANY of these, you FUCKING IDIOT MODDER.
var stat_atk_plus: int = 0
var stat_atk_minus: int = 0
var stat_def_plus: int = 0
var stat_def_minus: int = 0
var stat_haste: int = 0
var stat_bind: int = 0

## Sync var.
@export_storage var buflist_id: PackedInt32Array = []
var buflist_shortcut: Array[Buf] = []

func UpdateShortcutBufList() -> void:
	pass
func UpdateStats(upd_shortcut: bool = true) -> void:
	stat_atk_plus = 0
	stat_atk_minus = 0
	stat_def_plus = 0
	stat_def_minus = 0
	stat_haste = 0
	stat_bind = 0
	
	if upd_shortcut: UpdateShortcutBufList()
	for buf in buflist_shortcut:
		buf.ModifyUnitStats()


func _exit_tree() -> void:
	GameData.unitDict.erase(unitID)
func free() -> void:
	walkpacket.free()
	super()

func _ready() -> void:
	GameData.unitDict[unitID] = self
	_interval -= ClientData.rng.randf()
	
	if not GameData.isServer:
		if not is_instance_valid(tibia_ref): tibia_ref = GameData.tibiadict_unitry[unitidentifier]
		if not is_instance_valid(config_ref): config_ref = tibia_ref.config_ref
	
	
	PilotCheck()
	
	standin_ref = config_ref.standin_scene.instantiate()
	standin_ref.unit_ref = self
	GameData.Gamespace_Node.add_child(standin_ref)
	
	for config: CardConfig in config_ref.default_card_pool:
		var amount: int = config_ref.default_card_pool[config]
		var tibia: CardTibia = GameData.tibiadict_cards[config.identifier]
		var id: int = tibia.tibia_id
		for i in amount:
			pile_discard.push_back(id)
	
	_ready_unit()
func _ready_unit() -> void: pass

func _physics_process(delta: float) -> void:
	_interval += delta
	if _interval >= 0.5:
		_interval -= 0.5
		fulltime = not fulltime
		_SlowTick(delta)
	
	var thres_l: float = config_ref.default_light_regen
	var thres_d: float = config_ref.default_card_regen
	
	if light < light_max:
		var regen: float = delta / thres_l
		timer_light += regen
	else: timer_light = 0
	
	var hand_count: int = pile_hand.size()
	var discard_count: int = pile_discard.size()
	if hand_count < config_ref.default_hand_max and discard_count > 0:
		var regen: float = delta / thres_d
		timer_draw += regen
	else: timer_draw = 0
	
	if GameData.isServer:
		if timer_light >= 1.0:
			synctick = true
			timer_light -= 1.0
			light += 1
		
		if timer_draw >= 1.0:
			timer_draw -= 1.0
			DrawCards(1)
	
	var isFloored: bool = is_on_floor()
	
	if isFloored:
		var overlap_list: Array[Area3D] = RepulsionArea_Node.get_overlapping_areas()
		if overlap_list.size() > 0:
			for area in overlap_list:
				var area_parent: Unit = area.get_parent() as Unit
				var push_vec: Vector3 = Vector3.ZERO
				push_vec += position - area_parent.position
				velocity += push_vec.normalized() * delta * 5.0
		
		var slowdown: Vector3 = velocity * minf(delta * 5.0, 1.0)
		var min_slow: float = 0.4 * delta
		
		if slowdown.length() < min_slow: velocity = Vector3.ZERO
		else: velocity -= slowdown
	else:
		velocity += get_gravity() * delta
		velocity -= velocity * minf(delta * 0.4, 1.0)
	
	intent = 0 # Reset Intent
	if is_instance_valid(pilot_ref):
		mouse_worldPos = pilot_ref.mouse_worldPos
		intent = pilot_ref.intent
		
		var north: bool = intent & (1 << ClientData.P_FLAG.north)
		var west: bool =  intent & (1 << ClientData.P_FLAG.west)
		var south: bool = intent & (1 << ClientData.P_FLAG.south)
		var east: bool =  intent & (1 << ClientData.P_FLAG.east)
		var wants_jump: bool = intent & (1 << ClientData.P_FLAG.jump)
		
		var movement_norm: Vector3 = Vector3.ZERO
		if north: movement_norm.z += -1.0
		elif south and not north: movement_norm.z += 1.0
		
		if west: movement_norm.x += -1.0
		elif east and not west: movement_norm.x += 1.0
		movement_norm = movement_norm.normalized()
		walkpacket.vec_norm = movement_norm
		
		var speed: float = config_ref.move_speed_mult * 20.0 * delta # TODO bonuses
		if not isFloored: speed *= 0.1 # Reduced walk in air
		else:
			var vec_dot: float = movement_norm.dot(velocity.normalized())
			vec_dot = vec_dot * -2.0
			if vec_dot > 1.0: speed *= vec_dot
			elif velocity.length() < 0.1 * delta: speed *= 2.0
		walkpacket.vec = movement_norm * speed
		
		if GameData.isServer:
			if isFloored and wants_jump: Jump()
		
		velocity += walkpacket.vec
	
	var m1: bool = intent & (1 << ClientData.P_FLAG.m1)
	
	if m1 and not skill_using:
		if true: # TODO skill cooldown, stun, and other blockers
			skill_using = true
	
	if skill_using:
		if GameData.isServer and not skill_acting: Server_CheckActivation(m1)
		skill_selected.HandleCharge(m1, delta)
		skill_selected.ProcessPhys(delta)
	
	_physics_process_unit(delta)
	
	move_and_slide()
	
	
	if GameData.isServer:
		synced_this_tick = false
		if synctick:
			synctick = false
			synced_this_tick = true
			Authority_SyncDeck.rpc(timer_light, timer_draw, light, pile_hand, pile_discard)
			GameData.sig_updatehandvisual.emit()
			if energy2_enabled:
				Authority_SyncVecs.rpc(position, velocity, energy1, energy2)
			elif energy1_enabled:
				Authority_SyncVecs.rpc(position, velocity, energy1)
			else: Authority_SyncVecs.rpc(position, velocity)
	
	info_realvel = get_real_velocity()
	info_realspeed = info_realvel.length()
func _physics_process_unit(_delta: float) -> void: pass

var info_realvel: Vector3 = Vector3.ZERO
var info_realspeed: float = 0

func DrawCards(amount: int = 1) -> void:
	synctick = true
	for i in amount:
		var discard_count: int = pile_discard.size()
		var random_pick: int = ClientData.rng.randi_range(0, discard_count-1)
		var tib: int = pile_discard[random_pick]
		pile_discard.remove_at(random_pick)
		pile_hand.push_back(tib)

func DiscardCardByTibiaID(id: int = -1, _activate_discard: bool = false) -> void:
	if id < 0: return
	synctick = true
	# TODO Discard Effects
	if pile_hand.has(id):
		pile_hand.erase(id)
		pile_discard.push_back(id)


## Request from Client to Server only.[br]
## Checks if Client Player ID is same as this unit's Pilot Player, 
## then calls [method Unit.Server_ActivateCardByTibiaID].
@rpc("any_peer", "call_remote", "reliable")
func Request_ActivateCardByTibiaID(id: int = -1) -> void:
	if not GameData.isServer: return
	if not is_instance_valid(pilot_ref): return
	if pilot_ref is not Player: return
	var player: Player = pilot_ref as Player
	var senderID: int = multiplayer.get_remote_sender_id()
	if player.playerID != senderID: return # LOUD INCORRECT BUZZER
	Server_ActivateCardByTibiaID(id)

## Only call on Server.[br]
## Calls [method Unit.Server_ActivateCard] if successful.
func Server_ActivateCardByTibiaID(id: int = -1) -> void:
	if id < 0: return
	if not pile_hand.has(id): return
	var cardtib: CardTibia = GameData.tibialist_cards[id]
	Server_ActivateCard(cardtib)

## Only call on Server.
func Server_ActivateCard(card: CardTibia) -> void:
	var cardconfig: CardConfig = card.config_ref
	if cardconfig.light_cost > light: return
	light -= cardconfig.light_cost
	# TODO can activate card y/n
	if not cardconfig.is_generic:
		_ActivateCard_Unit(card, cardconfig)
	synctick = true
	pile_hand.erase(card.tibia_id)
	pile_discard.push_back(card.tibia_id)

## Unique card activation. Override this with custom units.
func _ActivateCard_Unit(_card: CardTibia, _cardconfig: CardConfig) -> void: pass

## Returns -1 if invalid.
#func TryGetCardTibiaIDByHandIndex(hand_index: int) -> int:
	#var hand_size: int = pile_hand.size()
	#if hand_index >= hand_size: return -1
	#var tib_ID: int = pile_hand[hand_index]
	#return tib_ID

func Jump() -> void:
	walkpacket.vec += walkpacket.vec_norm * 1.0
	walkpacket.vec.y += 6.0
	synctick = true
	if not GameData.isDedicated: Authority_R_JumpEffects(position)
	Authority_R_JumpEffects.rpc(position)

const pb_jump_scene: PackedScene = preload("res://scenes/ParticleBlobs/pb_jump.tscn")
@rpc("authority", "call_remote", "reliable")
func Authority_R_JumpEffects(jump_pos: Vector3) -> void:
	var node_new: ParticleBlob = pb_jump_scene.instantiate()
	node_new.position = jump_pos
	GameData.Gamespace_Node.add_child(node_new)

func _SlowTick(_delta: float) -> void:
	PilotCheck()
	
	if GameData.isServer:
		synctick = true
		if fulltime: pass
		Authority_SyncBufs(buflist_id)
	
	UpdateShortcutBufList()
	UpdateStats(false)

@rpc("authority", "call_remote", "reliable")
func Authority_SyncBufs(bufids: PackedInt32Array) -> void:
	buflist_id = bufids

func PilotCheck() -> void:
	if not is_instance_valid(pilot_ref) && pilotID_ref != -1:
		# If ID is known, check if pilot exists. If not, server_propagate -1 ID
		var pilot: Pilot = GameData.pilotDict.get(pilotID_ref)
		if is_instance_valid(pilot):
			pilot_ref = pilot
			pilot_ref.unit_ref = self
		elif GameData.isServer: Authority_SetPilotIDRef.rpc(-1)

@rpc("authority", "call_remote", "reliable")
func Authority_SyncDeck(timer_l: float, timer_d: float, l: int, h: PackedInt32Array, d: PackedInt32Array) -> void:
	timer_light = timer_l
	timer_draw = timer_d
	light = l
	pile_hand = h
	pile_discard = d
	GameData.sig_updatehandvisual.emit()
@rpc("authority", "call_remote", "unreliable_ordered")
func Authority_SyncVecs(pos_new: Vector3, vel_new: Vector3, e1: int = energy1, e2: int = energy2) -> void:
	position = pos_new
	velocity = vel_new
	energy1 = e1
	energy2 = e2

@rpc("authority", "call_remote", "reliable")
func Authority_R_SetSkill(i: int) -> void:
	# Only clients receive this, and skills cannot be changed unless charge is 0.
	# So, if this is received in the wrong order, force skillcancel.
	if skill_charge != 0:
		skill_charge = 0
		skill_list[skill_selected_i].OnCancel()
	skill_selected_i = i
	skill_selected = skill_list[skill_selected_i]

@rpc("authority", "call_remote", "unreliable_ordered")
func Authority_R_SetSkillCharge(chrg: float) -> void:
	skill_charge = chrg

func Server_CheckActivation(m1: bool) -> void:
	var fullcharge: bool = skill_charge == 1.0
	var go: bool = false
	match skill_selected.stats.enactment_type:
		SkillStats.ENACTMENT.normal:    go = not m1 and fullcharge
		SkillStats.ENACTMENT.looping:   go = m1 and fullcharge
		SkillStats.ENACTMENT.scripted:  go = fullcharge
	#	SkillStats.ENACTMENT.continued: go = m1 and fullcharge
	#	SkillStats.ENACTMENT.rampup:    go = false
	#	SkillStats.ENACTMENT.windup:    go = false
	if go:
		Authority_R_ActivateSkill.rpc(skill_selected_i)
		Client_ActivateSkill()

@rpc("authority", "call_remote", "unreliable_ordered")
func Authority_R_ActivateSkill(i: int) -> void:
	skill_selected_i = i
	skill_selected = skill_list[i]
	Client_ActivateSkill()

func Client_ActivateSkill() -> void:
	skill_acting = true
	EnactSkill()

## Unit unique override
func EnactSkill() -> void: pass

@rpc("authority", "call_local", "reliable")
func Authority_SetPilotIDRef(id: int) -> void:
	pilotID_ref = id

@rpc("authority", "call_local", "reliable")
func Authority_SetNewPilot(newPilotID: int) -> void:
	var pilot: Pilot = GameData.pilotDict.get(newPilotID)
	if is_instance_valid(pilot): pilotID_ref = pilot.pilotID
	PilotCheck()
