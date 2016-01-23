<!-- README.md is generated from README.Rmd. Please edit that file -->
Kootenay Lake Exploitation Study Data

An R package of data for the Kootenay Lake Large Trout Exploitation Study

    Data sets in package ‘klexdatr’:

    capture                          Fish Capture Data
    deployment                       Receiver Deployment Data
    depth                            Acoustic Depth Dat
    detection                        Acoustic Detection Data
    recapture                        Fish Recapture Data
    section                          Section Data
    station                          Station Data

``` r
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> 
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> 
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union
library(lexr)
library(klexdatr)

lex <- input_lex_data("klexdatr")

print(lex)
#> $section
#> Source: local data frame [28 x 5]
#> 
#>    Section Habitat Bounded EastingSection NorthingSection
#>     (fctr)  (fctr)   (lgl)          (dbl)           (dbl)
#> 1      S06   Lotic    TRUE        1644250        617467.1
#> 2      S07  Lentic    TRUE        1645549        613463.1
#> 3      S19   Lotic   FALSE        1646110        551371.8
#> 4      S08  Lentic    TRUE        1647660        607626.7
#> 5      S09  Lentic    TRUE        1650291        602447.3
#> 6      S10  Lentic    TRUE        1650810        599521.1
#> 7      S11  Lentic    TRUE        1651141        595980.9
#> 8      S20  Lentic    TRUE        1651399        553316.7
#> 9      S12  Lentic    TRUE        1652595        588442.7
#> 10     S13  Lentic    TRUE        1653765        581673.5
#> ..     ...     ...     ...            ...             ...
#> 
#> $station
#> Source: local data frame [25 x 4]
#> 
#>                                Station Section EastingStation
#>                                 (fctr)  (fctr)          (dbl)
#> 1                        Lardeau Delta     S07        1646121
#> 2                            Fry Creek     S09        1649731
#> 3          Kaslo - Shutty Bench - West     S11        1651302
#> 4          Kaslo - Shutty Bench - East     S11        1650824
#> 5                Boathouse in West Arm     S20        1651422
#> 6                South of Kaslo - East     S13        1654290
#> 7                South of Kaslo - West     S13        1653342
#> 8                       Woodbury Point     S15        1655385
#> 9    Coffee Creek - Power Lines - West     S17        1655011
#> 10 Coffee Creek - Power Lines - Middle     S17        1655905
#> ..                                 ...     ...            ...
#> Variables not shown: NorthingStation (dbl)
#> 
#> $deployment
#> Source: local data frame [255 x 4]
#> 
#>                                Station Receiver  DateTimeReceiverIn
#>                                 (fctr)   (fctr)              (time)
#> 1                        Lardeau Delta     6095 2007-08-26 11:00:00
#> 2          Kaslo - Shutty Bench - West     4348 2007-03-06 12:00:00
#> 3          Kaslo - Shutty Bench - East     5306 2007-03-06 12:00:00
#> 4    Coffee Creek - Power Lines - East     6093 2007-02-28 12:00:00
#> 5  Coffee Creek - Power Lines - Middle     5308 2007-02-28 12:00:00
#> 6    Coffee Creek - Power Lines - West     5309 2007-02-28 12:00:00
#> 7                     Pilot Point West     5298 2007-03-02 12:00:00
#> 8                      Pilot Point Mid     2726 2007-02-28 12:00:00
#> 9                     Pilot Point East     5301 2007-08-30 11:00:00
#> 10                        Crawford Bay     5299 2007-03-02 12:00:00
#> ..                                 ...      ...                 ...
#> Variables not shown: DateTimeReceiverOut (time)
#> 
#> $capture
#> Source: local data frame [191 x 10]
#> 
#>    Capture     DateTimeCapture SectionCapture    Species Length Weight
#>     (fctr)              (time)         (fctr)     (fctr)  (int)  (dbl)
#> 1     F075 2008-05-24 10:40:00            S25 Bull Trout    545   1.75
#> 2     F076 2008-05-24 11:10:00            S25 Bull Trout    654   3.40
#> 3     F084 2008-06-05 08:01:00            S16 Bull Trout    553     NA
#> 4     F100 2009-05-02 13:31:00            S21 Bull Trout    643   2.75
#> 5     F104 2009-05-03 11:17:00            S22 Bull Trout    567   2.00
#> 6     F129 2009-05-07 09:11:00            S21 Bull Trout    703   3.90
#> 7     F133 2009-05-07 13:58:00            S21 Bull Trout    712   3.65
#> 8     F137 2009-05-08 11:16:00            S21 Bull Trout    572   1.90
#> 9     F141 2009-05-20 15:13:00            S16 Bull Trout    564   2.20
#> 10    F143 2009-05-21 08:00:00            S16 Bull Trout    595   2.40
#> ..     ...                 ...            ...        ...    ...    ...
#> Variables not shown: Reward1 (int), Reward2 (int), DateTimeTagExpire
#>   (time), DepthRangeTag (int)
#> 
#> $recapture
#> Source: local data frame [42 x 8]
#> 
#>      DateTimeRecapture Capture SectionRecapture TBarTag1 TBarTag2
#>                 (time)  (fctr)           (fctr)    (lgl)    (lgl)
#> 1  2009-04-05 12:00:00    F006              S25     TRUE     TRUE
#> 2  2009-05-23 12:00:00    F131              S16     TRUE     TRUE
#> 3  2009-09-10 12:00:00    F097              S14     TRUE     TRUE
#> 4  2009-10-06 12:00:00    F169              S08     TRUE     TRUE
#> 5  2009-10-10 12:00:00    F076              S30     TRUE     TRUE
#> 6  2009-10-12 12:00:00    F099              S10     TRUE     TRUE
#> 7  2009-10-14 12:00:00    F112              S16     TRUE     TRUE
#> 8  2009-10-16 12:00:00    F111              S27     TRUE     TRUE
#> 9  2010-01-23 12:00:00    F197              S27     TRUE     TRUE
#> 10 2010-01-28 12:00:00    F075              S23     TRUE     TRUE
#> ..                 ...     ...              ...      ...      ...
#> Variables not shown: TagsRemoved (lgl), Released (lgl), Public (lgl)
#> 
#> $detection
#> Source: local data frame [477,021 x 4]
#> 
#>      DateTimeDetection Capture Receiver Detections
#>                 (time)  (fctr)   (fctr)      (int)
#> 1  2008-05-25 09:00:00    F076     5299          4
#> 2  2008-05-25 10:00:00    F076     5299          2
#> 3  2008-05-25 19:00:00    F076     5301          7
#> 4  2008-05-25 19:00:00    F076     6248          1
#> 5  2008-05-25 20:00:00    F076     5301          6
#> 6  2008-05-25 20:00:00    F076     6248          1
#> 7  2008-05-27 01:00:00    F076     6093          2
#> 8  2008-05-27 03:00:00    F076     6093          6
#> 9  2008-05-27 04:00:00    F076     6093          5
#> 10 2008-05-27 05:00:00    F076     6093          4
#> ..                 ...     ...      ...        ...
#> 
#> $depth
#> Source: local data frame [198,468 x 4]
#> 
#>          DateTimeDepth Capture Receiver Depth
#>                 (time)  (fctr)   (fctr) (dbl)
#> 1  2010-04-21 07:59:19    F214   220008    21
#> 2  2010-04-21 08:11:38    F214   103230    22
#> 3  2010-04-21 08:13:48    F214   103230    27
#> 4  2010-04-21 08:15:04    F214   103230    27
#> 5  2010-04-21 08:16:31    F214   103230    28
#> 6  2010-04-21 08:23:11    F214   103230    27
#> 7  2010-04-21 08:23:42    F214   220008    25
#> 8  2010-04-21 08:29:38    F214   103230    27
#> 9  2010-04-21 08:30:21    F214   220008    26
#> 10 2010-04-21 08:33:11    F214   103230    26
#> ..                 ...     ...      ...   ...
#> 
#> attr(,"class")
#> [1] "lex_data"

plot(lex, all = TRUE)
#> Regions defined for each Polygons
```

