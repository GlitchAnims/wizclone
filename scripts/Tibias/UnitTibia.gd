class_name UnitTibia extends Tibia

var config_ref: UnitConfig = null

func _init(config: UnitConfig, idx: int):
	config_ref = config
	tibia_id = idx
