# Changelog

## 1.0.10

-   Fixed static analysis and pub points
-   Adjusted dart SDK version

## 1.0.9

-   Improved documentation
-   `OmniModel.fromMap()` now accepts any `Map` and automatically converts it by using `toString()` on keys
-   `OmniModel.similar()` allows to extract the key that is most similar to the provided one
-   `OmniModelPreferences.similarityBackend` can be used to change the similarity algorithm used

## 1.0.8

-   Changed the similarity algorithm for keys from `levenshtein` to a custom `similarityConvolution`

## 1.0.7

-   OmniModelPreferences `enforceLowerCaseKeys` fix

## 1.0.6

-   OmniModelPreferences `enforceLowerCaseKeys`

## 1.0.5

-   Added project lints to enforce style
-   Exposed extension methdods `levensthein` on String and `deepUpdate` on Map
-   Get the entries of an OmniModel directly using `entries`

## 1.0.4

-   Fixed a problem in which in certain situations, calling `tokenAsModel` would throw an exception.

## 1.0.3

-   Fixed a problem in which in certain situations, calling `tokenAsModel` would throw an exception.

## 1.0.2

-   Examples.

## 1.0.1

-   Tests.

## 1.0.0

-   Initial version.