![](README-unnamed-chunk-2-1.png) ![](README-unnamed-chunk-2-2.png) ![](README-unnamed-chunk-2-3.png) ![](README-unnamed-chunk-2-4.png) ![](README-unnamed-chunk-2-5.png) ![](README-unnamed-chunk-2-6.png)

    #> Regions defined for each Polygons

![](README-unnamed-chunk-2-7.png) ![](README-unnamed-chunk-2-8.png) ![](README-unnamed-chunk-2-9.png) ![](README-unnamed-chunk-2-10.png)

Installation
------------

Then execute the following code at the R terminal:

``` r
# install.packages("devtools")
devtools::install_github("poissonconsulting/klexdatr")
```

Acknowledgements
----------------

![](koot.png)

The project was primarily funded by the Habitat Conservation Trust Foundation.

The Habitat Conservation Trust Foundation was created by an act of the legislature to preserve, restore and enhance key areas of habitat for fish and wildlife throughout British Columbia. Anglers, hunters, trappers and guides contribute to the projects of the Foundation through licence surcharges. Tax deductible donations to assist in the work of the Foundation are also welcomed.

The project was partially funded by the Fish and Wildlife Compensation Program on behalf of its program partners BC Hydro, the Province of B.C., Fisheries and Oceans Canada, First Nations and the public who work together to conserve and enhance fish and wildlife impacted by the construction of BC Hydro dams.

Annual operation and maintenance for VR2W arrays used in this study were completed by Ministry of Forests, Lands and Natural Resource Operations (MFLNRO) and funded by the Fish and Wildlife Compensation Program (FWCP) in conjunction with the Bonneville Power Administration (BPA) through the Northwest Power and Conservation Council’s Fish and Wildlife Program, in co-operation with the Idaho Department of Fish and Game (IDFG), and the Kootenai Tribe of Idaho (KTOI). The Freshwater Fish Society of British Columbia (FFSBC) provided tag rewards.
