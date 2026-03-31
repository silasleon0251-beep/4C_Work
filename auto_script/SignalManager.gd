extends Node


# 改变历史文档的可见性
@warning_ignore("unused_signal")
signal change_visible_historypanel(is_visible : bool)

# 替换图片
@warning_ignore("unused_signal")
signal change_texture(ch_texture:String)

# 展示角色
@warning_ignore("unused_signal")
signal show_character(ch_charcter : String)
# 隐藏角色
@warning_ignore("unused_signal")
signal hide_character(ch_charcter : String)

# 游戏结束播报
@warning_ignore("unused_signal")
signal game_over 

# 选关 
# 参数：int => 关卡
@warning_ignore("unused_signal")
signal change_level(lv_num : int)
