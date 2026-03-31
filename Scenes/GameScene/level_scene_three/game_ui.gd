# 继承CanvasLayer节点，用于UI层级显示管理
extends CanvasLayer

# 节点预加载：获取面板容器节点
@onready var panel_container: PanelContainer = $PanelContainer
# 节点预加载：获取颜色矩形节点（用于遮罩/黑屏效果）
@onready var color_rect: ColorRect = $ColorRect

# 导出变量：背景图片显示节点（外部可拖拽赋值）
@export var background_rect: TextureRect



# 常量定义：主场景文件路径
const MAIN_PATH = "res://Scenes/UIScene/start_scene/StartScene.tscn"

# 节点初始化完成时执行
func _ready() -> void:
	# 初始化隐藏颜色遮罩节点
	color_rect.visible = false



# 每帧执行的逻辑
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("esc"):
		print("游戏暂停")
		if GlobalConfig.is_game_running:
			_on_suspend_pressed()
		else:
			_on_continue_btn_pressed()
			


# 切换背景图片的核心函数（带淡入淡出动画）
# 参数：p_path - 目标图片的资源路径
func change_background(p_path: String) -> void:

	# 空值判断：背景节点未赋值时打印错误
	if background_rect == null:
		print("错误：找不到 TextureRect 节点")
		return
	
	# 空值判断：图片路径为空时打印警告
	if p_path == null or p_path == "":
		print("警告：图片路径为空")
		return
	
	# 加载指定路径的图片纹理资源
	var new_texture: Texture = load(p_path)
	
	# 判断图片资源是否加载成功
	if new_texture:
		 # 创建补间动画：先将当前背景图片淡出（透明度变为0）
		var tween = create_tween()
		tween.tween_property(background_rect, "modulate:a", 0.0, 0.3)
		
		# 淡出动画完成后执行的回调
		tween.finished.connect(func():
			# 更换背景节点的纹理为新图片
			background_rect.texture = new_texture
			# 创建新补间动画：将新图片淡入（透明度恢复为1）
			var tween_in = create_tween()
			tween_in.tween_property(background_rect, "modulate:a", 1.0, 0.3)
		)
		# 打印背景更换成功日志
		print("成功更换背景：", p_path)
	else:
		# 图片加载失败时打印错误（提示路径问题）
		print("错误：无法加载图片，请检查路径是否正确 -> ", p_path)

# 暂停按钮点击事件函数
func _on_suspend_pressed() -> void:
	# 设置全局配置：游戏暂停
	GlobalConfig.is_game_running = false
	# 隐藏操作面板容器
	#panel_container.visible = false
	# 显示颜色遮罩（黑屏/遮罩效果）
	color_rect.visible = true

	DialogueSignalManager.set_dialogue_visible(false)
	#当游戏暂停的时候关闭历史文档
	SignalManager.change_visible_historypanel.emit(false)

# 继续游戏按钮点击事件函数
func _on_continue_btn_pressed() -> void:
	# 设置全局配置：游戏恢复运行
	GlobalConfig.is_game_running = true
	# 显示操作面板容器
	#panel_container.visible = true
	# 隐藏颜色遮罩
	color_rect.visible = false

	DialogueSignalManager.set_dialogue_visible(true)
	#当游戏恢复暂停的时候打开历史文档
	SignalManager.change_visible_historypanel.emit(true)

# 返回主界面按钮点击事件函数
func _on_return_main_pressed() -> void:
	# 调用渐变切换场景工具，跳转到主场景
	GradualChange.change_scene(MAIN_PATH)
