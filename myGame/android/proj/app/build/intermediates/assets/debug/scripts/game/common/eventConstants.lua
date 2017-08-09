EventConstants = {}

local root = EventDispatcher.getInstance()
local event_generator = root.getUserEvent

-- http processer 事件
EventConstants.httpProcesser = event_generator(root);

-- http module 事件
EventConstants.httpModule = event_generator(root);

-- socket processer 事件
EventConstants.socketProcesser = event_generator(root);

--EventConstants.onEventCall = event_generator(root);

-- java call lua 事件
EventConstants.onEventCallBack = event_generator(root);

-- merge 合并patch包模块 事件
EventConstants.mergeModule = event_generator(root);

-- install apk 事件
EventConstants.installModule = event_generator(root);

-- store 购买 事件
EventConstants.storeBuyEvent = event_generator(root);

-- 关闭弹框
EventConstants.dismissPopupByName = event_generator(root);

-- 房间背景点击事件
EventConstants.evtBackgroundClick = event_generator(root);

-- 当前是在和呢个好友聊天
EventConstants.talkingWithWho = event_generator(root);

-- 隐藏旁观提示
EventConstants.hideWaitTips = event_generator(root)

-- 
EventConstants.serverHallBroadcastMsg = event_generator(root);
EventConstants.refreshBroadcastList = event_generator(root);

EventConstants.recFriendMsgInChatpopup = event_generator(root);

EventConstants.tryToEnterRoom = event_generator(root);
EventConstants.handCardSelected = event_generator(root);
EventConstants.tipsCardSelected = event_generator(root);
EventConstants.checkCardShow = event_generator(root);
EventConstants.handCardUsed = event_generator(root);
EventConstants.cardMoveBack = event_generator(root);

--message: click checkbox callback
EventConstants.messageCheckbox = event_generator(root)
--message: click get reward
EventConstants.messageGetRward = event_generator(root)
--task:  click  listview item callback
EventConstants.getreward = event_generator(root)
--task:  task listview changeData
EventConstants.taskChangeData = event_generator(root)
--close taskpopup
EventConstants.CloseTaskPopup = event_generator(root)
--pickImageCallBack
EventConstants.pickImageCallBack = event_generator(root)
--logout
EventConstants.logout = event_generator(root)
--PickPictureCallBack
EventConstants.PickPictureCallBack = event_generator(root)

-- 添加好友 事件
EventConstants.addFriendData = event_generator(root)

-- 删除好友 事件
EventConstants.deleteFriendData = event_generator(root)

-- 好友状态更新 事件
EventConstants.friendOnlineStatus = event_generator(root)

-- 关闭礼物弹框
EventConstants.closeGiftPopup = event_generator(root)
-- 关闭礼物弹框
EventConstants.giftSelected = event_generator(root)
-- 刷新礼物商城

EventConstants.onGiftChange = event_generator(root) --更新礼物界面右边人物的礼物

EventConstants.refreshGiftPopup = event_generator(root)

--UPDATE_SEATID_USERINFO
--打开个人信息弹窗，PHP返回后更新UserInfo
EventConstants.UPDATE_SEATID_USERINFO = event_generator(root)

-- 更新在线人数
EventConstants.UPDATE_ONLINE_NUM = event_generator(root)

-- 关闭场次选择弹框
EventConstants.showHallEnterAnim = event_generator(root)

-- 显示场次选择弹框
EventConstants.showRoomChoosePopup = event_generator(root)

-- 房间免费奖励 start
-- RFC RoomFreeChip

-- 领取宝箱奖励成功
EventConstants.getRFCBoxRewardSucc = event_generator(root)
-- 领取宝箱奖励失败
EventConstants.getRFCBoxRewardFail = event_generator(root)
-- 刷新宝箱状态
EventConstants.refreshBoxView = event_generator(root)
-- GET_COUNTDOWNBOX_REWARD -- 领取宝箱奖励后刷新座位金币
EventConstants.GET_COUNTDOWNBOX_REWARD = event_generator(root)
-- FREE_CHIP_CAN_GET_REWARD_NUM 
EventConstants.FREE_CHIP_CAN_GET_REWARD_NUM = event_generator(root)
-- FREE_CHIP_GET_LEVEL_UP_REWARD 
EventConstants.FREE_CHIP_GET_LEVEL_UP_REWARD = event_generator(root)

-- 房间免费奖励 end

--
-- 99 房新手指引
--

