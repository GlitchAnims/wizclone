class_name HUDCard extends PanelContainer

var tibia_ref: CardTibia = null
@onready var _CardName_Node: RichTextLabel = $"DecoPanel/CardName"
@onready var _LightCost_Node: RichTextLabel = $"DecoPanel/LightCost"
@onready var _CountInHand_Node: RichTextLabel = $"DecoPanel/CountInHand"
@onready var _CountInDiscard_Node: RichTextLabel = $"DecoPanel/CountInDiscard"

func _ready() -> void:
	if not is_instance_valid(tibia_ref): return
	_LightCost_Node.set_text(str(tibia_ref.config_ref.light_cost))
	_CardName_Node.set_text(tibia_ref.config_ref.card_name)
	self_modulate = tibia_ref.config_ref.color

var inhand_count: int = -1
var indiscard_count: int = -1

func SetCounts(inhand: int, indiscard: int) -> void:
	if inhand != inhand_count:
		inhand_count = inhand
		_CountInHand_Node.set_text(str(inhand))
	if indiscard != indiscard_count:
		indiscard_count = indiscard
		_CountInDiscard_Node.set_text(str(indiscard))
