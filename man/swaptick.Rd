\name{swaptick}
\alias{swaptick}
\title{
	Flip direction of axis tick
}
\description{
	Given a single coordinate of a single axis tick, flips it to the opposite side of the axis. Probably useless except inside \code{\link{mirror.ticks}}.
}
\usage{
	swaptick(tick)
}
\arguments{
	\item{tick}{
		A \code{\link{unit}} object
	}
}
\details{
	Tick coordinates for the end on the axis line are encoded as a \code{unit} containing \code{1npc}, while coordinates for the other end are objects of the undocumented subclass \code{unit.arithmetic}, containing \code{1npc - axis.tick.length}. We leave the axis end alone and move ticks to the other side of the line by flipping the sign of the subtraction.
}
\value{
	If \code{tick} was a \code{unit.arithmetic}, a \code{unit.arithmetic} with the sign flipped. If \code{tick} was a \code{unit}, the unchanged \code{tick}.
}
\author{
	Chris Black <chris@ckblack.org>
}
\seealso{
	\code{\link[ggplot]{theme}} for more on \code{axis.ticks}, \code{\link{mirror.ticks}} for a practical application of tick-flipping.
}
\examples{
tick_start = unit(1, "npc")
tick_stop = tick_start - unit(0.1, "npc")

tick_start
# [1] 1npc
tick_stop
# [1] 1npc-0.1npc

swaptick(tick_start)
# 1npc
swaptick(tick_stop)
# 1npc--0.1npc

# The intended use case: invert the ticks from a whole axis at once
ax=unit.c(tick_start, tick_stop, tick_start, tick_stop, tick_start, tick_stop)
ax_flipped = sapply(ax, swaptick, simplify=FALSE)
class(ax_flipped) = c("unit.list", "unit")

ax
# [1] 1npc        1npc-0.1npc 1npc        1npc-0.1npc 1npc        1npc-0.1npc
ax_flipped
# [1] 1npc         1npc--0.1npc 1npc         1npc--0.1npc 1npc         1npc--0.1npc

}
