
-- Date: 2016-8-10 

local UpgradeController = class()

function UpgradeController:ctor(view_)
    EventDispatcher.getInstance():register(EventConstants.httpProcesser, self, self.onHttpProcesser)
    self.view_ = view_
    self.getLevelRewardRetryTimes_ = 3
end

function UpgradeController:getReward()
    -- 领奖
    if self.rewardHttping then
        return 
    end
    self.rewardHttping = true
    
    local index = #nk.userData["invitableLevel"]
    local level = nk.userData["invitableLevel"][1]
    nk.HttpController:execute("Level.upGrade", {game_param ={level = level}})

end

function UpgradeController:onHttpProcesser(command, code, content)
    if command == "Level.upGrade" then
        if code ~= HttpErrorType.SUCCESSED then
            return 
        end
        self.rewardHttping = nil
        if not content or content.code ~= 1 then
            self.view_:setLoading(false) 
            self.view_:hide()
            return 
        end
        self:dataCallBack(code, content)
    end    
end

function UpgradeController:dataCallBack(code, content)    
    local data = content.data
    if content.code == 1 then
        nk.userData["mlevel"] = data.level;
            
        if data.money and data.addMoney then
            nk.functions.setMoney(data.money)
        end

        if data.props and (#data.props > 0) then
            --获取互动道具数量
            -- 2001 互动道具 1.0.1版本互动道具使用时直接消耗金币 jasonli
        end

        if not nk.updateFunctions.checkIsNull(self.view_) then
            self.view_:setLoading(false)

            if data.prizeText then
                self.view_:afterGetReward(data.prizeText)
            else
                self.view_:hide()
            end
            
        end

        if nk.userData["invitableLevel"] and #nk.userData["invitableLevel"] > 0 then
            table.foreach(nk.userData["invitableLevel"], function(i, v)
                if v==data.level then
                    table.remove(nk.userData["invitableLevel"],i)
                end
            end)
            if #nk.userData["invitableLevel"] > 0 then
                if nk.userData["FreeMoneyModTips"] then
                    local arrays = clone(nk.userData["FreeMoneyModTips"])
                    table.insert(arrays, 7)
                    nk.userData["FreeMoneyModTips"] = arrays;
                end
            end
        end

        -- 红点
        EventDispatcher.getInstance():dispatch(EventConstants.FREE_CHIP_GET_LEVEL_UP_REWARD)

        if not nk.updateFunctions.checkIsNull(self.view_) then
            self.view_:setIsCallback()
        end
    else
        Log.dump(content,"errData")
        if content.code then
            nk.userData.nextRwdLevel = 0
            if not nk.updateFunctions.checkIsNull(self.view_) then
                self.view_:setLoading(false)
                nk.TopTipManager:showTopTip(bm.LangUtil.getText("COUNTDOWNBOX", "REWARD_EEOR_3"))
                self.view_:setIsCallback()
                self.view_:hide()
            end
        end
    end

    --网络不好最多请求3次
    if code ~= 1 then
        if self.getLevelRewardRetryTimes_ > 0 then
             self:getReward()
             self.getLevelRewardRetryTimes_ = self.getLevelRewardRetryTimes_ - 1
        else
             nk.TopTipManager:showTopTip(bm.LangUtil.getText("COMMON", "BAD_NETWORK"))
             if not nk.updateFunctions.checkIsNull(self.view_) then
                   self.view_:setLoading(false)
             end
        end
        if not nk.updateFunctions.checkIsNull(self.view_) then
            self.view_:setIsCallback()
        end
    end
end

function UpgradeController:dtor()
    EventDispatcher.getInstance():unregister(EventConstants.httpProcesser, self, self.onHttpProcesser)
end

return UpgradeController