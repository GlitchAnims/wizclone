class_name Encompass extends PanelContainer

@onready var AllMouse_Node: Node2D = $"AllMouse"
@onready var SkillChargeCircle_Node: TextureProgressBar = $"AllMouse/SkillChargeCircle"

@onready var CombatHUD_Node: Control = $"CombatHUD"
@onready var HealthHUD_Node: Control = $"CombatHUD/HealthHUD"
@onready var LightHUD_Node: Control = $"CombatHUD/LightHUD"
@onready var HandHUD_Node: HandHUD = $"CombatHUD/HandHUD"
@onready var EnergyHUD_Node: Control = $"CombatHUD/EnergyHUD"
@onready var Energy1Dot_Node: Control = $"CombatHUD/EnergyHUD/Energy1Dot"
@onready var Energy2Dot_Node: Control = $"CombatHUD/EnergyHUD/Energy2Dot"

@onready var _HealthBar_Node: ProgressBar = $"CombatHUD/HealthHUD/HealthBar"
@onready var _SanityBar_Node: ProgressBar = $"CombatHUD/HealthHUD/SanityBar"
@onready var _HP_Node: RichTextLabel = $"CombatHUD/HealthHUD/HP"
@onready var _SP_Node: RichTextLabel = $"CombatHUD/HealthHUD/SP"

@onready var _LightLoading_Node: TextureProgressBar = $"CombatHUD/LightHUD/LightLoading"
@onready var _Light_Node: RichTextLabel = $"CombatHUD/LightHUD/Light"
@onready var _LightMax_Node: RichTextLabel = $"CombatHUD/LightHUD/LightMax"

@onready var _Energy1Bar_Node: ProgressBar = $"CombatHUD/EnergyHUD/Energy1Dot/Energy1Bar"
@onready var _Energy1_Node: RichTextLabel = $"CombatHUD/EnergyHUD/Energy1Dot/Energy1"
@onready var _Energy1Name_Node: RichTextLabel = $"CombatHUD/EnergyHUD/Energy1Dot/Energy1Name"
@onready var _Energy1Icon_Node: TextureRect = $"CombatHUD/EnergyHUD/Energy1Dot/Energy1Icon"

@onready var _Energy2Bar_Node: ProgressBar = $"CombatHUD/EnergyHUD/Energy2Dot/Energy2Bar"
@onready var _Energy2_Node: RichTextLabel = $"CombatHUD/EnergyHUD/Energy2Dot/Energy2"
@onready var _Energy2Name_Node: RichTextLabel = $"CombatHUD/EnergyHUD/Energy2Dot/Energy2Name"
@onready var _Energy2Icon_Node: TextureRect = $"CombatHUD/EnergyHUD/Energy2Dot/Energy2Icon"

func _ready() -> void:
	ClientData.viewportSize_changed.connect(UpdateSize)
	UpdateSize()
	
	ClientData.screenUnit_changed.connect(_ScreenUnitChanged)
	GameData.sig_updatehandvisual.connect(UpdateHandVisual)

func _ScreenUnitChanged() -> void:
	pass

func UpdateSize() -> void:
	set_begin(Vector2.ZERO)
	set_end(ClientData.viewportSize)
	
	var itemscale: Vector2 = Vector2(1,1) * minf(ClientData.viewportScale, 1.0)
	HealthHUD_Node.scale = itemscale
	LightHUD_Node.scale = itemscale
	HandHUD_Node.scale = itemscale
	EnergyHUD_Node.scale = itemscale

func UpdateHandVisual() -> void:
	var player: Player = ClientData.thisPlayer
	var unit: Unit = player.unit_ref
	if is_instance_valid(unit): HandHUD_Node.UpdateHandVisual(unit)

var _last_unit: Unit = null
var _last_hpmax: int = 1
var _hudbar_hp: HudBar = HudBar.new()
var _hudbar_sp: HudBar = HudBar.new()
var _hudbar_energy1: HudBar = HudBar.new()
var _hudbar_energy2: HudBar = HudBar.new()

func _process(_delta: float) -> void:
	AllMouse_Node.position = ClientData.mousePos

