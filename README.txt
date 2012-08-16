Flow Cytometry Toolkit
README

Created 2012/07/06 Jue Wang
Last updated 2012/07/27

This set of .m files contains MATLAB code for processing flow cytometry data, written by Bo and Jue. 

This package aims to provide small and modular functions that can be strung together to perform complicated analyses. Basic operations such as loading data, manual segmentation, and automated segmentation are implemented. To simplify code, the flow cytometry data is reformatted into a struct upon loading. All the other functions in this package assume that flow cytometry data is in this format.


FILES:

data/	contains some example data that is used to demonstrate the scripts.