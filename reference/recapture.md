# Fish Recapture Data

A tbl data frame of fish recaptures. As the time of recapture was not
reported it is assumed to be 12:00:00.

## Usage

``` r
recapture
```

## Format

A tbl data frame:

- DateTimeRecapture:

  The reported date of recapture (time).

- Capture:

  The fish code (fctr).

- SectionRecapture:

  The section code (fctr).

- TBarTag1:

  The first T-Bar Tag was reported (lgl).

- TBarTag2:

  A second T-Bar Tag was reported (lgl).

- TagsRemoved:

  The T-Bar tags were removed from the fish (lgl).

- Released:

  The angler reportedly released the fish (lgl).

- Public:

  The angler was a member of the public as opposed the study team (lgl).
