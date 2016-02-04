\name{facet_render-methods}
\alias{facet_render.ggTicks}
\alias{facet_render.ggTicksAll}
\title{
	Render Facets with Mirrored Axes
}
\description{
	S3 methods for the (undocumented, internal) \code{ggplot2} generic \code{facet_render}.
}
\usage{
	\method{facet_render}{ggTicks}(\dots)
	\method{facet_render}{ggTicksAll}(\dots)
}
\arguments{
	\item{\dots}{
		arguments. Provided by the \code{facet_render} generic and passed unchanged to \code{NextMethod("facet_render")}.
	}
}
\details{
	These methods are called automatically by ggplot2 whenever it renders a ggplot object with mirrored axes. You should never need to call them directly.

	Method dispatch is done according to the first entry of \code{class(ggobj$facet)}, hopefully as set by \code{\link{mirror_ticks}}: `ggTicksAll' if mirror_ticks was called with \code{allPanels=TRUE}, `ggTicks' otherwise.
}
\value{
	Invisibly, a gtable containing the result of calling \code{\link{mirror_gtable}} on the output of ggplot's internal generic \code{facet_render}.
}
\author{
	Chris Black <chris@ckblack.org>
}
