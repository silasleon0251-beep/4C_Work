extends Control

enum VolumeType {
	main,   # 主音量
	bgm,    # 背景音
	sound   # 音效
}

# 暴露外接节点 配置滑块
@export var main_volume_slider: HSlider
@export var bgm_volume_slider: HSlider
@export var sound_volume_slider: HSlider

# 测试音频
@onready var main_audio_test: AudioStreamPlayer2D = $MainVolume/TestButton/AudioTest
@onready var eff_audio_test: AudioStreamPlayer2D = $SoundEffect/TestButton/AudioTest
@onready var bgm_audio_test: AudioStreamPlayer2D = $BGM/TestButton/AudioTest

# 标记：是否已经保存过临时音量值（避免重复保存）
#var is_temp_volume_saved: bool = false # 存储在全局数据中

# 常量：音量映射系数（ 0.45 * value - 40 ）
const VOLUME_MULTIPLIER = 0.45
const VOLUME_OFFSET = -40
# ----------------------------------------------------------#
# ----------------------------------------------------------#
# ----------------------------------------------------------#

## 节点就绪时初始化
## 功能：
## 1. 打印就绪日志
## 2. 初始化所有音量滑块（主音量、BGM、音效）
func _ready()->void:
	print(self.name ,"ready 运行")
	
	# 初始化全局临时音量值（关键：启动时先把当前值存入全局临时变量）
	#GlobalConfig.tem_bgm_value = GlobalConfig.bgm_value
	#GlobalConfig.tem_sound_value = GlobalConfig.sound_effect_value
	
	# 初始化各个滑块
	init_slider(main_volume_slider, VolumeType.main, "主音量")
	init_slider(bgm_volume_slider, VolumeType.bgm, "背景音")
	init_slider(sound_volume_slider, VolumeType.sound, "音效")

## 初始化音量滑块
## @param slider 目标HSlider控件
## @param volume_type 音量类型（VolumeType枚举：main/bgm/sound）
## @param title_text 滑块标题文本
## @param is_reset 是否重置为配置值（默认false）
## @return void
## 功能：
## 1. 检查滑块节点是否有效，无效则打印警告
## 2. 设置滑块标题、数值显示标签
## 3. 配置滑块基础属性（最小值、最大值、步长）
## 4. 从全局配置加载初始值（重置时使用默认值）
## 5. 更新数值显示标签
## 6. 非重置状态下绑定滑块值变化信号和测试按钮点击信号
func init_slider(slider: HSlider, volume_type: VolumeType, title_text: String, is_reset:bool = false)->void:
	if not slider:
		print("警告：未配置 ", title_text, " 滑块")
		return
		
	# 1. 设置滑块基础属性
	var title_label:Label = slider.get_parent().get_node_or_null("TitlePanel/Title") 
	var num_label:Label = slider.get_parent().get_node_or_null("Panel/Number")   
	var test_btn:TextureButton = slider.get_parent().get_node_or_null("TestButton")  
	
	if title_label: title_label.text = title_text
	slider.min_value = 0
	slider.max_value = 100
	slider.step = 1
	
	# 2. 加载并设置初始值 (从GlobalConfig读取，不存在则用默认50)
	#  TODO_Finish 需要把这个数值改到全局函数里 TODO_Finish
	#var default_val = 50
	
	if not GlobalConfig.is_data_ok or is_reset:
		slider.value = GlobalConfig.default_val
	else:
		match volume_type:
			VolumeType.main:
				slider.value = GlobalConfig.main_volume_value
			VolumeType.bgm:
				slider.value = GlobalConfig.bgm_value
			VolumeType.sound:
				slider.value = GlobalConfig.sound_effect_value
		
		
	if num_label:
		num_label.text = str(int(slider.value))
	
	# 如果重置则不调用
	if not is_reset:
		# 3. 连接信号 (使用匿名函数绑定参数，避免写多个重复函数)
		slider.value_changed.connect(func(value: float)->void: _on_slider_value_changed(slider, volume_type, value))
		
		# 4. 绑定测试按钮事件
		if test_btn:
			test_btn.pressed.connect(_on_test_pressed.bind(volume_type))

## 私有：滑块值变化统一处理函数
## @param slider 触发事件的滑块控件
## @param volume_type 音量类型（VolumeType枚举）
## @param value 滑块当前数值（浮点型）
## @return void
## 功能：
## 1. 更新滑块数值显示标签
## 2. 将新值同步到全局配置对应字段
## 3. 主音量变化时触发联动逻辑
## 4. BGM/音效音量首次修改时保存临时值
func _on_slider_value_changed(slider: HSlider, volume_type: VolumeType, value: float)->void:
	var int_val:int = int(value)
	var num_label:Label = slider.get_parent().get_node_or_null("Panel/Number")
	if num_label:
		num_label.text = str(int_val)
	
	# 存储到全局配置
	match volume_type:
		VolumeType.main:
			GlobalConfig.main_volume_value = int_val
			_sync_volume_with_main()
		VolumeType.bgm:
			GlobalConfig.bgm_value = int_val
			if not GlobalConfig.is_temp_volume_saved:
				GlobalConfig.tem_bgm_value = int_val
			#print(GlobalConfig.tem_bgm_value)
		VolumeType.sound:
			GlobalConfig.sound_effect_value = int_val
			if not GlobalConfig.is_temp_volume_saved:
				GlobalConfig.tem_sound_value = int_val
			#print(GlobalConfig.tem_sound_value)
			
	# 【关键】这里可以添加实时应用音量的逻辑
	# 例如：AudioMixer.set_volume_bus("Master", ...)
	#print(title_text, " 音量更新为: ", int_val)


