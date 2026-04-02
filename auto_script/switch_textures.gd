extends Node

# ===================== 背景图片路径常量 =====================

# 黄鹤楼
const BG_YUANJING: String = "res://resource/background/bg_huang_he_lou/远景黄鹤楼.jpg"
const BG_XIAOSHI: String = "res://resource/background/bg_huang_he_lou/远景黄鹤楼消失.jpg"
const BG_HHL_INSIDE: String = "res://resource/background/bg_huang_he_lou/黄鹤楼内部.png"
const BG_HHL_NIGHT: String = "res://resource/background/bg_huang_he_lou/黄鹤楼夜二楼.png"
const BG_HHL_FIRST_FLOOR: String = "res://resource/background/bg_huang_he_lou/黄鹤楼一楼.png"

# 其他背景
const BG_BEDROOM: String = "res://resource/background/bg_others/卧室.jpg"
const BG_NEWS: String = "res://resource/background/bg_others/新闻.png"
const BG_BLUE_SKY: String = "res://resource/background/bg_others/蓝天.png"
const BG_RED_DOOR: String = "res://resource/background/bg_others/朱门.png"

# 过度背景
const BG_BLACK: String = "res://resource/background/bg_transitory_stage/黑背景.png"

# 章节背景
const BG_CRAFTSMAN: String = "res://resource/background/bg_section/工匠背景图.png"
const BG_LI_BAI: String = "res://resource/background/bg_section/李白背景图.jpg"
const BG_PLAYER_1: String = "res://resource/background/bg_section/主角背景图其一.png"
const BG_PLAYER_2: String = "res://resource/background/bg_section/主角背景图其二.png"
const BG_SPRITE: String = "res://resource/background/bg_section/精灵背景图.png"

# ===================== 角色图片路径常量 =====================

# 玩家
const CHAR_PLAYER: String = "res://resource/character/player/自然_全身.png"

# 精灵
const CHAR_SPRITE: String = "res://resource/character/elf/小精灵.png"

# 李白
const CHAR_LI_BAI: String = "res://resource/character/li_bai/李白_无脚.png"

# 工匠
const CHAR_CRAFTSMAN: String = "res://resource/character/craftsman/工匠_无脚.png"

# ========================= 映射字典 ============================
# ===================== 背景名称 -> 资源路径 =====================
var background_signal_map: Dictionary = {
	
	"远景": BG_YUANJING,             # 远景黄鹤楼
	"消失": BG_XIAOSHI,              # 远景黄鹤楼消失
	"一楼": BG_HHL_FIRST_FLOOR,      # 黄鹤楼一楼
	"内部": BG_HHL_INSIDE,           # 黄鹤楼内部
	"二楼夜": BG_HHL_NIGHT,          # 黄鹤楼夜二楼
	
	"卧室": BG_BEDROOM,              # 卧室
	"新闻": BG_NEWS,                 # 新闻界面
	"蓝天": BG_BLUE_SKY,             # 蓝天背景
	"朱门": BG_RED_DOOR,             # 朱门
	
	"黑背景": BG_BLACK,              # 转场黑背景
	
	"工匠背景": BG_CRAFTSMAN,        # 工匠章节背景
	"李白背景": BG_LI_BAI,           # 李白章节背景
	"主角背景一": BG_PLAYER_1,       # 主角背景图1
	"主角背景二": BG_PLAYER_2,       # 主角背景图2
	"精灵背景": BG_SPRITE            # 精灵章节背景
}

# ========================= 映射字典 ============================
# ===================== 角色名称 -> 资源路径 =====================
var character_name_map: Dictionary = {
	"主角": CHAR_PLAYER,     # 玩家主角
	"精灵": CHAR_SPRITE,     # 小精灵角色
	"李白": CHAR_LI_BAI,     # 李白角色
	"工匠": CHAR_CRAFTSMAN   # 工匠角色
}



# ==============================================
# 全局淡入淡出切换背景
# 传入：TextureRect节点 + 图片路径
# ==============================================
func change_background_with_fade(target_node: TextureRect, image_path: String) -> void:
	if not is_instance_valid(target_node):
		print("[全局背景] 错误：目标节点无效")
		return
	if not image_path:
		print("[全局背景] 警告：图片路径为空")
		return

	var new_texture: Texture2D = load(image_path)
	if not new_texture:
		print("[全局背景] 错误：加载失败 -> ", image_path)
		return
	print("[全局背景] 加载成功 -> ", image_path)
	# 淡出动画
	var tween_out:Tween = target_node.create_tween()
	tween_out.tween_property(target_node, "modulate:a", 0.0, 0.3)
	
	# 完成后切换并淡入
	tween_out.finished.connect(func()->void:
		target_node.texture = new_texture
		var tween_in:Tween = target_node.create_tween()
		tween_in.tween_property(target_node, "modulate:a", 1.0, 0.3)
	)

# ==============================================
# 根据信号名切换背景
# 外部一行调用：GlobalAssets.change_bg_by_name(节点, "远景")
# ==============================================
func change_bg_by_name(target_node: TextureRect, bg_name: String) -> void:
	# 测试
	print("传入的节点：", target_node, " 类型：", target_node.get_class())
	print("传入的名字：", bg_name)
	
	if background_signal_map.has(bg_name):
		change_background_with_fade(target_node, background_signal_map[bg_name])
		# 测试
		print(target_node,"切换完成")
	else:
		print("[全局背景] 不存在的背景名称：", bg_name)

# ==============================================
# 显示角色（根据角色名）
# 外部一行调用：GlobalAssets.show_character(节点, "李白")
# ==============================================
func show_character(character_rect: TextureRect, char_name: String) -> void:
	if not is_instance_valid(character_rect):
		return

	character_rect.texture = null
	character_rect.visible = true

	if character_name_map.has(char_name):
		change_background_with_fade(character_rect, character_name_map[char_name])
	else:
		print("[全局角色] 不存在的角色名称：", char_name)

# ==============================================
# 隐藏角色
# ==============================================
func hide_character(character_rect: TextureRect) -> void:
	if is_instance_valid(character_rect):
		character_rect.visible = false
