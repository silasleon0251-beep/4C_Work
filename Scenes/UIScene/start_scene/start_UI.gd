extends Control

# 标记是否正在退出（避免重复触发）
var is_exiting: bool = false

@onready var texture_rect: TextureRect = $TextureRect

@onready var exit_confirm_panel: ColorRect = $ExitConfirmPanel
@onready var confirm_exit_btn: TextureButton = $ExitConfirmPanel/ConfirmExitBtn
@onready var cancel_exit_btn: TextureButton = $ExitConfirmPanel/CancelExitBtn

@onready var head_line: Control = $HeadLine/HeadLine
@onready var v_box_container: VBoxContainer = $VBoxContainer



func _ready() -> void:
	print(self.name ,"    ready 运行")
	
	GlobalAudio.play_bgm("目录")
	
	set_meta("is_scene_node", true)  # 标记为场景节点
	texture_rect.visible = false
	
	

func _exit_tree() -> void:
	print(self.name, "   Destruction")

func _on_start_but_pressed() -> void:
	GlobalAudio.play_select()
	
	GradualChange.change_scene(GlobalData.LEVEL_SCENE_PATH)


func _on_set_but_pressed() -> void:
	
	GlobalAudio.play_select()
	GradualChange.change_scene(GlobalData.SET_SCENE_PATH)


# 退出游戏

# 退出按钮点击 → 只弹确认框，不直接退出
func _on_exit_pressed() -> void:
	GlobalAudio.play_select()
	show_exit_confirm()

# 显示退出确认弹窗
func show_exit_confirm() -> void:
	exit_confirm_panel.visible = true
	
	head_line.visible = false
	v_box_container.visible = false

# 取消退出
func _cancel_exit() -> void:
	exit_confirm_panel.visible = false
	GlobalAudio.play_cancel()
	head_line.visible = true
	v_box_container.visible = true

# 真正执行退出游戏（确认后才跑）
func _do_real_exit() -> void:
	if is_exiting:
		return
	is_exiting = true
	GlobalAudio.play_select()
	await get_tree().process_frame
	
	# 1. 清理SceneManager的场景缓存
	if SceneManager:
		var scene_paths:Array = SceneManager.scene_cache.keys()
		for path:String in scene_paths:
			var scene:Node = SceneManager.scene_cache[path]
			if scene and scene.is_inside_tree():
				scene.queue_free()
		SceneManager.scene_cache.clear()
		SceneManager.current_scene = null
	
	# 2. 安全清理节点
	var root:Node = get_tree().root
	for child in root.get_children():
		if child.name != "SceneManager" and (child.has_meta("is_scene_node") or child is Control):
			child.queue_free()
	
	# 退出游戏
	get_tree().quit()

# 监听窗口关闭事件（点击右上角X → 弹确认框）
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		# 拦截系统关闭，改为显示确认框
		show_exit_confirm()

func _on_easter_egg_pressed() -> void:
	GlobalAudio.play_select()
	texture_rect.visible = true



func _on_easter_egg_exit_pressed() -> void:
	texture_rect.visible = false


func _btn_hover()->void:
	GlobalAudio.play_hover()
