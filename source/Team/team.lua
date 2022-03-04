local gfx <const> = playdate.graphics

class('Team').extends()

function Team:init(members, alignment)
	Team.super.init(self)
	
	self.members = members
	self.alignment = alignment
	self.view =  playdate.ui.gridview.new(80, 78)
	self.lastSelection = { 1, 1, 1 }
end

function Team:setup()
	
	self.view:setNumberOfRows(#self.members)
	self.view:setCellPadding(1, 1, 1, 1)
	
	local members = self.members
	local alignment = self.alignment
	
	function self.view:drawCell(section, row, column, selected, x, y, width, height)
		if selected then
			gfx.fillRoundRect(x, y, width, height, 4)
			gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
			else
			gfx.setImageDrawMode(gfx.kDrawModeCopy)
		end
		
		local xOffset = ternary(alignment == kTextAlignment.left, 3, -3)
		gfx.drawTextInRect(members[row], x + xOffset, y + 3, width, height, nil, "...", alignment)
	end
	
	self.view:setSelection(self.lastSelection)
	
end

function Team:deselect()
	self.lastSelection = table.pack(self.view:getSelection())
	self.view:setSelection(nil)
end

function Team:reselect()
	self.view:setSelection(table.unpack(self.lastSelection))
end

function Team:switchFrom(team)
	team:deselect()
	self.view:setSelection(table.unpack(team.lastSelection))
end