-- 隐藏操作指引
EventConstants.ROOM_GUIDE_HIDE_MAKE_OPERATION = event_generator(root)
-- 隐藏全部指引
EventConstants.ROOM_GUIDE_HIDE_ALL = event_generator(root)
-- 隐藏操作栏指引
EventConstants.ROOM_GUIDE_HIDE_OPERATION_BAR = event_generator(root)
-- 隐藏坐下指引
EventConstants.ROOM_GUIDE_HIDE_SIT_HERE = event_generator(root)
-- 隐藏自动看牌或弃牌指引
EventConstants.ROOM_GUIDE_HIDE_AUTO_CHECK_OR_FOLD = event_generator(root)
-- 隐藏自动跟注指引
EventConstants.ROOM_GUIDE_HIDE_AUTO_CALL = event_generator(root)
-- 隐藏跟任何注指引
EventConstants.ROOM_GUIDE_HIDE_AUTO_CALL_ANY = event_generator(root)

-- 显示操作指引
EventConstants.ROOM_GUIDE_SHOW_MAKE_OPERATION = event_generator(root)
-- 显示自动跟注指引
EventConstants.ROOM_GUIDE_SHOW_AUTO_CALL = event_generator(root)
-- 显示自动看牌或弃牌指引
EventConstants.ROOM_GUIDE_SHOW_AUTO_CHECK_OR_FOLD = event_generator(root)
-- 显示坐下指引
EventConstants.ROOM_GUIDE_SHOW_SIT_HERE = event_generator(root)
-- 显示跟任何注指引
EventConstants.ROOM_GUIDE_SHOW_AUTO_CALL_ANY = event_generator(root)

-- 赠送荷官金币 气泡
EventConstants.SEND_DEALER_CHIP_BUBBLE_VIEW = event_generator(root)

-- 向荷官发送道具
EventConstants.ROOM_DEALE_RPROP = event_generator(root)

-- socket 错误事件
EventConstants.SVR_ERROR = event_generator(root)

-- socket error
EventConstants.socketError = event_generator(root)

--购买金币成功事件
EventConstants.message_buy_gold = event_generator(root)

--update invite award
EventConstants.update_invite_award = event_generator(root)

--弃牌事件。广播手牌变黑禁止点击
EventConstants.SELF_CLICK_FOLD_CARD = event_generator(root)

--限时礼包开启
EventConstants.open_limit_time_giftbag = event_generator(root)

--限时礼包到期
EventConstants.close_limit_time_giftbag = event_generator(root)

--切换支付方式
EventConstants.change_pay_type = event_generator(root)

--用户信息回调
EventConstants.getMemberInfoCallback = event_generator(root)

--切换头像
EventConstants.change_head_icon = event_generator(root)

--更新相册
EventConstants.update_photo = event_generator(root)

-- 点赞
EventConstants.THUMB_UP = event_generator(root)

-- 限时礼包具体内容
EventConstants.getLimitTimeGift = event_generator(root)

--玩家图像更新
EventConstants.playerIconChange = event_generator(root)

--玩家金币更新
EventConstants.playerMoneyChange = event_generator(root)

-- 奖励弹窗关闭
EventConstants.rewardClosed = event_generator(root)

-- 获取抽奖配置
EventConstants.getLotteryConfig = event_generator(root)

-- 更新个人或全服活动界面
EventConstants.update_limitTimeEvent_view = event_generator(root)

-- 更新个人或全服活动界面倒计时
EventConstants.update_lTEvent_countDownTime = event_generator(root)

-- 道具发送改变
EventConstants.PROP_INFO_CHANGED = event_generator(root)

	-- 更新抽奖次数
EventConstants.updateLotteryTimes = event_generator(root)

-- 活动领取奖励结果
EventConstants.limitTimeEvent_prize_result = event_generator(root)

--免费领取红点(改成手动领取后红点才消失)
EventConstants.freeMoney = event_generator(root)

--举报色情图像、辱骂他人等
EventConstants.reportPicture = event_generator(root)

-- 游客绑定FB状态
EventConstants.updateFBBindStatus = event_generator(root)

-- 点击弹窗背景
EventConstants.onPopBgTouch = event_generator(root)

-------------------------------------------------------------------------------
-- 点击重新开始
EventConstants.restartDomoScene = event_generator(root)

-- 点击继续按钮
EventConstants.continueDomoScene = event_generator(root)

-- 点击取消按钮
EventConstants.cancelDomoScene = event_generator(root)

-- 点击上传头像
EventConstants.pickImageCallBack = event_generator(root)

-- 点击复活按钮
EventConstants.reviveDomoScene = event_generator(root)

-- 点击提示按钮
EventConstants.tipDemoScene = event_generator(root)

-- 点击拍照按钮
EventConstants.onTakePhotoDomoScene = event_generator(root)

-- 点击打开相册
EventConstants.onOpenAlbmDomoScene = event_generator(root)

-- 返回失败界面
EventConstants.failDemoScene = event_generator(root)

-- 统计按钮次数
EventConstants.btn_event_upload = event_generator(root)

-- 返回主页面
EventConstants.backHomeDomoScene = event_generator(root)

-- 上传头像成功
EventConstants.changeHeadSuccess = event_generator(root)

-- 更新设置名字
EventConstants.setNameDemoScene = event_generator(root)
