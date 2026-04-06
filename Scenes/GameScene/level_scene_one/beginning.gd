extends TextureButton

@onready var background: TextureRect = $".."
@onready var btn_bg: TextureRect = $"../BtnBg"

# 图片资源
var buton_textures : Array = [
	null,
	"res://resource/UI/章节/0_0011_第一章选中.png",
	"res://resource/UI/章节/0_0010_第一章默认.png",
	"res://resource/UI/章节/0_0008_第二章选中.png",
	"res://resource/UI/章节/0_0009_第二章默认.png",
	"res://resource/UI/章节/0_0006_第三章选中.png",
	"res://resource/UI/章节/0_0007_第三章默认.png",
	"res://resource/UI/章节/0_0002_第四章选中.png",
	"res://resource/UI/章节/0_0003_第四章默认.png",
	"res://resource/UI/章节/0_0000_第五章选中.png",
	"res://resource/UI/章节/0_0001_第五章默认.png",
]


func _ready() -> void:
	var lv_num:int = 0
	for temp:bool in GlobalData.change_lv:
		if temp :
			print(lv_num)
			change_btn_textures(lv_num)
			match lv_num:
				1:
					SwitchTextures.change_bg_by_name(background,"精灵背景")
					
				2:
					SwitchTextures.change_bg_by_name(background,"李白背景")
				3:
					SwitchTextures.change_bg_by_name(background,"工匠背景")
				4:
					SwitchTextures.change_bg_by_name(background,"主角背景一")
				5:
					SwitchTextures.change_bg_by_name(background,"主角背景二")
		else:
			lv_num += 1

func _on_beginning_pressed() -> void:
	print(self.name, " 被按下")
	GlobalAudio.play_select()
	
	var lv_num:int = 0
	for temp:bool in GlobalData.change_lv:
		if temp :
			print(lv_num)
			match lv_num:
				1:
					GlobalConfig.show_my_dialogue_balloon(load("res://Dialogue/完整版.dialogue"),"chapter1")
				2:
					GlobalConfig.show_my_dialogue_balloon(load("res://Dialogue/完整版.dialogue"),"chapter2")
				3:
					GlobalConfig.show_my_dialogue_balloon(load("res://Dialogue/完整版.dialogue"),"chapter3")
				4:
					GlobalConfig.show_my_dialogue_balloon(load("res://Dialogue/完整版.dialogue"),"chapter4")
				5:
					GlobalConfig.show_my_dialogue_balloon(load("res://Dialogue/完整版.dialogue"),"final_chapter")
		
		else:
			lv_num += 1
	
	self.disabled = false
	self.visible = false
	btn_bg.visible = false
	DialogueSignalManager.set_dialogue_visible(true)

# 切换按钮纹理
func change_btn_textures(lv_num : int)->void:
	set_button_textures(
		self,
		buton_textures[lv_num * 2],            # 默认纹理
		buton_textures[lv_num * 2 - 1],        # 选中纹理
		buton_textures[lv_num * 2],            # 按下纹理
	)
	pass

func set_button_textures(
	btn: TextureButton,
	my_normal: String,
	my_hover: String,
	my_pressed: String,
)->void:
	if not is_instance_valid(btn):
		return
	
	btn.texture_normal = load(my_normal)
	btn.texture_hover = load(my_hover)
	btn.texture_pressed = load(my_pressed)

func _btn_hover()->void:
	GlobalAudio.play_hover()
