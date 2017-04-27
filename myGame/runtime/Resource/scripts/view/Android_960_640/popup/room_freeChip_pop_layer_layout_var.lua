--Created by the QnEditor,do not modify.If not,you will die very nankan!
local MAP = {
	var = {
		popup_bg = 1,
		daily_task = 2,
		dailyTask_icon = 3,
		dailyTask_redPoint = 4,
		dailyTask_desc = 5,
		onLine_box = 6,
		box_normal = 7,
		box_reward = 8,
		box_finished = 9,
		onLineBox_redPoint = 10,
		onLineBox_time = 11,
		level_up = 12,
		levelUp_icon = 13,
		levelUp_redPoint = 14,
		mextLevel = 15,
	},
	ui = {
		[1] = {"popup_bg"},
		[2] = {"popup_bg","daily_task"},
		[3] = {"popup_bg","daily_task","dailyTask_icon"},
		[4] = {"popup_bg","daily_task","dailyTask_redPoint"},
		[5] = {"popup_bg","daily_task","dailyTask_desc"},
		[6] = {"popup_bg","onLine_box"},
		[7] = {"popup_bg","onLine_box","box_normal"},
		[8] = {"popup_bg","onLine_box","box_reward"},
		[9] = {"popup_bg","onLine_box","box_finished"},
		[10] = {"popup_bg","onLine_box","onLineBox_redPoint"},
		[11] = {"popup_bg","onLine_box","onLineBox_time"},
		[12] = {"popup_bg","level_up"},
		[13] = {"popup_bg","level_up","levelUp_icon"},
		[14] = {"popup_bg","level_up","levelUp_redPoint"},
		[15] = {"popup_bg","level_up","mextLevel"},
	},
	func = {
		[1] = "onPopupBgTouch",
		[2] = "onDailyTaskBtnClick",
		[6] = "onOnLineBoxClick",
		[12] = "onLevelUpBtnClick",
		[15] = "onLevelUpTextTouch",
	},
}
return MAP;