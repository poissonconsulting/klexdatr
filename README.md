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
#check_lex_data(lex)

print(lex)
#> $section
#> Source: local data frame [34 x 5]
#> 
#>    Section Habitat Bounded EastingSection NorthingSection
#>     (fctr)  (fctr)   (lgl)          (dbl)           (dbl)
#> 1      S03  Lentic    TRUE        1604608        655497.0
#> 2      S02   Lotic    TRUE        1617054        648567.1
#> 3      S01   Lotic    TRUE        1632833        635384.2
#> 4      S19   Lotic   FALSE        1635615        544900.5
#> 5      S04  Lentic    TRUE        1640395        641856.5
#> 6      S05   Lotic    TRUE        1643460        622558.7
#> 7      S06   Lotic    TRUE        1644250        617467.1
#> 8      S07  Lentic    TRUE        1645549        613463.1
#> 9      S08  Lentic    TRUE        1647660        607626.7
#> 10     S09  Lentic    TRUE        1650291        602447.3
#> ..     ...     ...     ...            ...             ...
#> 
#> $station
#> Source: local data frame [47 x 4]
#> 
#>                      Station Section EastingStation NorthingStation
#>                       (fctr)  (fctr)          (dbl)           (dbl)
#> 1             Gerrard Bridge     S02        1616869        648570.7
#> 2         Gerrard Scafolding     S02        1617116        648578.0
#> 3        Lardeau R. at Mobbs     S02        1617346        648516.6
#> 4              Lardeau River     S01        1642880        622350.2
#> 5  Duncan Lardeau Confluence     S01        1643548        621751.5
#> 6                   West Arm     S19        1648336        552145.1
#> 7             Duncan-Forebay     S04        1643633        623415.9
#> 8           Boat Launch Area     S05        1643434        622169.7
#> 9       Duncan-Tailout Point     S05        1643457        622354.6
#> 10             Spillway Pool     S05        1643669        622512.6
#> ..                       ...     ...            ...             ...
#> 
#> $deployment
#> Source: local data frame [462 x 4]
#> 
#>                              Station Receiver  DateTimeReceiverIn
#>                               (fctr)   (fctr)              (time)
#> 1                   Pilot Point East     2727 2003-04-01 12:00:00
#> 2                   Pilot Point West     2727 2004-04-22 11:00:00
#> 3                    Redman Point ME     2728 2003-04-01 12:00:00
#> 4                    Redman Point ME     2728 2004-05-06 11:00:00
#> 5                    Pilot Point Mid     2729 2003-04-01 12:00:00
#> 6                   Pilot Point East     2729 2004-04-22 11:00:00
#> 7                   Pilot Point West     2730 2003-04-01 12:00:00
#> 8                 Mountain Shores MW     2730 2004-04-22 11:00:00
#> 9  Coffee Creek - Power Lines - East     2731 2003-04-01 12:00:00
#> 10                Mountain Shores MW     2724 2003-04-01 12:00:00
#> ..                               ...      ...                 ...
#> Variables not shown: DateTimeReceiverOut (time)
#> 
#> $capture
#> Source: local data frame [168 x 10]
#> 
#>    Capture     DateTimeCapture SectionCapture    Species Length Weight
#>     (fctr)              (time)         (fctr)     (fctr)  (int)  (dbl)
#> 1     F100 2009-05-02 13:31:00            S21 Bull Trout    643   2.75
#> 2     F104 2009-05-03 11:17:00            S22 Bull Trout    567   2.00
#> 3     F129 2009-05-07 09:11:00            S21 Bull Trout    703   3.90
#> 4     F133 2009-05-07 13:58:00            S21 Bull Trout    712   3.65
#> 5     F137 2009-05-08 11:16:00            S21 Bull Trout    572   1.90
#> 6     F141 2009-05-20 15:13:00            S16 Bull Trout    564   2.20
#> 7     F143 2009-05-21 08:00:00            S16 Bull Trout    595   2.40
#> 8     F153 2009-05-27 09:13:00            S25 Bull Trout    697   3.50
#> 9     F155 2009-05-27 10:38:00            S25 Bull Trout    640   3.00
#> 10    F161 2009-05-30 10:55:00            S16 Bull Trout    570   2.05
#> ..     ...                 ...            ...        ...    ...    ...
#> Variables not shown: Reward1 (int), Reward2 (int), DateTimeTagExpire
#>   (time), DepthRangeTag (int)
#> 
#> $recapture
#> Source: local data frame [39 x 7]
#> 
#>      DateTimeRecapture Capture SectionRecapture TBarTag1 TBarTag2
#>                 (time)  (fctr)           (fctr)    (lgl)    (lgl)
#> 1  2009-05-23 12:00:00    F131              S03     TRUE     TRUE
#> 2  2009-09-10 12:00:00    F097              S03     TRUE     TRUE
#> 3  2009-10-06 12:00:00    F169              S03     TRUE     TRUE
#> 4  2009-10-12 12:00:00    F099              S03     TRUE     TRUE
#> 5  2009-10-14 12:00:00    F112              S03     TRUE     TRUE
#> 6  2009-10-16 12:00:00    F111              S03     TRUE     TRUE
#> 7  2010-01-23 12:00:00    F197              S03     TRUE     TRUE
#> 8  2010-02-27 12:00:00    F162              S03    FALSE    FALSE
#> 9  2010-04-04 12:00:00    F155              S03     TRUE     TRUE
#> 10 2010-04-05 12:00:00    F175              S03     TRUE     TRUE
#> ..                 ...     ...              ...      ...      ...
#> Variables not shown: TagsRemoved (lgl), Released (lgl)
#> 
#> $detection
#> Source: local data frame [446,397 x 4]
#> 
#>      DateTimeDetection Capture Receiver Detections
#>                 (time)  (fctr)   (fctr)      (int)
#> 1  2010-04-30 07:00:00    F238   220007          1
#> 2  2010-04-30 08:00:00    F238   220007          1
#> 3  2010-04-30 09:00:00    F238   220007          1
#> 4  2010-04-30 10:00:00    F238   220007         13
#> 5  2010-04-30 11:00:00    F238   220005         11
#> 6  2010-04-30 12:00:00    F238   220005         21
#> 7  2010-04-30 13:00:00    F238   220007          8
#> 8  2010-04-30 13:00:00    F238   220005         20
#> 9  2010-04-30 14:00:00    F238   220005          5
#> 10 2010-04-30 14:00:00    F238   220007          6
#> ..                 ...     ...      ...        ...
#> 
#> $depth
#> Source: local data frame [199,246 x 4]
#> 
#>          DateTimeDepth Capture Receiver Depth
#>                 (time)  (fctr)   (fctr) (int)
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

