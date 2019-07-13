# StatsMakie Tutorial

This tutorial shows how to create data visualizations using the StatsMakie grouping and styling APIs as well as the StatsMakie statistical recipes.

## Grouping data by discrete variables

The first feature that StatsMakie adds to Makie is the ability to group data by some discrete variables and use those variables to style the result. Let's first create some vectors to play with:

@example_database("StatsMakie", 1)

To see how `x` and `y` relate to each other, we could simply try (be warned: the first plot is quite slow, the following ones will be much faster):

@example_database("StatsMakie", 2)


It looks like there are two components in the data, and we can ask whether they come from different values of the `a` variable:

@example_database("StatsMakie", 3)

`Group` will split the data by the discrete variable we provided and color according to that variable. Colors will cycle across a range of default values, but we can easily customize those:

@example_database("StatsMakie", 4)


and of course we are not limited to grouping with colors: we can use the shape of the marker instead. `Group(a)` defaults to `Group(color = a)`, whereas `Group(marker = a)` with encode the information about variable `a` in the marker:

@example_database("StatsMakie", 5)

Grouping by many variables is also supported:

@example_database("StatsMakie", 6)


## Styling data with continuous variables

One of the advantage of using an inherently discrete quantity (like the shape of the marker) to encode a discrete variable is that we can use continuous attributes (e.g. color within a colorscale) for continuous variable. In this case, if we want to see how `a, x, y, z` interact, we could choose the marker according to `a` and style the color according to `z`:

@example_database("StatsMakie", 7)


Just like with `Group`, we can `Style` any number of attributes in the same plot. `color` is probably the most common, `markersize` is another sensible option (especially if we are using `color` already for the grouping):

@example_database("StatsMakie", 8)

## Split-apply-combine strategy with a plot

StatsMakie also has the concept of a "visualization" function (which is somewhat different but inspired on Grammar of Graphics statistics). The idea is that any function whose return type is understood by StatsMakie (meaning, there is an appropriate visualization for it) can be passed as first argument and it will be applied to the following arguments as well.

A simple example is probably linear and non-linear regression.

### Linear regression

StatsMakie knows how to compute both a linear and non-linear fit of `y` as a function of `x`, via the "analysis functions" `linear` (linear regression) and `smooth` (local polynomial regression) respectively:

@example_database("StatsMakie", 9)

That was anti-climatic! It is the linear prediction of `y` given `x`, but it's a bit of a sad plot! We can make it more colorful by splitting our data by `a`, and everything will work as above:

@example_database("StatsMakie", 10)

And then we can plot it on top of the previous scatter plot, to make sure we got a good fit:

@example_database("StatsMakie", 11)

Here of course it makes sense to group both things by color, but for line plots we have other options like `linestyle`:

@example_database("StatsMakie", 12)

### A non-linear example

Using non-linear techniques here is not very interesting as linear techniques work quite well already, so let's change variables:

@example_database("StatsMakie", 12)

and then:

@example_database("StatsMakie", 13)

### Different analyses

`linear` and `smooth` are two examples of possible analysis, but many more are possibles and it's easy to add new ones. If we were interested to the distributions of `x` and `y` for example we could do:

@example_database("StatsMakie", 14)


The default plot type is determined by the dimensionality of the input and the analysis.
A `histogram` analysis over one input variable produces a bar plot:

@example_database("StatsMakie", 15)

whereas with two variables one would get a heatmap:

@example_database("StatsMakie", 16)

This plots is reasonably customizable in that one can pass keywords arguments to the `histogram` analysis:

@example_database("StatsMakie", 17)

and change the default plot type to something else:

@example_database("StatsMakie", 18)

Of course heatmap is the saner choice, but why not abuse Makie 3D capabilities?

Other available analysis are `density` (to use kernel density estimation rather than binning) and `frequency` (to count occurrences of discrete variables).

## What if my data is in a table, such as a DataFrame?

It is possible to signal StatsMakie that we are working from a DataFrame (or any table actually) and it will interpret symbols as columns:

@example_database("StatsMakie", 19)


And everything else works as usual:

@example_database("StatsMakie", 20)

@example_database("StatsMakie", 21)

### Plotting multiple columns

Other than comparing the same column split by a categorical variable, one may also compare different columns put side by side (here in a `Tuple`, `(:PetalLength, :PetalWidth)`). The attribute that styles them has to be set to `bycolumn`. Here color will distinguish `:PetalLength` versus `:PetalWidth` whereas the marker will distinguish the species.

@example_database("StatsMakie", 22)

## Analysis of data

There are multiple options with which to analyze your data before plotting it.  These are:

- density (kernel density estimation, 1D or 2D)
- histogram (1D, 2D or even 3D!)
- frequency (count occurrences of discrete variables, 1 or 2D)
- linear (linear regression)
- smooth (LOESS regression)

To use these analyses, one can simply write something like `plot(density, x, y)`.  One can also pass options to the analysis, as in: `plot(density(bandwidth=0.1), x, y)`, or something analogous for other analyses.

For example, see the initial setup below:

@example_database("Analysis", 1)

for which one can plot a kernel density estimation:

@example_database("Analysis", 2)

or a histogram:

@example_database("Analysis", 3)

One can also count the frequency of a discrete variable:

@example_database("Analysis", 4)

Fitting data using LOESS fitting is of course possible:

@example_database("Analysis", 5)

and, as seen earlier, fitting it with a line is possible as well.

@example_database("Analysis", 6)

## Statistical plot types

One can use box plots and violin plots with the same interface as `StatsPlots`.  

One can create a box plot:

@example_database("Box plot")

or a violin plot:

@example_database("Violin plot")

and the two can be superimposed:

@example_database("Violin and box plot")
