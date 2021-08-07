# ``Lookdown``

Lookdown is used to dynamically look up values in JSON data or string.

## Usage of Lookdown

```swift
// Example JSON string
let jsonString = """
    {
        'europe': {
            'countries': [
                {
                    'name': 'germany',
                    'cities': ['Berlin', 'München', 'Nürnberg'],
                    'language': 'german'
                },
                {
                    'name': 'spain',
                    'cities': ['Madrid', 'Barcelona'],
                    'language': 'spanish'
                }
            ],
            'area': '10,180,000 km^2',
            'population': 746419440
        }
    }
"""

// Load JSON
let lookdown = try Lookdown(jsonString)

// Access all data of the JSON
let europePopulation = try lookdown.europe.population.toInt
let languageInGermany = try lookdown: lookdown.europe.countries[0].language.toString
```

You can dynamically access all properties of loaded JSON by writing `.[Property name]`
using classic dot syntax, as if accessing a property of a structure / class.

Use one of the properties to convert the property to actual type:

```swift
let stringValue = try property.toSring      // String
let doubleValue = try property.toDouble     // Double
let intValue    = try property.toInt        // Int
let int32Value  = try property.toInt32      // Int32
let int64Value  = try property.toInt64      // Int64
let boolValue   = try property.toBool       // Bool
let arrayValue  = try property.toArray      // Array<Lookdown>
let dictValue   = try property.toDictionary // Dictionary<String, Lookdown>

// Use Decodable type
struct Country: Decodable {
    let name: String
    let cities: [String]
    let language: String
}
let germany = try lookdown.europe.countries[0].decode(Country.self) // Country
```

Note that all of this statment can throw an error, this is the case if the property cannot be converted to this type or
if there is no dynamic property with given name:

```swift
let wrongType = try lookdown.europe.area.toArray              // throws an error
let unknownProperty = try lookdown.europe.unknown.toString    // throws an error
```

As can be seen in the first example, you can use subscripts to access values in an array.
You can also use the type initializers with the lookdown as parameter like this:

```swift
let europePopulation = try Int(lookdown: lookdown.europe.population)
let languageInGermany = try String(lookdown: lookdown.europe.countries[0].language)
```

If a value is null or you are unsure if the JSON has a specific value, you can use the optional
operator `|?` at the end of this property to make entire Lookdown optional:

```swift
let africaPopulation = try Int(lookdown: lookdown.africa|?.population)
// Type Int? and can throw an error
```

This statement can still throw an error as it's unknown if the property population exists and
if this property is from type `Int`. When you make all properties optional the Lookdown
statement is optional and doesn't throw an error even if the property isn't from the type to
cast to:

```swift
let africaPopulation = Int(lookdown: lookdown.africa|?.population|?)
// Type Int? but throws no error
```

When you are sure a value with this property name exist and the value isn't null, you can use
the unsafe optional operator `|!`to unwrap the value. It raises a fatal error if there is
an error.

```swift
let europePopulation = try Int(lookdown: lookdown.europe|!.population)
// Type Int but can throw an error
```

This statement can still throw an error as it's unknown if the property population exists and
if this property is from type `Int`. When you make all properties unsafe optional the Lookdown
statement isn't optional and doesn't throw an error even if the property isn't from the type to
cast to:

```swift
let europePopulation = Int(lookdown: lookdown.europe|!.population|!)
// Type Int and throws no error
```