func _physics_process(delta: float) -> void:
	if not is_instance_valid(ClientData.thisPlayer):
		if AllMouse_Node.visible: AllMouse_Node.visible = false
		if CombatHUD_Node.visible: CombatHUD_Node.visible = false
		return
	
	var unit: Unit = ClientData.screenUnit
	var valid_unit: bool = is_instance_valid(unit)
	AllMouse_Node.visible = valid_unit
	CombatHUD_Node.visible = valid_unit
	if not valid_unit: return # TODO unitless HUD
	
	SkillChargeCircle_Node.set_value(unit.skill_charge)
	
	if _last_unit != unit:
		_last_unit = unit
		_last_hpmax = -1
		_SanityBar_Node.visible = unit.sanity_enabled
		_SP_Node.visible = unit.sanity_enabled
		Energy1Dot_Node.visible = unit.energy1_enabled
		Energy2Dot_Node.visible = unit.energy2_enabled
		
		var config: UnitConfig = unit.config_ref
		Energy1Dot_Node.modulate = config.energy1_color
		Energy2Dot_Node.modulate = config.energy2_color
		_Energy1Name_Node.set_text(config.energy1_name)
		_Energy2Name_Node.set_text(config.energy2_name)
		_Energy1Icon_Node.set_texture(config.energy1_icon)
		_Energy2Icon_Node.set_texture(config.energy2_icon)
		
		HandHUD_Node.UpdateHandVisual(unit)
	
	if _last_hpmax != unit.hp_max:
		_last_hpmax = unit.hp_max
		_HealthBar_Node.set_max(_last_hpmax)
	
	var lerpspeed: float = delta * 5.5
	_ProcessHudBar(unit.hp, lerpspeed, _hudbar_hp, 0)
	if _SanityBar_Node.visible: _ProcessHudBar(unit.sanity, lerpspeed, _hudbar_sp, 1)
	if Energy1Dot_Node.visible: _ProcessHudBar(unit.energy1, lerpspeed, _hudbar_energy1, 2)
	if Energy2Dot_Node.visible: _ProcessHudBar(unit.energy2, lerpspeed, _hudbar_energy2, 3)
	
	_LightLoading_Node.set_value(unit.timer_light)
	_Light_Node.set_text("[font size=22]" + str(unit.light) + "[/font]")
	_LightMax_Node.set_text("[font size=28]/[/font][font size=18]" + str(unit.light_max) + "[/font]")
	
	HandHUD_Node._process_handhud(unit)

func _ProcessHudBar(value: int, lerpspeed: float, hudbar: HudBar, mode: int) -> void:
	if value != hudbar.goal:
		hudbar.goal = value
		hudbar.last = hudbar.cur
		hudbar.travel = 0
	
	if hudbar.cur != value:
		var diff: int = hudbar.goal - hudbar.last
		var lerp_value: float = 1 - pow(1 - hudbar.travel, 3)
		hudbar.travel = minf(hudbar.travel + lerpspeed, 1.0)
		hudbar.cur = hudbar.last + floori(float(diff) * lerp_value)
	
	var final_value: int = hudbar.cur
	var label_string: String = str(final_value)
	var label_string_first: String = label_string.left(-1)
	var label_string_last: String = label_string.right(1)
	
	match mode:
		0: 
			_HealthBar_Node.set_value(final_value)
			_HP_Node.set_text("[font size=22]" + label_string_first + "[/font].[font size=16]" + label_string_last + "[/font]")
		1:
			_SanityBar_Node.set_value(final_value)
			_SP_Node.set_text("[color=bbe2e4][font size=20]" + label_string_first + "[/font].[font size=15]" + label_string_last + "[/font] %")
		2:
			_Energy1Bar_Node.set_value(final_value)
			_Energy1_Node.set_text("[color=bbe2e4][font size=20]" + label_string_first + "[/font].[font size=15]" + label_string_last + "[/font] %")
		3:
			_Energy2Bar_Node.set_value(final_value)
			_Energy2_Node.set_text("[color=bbe2e4][font size=20]" + label_string_first + "[/font].[font size=15]" + label_string_last + "[/font] %")

class HudBar extends RefCounted:
	var travel: float = 0.0
	var cur: int = 0
	var last: int = 0
	var goal: int = 0
