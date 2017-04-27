
local LoadGiftControl = import(".loadGiftControl")
local GiftShopController = class()

function GiftShopController:ctor(view)

    self.view_ = view

    self.mainViewIndex = 1

    self.hotGift_ = {}
    self.boutiqueGift_ = {}
    self.festivalGift_ = {}
    self.otherGift_ = {}
    self.fifthGift_ = {}

    self.classifyGiftData = {
        [1] = self.hotGift_,
        [2] = self.boutiqueGift_,
        [3] = self.festivalGift_,
        [4] = self.otherGift_,
        [5] = self.fifthGift_,
    }

    self.selfBuyGiftData = {}
    self.friendPresentData = {}
    self.systemPresentData = {}
    self.allPresentData = {}  -- all 是后加的，虽然显示为第一项，放到这里数组4

    self.classifyMyGiftData = {
        [1] = self.selfBuyGiftData,
        [2] = self.friendPresentData,
        [3] = self.systemPresentData,
        [4] = self.allPresentData -- all 是后加的，虽然显示为第一项，放到这里数组4
    }


    self.uid_ = 0
    self.tableUidArr_ = 0
    self.toUidArr_ = 0
    self.selectGiftId_ = nil

    self:requestMyGiftData_()
    self:requestShopGiftData_()
end

function GiftShopController:dtor()

end

function GiftShopController:setMainViewIndex(index)
    self.mainViewIndex = index
end

function GiftShopController:getMainViewIndex(index)
    return self.mainViewIndex
end

function GiftShopController:requestShopGiftData_()
    if not self.selfShopGiftData then
        LoadGiftControl:getInstance():loadConfig(nk.userData.GIFT_JSON, function(success, data)
            if success then
                -- self.view_:setLoading(false)
                self.selfShopGiftData = data or {}
                for i=1,#self.selfShopGiftData do
                    if self.selfShopGiftData[i].status == "1"  then

                        if self.selfShopGiftData[i].gift_category == "0" then
                            table.insert(self.hotGift_, self.selfShopGiftData[i])

                        elseif self.selfShopGiftData[i].gift_category == "1" then
                            table.insert(self.boutiqueGift_, self.selfShopGiftData[i])

                        elseif self.selfShopGiftData[i].gift_category == "2" then
                            table.insert(self.festivalGift_, self.selfShopGiftData[i])

                        elseif  self.selfShopGiftData[i].gift_category == "3" then 
                            table.insert(self.otherGift_, self.selfShopGiftData[i])

                        elseif  self.selfShopGiftData[i].gift_category == "4" then 
                            table.insert(self.fifthGift_, self.selfShopGiftData[i])
                        end
                    end
                end
                EventDispatcher.getInstance():dispatch(EventConstants.refreshGiftPopup)
            else
                -- self.view_:setLoading(false)
            end
        end)
    end
    
end

function GiftShopController:requestMyGiftData_()
    if self.myGiftRequesting_ then return end
    local request
    local retry = 3
    request = function()
        self.myGiftRequesting_ = true
        local params = {}
        --[[
            pmode   string  否   礼物获取类型（2.自己购买，3.系统赠送，4.别人赠送）    2，3，4
            type    int     否   区分1.5.0以前老版本    1 
        ]]
    	params.pmode = "2,3,4"
        params.type = 1
        nk.HttpController:execute("getMyGiftInfo", {game_param = params}, nil, handler(self, function (obj, errorCode, data)
	        if errorCode == 1 and data and data.code == 1 then
	    		self:onGetMyGiftData_(data.data)
                EventDispatcher.getInstance():dispatch(EventConstants.refreshGiftPopup)
	        else
	        	retry = retry - 1
	            if retry > 0 then
	                request()
	            else
	                self.myGiftRequesting_ = false
	                local args = {
					    messageText = bm.LangUtil.getText("COMMON", "REQUEST_DATA_FAIL"), 
					    secondBtnText = bm.LangUtil.getText("COMMON", "RETRY"), 
					    callback = function (type)
					        if type == nk.Dialog.SECOND_BTN_CLICK then
	                            retry = 3
	                            request()
	                        end
					    end
					}
					nk.PopupManager:addPopup(nk.Dialog,"login",args)
	            end
	        end
	    end ))
    end
    request()
end

