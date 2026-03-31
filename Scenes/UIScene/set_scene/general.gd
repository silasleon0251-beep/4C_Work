extends CanvasLayer

# 按钮集合
@onready var basic_btn: TextureButton = $VSeparator/BasicBtn
@onready var picture_btn: TextureButton = $VSeparator/PictureBtn
@onready var control_btn: TextureButton = $VSeparator/ControlBtn

# 控件
@onready var basic_setting: CanvasLayer = $"../BasicSetting"
@onready var picture_setting: CanvasLayer = $"../PictureSetting"
@onready var control_setting: CanvasLayer = $"../ControlSetting"



# 三个按钮放进【数组】里统一管理
@onready var tab_buttons: Array = [
	basic_btn,    # 索引 0
	picture_btn,    # 索引 1
	control_btn     # 索引 2
]

@onready var setting_node: Array = [
	basic_setting,    # 索引 0
	picture_setting,    # 索引 1
	control_setting     # 索引 2
]

func _ready() -> void:
	print(self.name ,"ready 运行")
	switch_tab(0)
	
# 保存数据
func _on_save_btn_pressed() -> void:
	# 数据保存函数
	GlobalConfig.save_config()
	print("数据保存成功!")
	

# 返回开始界面
func _on_back_btn_pressed() -> void:
	GradualChange.change_scene(GlobalData.START_SCENE_PATH)
	pass # Replace with function body.

# 重置数据
func _on_reset_btn_pressed() -> void:
	$"../BasicSetting/Control".reset_slider()
	pass # Replace with function body.


func _on_test_btn_pressed() -> void:
	# TODO 临时充当数据输出的端口 TODO
	GlobalConfig.print_all_config_data()
	pass # Replace with function body.


func _on_basic_btn_pressed() -> void:
	switch_tab(0)
	print("基础设置")

func _on_picture_btn_pressed() -> void:
	switch_tab(1)
	print("画面设置")

func _on_control_btn_pressed() -> void:
	switch_tab(2)
	print("操作设置")

# 同时只显示一个设置界面
func switch_tab(show_index: int) -> void:
	 # 越界保护
	if show_index < 0 or show_index >= tab_buttons.size():
		return
	
	 # 判断是不是已经打开
	if setting_node[show_index].visible == true:
		print("按钮已经是显示状态，跳过")
		return
	
	# 遍历数组里的每一个按钮
	for i in range(tab_buttons.size()):
	
		# 判断：是不是我们要显示的那个？
		if i == show_index:
			setting_node[i].visible = true       # 显示指定按钮
		else:
			setting_node[i].visible = false      # 隐藏其他所有按钮
