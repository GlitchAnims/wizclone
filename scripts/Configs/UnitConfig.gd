class_name UnitConfig extends Resource

## Format this as follows:[br]"mod_ID" = "og_bloodfiend"[br]
##Utilizing the same identifier as another unit will overwrite it.
@export var identifier: StringName = &""
@export var unit_name: StringName = &""
@export var unit_scene: PackedScene = null
@export var standin_scene: PackedScene = preload("res://scenes/standin.tscn")

## The list of default cards that come with this unit
@export var cardconfig_default_list: Array[CardConfig] = []
@export var default_card_pool: Dictionary[CardConfig, int] = {}
#@export var default_card_arrangement: Dictionary[CardConfig, int] = {}

## For player-usable units, select a power rating that fits the
## power disparity between this unit and a default unit, up to 3x power.[br]
## This setting affects PVP and PVE variables such as respawn rates,
## enemy strength and density, and Stage effects.[br]
## It does NOT indicate canonical power level. This is a variable for automated game systems to read.[br]
## 0.4 = Gnomes[br]
## 0.5 = Sweeper[br]
## 1.0 = LCB Sinner[br]
## 2.8 = Most Color Fixers[br]
## 3.0 = Red Mist[br]
@export_range(0.4, 3.0, 0.1, "or_greater") var power_rating: float = 1.0

## Default = 1000
@export_range(10,10000,10, "or_greater") var default_hp_max: int = 1000

## Walk Speed Multiplier.[br]1.0 = Standard
@export_range(0.0, 2.0, 0.05, "or_greater") var move_speed_mult: float = 1.0
## Default Light Capacity.[br](units spawn with half this amount of Light)
@export_range(1, 20, 1, "prefer_slider", "or_greater") var default_light_max: int = 10
## Default Hand Max Size.[br](units spawn by drawing 3 cards)
@export_range(3, 15, 1, "prefer_slider", "or_greater") var default_hand_max: int = 8
## Default amount of time per Light Regeneration in seconds.
@export_range(0.2, 4.0, 0.1, "or_greater") var default_light_regen: float = 2.0
## Default amount of time per Card Draw in seconds.
@export_range(0.2, 5.0, 0.1, "or_greater") var default_card_regen: float = 2.50

@export var energy1_name: StringName = &"N/A"
@export var energy1_color: Color = Color.WHITE
@export var energy1_icon: Texture2D = preload("res://icon.svg")
@export var energy2_name: StringName = &"N/A"
@export var energy2_color: Color = Color.WHITE
@export var energy2_icon: Texture2D = preload("res://icon.svg")
