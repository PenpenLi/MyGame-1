--
-- Author: tony
-- Date: 2014-08-28 15:14:46
--
local PopupModel = import('game.popup.popupModel')
local CardTypePopup = class(PopupModel)
local viewConfig = require(VIEW_PATH .. "roomQiuQiu.roomQiuQiu_card_type_layer")
local varConfig = VIEW_PATH .. "roomQiuQiu.roomQiuQiu_card_type_layer_layout_var"

function CardTypePopup.show()
    PopupModel.show(CardTypePopup, viewConfig, varConfig, {name="CardTypePopup", defaultAnim=false}, data) 
end

function CardTypePopup.hide()
    if CardTypePopup.s_instance then
        CardTypePopup.s_instance:onRemovePopup()
    end
end

function CardTypePopup:ctor()
    self:addShadowLayer()
    self.m_cardTypeImage = self:getUI("cardTypeImage")
    self:onShowPopup()
end

function CardTypePopup:dtor()
    self.m_cardTypeImage:stopAllActions()
end

-- @overwrite
function CardTypePopup:dismiss()
    self:onRemovePopup()
end

function CardTypePopup:onShowPopup()
    self.m_cardTypeImage:stopAllActions()
    self.m_cardTypeImage:setPos(-450)
    transition.moveTo(self.m_cardTypeImage, {time=0.3, x=5, easing="OUT"})
end

function CardTypePopup:onRemovePopup()
    self.m_cardTypeImage:stopAllActions()
    transition.moveTo(self.m_cardTypeImage, {time=0.2, x=-450, easing="OUT", onComplete=function()
        PopupModel.hide(CardTypePopup)
    end})
end

return CardTypePopup