## 私有：测试播放按钮统一处理
## @param volume_type 音量类型（VolumeType枚举）
## @return void
## 功能：
## 1. 获取对应类型的音量值
## 2. 获取对应类型的音频播放器节点
## 3. 设置音量并播放测试音频
## 4. 打印播放日志
func _on_test_pressed(volume_type: VolumeType) -> void:
	# 只调用全局音频播放，不处理逻辑
	match volume_type:
		VolumeType.main:
			GlobalAudio.play_select()
		VolumeType.bgm:
			GlobalAudio.play_select()
		VolumeType.sound:
			GlobalAudio.play_select()

## 根据音量类型获取对应的音量值
## @param volume_type 音量类型（VolumeType枚举）
## @return float 对应类型的音量值（0~100）
## 功能：根据传入的音量类型，从全局配置中读取对应的音量数值
func _get_volume_value_by_type(volume_type: VolumeType) -> float:
	match volume_type:
		VolumeType.main:
			return GlobalConfig.main_volume_value
		VolumeType.bgm:
			return GlobalConfig.bgm_value
		VolumeType.sound:
			return GlobalConfig.sound_effect_value
	return 0  # 兜底默认值


## 处理主音量联动逻辑的核心函数
## @return void
## 功能：
## 1. 主音量为0时：
##    - 首次触发时保存BGM/音效当前音量到临时变量
##    - 将BGM/音效音量置0并更新滑块显示
##    - 禁用BGM/音效滑块编辑
## 2. 主音量非0时：
##    - 恢复之前保存的BGM/音效临时音量
##    - 更新滑块显示和全局配置
##    - 启用BGM/音效滑块编辑
##    - 重置临时音量保存标记
func _sync_volume_with_main()->void:
	# 获取当前主音量值
	var main_volume:int = GlobalConfig.main_volume_value
	
	# 主音量为 0 时，将 bgm 和 sound 音量置 0
	if main_volume == 0:
		# 只在首次置0时保存临时值
		if not GlobalConfig.is_temp_volume_saved:
			GlobalConfig.tem_bgm_value = GlobalConfig.bgm_value
			GlobalConfig.tem_sound_value = GlobalConfig.sound_effect_value
			#print("tem_bgm_value ",GlobalConfig.tem_bgm_value)
			#print("tem_sound_value ",GlobalConfig.tem_sound_value)
			#print("bgm_value ",GlobalConfig.bgm_value)
			#print("sound_value ",GlobalConfig.sound_effect_value)
			GlobalConfig.is_temp_volume_saved = true  # 标记已保存
		
		# 更新全局配置的 bgm 和 sound 音量为 0
		GlobalConfig.bgm_value = 0
		GlobalConfig.sound_effect_value = 0
		
		# 更新滑块显示
		if bgm_volume_slider:
			bgm_volume_slider.value = 0
			var bgm_num_label:Label = bgm_volume_slider.get_parent().get_node_or_null("Panel/Number")
			if bgm_num_label:
				bgm_num_label.text = "0"
		
		if sound_volume_slider:
			sound_volume_slider.value = 0
			var sound_num_label:Label = sound_volume_slider.get_parent().get_node_or_null("Panel/Number")
			if sound_num_label:
				sound_num_label.text = "0"
				
		# 禁用其余两个滑块 防止更改
		bgm_volume_slider.editable = false
		sound_volume_slider.editable = false
		
	# 主音量不为 0 时，恢复之前保存的 bgm 和 sound 音量
	else:
		#print("tem_bgm_value ",GlobalConfig.tem_bgm_value)
		#print("tem_sound_value ",GlobalConfig.tem_sound_value)
		
		if GlobalConfig.is_temp_volume_saved:
			print("开始读取临时数据!", GlobalConfig.tem_bgm_value, GlobalConfig.tem_sound_value)
			# 恢复 bgm 音量
			if GlobalConfig.tem_bgm_value != null:
				GlobalConfig.bgm_value = GlobalConfig.tem_bgm_value
				if bgm_volume_slider:
					bgm_volume_slider.value = GlobalConfig.tem_bgm_value
					var bgm_num_label:Label = bgm_volume_slider.get_parent().get_node_or_null("Panel/Number")
					if bgm_num_label:
						bgm_num_label.text = str(int(GlobalConfig.tem_bgm_value))
			
			# 恢复 sound 音量
			if GlobalConfig.tem_sound_value != null:
				GlobalConfig.sound_effect_value = GlobalConfig.tem_sound_value
				if sound_volume_slider:
					sound_volume_slider.value = GlobalConfig.tem_sound_value
					var sound_num_label:Label = sound_volume_slider.get_parent().get_node_or_null("Panel/Number")
					if sound_num_label:
						sound_num_label.text = str(int(GlobalConfig.tem_sound_value))
		GlobalConfig.is_temp_volume_saved = false  # 标记已保存
		# 重新启用
		bgm_volume_slider.editable = true
		sound_volume_slider.editable = true

## 外部调用函数, 重置数据
## @return void
## 功能：
## 调用init_slider函数并传入is_reset=true，将所有音量滑块重置为全局配置的默认值
func reset_slider()->void:
	init_slider(main_volume_slider, VolumeType.main, "主音量",true)
	init_slider(bgm_volume_slider, VolumeType.bgm, "背景音",true)
	init_slider(sound_volume_slider, VolumeType.sound, "音效",true)

func _on_test_button_pressed() -> void:
	GlobalAudio.play_select()


func _btn_hover()->void:
	GlobalAudio.play_hover()
