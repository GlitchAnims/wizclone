class_name HandHUD extends Control


const hudcard_scene: PackedScene = preload("res://scenes/HUD/hud_card.tscn")
@onready var CardHolder_Node: HBoxContainer = $"HBox1"
var hudcard_dict: Dictionary[int, HUDCard] = {}

func _ready() -> void:
	for child in CardHolder_Node.get_children():
		child.queue_free()


func UpdateHandVisual(unit: Unit) -> void:
	var cardset: Dictionary[int, Vector2i] = {}
	
	for id in unit.pile_hand:
		var dualcount: Vector2i = Vector2i.ZERO
		if cardset.has(id): dualcount = cardset[id]
		dualcount.x += 1
		cardset[id] = dualcount
	
	for id in unit.pile_discard:
		var dualcount: Vector2i = Vector2i.ZERO
		if cardset.has(id): dualcount = cardset[id]
		dualcount.y += 1
		cardset[id] = dualcount
	
	var destroy_list: Array[int] = []
	for id in cardset:
		var dualcount: Vector2i = cardset[id]
		var inhand: int = dualcount.x
		var indiscard: int = dualcount.y
		
		var hudcard: HUDCard = hudcard_dict.get(id, null)
		if is_instance_valid(hudcard):
			if inhand < 1 and indiscard < 1: destroy_list.push_back(id)
			else: hudcard.SetCounts(inhand, indiscard)
		else:
			hudcard = hudcard_scene.instantiate()
			hudcard.tibia_ref = GameData.tibialist_cards[id]
			CardHolder_Node.add_child(hudcard)
			hudcard_dict[id] = hudcard
			hudcard.SetCounts(inhand, indiscard)
	
	for id in destroy_list:
		hudcard_dict[id].queue_free()
		hudcard_dict.erase(id)
