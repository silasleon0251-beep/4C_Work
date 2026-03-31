extends Control

# 标记是否正在退出（避免重复触发）
var is_exiting: bool = false

@onready var texture_rect: TextureRect = $TextureRect


func _ready() -> void:
	print(self.name ,"    ready 运行")
	set_meta("is_scene_node", true)  # 标记为场景节点
	texture_rect.visible = false

func _exit_tree() -> void:
	print(self.name, "   Destruction")

func _on_start_but_pressed() -> void:
	GradualChange.change_scene(GlobalData.LEVEL_SCENE_PATH)
	pass # Replace with function body.

func _on_set_but_pressed() -> void:
	GradualChange.change_scene(GlobalData.SET_SCENE_PATH)

func _on_collect_but_pressed() -> void:
	pass # Replace with function body.

## 退出游戏
func _on_exit_pressed() -> void:
	if is_exiting:
		return  # 防止重复点击触发多次退出逻辑
	is_exiting = true
	
	#print("开始退出游戏，释放内存中...")
	
	# 1. 清理SceneManager的场景缓存（释放所有缓存的场景实例）
	if SceneManager:
		# 遍历缓存，销毁所有场景节点并清空缓存
		var scene_paths = SceneManager.scene_cache.keys()
		for path in scene_paths:
			var scene = SceneManager.scene_cache[path]
			if scene and scene.is_inside_tree():
				scene.queue_free()  # 销毁场景节点
		SceneManager.scene_cache.clear()  # 清空缓存字典
		SceneManager.current_scene = null  # 清空当前场景引用
	
	 # 2. 安全清理节点（只清理"场景节点"，不销毁根节点核心组件）
	var root = get_tree().root
	for child in root.get_children():
		# 只销毁场景节点和非核心UI，保留自动加载的SceneManager
		if child.name != "SceneManager" and (child.has_meta("is_scene_node") or child is Control):
			child.queue_free()
	
	# 3. 延迟一小段时间（确保内存释放完成），再退出游戏
	get_tree().quit()

# 监听窗口关闭事件（点击右上角X也触发内存释放）
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_on_exit_pressed()
	pass # Replace with function body.


func _on_easter_egg_pressed() -> void:
	texture_rect.visible = true
	pass # Replace with function body.


func _on_easter_egg_exit_pressed() -> void:
	texture_rect.visible = false
	pass # Replace with function body.
