extends Node

# 使用Config保存数据

var config: = ConfigFile.new()
var is_data_ok: bool = false

# 音量初始值
var default_val:int = 50
# 三个音量变量
var main_volume_value: int = 50     # 主音量
var bgm_value: int = 1              # 背景音
var sound_effect_value: int = 51    # 音效

# 临时存储 当主音量为零时其它音量也为零 当主音量不为零时,恢复原来的音量大小
var tem_bgm_value : int = 0             # 背景音
var tem_sound_value : int = 0           # 音效

# 标记：是否已经保存过临时音量值（避免重复保存）
var is_temp_volume_saved: bool = false

# 是否重置
var is_reset : bool = false

# 角色状态:情商,智商
var EQ : int:
	set(value):
		EQ = clamp(value, 0, 100)  # 限制0-100
		SignalManager.update_player_status_UI.emit()

var IQ : int:
	set(value):
		IQ = clamp(value, 0, 100)  # 限制0-100
		SignalManager.update_player_status_UI.emit()

var Luck : int:
	set(value):
		Luck = clamp(value, 0, 100)  # 限制0-100
		SignalManager.update_player_status_UI.emit()

# 数据储存位置
const CONFIG_PATH: String = "user://basic_settings.cfg"

# 游戏各章节进度

enum Chapters {
	NONE = 0,
	CHAPTER_1 = 1,
	CHAPTER_2 = 2,
	CHAPTER_3 = 3,
	CHAPTER_4 = 4,
	CHAPTER_5 = 5
}


# ====================== 剧情进度 ======================
# 全局变量：记录哪个关卡已解锁
# 默认只有第一关解锁
var unlocked_levels:Array = [null, true, false, false, false, false]

# ====================== 剧情选项标记（防止重复选择） ======================
var locals: Dictionary = {
	# chapter1
	"tried_shake": false,
	"tried_tap": false,
	"tried_blow": false,
	# chapter2
	"tried_complain": false,
	"tried_urge": false,
	"tried_giveup": false,
	# chapter3
	"blamed_elf": false,
	"apologized_much": false,
	"tried_explain": false,
	"respectful": false,
	"fan_mode": false,
	"calm": false,
	"urge_poem": false,
	"ask_gossip": false,
	"ask_strategy": false,
	"pretend_distracted": false,
	"lied_hallucination": false,
	"made_up_excuse": false,
	# chapter4
	"praised_craftsman": false,
	"asked_detail": false,
	"compared_modern": false,
	"said_underage": false,
	"said_cant_drink": false,
	"said_afraid_mess": false,
	# final
	"said_reluctant": false,
	"asked_future": false,
	"asked_contact": false,
	"formal_farewell": false,
	"promised_meet": false,
	"asked_signature": false,
	"thanked_elf": false,
	"teased_elf": false,
	"cared_compass": false,
}


func _ready()->void:
	print(self.name ,"ready 运行")
	
	# 默认初始化
	tem_bgm_value = bgm_value              # 背景音
	tem_sound_value  = sound_effect_value   # 音效
	
	EQ = 50
	IQ = 70
	Luck = 50
	
	#加载数据
	load_config()
	pass

# TODO 可以改变存储方法?? TODO

## 加载数据
func load_config()->void:
	var err:Error = config.load(CONFIG_PATH)  # 这里也对应改为 config
	if err == OK:
		# 加载基础设置
		main_volume_value = config.get_value("BasicSettings", "main_volume_value", main_volume_value)
		bgm_value = config.get_value("BasicSettings", "bgm_value", bgm_value)
		sound_effect_value = config.get_value("BasicSettings", "sound_effect_value", sound_effect_value)
		tem_bgm_value = config.get_value("BasicSettings", "tem_bgm_value", tem_bgm_value)
		tem_sound_value  = config.get_value("BasicSettings", "tem_sound_value", tem_sound_value)
		is_temp_volume_saved = config.get_value("BasicSettings", "is_temp_volume_saved", is_temp_volume_saved)
		
		# 加载角色状态
		
		# 加载关卡进度
		unlocked_levels = config.get_value("LevelProgress", "unlocked_levels", unlocked_levels)
		
		is_data_ok = true
		print("数据加载成功@")
	else:
		save_config()

## 保存数据
func save_config()->void:
	# 保存基础设置
	config.set_value("BasicSettings", "main_volume_value", main_volume_value)  # 对应改为 config
	config.set_value("BasicSettings", "bgm_value", bgm_value)
	config.set_value("BasicSettings", "sound_effect_value", sound_effect_value)
	config.set_value("BasicSettings", "tem_bgm_value", tem_bgm_value)
	config.set_value("BasicSettings", "tem_sound_value", tem_sound_value)
	config.set_value("BasicSettings", "is_temp_volume_saved", is_temp_volume_saved)
	
	# 保存角色状态
	config.set_value("BasicSettings", "tem_sound_value", tem_sound_value)
	config.set_value("BasicSettings", "is_temp_volume_saved", is_temp_volume_saved)
	
	# 保存关卡进度
	config.set_value("LevelProgress", "unlocked_levels", unlocked_levels)
	
	config.save(CONFIG_PATH)  # 对应改为 config

# 重置关卡
func reset_all_levels() -> void:
	# 恢复默认：仅第1关解锁，其余全部锁定
	unlocked_levels = [null, true, false, false, false, false]
	
	# 立即保存到配置文件
	save_config()
	
	# 调试提示
	print("✅ 关卡进度已重置：仅第1关解锁")
	print_all_config_data()


# ====================== 解锁章节 ======================
# 外部调用：解锁指定关卡（自动保存 + 防错误）
# 参数：level_num → 关卡编号（1~5）
func unlock_level(level_num: int) -> void:
	# 安全判断：关卡必须在 1~5 之间
	if level_num < 1 or level_num > 5:
		print("解锁失败：关卡编号必须是 1~5")
		return

	# 解锁目标关卡
	unlocked_levels[level_num] = true

	# 自动保存到配置文件
	save_config()

	# 提示信息
	print("成功解锁关卡 " + str(level_num))
	print("当前关卡状态：", unlocked_levels)

## 开发数据检测
## @return void
## 功能:
##     在控制台打印可被外部节点/脚本调用，方便调试和查看数据状态
func print_all_config_data() -> void:
	"""
	输出当前保存的所有配置数据到控制台
	可被外部节点/脚本调用，方便调试和查看数据状态
	"""
	print("\n===== 当前配置数据 START =====")
	print("配置文件路径: ", CONFIG_PATH)
	print("数据加载状态: ", "成功" if is_data_ok else "失败/使用默认值")
	print("-----------------------------")
	print("音量初始值: ", default_val)
	print("-----------------------------")
	print("主音量: ", main_volume_value)
	print("背景音音量: ", bgm_value)
	print("音效音量: ", sound_effect_value)
	print("-----------------------------")
	print("临时背景音音量: ", tem_bgm_value)
	print("临时音效音量: ", tem_sound_value)
	print("临时音量已保存标记: ", is_temp_volume_saved)
	print("-----------------------------")
	print("关卡解锁状态: ", unlocked_levels)
	print("===== 当前配置数据 END =====\n")


## Show the configured dialogue balloon
func show_my_dialogue_balloon(resource: DialogueResource, title: String = "", extra_game_states: Array = []) -> Node:
	var balloon_path: String = "res://Dialogue/my_example_balloon/example_balloon.tscn"
	#if not ResourceLoader.exists(balloon_path):
		#balloon_path = _get_example_balloon_path()
	return DialogueManager.show_dialogue_balloon_scene(balloon_path, resource, title, extra_game_states)
	
