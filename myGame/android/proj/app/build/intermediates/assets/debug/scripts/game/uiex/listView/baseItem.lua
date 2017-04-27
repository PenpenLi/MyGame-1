-- Listview.lua
-- Date: 2016-07-06

local BaseItem = class(Node)

function BaseItem:ctor(w, h)
    self:setSize(w,h)
    self.width_ = w
    self.height_ = h
end

function BaseItem:setData(data)
    local dataChanged = (self.data_ ~= data)
    self.data_ = data
    if self.setItemData then
        self:setItemData(dataChanged, data)
    end
    return self
end

function BaseItem:getData()
    return self.data_
end

function BaseItem:setIndex(index)
    self.index_ = index
    return self
end

function BaseItem:getIndex()
    return self.index_
end

function BaseItem:setOwner(owner)
    self.owner_ = owner
    return self
end

function BaseItem:getOwner()
    return self.owner_
end

return BaseItem