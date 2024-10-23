This project builds on research from the classification problems within penguins within the Palmer Penguins dataset.

Included is a gradient-based functor network map as a 3D display for penguin migrations and variabity sourced from the PalmerPenguins.jl dataset and library.

All that is needed is:

# Penguin Migration 3D Visualization Project

This project builds on research from classification problems using the Palmer Penguins dataset.

Included is a gradient-based functor network map as a 3D display for penguin migrations and variability sourced from the `PalmerPenguins.jl` dataset and library.

## Requirements

To get started, install the following Julia packages:

```julia
Pkg.add("PlotlyJS", CSV, DataFrames, Interpolations, CategoricalArrays, PooledArrays, Interpolations, Turing, GraphPlot, LightGraphs )

using Pkg; Pkg.add("CSV", "DataFrames", "PalmerPenguins", "Statistics", "PooledArrays", "PlotlyJS", "Python" ### again, depending on python's path
include("penguin_3dplot.jl")

Thereafter, your IDE should render the interactive plot, if you have your Jupyter set up, you can run multidispatch, including the penguins_multiclass.ipynb

If you would like to work on this type of functor network or have questions about it, feel free to email hkinder@stlteach.org

More of the usability of this data set can be explored in R as well, which was used for quick-preprocessing, cleaning and summary statistics for the functor networks.

To find out more about the original research, please reference:

   Horst AM, Hill AP, Gorman KB (2020). palmerpenguins: Palmer
   Archipelago (Antarctica) penguin data. R package version 0.1.0.
   https://allisonhorst.github.io/palmerpenguins/. doi:
   10.5281/zenodo.3960218.
 
   A BibTeX entry for LaTeX users is
 
   @Manual{,
     title = {palmerpenguins: Palmer Archipelago (Antarctica) penguin data},
     author = {Allison Marie Horst and Alison Presmanes Hill and Kristen B Gorman},
     year = {2020},
     note = {R package version 0.1.0},
     doi = {10.5281/zenodo.3960218},
     url = {https://allisonhorst.github.io/palmerpenguins/},
   }
