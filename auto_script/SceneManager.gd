extends Node

## 全局场景管理器 - 自动加载单例
## 核心功能：场景缓存、切换、卸载，支持保留/销毁旧场景
## 使用方式：项目设置 -> 自动加载 -> 添加此脚本，命名为 SceneManager
## 调用示例：SceneManager.switch_scene("res://scenes/Game.tscn")

# 场景缓存：键=场景路径（String），值=场景实例（Node）
var scene_cache: Dictionary = {}
# 当前激活的场景节点
var current_scene: Node = null
# 场景挂载的父节点（默认用根节点，可手动指定）
var scene_parent: Node = null

## 节点就绪时初始化
## 自动将场景父节点设为场景树的根节点（root）
func _ready() -> void:
	# 初始化场景父节点（默认使用根节点/场景树的根）
	scene_parent = get_tree().root
	#print("场景管理器初始化完成，父节点：", scene_parent.name)

## 核心方法：切换场景（支持缓存复用）
## @param scene_path: 目标场景路径（如 "res://scenes/Game.tscn"）
## @param keep_current: 是否保留当前场景（默认false，销毁非目标场景）
## @note 场景会被自动标记 meta "is_scene_node" 用于区分普通节点
func switch_scene(scene_path: String, keep_current: bool = false) -> void:
	if not scene_path:
		print("错误：场景路径为空！")
		return

	# 1. 清理旧场景（非目标场景）
	if not keep_current:
		_clean_old_scenes(scene_path)

	# 2. 复用缓存场景 或 加载新场景
	if scene_path in scene_cache:
		# 复用缓存的场景实例
		_activate_scene(scene_cache[scene_path])
	else:
		# 加载并实例化新场景
		_load_and_activate_scene(scene_path)

## 内部方法：清理非目标场景（私有方法）
## @param target_scene_path: 要保留的目标场景路径
## @note 会跳过 Transition 节点、目标场景节点、非场景标记节点
func _clean_old_scenes(target_scene_path: String) -> void:
	var target_scene = scene_cache.get(target_scene_path, null)

	# 遍历父节点下所有子节点，清理场景节点（保留非场景节点如UI/过渡节点）
	for child in scene_parent.get_children():
		# 跳过目标场景、Transition过渡节点、非场景节点
		if child == target_scene or child.name == "Transition" or not child.has_meta("is_scene_node"):
			continue

		# 销毁旧场景节点并移除缓存
		#print("销毁旧场景节点：", child.name)
		child.queue_free()
		# 从缓存中移除对应引用
		for path in scene_cache:
			if scene_cache[path] == child:
				scene_cache.erase(path)
				break

## 内部方法：激活场景（显示并设为当前）
## @param target_scene: 要激活的场景节点
## @note 会自动隐藏当前场景、将目标场景加入场景树（未加入时）
func _activate_scene(target_scene: Node) -> void:
	# 隐藏当前场景
	if current_scene and current_scene != target_scene:
		current_scene.hide()

	# 将目标场景添加到场景树（如果未添加）
	if not target_scene.is_inside_tree():
		scene_parent.add_child(target_scene)

	# 显示并设为当前场景
	target_scene.show()
	current_scene = target_scene
	#print("切换到场景：", target_scene.name)

## 内部方法：加载并激活新场景
## @param scene_path: 要加载的场景路径
## @note 同步加载场景，如需异步可改用 ResourceLoader.load_threaded_request
## @warning 场景路径错误会返回空，需确保路径正确
func _load_and_activate_scene(scene_path: String) -> void:
	# 同步加载（如需异步，可改用 ResourceLoader.load_threaded_request）
	var packed_scene = load(scene_path)
	if not packed_scene:
		#print("场景加载失败：", scene_path)
		return

	# 实例化场景并标记为场景节点
	var new_scene = packed_scene.instantiate()
	new_scene.set_meta("is_scene_node", true)  # 用meta避免修改节点属性

	# 缓存场景实例
	scene_cache[scene_path] = new_scene

	# 激活新场景
	_activate_scene(new_scene)

## 公开方法：手动卸载指定场景（释放内存）
## @param scene_path: 要卸载的场景路径
## @note 卸载后会从缓存移除并销毁场景节点
func unload_scene(scene_path: String) -> void:
	if scene_path in scene_cache:
		var scene = scene_cache[scene_path]
		if scene.is_inside_tree():
			scene.queue_free()
		scene_cache.erase(scene_path)
		#print("卸载场景：", scene_path)

## 公开方法：获取当前场景路径
## @return: 当前激活场景的路径（空字符串表示无）
func get_current_scene_path() -> String:
	for path in scene_cache:
		if scene_cache[path] == current_scene:
			return path
	return ""
