local gfx <const> = playdate.graphics

class('Grid').extends()

function Grid:init()
	Grid.super.init(self)
	self.view = playdate.ui.gridview.new(24, 24)
	self.lastSelection = { 1, 1, 1 }
end

function Grid:setup()

	self.view:setNumberOfColumns(8)
	self.view:setNumberOfRows(8)
	self.view:setCellPadding(2, 2, 2, 2)
	self.view.changeRowOnColumnWrap = false
	self.view.changeColumnonRowWrap = false
	self.view.scrollCellsToCenter = false

	function self.view:drawCell(section, row, column, selected, x, y, width, height)
		gfx.setLineWidth(ternary(selected, 3, 1))
		gfx.drawCircleInRect(x, y, width, height)
	end

end

function Grid:deselect()
	self.lastSelection = table.pack(self.view:getSelection())
	self.view:setSelection(nil)
end

function Grid:reselect()
	self.view:setSelection(table.unpack(self.lastSelection))
end