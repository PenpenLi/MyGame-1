local WAndFChatConfig = {}

WAndFChatConfig.DEFAULT_VIEWINDEX = 1 --默认显示世界聊天界面
WAndFChatConfig.CUR_VIEWINDEX = WAndFChatConfig.DEFAULT_VIEWINDEX

-- 弹框主界面按钮 选中颜色
function WAndFChatConfig.getBtnSelectedColor()
	return 255,255,255
end
-- 弹框主界面按钮 未选中颜色
function WAndFChatConfig.getBtnUnSelectedColor()
	-- c7 7f f1
	return 199,127,241
end
-- 世界聊天 自己名字颜色
function WAndFChatConfig.getWChatSelfColor()
	-- 14 ff 00
	return 20,255,0
end
-- 世界聊天 别人名字颜色
function WAndFChatConfig.getWChatOtherColor()
	return 255,255,255
end
-- 世界聊天 消息颜色
function WAndFChatConfig.getWChatMsgColor()
	-- fa e6 ff
	return 250,230,255
end
-- 世界聊天 时间颜色
function WAndFChatConfig.getWChatTimeColor()
	-- aa 91 e6
	return 170,145,230
end

WAndFChatConfig.DEFAULT_CHAT_MAX_W = 313

-- 好友消息最大宽度
WAndFChatConfig.DEFAULT_CHAT_MSG_MAX_W = 270














return WAndFChatConfig






