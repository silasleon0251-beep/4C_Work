# HistoryPanel.gd
# 历史记录面板UI控制器
extends Control

# 节点预加载：滚动容器（承载历史记录的滚动区域）
@onready var _scroll_container: ScrollContainer = $ScrollContainer
# 节点预加载：垂直布局容器（用于自动排列所有历史记录文本）
@onready var _vbox: VBoxContainer = $ScrollContainer/VBoxContainer
# 节点预加载：关闭按钮（点击关闭历史面板）
@onready var _close_button: Button = $CloseButton

# 私有变量：存储对话管理器实例，用于控制对话显示状态
var _dialogue_manager: MyGame_DialogueManagerExampleBalloon = null

# 【全局字体配置】改这里就行！
# 导出变量：自定义字体文件路径（可在编辑器直接修改）
@export var font_path: String = "res://Resource/typeface/AlimamaFangYuanTiVF-Thin-2.ttf"  # 你的字体路径
# 私有变量：加载后的字体资源，供所有历史记录文本使用
var _custom_font: FontFile = null

# 节点初始化完成时执行（节点进入场景树并准备就绪）
func _ready() -> void:
	# 初始化隐藏面板
	hide()
	visible = false
	# 提前加载自定义字体，避免运行时卡顿
	_load_custom_font()
	# 连接关闭按钮的点击信号
	_close_button.pressed.connect(_on_close_pressed)
	# 连接历史记录更新信号（先判断避免重复连接报错）
	if not HistoryManager.history_updated.is_connected(_on_history_updated):
		HistoryManager.history_updated.connect(_on_history_updated)
	
	# 连接信号管理器的历史面板显隐控制信号
	SignalManager.change_visible_historypanel.connect(_update_visible)

# 加载自定义字体文件
func _load_custom_font():
	# 判断字体文件是否存在
	if FileAccess.file_exists(font_path):
		# 加载字体资源
		_custom_font = load(font_path)
		print("字体加载成功：", font_path)
	else:
		print("字体文件不存在，请检查路径：", font_path)

# 场景树节点添加时触发（全局监听节点创建）
func _on_node_added(node: Node):
	# 判断添加的节点是否为对话管理器
	if node.name == "MyExampleBalloon":
		# 连接对话管理器的就绪信号，等待管理器初始化完成
		node.connect("dialogue_manager_ready", _on_dialogue_manager_ready)

# 👇 【收到信号 → 拿到对话管理器！】
# 对话管理器就绪时触发，获取并保存管理器实例
func _on_dialogue_manager_ready(manager: Node):
	_dialogue_manager = manager
	print("成功拿到对话管理器：", manager.name)

# 更新面板可见性（根据外部信号控制）
func _update_visible(is_visibling : bool)->void:
	if self.visible:
		if is_visibling:
			open_history()
		else:
			close_history()
	

# 打开历史面板
func open_history():
	# 显示面板
	visible = true
	# 刷新历史记录显示内容
	refresh_display()
	
	# 暂停游戏内逻辑（角色、敌人、NPC等）
	pause_game_only()
	# 设置面板不受游戏暂停影响，保证UI交互正常
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# 调用信号管理器隐藏主对话气球
	DialogueSignalManager.set_dialogue_visible(false)

# 关闭历史面板
func close_history():
	# 隐藏面板
	visible = false
	# 恢复游戏内逻辑运行
	resume_game()
	# 如果游戏正在运行，恢复显示主对话气球
	if GameManager.is_game_running:
		DialogueSignalManager.set_dialogue_visible(true)

# 暂停游戏（只暂停玩家、敌人、NPC等游戏逻辑，UI完全不受影响）
func pause_game_only():
	# 遍历 GamePlay 组里所有节点，只暂停它们的逻辑
	for node in get_tree().get_nodes_in_group("GamePlay"):
		if node.is_valid() and node.has_method("set_paused"):
			node.paused = true

