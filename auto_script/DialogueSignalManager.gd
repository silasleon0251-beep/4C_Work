extends Node

# 存储当前最新可用的对话管理器实例（全局唯一引用）
var current_dialogue_manager: MyGame_DialogueManagerExampleBalloon = null

# 定义实例更新信号：当对话管理器实例变更时自动发射
# 外部脚本可监听此信号获取最新的管理器实例
signal on_manager_updated(manager: MyGame_DialogueManagerExampleBalloon)

# 常量定义：主场景文件路径
const MAIN_PATH = "res://Scenes/UIScene/start_scene/StartScene.tscn"

# ==============================
# 初始化：节点就绪时执行
# ==============================
func _ready() -> void:
	# 1. 监听DialogueManager的对话开始信号（对话加载时触发）
	# 防止重复连接：先判断是否已连接，再执行连接
	if DialogueManager and not DialogueManager.is_connected("dialogue_started", _on_dialogue_started):
		DialogueManager.connect("dialogue_started", _on_dialogue_started)
	
	# 2. 监听场景树节点添加事件（兜底方案）
	# 用于捕获手动创建/添加的对话管理器节点
	if get_tree() and not get_tree().is_connected("node_added", _on_node_added):
		get_tree().connect("node_added", _on_node_added)
	
	SignalManager.game_over.connect(_game_over)

# ==============================
# 信号回调：对话开始加载时触发
# ==============================
func _on_dialogue_started(_resource: Resource) -> void:
	# 方式1：从分组中获取对话气球节点（推荐，精准高效）
	# 前提：需要在编辑器中给气球节点设置分组 dialog_balloon
	var balloon_node:Node = get_tree().get_first_node_in_group("dialogue_balloon")
	# 判断节点存在且类型匹配
	if balloon_node and balloon_node is MyGame_DialogueManagerExampleBalloon:
		_update_manager_instance(balloon_node)
	
	# 方式2：遍历场景树查找管理器（兜底方案，分组失效时使用）
	else:
		# 递归查找名称为 MyExampleBalloon 的子节点
		var new_manager:Node = get_tree().root.find_child("MyExampleBalloon", true, false)
		if new_manager and new_manager is MyGame_DialogueManagerExampleBalloon:
			_update_manager_instance(new_manager)

# ==============================
# 信号回调：场景树新增节点时触发
# ==============================
func _on_node_added(node: Node) -> void:
	# 判断新增节点是否为目标对话管理器（名称+类型双重校验）
	if node.name == "MyExampleBalloon" and node is MyGame_DialogueManagerExampleBalloon:
		_update_manager_instance(node)

# ==============================
# 核心方法：统一更新管理器实例
# ==============================
func _update_manager_instance(new_manager: MyGame_DialogueManagerExampleBalloon) -> void:
	# 1. 覆盖旧实例，保存最新的对话管理器
	current_dialogue_manager = new_manager
	print("对话管理器实例已更新：", new_manager.name)
	
	# 2. 发射信号，通知所有监听者实例已更新
	on_manager_updated.emit(current_dialogue_manager)

# ==============================
# 外部调用方法：设置对话气球可见性
# @param is_visible: 是否显示
# @return: 操作是否成功
# ==============================
func set_dialogue_visible(is_visible: bool) -> bool:
	# 安全校验：无可用实例时直接返回失败
	if not current_dialogue_manager:
		print("错误：无可用的对话管理器实例")
		return false
	
	# 自动适配节点类型，设置可见性
	if current_dialogue_manager:
		current_dialogue_manager.visible = is_visible
	else:
		print("错误：节点不支持可见性修改")
		return false
	
	# 执行成功
	return true

func _game_over()->void:
	GradualChange.change_scene(MAIN_PATH)
