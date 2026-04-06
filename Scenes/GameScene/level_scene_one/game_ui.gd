extends CanvasLayer

# 暂停面板
@onready var pause_interface: ColorRect = $PauseInterface

# 节点初始化完成时执行
func _ready() -> void:
	# 初始化隐藏颜色遮罩节点
	pause_interface.visible = false

# 每帧执行的逻辑
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("esc"):
		print("游戏暂停")
		if GameManager.is_game_running:
			_on_suspend_pressed()
		else:
			_on_continue_btn_pressed()


# 暂停按钮点击事件函数
func _on_suspend_pressed() -> void:
	# 设置全局配置：游戏暂停
	GameManager.is_game_running = false

	# 显示游戏暂停的界面
	pause_interface.visible = true

	DialogueSignalManager.set_dialogue_visible(false)
	#当游戏暂停的时候关闭历史文档
	SignalManager.change_visible_historypanel.emit(false)

# 继续游戏按钮点击事件函数
func _on_continue_btn_pressed() -> void:
	GlobalAudio.play_select()
	# 设置全局配置：游戏恢复运行
	GameManager.is_game_running = true

	# 隐藏颜色遮罩
	pause_interface.visible = false

	DialogueSignalManager.set_dialogue_visible(true)
	#当游戏恢复暂停的时候打开历史文档
	SignalManager.change_visible_historypanel.emit(true)

# 返回主界面按钮点击事件函数
func _on_return_main_pressed() -> void:
	GlobalAudio.play_select()
	# 调用渐变切换场景工具，跳转到主场景
	GradualChange.change_scene(GlobalData.START_SCENE_PATH)

func _btn_hover()->void:
	GlobalAudio.play_hover()
