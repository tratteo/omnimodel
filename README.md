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

## Examples

Suppose a certain `Map` containing the following data:
```dart
data = {
    "name": "Mario",
    "surname": "Rossi",
    "meta":{
        "age": 25,
        "birth_date": null,
        "address": "Via Prima 12",
    },    
    "interests": [
        "Computer Science",
        "Physics",
        "Food",
        "Outdoor",
    ]
}
```
The **OmniModel** allows to safe wrap the data structure and handle missing values and default cases with ease. 
Create the model form the map and start using it:
```dart
var model = OmniModel.fromMap(data);
```
Nested fields can be accessed simply by concatenating the keys with a separator (default `"."`):
```dart
//--> Null default value
var age = model.tokenOrNull<num>("meta.age");

//--> Default value
var birth_date = model.tokenOr<String>("meta.birth_date", "01/01/1970");

//--> Different types
var interests = model.tokenOr<List<String>>("interests", List.empty());

//--> Access nested models
var metaModel = model.tokenAsModel("meta");
// metaModel is now:
//{
//    "age": 25,
//    "birth_date": null,
//    "address": "Via Prima 12",
//}

//--> Edit the model with side effect, do not worry about non existing nested models, they are automatically created
model.edit({
    "birth_date": "08/08/1998",
    "meta.phones": {"mobile":"+39 3331234567"}
});
// Add an interest
model.edit({
    "interests": model.tokenOr<List<String>>("interests", List.empty())..add("Maths")
});

//--> Or get a new model instance
var newModel = model.copyWith({
    "birth_date": "08/08/1998",
    "meta.phone": {"mobile":"+39 3331234567"}
});

//--> Get the most similar keys to the provided one. Uses a similarity convolution algorithm
var closeMatch = model.similar("metadata") //<--- will return "meta"
```
## Flutter
The `OmniModel` package is very useful in situations of declarative programming. With **Flutter**, the possibility to prevent null checks on each data key allows to make the code smaller and less bug prone.
```dart
if(data["meta"] != null && data["meta"]["birth_date"] != null)
    Text(
        data["meta"]["birth_date"]
    );
else
    Text(
        "Birth date not provided"
    );


//---> With the OmniModel the code is smaller and easier to mantain.
// Also the generic nature of the tokenOr method allows to enforce static types

Text(
    model.tokenOr<String>("meta.birth_date","Birth date not provided")
);


```