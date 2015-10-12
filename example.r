require(ggplot2)
require(grid)
require(gtable)
require(gridExtra) # just for multiplot demos.

# Run examples from source files, not the installed package version
sapply(
	X=list.files(path="./R", pattern="*.R", full.names=TRUE),
	FUN=source)

testplot=(ggplot(mtcars, aes(wt, hp))
	+geom_point())

grid.arrange(testplot, mirror.ticks(testplot))

# The reason I did this in the first place:
# My advisor prefers INWARD-facing ticks on all sides.
lab_theme = theme_bw(10)+theme(
	panel.grid.major = element_blank(),
	panel.grid.minor = element_blank(),
	axis.ticks.length = unit(-0.25 , "lines"),
	axis.ticks.margin = unit(0.5 , "lines"))

testplot.fancy=(ggplot(mtcars, aes(wt, hp, color=factor(cyl)))
	+geom_point()
	+lab_theme)

grid.arrange(testplot.fancy, mirror.ticks(testplot.fancy))


# Multipanel plots:
print("tp_grid")
tp_grid = (testplot.fancy
	+facet_grid(am~carb)
	+ggtitle("facet_grid, fixed scales"))
grid.arrange(
	tp_grid,
	mirror.ticks(tp_grid),
	mirror.ticks(tp_grid, allPanels=TRUE))

print("tp_grid_free")
tp_grid_free = (testplot.fancy
	+facet_grid(am~carb, scales="free")
	+ggtitle("facet_grid, free scales"))
grid.arrange(
	tp_grid_free,
	mirror.ticks(tp_grid_free),
	mirror.ticks(tp_grid_free, allPanels=TRUE))

print("tp_wrap")
tp_wrap = (testplot.fancy
	+facet_wrap(~carb)
	+ggtitle("facet_wrap, fixed scales"))
grid.arrange(
	tp_wrap,
	mirror.ticks(tp_wrap),
	mirror.ticks(tp_wrap, allPanels=TRUE))

print("tp_wrap_free")
tp_wrap_free = (testplot.fancy
	+facet_wrap(~carb, scales="free")
	+ggtitle("facet_wrap, free scales"))
grid.arrange(
	tp_wrap_free,
	mirror.ticks(tp_wrap_free),
	mirror.ticks(tp_wrap_free, allPanels=TRUE))

print("tp_wrap_ragged")
tp_wrap_ragged = (testplot.fancy
	+facet_wrap(~carb, ncol=4))
grid.arrange(
	tp_wrap_ragged,
	mirror.ticks(tp_wrap_ragged),
	mirror.ticks(tp_wrap_ragged, allPanels=TRUE))
