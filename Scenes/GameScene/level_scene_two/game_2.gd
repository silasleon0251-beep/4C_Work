extends Node2D

@onready var beginning: Button = $GameUI/TextureRect/Beginning



const background_1 = "res://Resource/Level/One/背景01.jpg"
const background_2 = "res://Resource/Level/One/背景02.jpg"
const background_3 = "res://Resource/Level/One/卧室.jpg"
const background_4 = "res://Resource/background/黑背景.png"
const background_5 = "res://Resource/Level/One/新闻.png"
const background_6 = "res://Resource/background/蓝天.png"
const background_7 = "res://Resource/background/朱门2.png"
const background_8 = "res://Resource/background/黄鹤楼一楼.png"
const background_9 = "res://Resource/background/黄鹤楼内部.png"
const background_10 = "res://Resource/background/黄鹤楼夜二楼.png"
const background_11 = "res://Resource/background/开始背景.png"
const background_12 = "res://Resource/background/开始背景三.png"
const background_13 = "res://Resource/background/开始背景二.png"
const background_14 = "res://Resource/background/开始背景五.png"
const background_15 = "res://Resource/background/开始背景四.png"

# 背景资源
const game_level_1_background : Array = [
	null,
	background_1,	# 远景黄鹤楼
	background_2,	# 远景黄鹤楼  消失
	background_3,	# 卧室
	background_4,	# 黑背景
	background_5,	# 新闻 
	background_6,	# 蓝天
	background_7,	# 朱门
	background_8,	# 黄鹤楼一楼
	background_9,	# 黄鹤楼内部
	background_10,	# 黄鹤楼夜二楼
	background_11,	# 工匠背景
	background_12,	# 李白背景
	background_13,	# 主角背景一
	background_14,	# 主角背景二
	background_15	# 精灵背景
]



func _ready() -> void:
	print("游戏一加载完成")
	SignalManager.change_texture.connect(_receive_signal)
	SignalManager.show_character.connect(_show_character)
	SignalManager.hide_character.connect(_hide_character)

func _exit_tree() -> void:
	print("游戏一销毁完成")



func _on_beginning_pressed() -> void:
	print(beginning.name, " 被按下")
	# 开始游戏
	GlobalConfig.show_my_dialogue_balloon(load("res://Dialogue/测试.dialogue"),"chapter2")
	global_change_background($GameUI/TextureRect,game_level_1_background[6])
	beginning.disabled = false
	beginning.visible = false

func _show_character(my_name : String):
	$GameUI/TextureRect/TextureRect.texture = null
	$GameUI/TextureRect/TextureRect.visible = true
	match my_name:
		"主角":
			global_change_background($GameUI/TextureRect/TextureRect,FunctionScript.game_character[1])
		"精灵":
			global_change_background($GameUI/TextureRect/TextureRect,FunctionScript.game_character[2])
		"李白":
			global_change_background($GameUI/TextureRect/TextureRect,FunctionScript.game_character[3])
		"工匠":
			global_change_background($GameUI/TextureRect/TextureRect,FunctionScript.game_character[4])

func _hide_character(_my_name : String):
	$GameUI/TextureRect/TextureRect.visible = false


func _receive_signal(my_texture:String):
	match my_texture:
		"远景":
			global_change_background($GameUI/TextureRect,game_level_1_background[1])
		"消失":
			global_change_background($GameUI/TextureRect,game_level_1_background[2])
		"卧室":
			global_change_background($GameUI/TextureRect,game_level_1_background[3])
		"黑背景":
			global_change_background($GameUI/TextureRect,game_level_1_background[4])
		"新闻":
			global_change_background($GameUI/TextureRect,game_level_1_background[5])
		"蓝天":
			global_change_background($GameUI/TextureRect,game_level_1_background[6])
		"朱门":
			global_change_background($GameUI/TextureRect,game_level_1_background[7])
		"一楼":
			global_change_background($GameUI/TextureRect,game_level_1_background[8])
		"内部":
			global_change_background($GameUI/TextureRect,game_level_1_background[9])
		"二楼夜":
			global_change_background($GameUI/TextureRect,game_level_1_background[10])
		"工匠背景":
			global_change_background($GameUI/TextureRect,game_level_1_background[11])
		"李白背景":
			global_change_background($GameUI/TextureRect,game_level_1_background[12])
		"主角背景一":
			global_change_background($GameUI/TextureRect,game_level_1_background[13])
		"主角背景二":
			global_change_background($GameUI/TextureRect,game_level_1_background[14])
		"精灵背景":
			global_change_background($GameUI/TextureRect,game_level_1_background[15])


# ==============================================
# 全局通用：切换背景图片（带淡入淡出动画）
# 兼容：Godot 4.0 ~ 4.5
# 参数1：target_node - 要挂载图片的目标节点（TextureRect）
# 参数2：image_path  - 目标图片的资源路径
# ==============================================
func global_change_background(target_node: TextureRect, image_path: String) -> void:
	# 1. 目标节点空值判断
	if not is_instance_valid(target_node):
		print("【全局背景切换】错误：目标节点无效或已被销毁")
		return

	# 2. 图片路径空值判断
	if image_path == null:
		print("【全局背景切换】警告：图片路径为空")
		return

	# 3. 加载图片纹理
	var new_texture: Texture2D = load(image_path)

	# 4. 加载成功 → 执行淡入淡出动画
	if new_texture:
		# 淡出当前图片（透明度 0）
		var tween_out = target_node.create_tween()
		tween_out.tween_property(target_node, "modulate:a", 0.0, 0.3)

		# 淡出完成后更换图片并淡入
		tween_out.finished.connect(func():
			target_node.texture = new_texture
			var tween_in = target_node.create_tween()
			tween_in.tween_property(target_node, "modulate:a", 1.0, 0.3)
		)

		print("【全局背景切换】成功：", image_path)
	else:
		# 5. 加载失败提示
		print("【全局背景切换】错误：无法加载图片 → ", image_path)
