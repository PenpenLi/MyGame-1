-- AboutPopup.lua
-- Date : 2016-08-25
-- Description: a scene in login moudle
local PopupModel = import('game.popup.popupModel')
local firstRechargeView = require(VIEW_PATH .. "firstRecharge/firstRecharge_layer")
local firstRechargeInfo = VIEW_PATH .. "firstRecharge/firstRecharge_layer_layout_var"
local PayManager = require("game.store.pay.payManager")
local FirstPayTypeItem = require("game.firstRecharge.FirstPayTypeItem")
local FirstRechargePopup= class(PopupModel);

local REWARD_COUNT = 3  --几个奖励栏

function FirstRechargePopup.show(data)
	PopupModel.show(FirstRechargePopup, firstRechargeView, firstRechargeInfo, {name="FirstRechargePopup"}, data)
end

function FirstRechargePopup.hide()
    PopupModel.hide(FirstRechargePopup)
end

function FirstRechargePopup:ctor(viewConfig)
	Log.printInfo("FirstRechargePopup.ctor");
    self:addShadowLayer(kImageMap.common_transparent_blank)
    nk.AnalyticsManager:report("New_Gaple_firstRecharge", "firstRecharge")
    self:initLayer()
    self:requestFirstRechargeData()

    self.onFirstRechargeStatusHandle_ = nk.DataProxy:addPropertyObserver(nk.dataKeys.USER_DATA, "firstRechargeStatus", handler(self, self.firstRechargeStatus))
end 

function FirstRechargePopup:dtor()
    Log.printInfo("FirstRechargePopup.dtor");
    nk.DataProxy:removePropertyObserver(nk.dataKeys.USER_DATA, "firstRechargeStatus", self.onFirstRechargeStatusHandle_)
end 

function FirstRechargePopup:initLayer()
    self:initWidget()
end

function FirstRechargePopup:initWidget()
    self.image_bg_ = self:getUI("Image_bg")  
    self.View_tip_ = self:getUI("View_tip")

    self.selectedTypeView = self:getUI("typeTxt")  
    self.selectedTypeView:setFile("res/common/common_blank.png")

    self.selectedAmount = self:getUI("amountTxt")
    self.selectedAmount:setText("")

    self.payTypeTxt = self:getUI("payTypeTitle")
    self.payTypeTxt:setText(bm.LangUtil.getText("STORE", "FIRST_RECHARGE_TYPE_SELECT"))

    self.payAmountTxt = self:getUI("payAmountTitle")
    self.payAmountTxt:setText(bm.LangUtil.getText("STORE", "FIRST_RECHARGE_AMOUNT_SELECT"))

    self.typeList = self:getUI("ListView50")
    self.typeList:setVisible(false)

    self.payBtn = self:getUI("Button36")

    self.buyBtnTxt = self:getUI("buyBtnTxt")
    self.buyBtnTxt:setText(bm.LangUtil.getText("STORE", "BUY"))

    self.moreRewardContainer = {}
    self.image_reward_list_={}
    self.text_reward_list_ ={}
    for i = 1,REWARD_COUNT  do
        table.insert(self.moreRewardContainer,self:getUI("rewardView" .. i))

        table.insert(self.image_reward_list_,self:getUI("Image_reward" .. i))
        table.insert(self.text_reward_list_,self:getUI("Text_reward" .. i))
    end
    self:addCloseBtn(self.image_bg_,24,100)
    -- self:getUI("Text_type_title"):setText(bm.LangUtil.getText("STORE", "FIRST_RECHARGE_PAYTYPE"))
end

