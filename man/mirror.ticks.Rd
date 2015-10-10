\name{mirror.ticks}
\alias{mirror.ticks}
\title{
	Put axis ticks on all four sides of a ggplot
}
\description{
	Given a ggplot with standard left-and-bottom axes, returns a plot with ticks (but not numbers) on all four sides.
}
\usage{
	mirror.ticks(ggobj)
}
\arguments{
	\item{ggobj}{
		A ggplot object.
	}
}
\details{
	\code{mirror.ticks} converts its argument from a ggplot to a gtable, so do all your ggplot adjustments upstream and call this as the last step before plotting.

	Multipanel plots are not yet supported.
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
\dontrun{
# a simple exmple plot
a=ggplot(mtcars, aes(wt, mpg))+geom_point()

# ticks are redundant when panel grid is present...
plot(mirror.ticks(a+theme_bw()))

# ...but help guide the viewer's eye when there is no grid.
plot(mirror.ticks(a+theme_classic()))
}
}