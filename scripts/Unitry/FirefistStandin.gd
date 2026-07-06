class_name FirefistStandin extends Standin

@onready var Sprite_Node: AnimatedSprite3D = $"GegorSprite"
func _ready_standin() -> void: pass

func _process_standin(delta: float) -> void:
	if unit_ref.info_realspeed > 1.0:
		Sprite_Node.animation = &"run"
	else:
		Sprite_Node.animation = &"default"
	
	if not unit_ref.skill_using: return
	
	var skl: Skill = unit_ref.skill_selected
	var chrg: float = unit_ref.skill_charge
	
	skl.ProcessVisCharge(delta)
