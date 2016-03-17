<!-- README.md is generated from README.Rmd. Please edit that file -->
Kootenay Lake Exploitation Study Data
=====================================

An R package of data for the Kootenay Lake Large Trout Exploitation Study. The package provides six related datasets.

    capture                          Fish Capture Data
    deployment                       Receiver Deployment Data
    detection                        Acoustic Detection Data
    recapture                        Fish Recapture Data
    section                          Section Data
    station                          Station Data

![](README-unnamed-chunk-2-1.png)<!-- -->

    #> Kootenay Lake by color-coded section.

![](README-unnamed-chunk-2-2.png)<!-- -->

    #> Detections by fish, species, date and color-coded section. Captures are indicate by a red circle, released recaptures by a black triangle and harvested recaptures by a black square.

![](README-unnamed-chunk-2-3.png)<!-- -->

    #> Receiver coverage by color-coded section and date.

Installation
------------

To install and load the klexdatr package, execute the following code at the R terminal:

``` r
# install.packages("devtools")
devtools::install_github("poissonconsulting/klexdatr")
library(klexdatr)
```

Information
-----------

For more information, install and load the package and then type `?qlexdatr` at the R terminal.

Acknowledgements
----------------

![](koot.png)

The project was primarily funded by the Habitat Conservation Trust Foundation.

The Habitat Conservation Trust Foundation was created by an act of the legislature to preserve, restore and enhance key areas of habitat for fish and wildlife throughout British Columbia. Anglers, hunters, trappers and guides contribute to the projects of the Foundation through licence surcharges. Tax deductible donations to assist in the work of the Foundation are also welcomed.

The project was partially funded by the Fish and Wildlife Compensation Program on behalf of its program partners BC Hydro, the Province of B.C., Fisheries and Oceans Canada, First Nations and the public who work together to conserve and enhance fish and wildlife impacted by the construction of BC Hydro dams.

Annual operation and maintenance for VR2W arrays used in this study were completed by Ministry of Forests, Lands and Natural Resource Operations (MFLNRO) and funded by the Fish and Wildlife Compensation Program (FWCP) in conjunction with the Bonneville Power Administration (BPA) through the Northwest Power and Conservation Council’s Fish and Wildlife Program, in co-operation with the Idaho Department of Fish and Game (IDFG), and the Kootenai Tribe of Idaho (KTOI). The Freshwater Fish Society of British Columbia (FFSBC) provided tag rewards.
