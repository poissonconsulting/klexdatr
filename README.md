
<!-- README.md is generated from README.Rmd. Please edit that file -->

# klexdatr

<!-- badges: start -->

[![Lifecycle:
stable](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://www.tidyverse.org/lifecycle/#stable)
[![R build
status](https://github.com/poissonconsulting/klexdatr/workflows/R-CMD-check/badge.svg)](https://github.com/poissonconsulting/klexdatr/actions)
[![codecov](https://codecov.io/gh/poissonconsulting/klexdatr/branch/master/graph/badge.svg)](https://codecov.io/gh/poissonconsulting/klexdatr)
[![License:
CC0](https://img.shields.io/badge/License-CC0-green.svg)](https://creativecommons.org/publicdomain/zero/1.0/legalcode)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.596624.svg)](https://doi.org/10.5281/zenodo.596624)
[![CRAN
status](https://www.r-pkg.org/badges/version/klexdatr)](https://CRAN.R-project.org/package=klexdatr)
[![Codecov test
coverage](https://codecov.io/gh/poissonconsulting/klexdatr/branch/master/graph/badge.svg)](https://codecov.io/gh/poissonconsulting/klexdatr?branch=master)
<!-- badges: end -->

`klexdatr` is an R package of six relational tibbles for the Kootenay
Lake Large Trout Exploitation
    Study.

    #> [1] "capture"    "deployment" "detection"  "recapture"  "section"   
    #> [6] "station"
    #> # A tibble: 245 x 9
    #>    Capture DateTimeCapture     SectionCapture Species Length Weight Reward1
    #>    <fct>   <dttm>              <fct>          <fct>    <int>  <dbl>   <int>
    #>  1 F075    2008-05-24 10:40:00 S25            Bull T…    545   1.75       0
    #>  2 F076    2008-05-24 11:10:00 S25            Bull T…    654   3.4        0
    #>  3 F084    2008-06-05 08:01:00 S16            Bull T…    553  NA          0
    #>  4 F100    2009-05-02 13:31:00 S21            Bull T…    643   2.75     100
    #>  5 F104    2009-05-03 11:17:00 S22            Bull T…    567   2        100
    #>  6 F129    2009-05-07 09:11:00 S21            Bull T…    703   3.9      100
    #>  7 F133    2009-05-07 13:58:00 S21            Bull T…    712   3.65     100
    #>  8 F137    2009-05-08 11:16:00 S21            Bull T…    572   1.9      100
    #>  9 F141    2009-05-20 15:13:00 S16            Bull T…    564   2.2      100
    #> 10 F143    2009-05-21 08:00:00 S16            Bull T…    595   2.4      100
    #> # … with 235 more rows, and 2 more variables: Reward2 <int>,
    #> #   DateTimeTagExpire <dttm>

## Installation

<!-- To install the latest release from [CRAN](https://cran.r-project.org) -->

To install the developmental version from
[GitHub](https://github.com/poissonconsulting/klexdatr)

``` r
# install.packages("remotes")
remotes::install_github("poissonconsulting/klexdatr")
```

## Information

The data are analysed by

**Thorley, J.L.**, and **Andrusak, G.F. 2017.** *The fishing and natural
mortality of large, piscivorous Bull Trout and Rainbow Trout in Kootenay
Lake, British Columbia (2008–2013)*. PeerJ 5: e2874.
<https://peerj.com/articles/2874>.

If you use the data in your own publications please cite
<http://doi.org/10.5281/zenodo.596624>

## Contribution

Please report any
[issues](https://github.com/poissonconsulting/pkgtemplate/issues).

[Pull requests](https://github.com/poissonconsulting/pkgtemplate/pulls)
are always welcome.

## Code of Conduct

Please note that the klexdatr project is released with a [Contributor
Code of
Conduct](https://contributor-covenant.org/version/2/0/CODE_OF_CONDUCT.html).
By contributing to this project, you agree to abide by its terms.

## Acknowledgements

![](man/figures/logos.png)

The project was primarily funded by the Habitat Conservation Trust
Foundation.

The Habitat Conservation Trust Foundation was created by an act of the
legislature to preserve, restore and enhance key areas of habitat for
fish and wildlife throughout British Columbia. Anglers, hunters,
trappers and guides contribute to the projects of the Foundation through
licence surcharges. Tax deductible donations to assist in the work of
the Foundation are also welcomed.

The project was partially funded by the Fish and Wildlife Compensation
Program on behalf of its program partners BC Hydro, the Province of
B.C., Fisheries and Oceans Canada, First Nations and the public who work
together to conserve and enhance fish and wildlife impacted by the
construction of BC Hydro dams.

Annual operation and maintenance for VR2W arrays used in this study were
completed by Ministry of Forests, Lands and Natural Resource Operations
(MFLNRO) and funded by the Fish and Wildlife Compensation Program (FWCP)
in conjunction with the Bonneville Power Administration (BPA) through
the Northwest Power and Conservation Council’s Fish and Wildlife
Program, in co-operation with the Idaho Department of Fish and Game
(IDFG), and the Kootenai Tribe of Idaho (KTOI). The Freshwater Fish
Society of British Columbia (FFSBC) provided tag rewards.