--pmode:'0,1,2,3,4,5'   //道具来源，0系统 1管理员添加 2商城购买 3好友赠送 4任务获得 5使用道具获得
-- 礼物获取类型（2.自己购买，3.系统赠送，4.别人赠送） 1.5.0
function GiftShopController:onGetMyGiftData_(data)
    self.myGiftRequesting_ = false
    if data then
        self.selfMyGiftData = data
        if self.selfMyGiftData and self.selfShopGiftData then
            for i=1,#self.selfShopGiftData do
                for j=1,#self.selfMyGiftData do
                    if checkint(self.selfMyGiftData[j].pmode) == 2 and  (checkint(self.selfMyGiftData[j].pnid) ==  checkint(self.selfShopGiftData[i].pnid)) then
                        self.selfMyGiftData[j].image = self.selfShopGiftData[i].image
                        self.selfMyGiftData[j].money = self.selfShopGiftData[i].money
                        self.selfMyGiftData[j].desc = self.selfShopGiftData[i].desc -- 礼物描述
                        self.selfMyGiftData[j].expire = self.selfMyGiftData[j].day  -- 期限用mygift的，shop是固定的
                        self.selfMyGiftData[j].giftType = 1
                        table.insert(self.selfBuyGiftData, self.selfMyGiftData[j])
                        self:insertAllData(self.selfMyGiftData[j])
                    elseif checkint(self.selfMyGiftData[j].pmode) == 3 and (checkint(self.selfMyGiftData[j].pnid) ==  checkint(self.selfShopGiftData[i].pnid)) then
                        self.selfMyGiftData[j].image = self.selfShopGiftData[i].image
                        self.selfMyGiftData[j].money = self.selfShopGiftData[i].money
                        self.selfMyGiftData[j].desc = self.selfShopGiftData[i].desc -- 礼物描述
                        self.selfMyGiftData[j].expire = self.selfMyGiftData[j].day
                        self.selfMyGiftData[j].giftType = 1
                        table.insert(self.systemPresentData, self.selfMyGiftData[j])
                        self:insertAllData(self.selfMyGiftData[j])
                    elseif checkint(self.selfMyGiftData[j].pmode) == 4 and (checkint(self.selfMyGiftData[j].pnid) ==  checkint(self.selfShopGiftData[i].pnid)) then
                        self.selfMyGiftData[j].image = self.selfShopGiftData[i].image
                        self.selfMyGiftData[j].money = self.selfShopGiftData[i].money
                        self.selfMyGiftData[j].desc = self.selfShopGiftData[i].desc -- 礼物描述
                        self.selfMyGiftData[j].expire = self.selfMyGiftData[j].day
                        self.selfMyGiftData[j].giftType = 1
                        table.insert(self.friendPresentData, self.selfMyGiftData[j])
                        self:insertAllData(self.selfMyGiftData[j])
                    end
                end
            end
        else
            --重置数据
        end
    else
        -- 重置数据
    end

end

function GiftShopController:insertAllData(data)
    -- 重复的pid只显示最大天数的
    local flag = 1
    for k,v in pairs(self.allPresentData) do
        if (checkint(data.pnid) == checkint(v.pnid)) then
            if (checkint(data.day) > checkint(v.day)) then
                table.remove(self.allPresentData, k)
                break
            else
                flag = 0
            end
        end
    end

    if flag == 1 then
        table.insert(self.allPresentData, data)
    end
end

--[[
self.selfMyGiftData
-- -       data    {time=1470990464 code=1 exetime=0.002039909362793 codemsg="" data={} sid="1" }  
--         time    1470990464  number
--         code    1   number
--         exetime 0.002039909362793   number
--         codemsg ""  string
-- -       data    {[1]={} }   
-- -       [1] {pmode="3" day=1 pnid=1 }   
--         pmode   "3" string
--         day 1   number
--         pnid    1   number
--         sid "1" string
--]]



