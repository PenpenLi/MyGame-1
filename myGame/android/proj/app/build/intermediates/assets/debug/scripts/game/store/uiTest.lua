
local test = {}
local ui = require('byui/basic')
local AL = require('byui/autolayout')
local Layout = require('byui/layout')

local rules = {
		payType_item = {
			AL.width:eq(AL.parent('width')),
	        AL.height:eq(69*LayoutScale),
	    },
        content_item = {
            AL.width:eq(200),
            AL.height:eq(AL.parent('height')),
        },
}

-- 名称
local payTypeName = {
	"ui/image.png",
	"ui/image.png",
	"ui/image.png",
	"ui/image.png",
	"ui/image.png",
}

-- 图片
local payTypeIcon = {
	"ui/button.png",
	"ui/button.png",
	"ui/button.png",
	"ui/button.png",
	"ui/button.png",
}

local strData = {"test1", "test2", "test3", "test4", "test5"}

local UiTestLayer = class(Node)

function UiTestLayer:ctor()
    self.m_root = Sprite(TextureUnit(TextureCache.instance():get("ui/button.png")))
    if self.m_root then 
        GameLayer.addChild(self,self.m_root);
    end
    self.size = Point(self.m_root.width, self.m_root.height)
end 

function UiTestLayer:dtor()

end

function test.ui_test(root, data)
	local payTypeList = ui.ListView{
        size = Point(400,400),
        row_height = 80,
        max_number = 200,
        cell_spacing = 1,
        shows_scroll_indicator = true,
    }

    payTypeList.create_cell = function(self, i)
        if not self.m_imgData[i] or not self.m_strData[i] then
            return
        end
        local c = Widget()
        c.width = 220 * LayoutScale
        c.height = 80
        -- local bg = Sprite(TextureUnit(TextureCache.instance():get(self.m_imgData[i])))
        local bg = new(UiTestLayer)
        bg:setAlign(kAlignCenter)
        c:add(bg)
        local l = Label()
        local s =self.m_strData[i] or ""
        l:set_rich_text(string.format('<font size=20 color=#ffffff>%s</font>', s))
        l.align_h = ALIGN.LEFT%4
        l.align_v = (ALIGN.LEFT - ALIGN.LEFT % 4)/4
        l:add_rules{
            AL.top:eq(30),
            AL.left:eq(75),
        }
        bg:add(l)
        c.cache = true
        c.clip = true
        return c
    end

    payTypeList.m_imgData = payTypeIcon
    payTypeList.m_strData = strData
    root:add(payTypeList)
    payTypeList:update_data()
end

function test.test_scroll(root)
    local s = ui.ScrollView{}
    s:add_rules(AL.rules.fill_parent)
    s.dimension = kVertical
    s.shows_scroll_indicator = true
    local content = Layout.FloatLayout{}
    -- local content = Widget()
    local content_item = {
            AL.width:eq(200),
            AL.height:eq(AL.parent('height')),
        }
    content:add_rules(content_item)
    content.spacing = Point(0,10)
    content.relative = true

    s.content = content
    
    for i=1, 7 do
        local c = new(UiTestLayer)
        -- c:add_rules(AL.rules.align(ALIGN.CENTER))
        -- local c = Widget()
        -- c.width = 200
        -- c.height = 200
        -- if math.fmod(i,2) == 1 then
        --     c.background_color = Colorf.white
        -- else
        --     c.background_color = Colorf.red
        -- end
        -- ui.init_simple_event(c,function()
        --     print("click")
        --     c.height = 500
        -- end)
        content:add(c)
    end

    root:add(s)
end

function test.test_radio(root, data)
    local data = {1,2,3,4}
    local widget = Widget()
    widget.background_color = Colorf.white
    widget:add_rules({
            AL.width:eq(AL.parent('width')*0.5),
            AL.height:eq(AL.parent('height')),
        })

    local radioGroup = ui.RadioContainer()

    -- radioGroup:add_rules({
    --     AL.width:eq(AL.parent('width')*0.4),
    --     AL.height:eq(AL.parent('height')),
    -- })

    radioGroup.background_color = Colorf.red
    
    for i, v in ipairs(data) do
        local radioBtn = ui.RadioButton{
            image = {
                checked_enabled = TextureUnit(TextureCache.instance():get("ui/radioButton1.png")),
                unchecked_enabled = TextureUnit(TextureCache.instance():get("ui/radioButton2.png")),
            };
        }
        if i == 1 then
            radioBtn.checked = true
        end

        radioBtn:add_rules({
            AL.width:eq(AL.parent('width')),
            AL.height:eq(100),
        })

        Clock.instance():schedule_once(function(dt)
            radioBtn:dump_constraint()
        end, 3)

        radioBtn.pos = Point(0, 80*(i-1))
        local icon = Sprite(TextureUnit(TextureCache.instance():get(payTypeName[i])))
        icon:add_rules{
            AL.top:eq(12*LayoutScale),
            AL.left:eq(20*LayoutScale),
        }
        radioBtn:add(icon)
        local l = Label()
        local s = strData[i] or ""
        l:set_rich_text(string.format('<font size=20 color=#ffffff>%s</font>', s))
        l.align_h = ALIGN.LEFT%4
        l.align_v = (ALIGN.LEFT - ALIGN.LEFT % 4)/4
        l:add_rules{
            AL.top:eq(30),
            AL.left:eq(55),
        }
        radioBtn:add(l)
        radioGroup:add(radioBtn)
    end

    widget:add(radioGroup)
    root:add(widget)
end

function test.test_borderSprite(root, data)
    -- local c = Widget()
    -- c.size = Point(200, 200)
    -- local sp = BorderSprite();
    -- sp.unit = TextureUnit.load("ui/button.png");
    -- sp:add_rules(AL.rules.fill_parent)
    -- c:add(sp)
    -- root:add(c)
    -- sp.unit = TextureUnit.load("ui/radioButton2.png");
    -- c.size = Point(300, 200)

    local s = ui.ScrollView{}
    s:add_rules(AL.rules.fill_parent)
    s.dimension = kVertical
    s.shows_scroll_indicator = true

    local content = Layout.FloatLayout{}
    content:add_rules(AL.rules.fill_parent)
    content.spacing = Point(0,0)
    content.relative = true
    s.content = content

    for i=1, 3 do
        local item = new(UiTestLayer)
        -- item:add_rules(AL.rules.fill_parent)
        item.pos = Point(10, 0)
        ui.init_simple_event(item,function()
            print("click")
            if item.m_isOpen then
                item.m_isOpen = false
                item.height = 100
                item.width = 100
                item.m_root.unit = TextureUnit(TextureCache.instance():get("ui/button.png"))
                item.m_root:setSize(100, 100)
            else
                item.height = 300
                item.width = 300
                item.m_isOpen = true
                item.m_root.unit = TextureUnit(TextureCache.instance():get("ui/radioButton2.png"))
                item.m_root:setSize(300, 300)
            end
        end)
        content:add(item)
    end

    root:add(s)
end

return test