extends Node

# 开始界面
const START_SCENE_PATH = "res://Scenes/UIScene/start_scene/StartScene.tscn"
# 设置界面
const SET_SCENE_PATH = "res://Scenes/UIScene/set_scene/SetScene.tscn"
# 关卡界面
const LEVEL_SCENE_PATH = "res://Scenes/SelectLevel/SelectLevel.tscn"
# 关卡
const L1_SCENE_PATH = "res://Scenes/GameScene/level_scene_one/Game1.tscn"

# 选中的关卡,数组,选中那一关,就更新为true
var change_lv : Array = []
