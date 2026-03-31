extends Control


func _ready():
	# 初始化：刷新所有关卡按钮状态
	refresh_all_level_buttons()

func refresh_all_level_buttons() -> void:
	# 自动获取所有组名为 Level 的按钮
	for btn in get_tree().get_nodes_in_group("Level"):
		 # 获取关卡号
		var level_num = get_level_number(btn.name)
		# 设置锁定/解锁状态
		if level_num != 0:
			set_lock_level(btn, level_num)
			# 检查：只有未连接时才连接信号，避免重复连接报错
			if not btn.pressed.is_connected(_on_level_clicked.bind(btn)):
				btn.pressed.connect(_on_level_clicked.bind(btn))


# 所有关卡按钮共用的点击函数
func _on_level_clicked(button):
	# 获取关卡编号
	var level_num = get_level_number(button.name)
	# 安全判断：关卡已解锁才允许进入
	if level_num == 0 or not GlobalConfig.unlocked_levels[level_num]:
		print("❌ 关卡 " + str(level_num) + " 未解锁！")
		return
	
	match button.name:
		"LevelOne":
			load_level(GlobalData.L1_SCENE_PATH)
			#GlobalConfig.unlock_level(2)
			#print("点击了: " + button.name)
		"LevelTwo":
			load_level(GlobalData.L2_SCENE_PATH)
			#GlobalConfig.unlock_level(3)
			#print("点击了: " + button.name)
		"LevelThree":
			load_level(GlobalData.L3_SCENE_PATH)
			#GlobalConfig.unlock_level(4)
			#print("点击了: " + button.name)
		"LevelFour":
			load_level(GlobalData.L4_SCENE_PATH)
			#GlobalConfig.unlock_level(5)
			#print("点击了: " + button.name)
		"LevelFive":
			load_level(GlobalData.L5_SCENE_PATH)
			#GlobalConfig.reset_all_levels()
			#print("点击了: " + button.name)
	# 更新关卡状态
	refresh_all_level_buttons()

func load_level(scene_path : String)-> void:
	GradualChange.change_scene(scene_path)

# 自动识别关卡号（LevelOne=1, LevelTwo=2...）
func get_level_number(lv_name: String) -> int:
	match lv_name:
		"LevelOne": 
			return GlobalConfig.Chapters.CHAPTER_1
		"LevelTwo": 
			return GlobalConfig.Chapters.CHAPTER_2
		"LevelThree": 
			return GlobalConfig.Chapters.CHAPTER_3
		"LevelFour": 
			return GlobalConfig.Chapters.CHAPTER_4
		"LevelFive": 
			return GlobalConfig.Chapters.CHAPTER_5
		_: 
			return GlobalConfig.Chapters.NONE


# 设置关卡是否锁定
func set_lock_level(btn: TextureButton,level_num:int):
	btn.disabled = not GlobalConfig.unlocked_levels[level_num]  

func _on_back_start_pressed() -> void:
	GradualChange.change_scene(GlobalData.START_SCENE_PATH)


func _on_reset_pressed() -> void:
	print("重置按钮按下")
	GlobalConfig.reset_all_levels()
	refresh_all_level_buttons()
	pass # Replace with function body.
