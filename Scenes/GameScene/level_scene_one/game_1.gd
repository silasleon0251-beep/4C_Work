extends CanvasLayer


@onready var background: TextureRect = $BgAndChar/Background
@onready var character: TextureRect = $BgAndChar/Character


func _ready() -> void:
	print("游戏一加载完成")
	SignalManager.change_texture.connect(_receive_signal)
	SignalManager.show_character.connect(_show_character)
	SignalManager.hide_character.connect(_hide_character)
	#SwitchTextures.change_bg_by_name(background,"主角背景一")
	character.visible = false

func _exit_tree() -> void:
	print("游戏一销毁完成")


func _show_character(my_name : String)->void:
	character.texture = null
	character.visible = true
	SwitchTextures.show_character(character,my_name)

func _hide_character(_my_name : String)->void:
	character.visible = false

func _receive_signal(my_texture:String)->void:
	print("收到信号:", my_texture)
	SwitchTextures.change_bg_by_name(background,my_texture)
