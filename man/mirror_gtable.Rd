\name{mirror_ticks}
\alias{mirror_ticks}
\alias{mirror_gtable}
\title{
	Put Axis Ticks on All Four Sides of a ggplot
}
\description{
	Given a ggplot with axes on the bottom and left, add matching axes on the top and right.
}
\usage{
	mirror_ticks(ggobj, allPanels=FALSE)
	mirror_gtable(ggobj, allPanels=FALSE)
}
\arguments{
	\item{ggobj}{
		The plot to be mirrored: For mirror_ticks, a \code{\link{ggplot}} object. For mirror_gtable, a \code{\link{gtable}} or anything \code{\link{ggplotGrob}} can convert to one.
	}
	\item{allPanels}{
		Logical: Sets behavior in multipanel plots. If TRUE, put ticks on all four sides of every panel. If FALSE, only add them at the right end of each row and the top of each column. See ``Details'' for more caveats.
	}
}
\details{
	\subsection{Multipanel considerations}{
		For plots made using \code{\link{facet_wrap}(\dots, scales="free")}, the notion of ``only mirror ticks to the other end of the row/column'' doesn't make much sense and you will almost certainly want to set \code{allPanels=TRUE} if you use \code{mirror_ticks} at all.

		For fixed-scale multipanel plots where the bottom row of panels is not completely full (e.g. 10 panels in a 3 row * 4 column layout), the \code{ggplot} default is to display no x-axis in the columns above the empty spaces. Note that \code{mirror_ticks} always overrides this (even when \code{allPanels=FALSE}) and copies the x-axis from the last panel of the bottom row to the bottom panel of each unfilled column.

		If you change facets downstream of mirror_ticks, your plot will lose mirroring. This includes any call of the form \code{\link[ggplot2:gg-add]{plot + facet_fn(...)}} and notably includes the change from one panel (which is actually \code{plot + facet_null()}) to any other layout. As a workaround, wrap any facetting changes in another call to mirror_ticks, as  shown in the examples below.
	}
	\subsection{Limitations}{
		These functions provide a fairly inflexible interface for a single task: To provide axis ticks on all four sides of the panel, instead of the bottom-and-left-only that ggplot supports natively. 

		Some of this inflexibility is intentional: I think most possible variants variants on it, especially anything with multiple differing y-axes, are Bad Ideas That Lead To Bad Graphics. Mostly, though, it's because even this limited task requires us to count on internal plot structure details that could change in any ggplot2 release. This situation may change in future releases if/when ggplot's facetting API stabilizes, but for now I recommend rechecking your plots carefully any time you update packages.

		As currently implemented, \code{mirror_ticks(ggplot_object)} works by adding the subclass \code{"ggTicks"} to the classlist of \code{ggplot_object\$facet}. At drawing time, ggplot2 then calls \code{\link{facet_render.ggTicks}}, which in turn calls the appropriate method of \code{ggplot2::facet_render} and passes the result to \code{mirror_gtable}, which does the actual mirroring and returns a gtable, which is then drawn to the active graphics device by \code{\link[=grid-package]{grid}}. Once this whole dispatch chain has finished, the mirroring can still fail if the ticks we're mirroring are not where we expect them, which is: \code{unit.arithmetic} objects inside a \code{unit.list} inside a \code{polyLine} grob inside a \code{gtable} inside an \code{absoluteGrob} inside another \code{gtable}. Whew!

		If you need to do further manipulations between axis-rendering and plotting time, you can call \code{mirror_gtable(ggplot_object)} directly.

		Multipanel plots are supported but need to be re-mirrored after each faceting change. See the examples and ``Multipanel considerations'' above. 

		If one or both axes has no ticks in its plotted range, mirror_ticks will fail with the message ``Can't match axes to panel.'' This is probably fixable; patches or workaround suggestions welcome.
	}
	\subsection{Aesthetic notes}{
		\code{mirror_ticks} does not adjust any other plot settings, it just drops new ticks onto fully rendered panels. To get a good-looking result, you will probably need to write/modify a ggplot \code{\link{theme}} that allows room for the extra ticks. Consider at least setting custom axis.text margins, adjusting tick lengths, removing some or all panel grid lines, and maybe tweaking panel margins and strip settings.

		Use extra care when mirroring ticks in multipanel plots, especially those constructed using \code{\link[ggplot2]{facet_wrap}}. Without panel margin adjustments, any outward-facing ticks it adds are VERY likely to overlap with adjacent panels, hide behind facet labels, or otherwise prove that the last thing most multipanel plots need is more tick marks.
	
		I strongly suggest using a theme that has no panel grid. The main reason to put ticks on all edges is that with only two axes, people reading the graph may have trouble estimating the position of points that sit far from the axis. A background grid inside the panel is intended to address the same problem, and I think it looks kinda silly to use both at once.
	}
}
\value{
	For \code{mirror_ticks}, a ggplot object. For \code{mirror_gtable}, a \code{\link[gtable]{gtable}} object.
}
\author{
	Chris Black <chris@ckblack.org>
}
\examples{
# a simple example plot
a=ggplot(mtcars, aes(wt, mpg))+geom_point()

# ticks are redundant when panel grid is present...
plot(mirror_ticks(a+theme_bw()))

# ...but can help guide the viewer's eye when there is no grid.
theme_nogrid = theme_bw()+theme(
	panel.grid.major = element_blank(),
	panel.grid.minor = element_blank(),
	axis.ticks.length = unit(-0.25 , "lines"),
	axis.text.x = element_text(margin=margin(t=1, unit="lines")),
	axis.text.y = element_text(margin=margin(r=1, unit="lines")))
plot(mirror_ticks(a+theme_nogrid))

## Multipanel demo
# facet_grid always applies same scale to a whole row or column
# so ticks at each end are usually enough...
a_grid = a+facet_grid(am~carb)+theme_nogrid
plot(mirror_ticks(a_grid))
# ...but it may sometimes be helpful to add them everywhere
plot(mirror_ticks(a_grid, allPanels=TRUE))

# facet_wrap with free scales and default allPanels:
# Ugly, but technically does what you asked it to do...
a_wrap = a+facet_wrap(~carb, scales="free_y")+theme_nogrid
plot(mirror_ticks(a_wrap, allPanels=FALSE))
# ... but you probably wanted ticks everywhere.
plot(mirror_ticks(a_wrap, allPanels=TRUE))

# Mirroring works with any facetting method,
# but changing facets LOSES any previous mirroring:
a_grid_m = mirror_ticks(a_grid)
plot(a_grid_m) # ticks on 4 sides
plot(a_grid_m+facet_grid(cyl~carb)) # ticks on 2 sides
plot(mirror_ticks(a_grid_m)+facet_grid(cyl~carb)) # Still only 2 sides!
plot(mirror_ticks(a_grid_m+facet_grid(cyl~carb))) # Back to ticks on 4 sides
}
