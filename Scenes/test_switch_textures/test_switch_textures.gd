extends Control


@onready var texture_rect: TextureRect = $CanvasLayer/TextureRect

func _ready() -> void:
	
	SwitchTextures.change_bg_by_name(texture_rect,"主角背景一")
	pass