--[[
self.selfShopGiftData   {[1]={} [2]={} [3]={} [4]={} [5]={} [6]={} [7]={} [8]={} [9]={} [10]={} [11]={} [12]={} [13]={} [14]={} [15]={} [16]={} [17]={} [18]={} [19]={} [20]={} ...}    
-       [1] {status="1" image="https://mvgliddn01-static.akamaized.net/dominogaple/androidid/gifts/gift-1.png?1466064830" name="装饰品" pnid="1" money="100000" expire="2" cnname="装饰品" gift_category="0" }    
        status  "1" string
        image   "https://mvgliddn01-static.akamaized.net/dominogaple/androidid/gifts/gift-1.png?1466064830" string
        name    "装饰品"   string
        pnid    "1" string
        money   "100000"    string
        expire  "2" string
        cnname  "装饰品"   string
        gift_category   "0" string
+       [2] {status="1" image="https://mvgliddn01-static.akamaized.net/dominogaple/androidid/gifts/gift-2.png?1466064830" name="手套" pnid="2" money="150000" expire="2" cnname="手套" gift_category="0" }  
+       [3] {status="1" image="https://mvgliddn01-static.akamaized.net/dominogaple/androidid/gifts/gift-3.png?1466064830" name="冰淇淋" pnid="3" money="150000" expire="2" cnname="冰淇淋" gift_category="0" }    
+       [4] {status="1" image="https://mvgliddn01-static.akamaized.net/dominogaple/androidid/gifts/gift-4.png?1466064830" name="玩偶" pnid="4" money="200000" expire="2" cnname="玩偶" gift_category="0" }  
+       [5] {status="1" image="https://mvgliddn01-static.akamaized.net/dominogaple/androidid/gifts/gift-5.png?1466064830" name="巧克力" pnid="5" money="200000" expire="2" cnname="巧克力" gift_category="0" }    
+       [6] {status="1" image="https://mvgliddn01-static.akamaized.net/dominogaple/androidid/gifts/gift-6.png?1466064830" name="咖啡" pnid="6" money="150000" expire="2" cnname="咖啡" gift_category="0" }  
+       [7] {status="1" image="https://mvgliddn01-static.akamaized.net/dominogaple/androidid/gifts/gift-7.png?1466064830" name="蛋糕" pnid="7" money="200000" expire="2" cnname="蛋糕" gift_category="0" }  
+       [8] {status="1" image="https://mvgliddn01-static.akamaized.net/dominogaple/androidid/gifts/gift-8.png?1466064830" name="饮料" pnid="8" money="150000" expire="2" cnname="饮料" gift_category="0" }  
+       [9] {status="0" image="https://mvgliddn01-static.akamaized.net/dominogaple/androidid/gifts/gift-9.png?1466064830" name="冰淇淋" pnid="9" money="150000" expire="2" cnname="冰淇淋" gift_category="0" }    
+       [10]    {status="0" image="https://mvgliddn01-static.akamaized.net/dominogaple/androidid/gifts/gift-10.png?1466064830" name="玩偶" pnid="10" money="200000" expire="2" cnname="玩偶" gift_category="0" }    
+       [11]    {status="0" image="https://mvgliddn01-static.akamaized.net/dominogaple/androidid/gifts/gift-11.png?1466064830" name="巧克力" pnid="11" money="200000" expire="2" cnname="巧克力" gift_category="0" }  
+       [12]    {status="1" image="https://mvgliddn01-static.akamaized.net/dominogaple/androidid/gifts/gift-10001.png?1466064830" name="玫瑰" pnid="10001" money="900000" expire="3" cnname="玫瑰" gift_category="1" }  
+       [13]    {status="1" image="https://mvgliddn01-static.akamaized.net/dominogaple/androidid/gifts/gift-10002.png?1466064830" name="摆件" pnid="10002" money="900000" expire="3" cnname="摆件" gift_category="1" }  
+       [14]    {status="1" image="https://mvgliddn01-static.akamaized.net/dominogaple/androidid/gifts/gift-10003.png?1466064830" name="高尔夫球杆" pnid="10003" money="6000000" expire="3" cnname="高尔夫球杆" gift_category="1" }   
+       [15]    {status="1" image="https://mvgliddn01-static.akamaized.net/dominogaple/androidid/gifts/gift-10004.png?1466064830" name="香槟" pnid="10004" money="3000000" expire="3" cnname="香槟" gift_category="1" } 
+       [16]    {status="1" image="https://mvgliddn01-static.akamaized.net/dominogaple/androidid/gifts/gift-10005.png?1466064830" name="雪茄" pnid="10005" money="1500000" expire="3" cnname="雪茄" gift_category="1" } 
+       [17]    {status="1" image="https://mvgliddn01-static.akamaized.net/dominogaple/androidid/gifts/gift-10006.png?1466064830" name="打火机" pnid="10006" money="1500000" expire="3" cnname="打火机" gift_category="1" }   
+       [18]    {status="1" image="https://mvgliddn01-static.akamaized.net/dominogaple/androidid/gifts/gift-10007.png?1466064830" name="金奖杯" pnid="10007" money="1500000" expire="3" cnname="金奖杯" gift_category="1" }   
+       [19]    {status="1" image="https://mvgliddn01-static.akamaized.net/dominogaple/androidid/gifts/gift-20001.png?1466064830" name="名宠" pnid="20001" money="18000000" expire="4" cnname="名宠" gift_category="2" }    
+       [20]    {status="1" image="https://mvgliddn01-static.akamaized.net/dominogaple/androidid/gifts/gift-20002.png?1466064830" name="名牌包" pnid="20002" money="15000000" expire="4" cnname="名牌包" gift_category="2" }  
+       [21]    {status="1" image="https://mvgliddn01-static.akamaized.net/dominogaple/androidid/gifts/gift-20003.png?1466064830" name="金手表" pnid="20003" money="15000000" expire="4" cnname="金手表" gift_category="2" }  
+       [22]    {status="1" image="https://mvgliddn01-static.akamaized.net/dominogaple/androidid/gifts/gift-20004.png?1466064830" name="名香水" pnid="20004" money="15000000" expire="4" cnname="名香水" gift_category="2" }  
+       [23]    {status="1" image="https://mvgliddn01-static.akamaized.net/dominogaple/androidid/gifts/gift-20005.png?1466064830" name="金皇冠" pnid="20005" money="15000000" expire="4" cnname="金皇冠" gift_category="2" }  
+       [24]    {status="1" image="https://mvgliddn01-static.akamaized.net/dominogaple/androidid/gifts/gift-20006.png?1466064830" name="钻戒" pnid="20006" money="21000000" expire="4" cnname="钻戒" gift_category="2" }    
+       [25]    {status="1" image="https://mvgliddn01-static.akamaized.net/dominogaple/androidid/gifts/gift-20007.png?1466064830" name="钻石项链" pnid="20007" money="21000000" expire="4" cnname="钻石项链" gift_category="2" }    
+       [26]    {status="1" image="https://mvgliddn01-static.akamaized.net/dominogaple/androidid/gifts/gift-30001.png?1466064830" name="棒棒糖" pnid="30001" money="100000" expire="2" cnname="棒棒糖" gift_category="3" }    
+       [27]    {status="1" image="https://mvgliddn01-static.akamaized.net/dominogaple/androidid/gifts/gift-30002.png?1466064830" name="圣诞帽" pnid="30002" money="100000" expire="2" cnname="圣诞帽" gift_category="3" }    
+       [28]    {status="1" image="https://mvgliddn01-static.akamaized.net/dominogaple/androidid/gifts/gift-30003.png?1466064830" name="圣诞靴" pnid="30003" money="100000" expire="2" cnname="圣诞靴" gift_category="3" }    
+       [29]    {status="1" image="https://mvgliddn01-static.akamaized.net/dominogaple/androidid/gifts/gift-30004.png?1466064830" name="圣诞老人" pnid="30004" money="150000" expire="2" cnname="圣诞老人" gift_category="3" }  
+       [30]    {status="1" image="https://mvgliddn01-static.akamaized.net/dominogaple/androidid/gifts/gift-30005.png?1466064830" name="圣诞树" pnid="30005" money="150000" expire="2" cnname="圣诞树" gift_category="3" }    
+       [31]    {status="1" image="https://mvgliddn01-static.akamaized.net/dominogaple/androidid/gifts/gift-30006.png?1466064830" name="粽子" pnid="30006" money="600000" expire="2" cnname="粽子" gift_category="3" }  
+       [32]    {status="1" image="https://mvgliddn01-static.akamaized.net/dominogaple/androidid/gifts/gift-30007.png?1466064830" name="甜品盒子" pnid="30007" money="600000" expire="2" cnname="甜品盒子" gift_category="3" }  
+       [33]    {status="1" image="https://mvgliddn01-static.akamaized.net/dominogaple/androidid/gifts/gift-30008.png?1466064830" name="水果篮子" pnid="30008" money="600000" expire="2" cnname="水果篮子" gift_category="3" }  
+       [34]    {status="1" image="https://mvgliddn01-static.akamaized.net/dominogaple/androidid/gifts/gift-40001.png?1466064830" name="机车" pnid="40001" money="60000000" expire="10" cnname="机车" gift_category="4" }   
+       [35]    {status="1" image="https://mvgliddn01-static.akamaized.net/dominogaple/androidid/gifts/gift-40002.png?1466064830" name="跑车" pnid="40002" money="80000000" expire="10" cnname="跑车" gift_category="4" }   
+       [36]    {status="1" image="https://mvgliddn01-static.akamaized.net/dominogaple/androidid/gifts/gift-40003.png?1466064830" name="飞机" pnid="40003" money="100000000" expire="10" cnname="飞机" gift_category="4" }  
+       [37]    {status="1" image="https://mvgliddn01-static.akamaized.net/dominogaple/androidid/gifts/gift-40004.png?1466064830" name="游艇" pnid="40004" money="100000000" expire="10" cnname="游艇" gift_category="4" }  
+       [38]    {status="1" image="https://mvgliddn01-static.akamaized.net/dominogaple/androidid/gifts/gift-40005.png?1466064830" name="别墅" pnid="40005" money="280000000" expire="14" cnname="别墅" gift_category="4" }  
+       [39]    {status="1" image="https://mvgliddn01-static.akamaized.net/dominogaple/androidid/gifts/gift-40006.png?1466064830" name="城堡" pnid="40006" money="350000000" expire="14" cnname="城堡" gift_category="4" }  
+       [40]    {status="1" image="https://mvgliddn01-static.akamaized.net/dominogaple/androidid/gifts/gift-40007.png?1466064830" name="宫殿" pnid="40007" money="400000000" expire="14" cnname="宫殿" gift_category="4" }  

--]]













return GiftShopController



