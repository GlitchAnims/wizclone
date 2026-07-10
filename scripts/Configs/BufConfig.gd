class_name BufConfig extends Resource

## Format this as follows:[br]"mod_buf" = "og_shin"[br]
##Utilizing the same identifier as another buf will overwrite it.
@export var identifier: StringName = &""
## Card Name
@export var buf_name: StringName = &""
## Description
@export var buf_desc: StringName = &""

## Your custom buf Scene. Please inherit from the base Buf.tscn Scene.
@export var buf_scene: PackedScene = null
