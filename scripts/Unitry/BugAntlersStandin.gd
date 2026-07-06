class_name BugAntlersStandin extends Standin

func _ready_standin() -> void: pass

func _process_standin(delta: float) -> void:
	if not unit_ref.skill_using: return
	
	var skl: Skill = unit_ref.skill_selected
	var chrg: float = unit_ref.skill_charge
	
	skl.ProcessVisCharge(delta)
