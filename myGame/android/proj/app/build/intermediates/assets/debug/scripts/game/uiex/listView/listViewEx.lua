-- Listview.lua
-- Date: 2016-07-06
-- Description : 暂时支持垂直方向，横向以后扩展

local ListViewEx= class(ScrollView,false)
function ListViewEx:ctor(params, itemClass)
    super(self,params.x,params.y,params.w,params.h,true)   

  self.itemClass_ = itemClass
end

function ListViewEx:getData()
    return self.data_
end

function ListViewEx:setData(data)
    self.data_ = data
    local oldItemNum = self.itemNum_ or 0
    self.itemNum_ = self.data_ and #self.data_ or 0
    if self.items_ then
        if oldItemNum > self.itemNum_ then
            for i = oldItemNum, self.itemNum_ + 1, -1 do
                self:removeChild(self.items_[i],true)
                table.remove(self.items_,i)
            end
        end
    else
        self.items_ = {}
    end
    

    -- 创建item
    for i = 1, self.itemNum_ do
        if not self.items_[i] then
            self.items_[i] = new(self.itemClass_)
            self.items_[i]:setAlign(kAlignTopLeft)
            self:addChild(self.items_[i])
        end
        self.items_[i]:setIndex(i)
        self.items_[i]:setData(self.data_[i])
        self.items_[i]:setOwner(self)
        local w,h = self.items_[i]:getSize()
    end

    --设置item位置
    if self.itemNum_ > 0 then
         local w,h = self.items_[1]:getSize()
         self.items_[1]:setPos(0,0)
         for i = 2, self.itemNum_ do
           local w,h = self.items_[i]:getSize()
           self.items_[i]:setPos(0,(i-1)*h)
           -- self.items_[i]:setPos(0,(i-1)*(h +10))
         end
    end

    -- 更新滚动容器
    self:update()
end

function ListViewEx:Resize() 
    --设置scrollview大小
    self.m_nodeH = 0
    for i =1, self.itemNum_ do
      local w,h = self.items_[i]:getSize()
      self.m_nodeH = self.m_nodeH + h
    end
  
    --设置item位置    
    self.items_[1]:setPos(0, 0)
    for i = 2, self.itemNum_ do
        local w,h = self.items_[i-1]:getSize()
        local _,y = self.items_[i-1]:getPos()
        self.items_[i]:setPos(0, y+h)
    end

    -- 更新滚动容器
    self:update()
end



--消息中心删除按钮
function ListViewEx:changeItem(itype)
    for i = 1, self.itemNum_ do
        self.items_[i]:changeStyle(itype)
    end   
end

--消息中心全选按钮事件
function ListViewEx:setCheck(check)
    for i = 1, self.itemNum_ do
        self.items_[i]:setCheck(check)
    end   
end


return ListViewEx