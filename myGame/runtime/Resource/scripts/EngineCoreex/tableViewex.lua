---
-- 重写TableView的onScroll, 在回调增加一个参数
--
-- @param self
-- @param scroll_status See @{ui.scrollableNode#ScrollableNode.onScroll}.
-- @param diff See @{ui.scrollableNode#ScrollableNode.onScroll}.
-- @param totalOffset See @{ui.scrollableNode#ScrollableNode.onScroll}.
-- @param isMarginRebounding See @{ui.scrollableNode#ScrollableNode.onScroll}.
TableView.onScroll = function(self, scroll_status, diff, totalOffset, isMarginRebounding)
    ScrollableNode.onScroll(self, scroll_status, diff, totalOffset, isMarginRebounding);

    TableView.requireAndShowViews(self,totalOffset);

    if self.m_scrollCallback.func then
        local itemIndex = self.m_beginIndex*self.m_nItemsPerLine + 1;
        self.m_scrollCallback.func(self.m_scrollCallback.obj,scroll_status,itemIndex,#self.m_views,diff,totalOffset, isMarginRebounding);
    end
end