plot(lex)
#> Regions defined for each Polygons
```

![](README-unnamed-chunk-2-1.png) ![](README-unnamed-chunk-2-2.png) ![](README-unnamed-chunk-2-3.png) ![](README-unnamed-chunk-2-4.png) ![](README-unnamed-chunk-2-5.png) ![](README-unnamed-chunk-2-6.png) ![](README-unnamed-chunk-2-7.png)

Installation
------------

Then execute the following code at the R terminal:

``` r
# install.packages("devtools")
devtools::install_github("poissonconsulting/klexdatr")
```

Acknowledgements
----------------

This project was primarily funded by the Habitat Conservation Trust Foundation.

<img src="hctf.tif" width="50%" />

The Habitat Conservation Trust Foundation was created by an act of the legislature to preserve, restore and enhance key areas of habitat for fish and wildlife throughout British Columbia. Anglers, hunters, trappers and guides contribute to the projects of the Foundation through licence surcharges. Tax deductible donations to assist in the work of the Foundation are also welcomed.

### Need FWCP logo

This Project was partially funded by the Fish and Wildlife Compensation Program on behalf of its program partners BC Hydro, the Province of B.C., Fisheries and Oceans Canada, First Nations and the public who work together to conserve and enhance fish and wildlife impacted by the construction of BC Hydro dams.

Annual operation and maintenance for VR2W arrays used in this study were completed by Ministry of Forests, Lands and Natural Resource Operations (MFLNRO) and funded by the Fish and Wildlife Compensation Program (FWCP) in conjunction with the Bonneville Power Administration (BPA) through the Northwest Power and Conservation Council’s Fish and Wildlife Program, in co-operation with the Idaho Department of Fish and Game (IDFG), and the Kootenai Tribe of Idaho (KTOI).