function FirstRechargePopup:onShowTypeList()
    local isShow = self.typeList:getVisible()
    if self.isInit then
        if not isShow then
            self.typeList:setVisible(true)

            local t = self:getPayTypeArray()
            Log.dump(t, ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>> getPayTypeArray")
            for i = 1 , self.adapter:getCount() do 
                local item = self.adapter:getView(i)
                item:setData(t[i])
            end
        else
            self.typeList:setVisible(false)
        end
    end
end

--支付方式数组,包含了是否选中
function FirstRechargePopup:getPayTypeArray()
    local target = {}
    if self.contentData then
        local kArray = table.keys(self.contentData.list)
        for k,v in ipairs(kArray) do 
            v = checkint(v)
            local t = {}
            t.pmode = v
            t.isSelected = self.curType == t.pmode

            table.insert(target,t)
        end
    end

    return target
end

--该支付类型的所有商品
function FirstRechargePopup:getPayAmountArray()
    local temp = {}
    local dict = self.contentData.list[tostring(self.curType)] or {}

    for k, v in pairs(dict) do 
        table.insert(temp,v)
    end
    return temp
end

--首充赠送的礼物
function FirstRechargePopup:createMoreReward()
    local rewardArray 
    if self.finalPayData and self.finalPayData.prize then
        rewardArray = self.finalPayData.prize
    elseif self.contentData.default_prize then
        rewardArray = self.contentData.default_prize

        if self.contentData.default_prize.prize then
            rewardArray = self.contentData.default_prize.prize
        end
    end

    if not rewardArray then
        return
    end

    --赠送信息
    if self.finalPayData then
        local price = self.finalPayData.price or 0
        self.tip = new(RichText, bm.LangUtil.getText("STORE", "FIRST_RECHARGE_TIP_2",price), 300, 45, kAlignLeft, "", 20, 255, 255, 255,true)
        self.tip:addTo(self.View_tip_)
    end

    for i = 1 , REWARD_COUNT do
        local v = rewardArray[i]

        if v then
            local pos = string.find(v[2], "http")
            if pos then
                UrlImage.spriteSetUrl(self.image_reward_list_[i], v[2],true)
            end

            self.text_reward_list_[i]:setText(v[1])

            -- if v[3] == 1 then
            --     self.image_ex_list_[i]:setVisible(true)
            -- else
            --     self.image_ex_list_[i]:setVisible(false)
            -- end
        else
            self.moreRewardContainer[i]:setVisible(false)
        end

    end   

     
end

function FirstRechargePopup:onClickPay()
    self:onPay_()
end

function FirstRechargePopup:onPay_()
    if not self.isInit then
        nk.TopTipManager:showTopTip(T("配置加载中"))
        return
    end
    if not self.finalPayData then
        return
    end

    --发起支付的字段是pid
    self.finalPayData.pid = self.finalPayData.id
    local pmode = checkint(self.finalPayData.pmode)

    Log.dump(self.finalPayData, ">>>>>>>>>>>>>>>>>>>>>>>>>>>>> self.finalPayData")

    self.payManager_ = PayManager:getInstance()
    self.payServer_ = self.payManager_:getQickPay(pmode)
    self.payServer_:makeBuy(self.finalPayData.id,self.finalPayData)
    nk.AnalyticsManager:report("New_Gaple_firstRecharge_buy", "firstRecharge")
end

function FirstRechargePopup:purchaseResult_(succ, result)
    if succ then
        self.history_ = nil
        self:loadHistory()
        bm.EventCenter:dispatchEvent(nk.eventNames.ROOM_REFRESH_HDDJ_NUM)

        local userData = nk.userData
        local monitorMoney = nk.getMoney(true)
        local retryTimes = 4
        local monitorMoneyChange
        monitorMoneyChange = function()
            bm.HttpService.POST({mod="user", act="getUserProperty"}, function(ret)
                    local js = json.decode(ret)
                    if js then
                        if js.money ~= monitorMoney then
                            -- userData["aUser.money"] = js.money
                            nk.setMoney(js.money,true)
                            return
                        end
                    end
                    retryTimes = retryTimes - 1
                    if retryTimes > 0 then
                        self.schedulerPool_:delayCall(monitorMoneyChange, 10)
                    end
                end, function()
                    retryTimes = retryTimes - 1
                    if retryTimes > 0 then
                        self.schedulerPool_:delayCall(monitorMoneyChange, 10)
                    end
                end)
        end
        monitorMoneyChange()
    end
end

function FirstRechargePopup:requestFirstRechargeData()
    self:setLoading(true)

    local url = nk.userData.MONTH_FIRST_PAY_JSON
    local CacheHelper = require("game.cache.cache")
    local cacheHelper = new(CacheHelper)
    Log.dump(url, ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> MONTH_FIRST_PAY_JSON")

    cacheHelper:cacheFile(url,function(result, content, stype)
        self:setLoading(false)
        if result then
            Log:printInfo("success loading MONTH_FIRST_PAY_JSON")
            self.isInit = true
            self.contentData = content

            Log.dump(self.contentData,">>>>>>>>>>>>>>>>>>>>>>> self.contentData")

            if not tolua.isnull(self) then
                self.adapter = new(CacheAdapter, FirstPayTypeItem,self:getPayTypeArray())
                self.typeList:setAdapter(self.adapter)
                self.typeList:setOnItemClick(self,self.onTypeItemClick)
                --默认用玩家上一次的支付方式

                self:onTypeSelected(nk.updateFunctions.getUserLastPayData())
                
                --在上面设置了默认商品后，才创建赠品列表
                self:createMoreReward()
            end
        else
            Log:printInfo("error loading MONTH_FIRST_PAY_JSON")
        end
    end)
end
function FirstRechargePopup:onTypeItemClick(adapter,view,index,viewX,viewY)
    self.typeList:setVisible(false)
    local data = adapter:getData()[index]
    --如果该支付方式是上次支付的，选中的时候优先展示上次支付的商品
    local lastPay = nk.updateFunctions.getUserLastPayData()
    if lastPay and lastPay.pmode == data.pmode then
        data.id = lastPay.id
    end

    self:onTypeSelected(data)
end
function FirstRechargePopup:onTypeSelected(data)
    self.curType = checkint(data.pmode)

    local index = self.curType

    self.selectedTypeView:setFile("res/payType/first_recharge_"..index.."_icon.png")

    --找出默认的商品，如果没有就第一个
    self:onAmountSelected(self:getGoodsIndex(self:getPayAmountArray(), data.id))
end

function FirstRechargePopup:getGoodsIndex(arr,id)
    for k,v in pairs(arr) do
        if checkint(v.id) == checkint(id) then
            return v,k
        end
    end
    return arr[1],1
end
function FirstRechargePopup:onRefreshGoods()
    if self.tempIndex then
        local arr = self:getPayAmountArray()

        self.tempIndex = (self.tempIndex + 1) > #arr and 1 or (self.tempIndex + 1)

        self:onAmountSelected(arr[self.tempIndex],self.tempIndex)
    end
end

function FirstRechargePopup:onAmountSelected(data,index)
    if data then
        local str = nk.updateFunctions.formatBigNumber(data.pamount) .." ".. data.currency .. " = " ..data.getname
        self.selectedAmount:setText(str)
        self.finalPayData = data

        self.tempIndex = index
    end
end



function FirstRechargePopup:setLoading(isLoading)
    if isLoading then
        if not self.juhua_ then
            self.juhua_ =  new(nk.LoadingAnim)
            self.juhua_:addLoading(self.image_bg_)    
        end
        self.juhua_:onLoadingStart()
    else
        if self.juhua_ then
            self.juhua_:onLoadingRelease()
        end
    end
end

function FirstRechargePopup:firstRechargeStatus(firstRechargeStatus)
    if firstRechargeStatus and firstRechargeStatus == 0 then
        self:hide()
    end
end


return FirstRechargePopup