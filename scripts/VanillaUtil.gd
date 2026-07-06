class_name VanillaUtil 


static func LoadConfigFiles(dir: DirAccess) -> void:
	var currentDir: String = dir.get_current_dir() + "/"
	var filenameList: PackedStringArray = dir.get_files()
	
	for filename in filenameList:
		if filename.ends_with(".remap"): filename = filename.replace(".remap", "")
		var config: Resource = ResourceLoader.load(currentDir + filename)
		if config is UnitConfig:
			var unitConfig: UnitConfig = config as UnitConfig
			if unitConfig.identifier.is_empty(): continue
			GameData.tibiadict_unitry[unitConfig.identifier].config_ref = unitConfig
	
	var dirnameList: PackedStringArray = dir.get_directories()
	for dirname in dirnameList:
		var subDir: DirAccess = DirAccess.open(currentDir + dirname)
		LoadConfigFiles(subDir)
