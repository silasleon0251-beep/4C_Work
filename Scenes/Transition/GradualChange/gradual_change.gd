extends CanvasLayer
@onready var my_color_rect: ColorRect = $MyColorRect
@onready var anim_gradual: AnimationPlayer = $AnimGradual

# 参数：
#   scene_path: 目标场景路径（如 "res://scenes/Game.tscn"）
#   keep_current: 是否保留当前场景（默认false，销毁非目标场景）
func change_scene(scene_path: String, keep_current: bool = false)->void:
	my_color_rect.show()
	
	# 播放淡出动画并等待完成
	await play_anim_and_wait("gradual_change", false)
	
	# 延迟切换场景（确保动画完全结束）
	#get_tree().call_deferred("change_scene_to_packed", load(scene_path))
	
	# 延迟1秒（单位：秒）
	await get_tree().create_timer(0).timeout
	# 延迟结束后执行的代码
	SceneManager.switch_scene(scene_path, keep_current)
	
	await play_anim_and_wait("gradual_change", true)
	my_color_rect.hide()
	pass
	
 
func play_anim_and_wait(anim_name:String, is_backward:bool)->void:
	if is_backward:
		anim_gradual.play_backwards(anim_name)
	else:
		anim_gradual.play(anim_name) 
		
	await anim_gradual.animation_finished  # 等待动画播放完成
	#print("动画播放完毕，执行后续逻辑（切换场景）")
