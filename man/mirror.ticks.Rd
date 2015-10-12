\name{mirror.ticks}
\alias{mirror.ticks}
\title{
	Put axis ticks on all four sides of a ggplot
}
\description{
	Given a ggplot with axes on the bottom and left, add matching axes on the top and right.
}
\usage{
	mirror.ticks(ggobj, allPanels=FALSE)
}
\arguments{
	\item{ggobj}{
		A ggplot object.
	}
	\item{allPanels}{
		Logical: Sets behavior in multipanel plots. If TRUE, put ticks on all four sides of every panel. If FALSE, only add them at the right end of each row and the top of each column.
	}
}
\details{
	\code{mirror.ticks} converts its argument from a ggplot to a gtable, so do all your ggplot adjustments upstream and call this as the last step before plotting.

	Use care when mirroring ticks in multipanel plots, especially those constructed using \code{\link[ggplot2]{facet_wrap}}. \code{mirror.ticks} does not adjust panel spacing, so any outward-facing ticks it adds are VERY likely to overlap with adjacent panels, hide behind facet labels, or otherwise prove that the last thing most multipanel plots need is more tick marks.

	For plots made using \code{\link[ggplot2]{facet_wrap}(\dots, scales="free")}, the notion of ``only mirror ticks to the other end of the row/column'' doesn't make much sense and you will almost certainly want to set \code{allPanels=TRUE} if you use \code{mirror.ticks} at all.

	For fixed-scale multipanel plots where the bottom row of panels is not completely full (e.g. 10 panels in a 3 row * 4 column layout), the \code{ggplot} default is to display no x-axis in the columns above the empty spaces. Note that \code{mirror.ticks} always overrides this (even when \code{allPanels=FALSE}) and copies the x-axis from the last panel of the bottom row to the bottom panel of each unfilled column.
}
\value{
	A \code{\link[gtable]{gtable}} object.
}
\author{
	Chris Black <chris@ckblack.org>
}
\note{
	The reason to put ticks on all edges is that with only two axes, people reading the graph may have trouble estimating the position of points that sit far from the axis. Many of the standard ggplot themes use an in-panel background grid to address the same problem, and this author thinks it looks kinda silly to use both at once. I suggest only using \code{mirror.ticks} if your ggplot theme has no panel grid.
}
\examples{
# a simple example plot
a=ggplot(mtcars, aes(wt, mpg))+geom_point()

# ticks are redundant when panel grid is present...
plot(mirror.ticks(a+theme_bw()))

# ...but can help guide the viewer's eye when there is no grid.
theme_nogrid = theme_bw()+theme(
	panel.grid.major = element_blank(),
	panel.grid.minor = element_blank(),
	axis.ticks.length = unit(-0.25 , "lines"),
	axis.ticks.margin = unit(0.5 , "lines"))
plot(mirror.ticks(a+theme_nogrid))

## Multipanel demo
# facet_grid always applies same scale to a whole row or column
# so ticks at each end are usually enough...
a_grid = a+facet_grid(am~carb)+theme_nogrid
plot(mirror.ticks(a_grid))
# ...but it may sometimes be helpful to add them everywhere
plot(mirror.ticks(a_grid, allPanels=TRUE))

# facet_wrap with free scales and default allPanels:
# Ugly, but technically does what you asked it to do...
a_wrap = a+facet_wrap(~carb, scales="free_y")+theme_nogrid
plot(mirror.ticks(a_wrap, allPanels=FALSE))
# ... but you probably wanted ticks everywhere.
plot(mirror.ticks(a_wrap, allPanels=TRUE))
}
