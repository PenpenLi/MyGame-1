-- storeData.lua
-- Last modification : 2016-06-03
-- Description: a data in Store moudle

local StoreData = class();

function StoreData:ctor()
	Log.printInfo("StoreData.ctor");
end

function StoreData:dtor()
	Log.printInfo("StoreData.dtor");
end

-- 当前选中商品类型(金币、道具、购买历史)
function StoreData:setGoodsTypeViewId(str)
	self.m_goodsTypeId = str
end

function StoreData:getGoodsTypeViewId()
	return self.m_goodsTypeId
end

-- 当前选中支付类型
function StoreData:setPayViewId(str)
	self.m_payId = str
end

function StoreData:getPayViewId()
	return self.m_payId
end

-- 当前选中道具类型
function StoreData:setPropViewId(str)
	self.m_propId = str
end

function StoreData:getPropViewId()
	return self.m_propId
end

-- 可用的支付类型数据
function StoreData:setPayTypeAvailableData(data)
	self.m_payTypeAvailable = data
end

function StoreData:getPayTypeAvailableData(data)
	return self.m_payTypeAvailable
end

-- 金币商品数据
function StoreData:setGoodsData(type, data)
	if self.m_goodsData then
		self.m_goodsData[type] = data
	else
		self.m_goodsData = {}
		self.m_goodsData[type] = data
	end
end

function StoreData:getGoodsData(type)
	if self.m_goodsData and self.m_goodsData[type] then
		return self.m_goodsData[type]
	else
		return nil
	end
end

-- 道具类型数据
function StoreData:setPropTypeData(data)
	self.m_propType = data
end

function StoreData:getPropTypeData(data)
	return self.m_propType
end

-- 道具商品数据
function StoreData:setPropData(type, data)
	if self.m_propData then
		self.m_propData[type] = data
	else
		self.m_propData = {}
		self.m_propData[type] = data
	end
end

function StoreData:getPropData(type)
	if self.m_propData and self.m_propData[type] then
		local list = {}
		for k, v in pairs(self.m_propData[type]) do
			if tonumber(v.hide) ~= 1 then
				table.insert(list, v)
			end
		end
		return list
		-- return self.m_propData[type]
	else
		return nil
	end
end

-- 购买历史数据
function StoreData:setHistoryData(data)
	self.m_historyData = data
end

function StoreData:getHistoryData()
	return self.m_historyData
end

return StoreData