# 恢复游戏（恢复所有游戏逻辑节点运行）
func resume_game():
	for node in get_tree().get_nodes_in_group("GamePlay"):
		if node.is_valid() and node.has_method("set_paused"):
			node.paused = false

# 输入事件监听（全局按键处理）
func _input(event: InputEvent) -> void:
	# 判断条件：游戏运行中 + 按下历史记录按键 + 非重复触发
	if GameManager.is_game_running and Input.is_action_just_pressed("text") and not event.is_echo():
		print("H被按下!")
		# 面板显示则关闭，隐藏则打开（切换逻辑）
		if visible:
			close_history()
		else:
			open_history()

# 历史记录更新时触发（HistoryManager发射信号时执行）
func _on_history_updated(_history: Array) -> void:
	# 只有面板处于显示状态时才刷新内容，节省性能
	if visible:
		refresh_display()

# 刷新历史记录显示内容（清空旧内容 → 重新渲染所有记录）
func refresh_display() -> void:
	# 清空容器内旧内容
	_clear_container()

	# 获取历史记录数据
	var history: Array = HistoryManager.get_history()
	# 无记录时显示空文本提示
	if history.is_empty():
		_add_empty_label()
		return

	# 遍历所有历史记录并添加到容器
	for entry in history:
		_add_history_entry(entry)

	# 等待一帧后，强制滚动到底部显示最新记录
	await get_tree().process_frame
	_scroll_container.scroll_vertical = int(_scroll_container.get_v_scroll_bar().max_value)

# 清空垂直容器内的所有子节点（释放旧记录）
func _clear_container() -> void:
	for child in _vbox.get_children():
		child.queue_free()

# 统一设置标签样式
# 参数：label-目标标签 font_size-字体大小 color-文字颜色
func setup_label_style(label: Label, font_size: int = 30, color: Color = Color(1,1,1)):
	# 覆盖字体大小
	label.add_theme_font_size_override("font_size", font_size)
	# 设置文字颜色
	label.modulate = color
	# 开启自动换行（文字超出宽度自动换行）
	label.autowrap_mode = TextServer.AUTOWRAP_WORD
	# 水平填充布局（占满容器宽度）
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL

# 给标签应用自定义加载的字体
func set_label_font(label: Label):
	if _custom_font:
		label.add_theme_font_override("font", _custom_font)

# 添加空记录提示标签（无历史时显示）
func _add_empty_label() -> void:
	var label := Label.new()
	label.text = "暂无历史记录"
	# 水平居中对齐
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	# 设置样式和字体
	setup_label_style(label, 30, Color(1,1,1))
	set_label_font(label) # 应用自定义字体
	
	# 添加到垂直容器
	_vbox.add_child(label)

# 添加单条历史记录（入口方法）
func _add_history_entry(entry: Dictionary) -> void:
		# 调用标签添加方法，渲染单条记录
		_add_label_entry(entry)

# 用标签展示单条历史记录内容（核心渲染方法）
func _add_label_entry(entry: Dictionary):
	var label := Label.new()
	
	# 获取说话人名称并清理格式
	var speaker: String = entry.get("speaker", "").strip_edges()
	# 获取对话文本内容
	var text: String = entry.get("text", "")

	# 清理说话人名称：删除冒号+前后空格
	speaker = speaker.replace(":", "").strip_edges()
	speaker = speaker.strip_edges()
	
	# 无说话人时，灰色显示纯文本（旁白/描述）
	if speaker == "" or speaker == "---":
		label.text = text
		setup_label_style(label, 30, Color(0.7, 0.7, 0.7))
	# 有说话人时，白色显示带名称的对话文本
	else:
		label.text = "%s:  %s" % [speaker, text]
		setup_label_style(label, 30, Color(1,1,1))
		#print(speaker," ",text)
	
	# 应用自定义字体
	set_label_font(label)
	
	# 添加到容器显示
	_vbox.add_child(label)

# 关闭按钮点击事件
func _on_close_pressed() -> void:
	close_history()
