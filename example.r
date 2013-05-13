require(ggplot2)
require(grid)
require(gtable)
require(gridExtra) # just for multiplot demos.

testplot=(ggplot(mtcars, aes(wt, hp))
	+geom_point())

grid.arrange(testplot, mirror.ticks(testplot))

# The reason I did this in the first place: 
# My advisor prefers INWARD-facing ticks on all sides.
testplot.fancy=(ggplot(mtcars, aes(wt, hp, color=factor(cyl)))
	+geom_point()
	+theme_bw()
	+theme(
		panel.grid.major = element_blank(), 
			panel.grid.minor = element_blank(), 
			axis.ticks.length = unit(-0.25 , "cm"),
			axis.ticks.margin = unit(0.5 , "cm")))

grid.arrange(testplot.fancy, mirror.ticks(testplot.fancy))