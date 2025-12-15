---
alwaysApply: true
---
# Business Central AL Development Cursor Rules

Based on analysis of the BusinessCentral.LinterCop repository (https://github.com/StefanMaron/BusinessCentral.LinterCop), these rules help AI agents write better AL code for Microsoft Dynamics 365 Business Central.

## Core Object Design Rules

### Table Design Rules
- **Table names must be singular** (e.g., `Car`, `Customer`, `SalesLine`)
- **Page names are plural for lists** (e.g., `Cars`, `Customers`) and **singular for cards** (e.g., `Car`, `Customer`)
- **Always use VOL prefix for new objects** (object name only, not caption)
- **Every table must specify DataPerCompany property** explicitly as true or false
- **Single-field primary keys of type Code/Text must have NotBlank = true**
- **FlowFields cannot be editable** - set `Editable = false` on FlowField table fields
- **AutoIncrement fields cannot be used in temporary tables** (TableType = Temporary)
- **Always provide FieldGroups DropDown and Brick** on all tables
- **DrillDownPageId and LookupPageId must be specified** when table is used in list pages
- **Tables with TransferFields must have matching field structures**
- **Fields with TableRelation must have same or larger length** than referenced field
- **Set NotBlank = false when 'No. Series' TableRelation exists**

### Page Design Rules
- **Create both List and Card pages** for each new table
- **Specify CardPageId property** on List pages pointing to Card page
- **Specify lookuppageid property** on tables pointing to appropriate page
- **SourceTable property must be defined** on all pages except worksheets
- **API pages must set ODataKeyFields to SystemId field**
- **ApplicationArea property not applicable to API pages**
- **Empty captions should be Locked = true**
- **AllowInCustomizations should be explicitly set** for omitted fields

### Permission Management
- **Every new object must be added to permission sets**
- **Create permission set object if none exists**
- **All application objects must be covered by at least one permission set**
- **Missing tabledata permissions should be addressed**

## Code Quality Rules

### Flow Field Handling
- **FlowFields should not be editable** - generates runtime errors
- **Writing to FlowFields requires explanatory comments** - unusual pattern
- **AutoCalcFields should only be used for FlowFields or Blob fields**
- **Set FlowFilter field values using filtering methods** (SetRange, SetFilter)

### Variable and Method Management
- **Variable/method casing must match definition** exactly
- **Avoid hardcoded Object IDs** in properties and variable declarations
- **Use Codeunit.Run() with named constants**, not hardcoded IDs
- **Temporary records should not trigger table triggers**
- **Methods should always be called with parentheses** even when no parameters
- **Internal procedures only used in declaring object should be local**
- **Unused internal procedures should be removed**

### Error Handling and Comments
- **Commit() requires justifying comments** (leading or trailing)
- **Use Error() with ErrorInfo or Label variables** for better telemetry
- **Empty statements need explanatory comments**
- **Procedures must be local, internal, or have documentation comments**
- **Use return values for better error handling**

### Performance Optimization
- **Avoid filter operators in SetRange** - use SetFilter instead
- **Use ReadIsolation instead of LockTable**
- **Use IsEmpty() instead of Count() > 0** for record existence checks
- **Consider Query or Find('-') with Next()** for large datasets
- **Zero-based indexing forbidden** on 1-based List objects
- **Use Get() with correct number/type of arguments** matching table key

### Modern AL Practices
- **Use SecretText for credentials** and sensitive data (AL 14.0+)
- **Use new Date/Time/DateTime methods** for date part extraction (AL 14.0+)
- **Use PageStyle datatype** instead of string literals (AL 14.0+)
- **Use IsNullGuid() for empty GUID checks**
- **Use CRLFSeparator from Type Helper** codeunit
- **Avoid Option types** - use Enum when applicable
- **Replace double quotes in JPath** with two single quotes

## Naming and Documentation Rules

### Naming Conventions
- **Interface names start with capital 'I'** without spaces
- **Label suffix 'Tok' must be locked** and vice versa
- **Locked labels must have 'Tok' suffix** when value matches name
- **Temporary variable names must have 'Temp' prefix**
- **Procedure names cannot contain whitespace**
- **Variable names cannot contain whitespace or wildcards**
- **Consider descriptive names** over generic terms

### Documentation Standards
- **ToolTip must end with period** and start with "Specifies"
- **No line breaks in ToolTip text**
- **ToolTip length should not exceed 200 characters**
- **Missing ToolTip on table fields** should be addressed
- **Avoid duplicate ToolTip between page and table fields**
- **Caption and ToolTip defined at field level**, not page level
- **ApplicationArea = All** only for extensions at field level
- **DataClassification = CustomerContent** only for extensions at field level

### Code Organization
- **Procedure declarations should not end with semicolon**
- **Global variables, triggers, and methods** must be in correct positions
- **Objects should not have empty sections**
- **Variable declarations should be ordered by type**
- **Access/Extensible properties** must be explicitly defined for public objects

## Advanced Rules

### API Development
- **Use camel case for API page property values**
- **Use camel case for API page field controls**
- **Mandatory fields must be present** on API pages
- **API pages require specific field configurations**

### Event Handling
- **Event publishers should not be public** - use Internal access
- **Event subscribers use identifier syntax** not string literals
- **Event subscriber 'var' keyword must match signature**
- **'IsHandled' parameters should be passed by var**
- **Events in internal codeunits not accessible** to extensions

### Performance and Complexity
- **Cyclomatic complexity threshold: 8** (configurable)
- **Maintainability index threshold: 20** (configurable)
- **Cognitive complexity monitoring** available
- **Code metrics warnings** for complex functions

### Version and Compatibility
- **Runtime version should be current** in app.json
- **Translatable texts should be translated** (AL 14.0+)
- **Single quote escaping** must be handled correctly
- **Use identifier syntax** instead of string literals

## Configuration Guidelines

### LinterCop.json Configuration
```json
{
  "cyclomaticComplexityThreshold": 8,
  "maintainabilityIndexThreshold": 20,
  "enableRule0011ForTableFields": false,
  "enableRule0016ForApiObjects": false
}
```

### Rule Suppression
- **Use pragma warnings** for selective rule suppression
- **Use Custom.ruleset.json** for project-wide rule configuration
- **Provide justification** for disabled rules
- **Prefer local suppression** over global rule disabling

## Integration Rules

### System Integration
- **Use Confirm Management codeunit** for Confirm() calls
- **Use Translation Helper codeunit** for GlobalLanguage()
- **Use Page Management codeunit** for page launching
- **Use Type Helper codeunit** for DateTime comparisons

### Install/Upgrade Patterns
- **Set Access = Internal** for Install/Upgrade codeunits
- **Clear(All) ineffective** in single instance codeunits
- **Temporary record patterns** should avoid table triggers

## Testing Considerations
- **Test functions may have empty sections**
- **Test cases should cover positive and negative scenarios**
- **Use marker syntax [| |]** for test diagnostic ranges
- **Test files must be compilable AL code**

These rules ensure consistent, maintainable, and performant AL code that follows Business Central best practices and avoids common runtime errors.