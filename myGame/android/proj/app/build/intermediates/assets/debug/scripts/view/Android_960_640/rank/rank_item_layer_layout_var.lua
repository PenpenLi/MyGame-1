--Created by the QnEditor,do not modify.If not,you will die very nankan!
local MAP = {
	var = {
		bg = 1,
		headButton = 2,
		headImage = 3,
		Vipk = 4,
		View_vip = 5,
		nameLabel = 6,
		goldImage = 7,
		moneyLabel = 8,
		statusLabel = 9,
		trackButton = 10,
		Text_track = 11,
		rankFirstImage = 12,
		rankNormalImage = 13,
		rankNormalLabel = 14,
		noRankLabel = 15,
		playButton = 16,
		playLabel = 17,
		detailButton = 18,
		detailLabel = 19,
		SexIcon = 20,
	},
	ui = {
		[1] = {"bg"},
		[2] = {"bg","headButton"},
		[3] = {"bg","headButton","headImage"},
		[4] = {"bg","headButton","Vipk"},
		[5] = {"bg","View_vip"},
		[6] = {"bg","nameLabel"},
		[7] = {"bg","goldImage"},
		[8] = {"bg","moneyLabel"},
		[9] = {"bg","statusLabel"},
		[10] = {"bg","trackButton"},
		[11] = {"bg","trackButton","Text_track"},
		[12] = {"bg","rankFirstImage"},
		[13] = {"bg","rankNormalImage"},
		[14] = {"bg","rankNormalImage","rankNormalLabel"},
		[15] = {"bg","noRankLabel"},
		[16] = {"bg","playButton"},
		[17] = {"bg","playButton","playLabel"},
		[18] = {"bg","detailButton"},
		[19] = {"bg","detailButton","detailLabel"},
		[20] = {"bg","SexIcon"},
	},
	func = {
		[2] = "onHeadButtonClick",
		[10] = "onTrackButtonClick",
		[16] = "onPlayButtonClick",
		[18] = "onDetailButtonClick",
	},
}
return MAP;