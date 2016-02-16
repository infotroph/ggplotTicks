ggplotTicks
============

Provides a single<sup>*</sup> function `mirror_ticks` that puts scale ticks on all four sides on a ggplot by copying axes from bottom to top and left to right. Think of this as a replacement for the panel grid; it is not a way of adding multiple scales to the same plot.

<sup>*</sup>Plus a helper function or two, but these may or may not ever be useful outside of `mirror_ticks`.

## Installation:

### From R using `devtools` (recommended)
```
install.packages("devtools")
library("devtools")
install_github("infotroph/ggplotTicks")
```
Note that I *think* you can ignore the step of the `devtools` [installation instructions](https://cran.r-project.org/web/packages/devtools/README.html) where it claims you need a full development toolchain (on OS X this involves a multi-gigabyte download of Xcode). If you have any trouble installing on a machine with no developer tools, please let me know.

The current version of ggplotTicks (0.1.0) does not work with versions of ggplot2 older than 2.0. If you are using ggplot2 v. 1.x and can't upgrade it yet, you'll need to use ggplotTicks 0.0.2: `install_github("infotroph/ggplotTicks", ref="v0.0.2")`.

### From a command line

Probably only necessary if you want to edit the package code. Modify these commands as needed for your system. 
```
git clone https://github.com/infotroph/ggplotTicks.git
R CMD build ggplotTicks
R CMD install ggplotTicks_<version.number.here>.tar.gz
```

## Basic usage

The basic idea: make a plot, call mirror_ticks on it, then either plot it as it is or keep modifying.

```
library(ggplot2)
library(ggplotTicks)

plt = (ggplot(iris, aes(Sepal.Length, Petal.Length))
	+geom_point())

plt_m = mirror_ticks(plt)
plt_m
plt_m + theme_bw() + geom_smooth(aes(group=Species))
```

I think mirrored ticks look best with no background grid.

```
theme_nogrid = theme_bw() + theme(
	panel.grid.major = element_blank(),
	panel.grid.minor = element_blank(),
	axis.ticks.length = unit(-0.25 , "lines"),
	axis.text.x = element_text(margin=margin(t=1, unit="lines")),
	axis.text.y = element_text(margin=margin(r=1, unit="lines")))

plt_m_s + theme_nogrid + geom_smooth(aes(group=Species))
plt_m_s
```

Mirroring works within facets too, though you have to think about what you want: Ticks on all the edges of the *plot*, or on all edges of *each panel*?

```
carplt = (ggplot(mtcars, aes(wt, mpg))
	+geom_point()
	+facet_grid(cyl~am)
	+theme_nogrid)
mirror_ticks(carplt)
mirror_ticks(carplt, allPanels=T)
```

Here both approaches work reasonably well. But when axes differ between panels, you probably ~always want allPanels=TRUE:

```
dplt = (ggplot(diamonds, aes(z, price, color=cut))
	+geom_point()
	+theme_nogrid
	+facet_wrap(~clarity, scales="free"))
mirror_ticks(dplt, allPanels=FALSE) # Almost certainly not what you want
mirror_ticks(dplt, allPanels=TRUE) # Better
```

## Known limitations:

* Changing facets will lose mirroring, because ggplot does all its axis rendering inside the facet functions.

	```
	mirror_ticks(plt + facet_wrap(~Species)) # has mirrored ticks
	mirror_ticks(plt) + facet_wrap(~Species) # does not
	```

	If you call `mirror_ticks` last thing before plotting, this will not affect you. If you prefer to call it earlier and then find you need to refacet an already-mirrored plot, the easiest workaround is to simply wrap another `mirror_ticks()` around the result. It's no problem to call mirror_ticks multiple times on the same object, so if in doubt mirror it again.

* Mirroring fails in the case where one or both axes contain no ticks.

	A slightly contrived example: Let's say you have a boxplot with in-panel labels, so you want to remove the x-axis but still mirror the y-axis.

	```
	mtlab = aggregate(drat~am, data=mtcars, FUN=mean)
	p = (ggplot(mtcars, aes(factor(am), drat))
		+geom_boxplot()
		+geom_text(data=mtlab, aes(label=am))
		+theme_nogrid)
	```

	One fairly easy way to remove an axis is by setting `breaks=NULL`, but that makes mirror_ticks fail:

	```
	p_nox = p + scale_x_discrete(breaks=NULL)
	mirror_ticks(p_nox)
	# Error in match_axes(cur_panel, axis_extents) : Can't match axes to panel
	```

	One possible workaround for this case: Remove the x-axis in the theme instead of in the scale.

	```
	p_hidx = p + theme(
			axis.ticks.x=element_blank(),
			axis.text.x=element_blank())
	mirror_ticks(p_hidx)
	```
