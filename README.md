 <div align="center">
<!-- do not remove line below -->

<a href="">![GitHub](https://img.shields.io/github/license/tratteo/omnimodel?color=orange&label=License)</a>
<a href="">![GitHub top language](https://img.shields.io/github/languages/top/tratteo/omnimodel?color=blue&label=dart&logo=dart)</a>
<a href="">![GitHub Workflow Status (branch)](https://img.shields.io/github/actions/workflow/status/tratteo/omnimodel/dart.yml?branch=main&label=Test&logo=github)</a>
<a href="">![GitHub last commit (branch)](https://img.shields.io/github/last-commit/tratteo/omnimodel/main?label=Last%20commit&color=brightgreen&logo=github)</a>

</div>

### Model complex data and access it in an easy and safe way

## Features

This package introduces a class that basically is a wrapper to any data that is representable as a `Map<String, dynamic>`.

The **OmniModel** allows to easily and safely access data inside the construct.

The package has been idealized for developing an easy and modular interface to communicate with any non relational, Json based database.

## Usage

The `OmniModel` simply wraps the data and allows for easy and safe access. When accessing keys, it is possible to define the behaviour in case of missing entry in the original data.

The package also includes some useful tools such a (suppressable) automatic logging behaviour suggesting the closest match in case of key mispell by the developer. The algorithm uses a very precise **similarity convolution** algorithm.

### Steps

-   Create the `OmniModel` with one of the various factories
-   Access entries in a controlled way
-   Access nested models in a modular way by recursively parsing models with `OmniModel.tokenAsModel()`

Advanced usages can be found in the `/example` folder.
