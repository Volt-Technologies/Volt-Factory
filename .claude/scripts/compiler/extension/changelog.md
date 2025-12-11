# Business Central 2026 release wave 1
## Version 17.0

<!-- ### GitHub issues
Make a subheading for the change, write an introductory paragraph that addresses what's added, and what the usage scenario is, and if relevant, add a code example or screenshot.

#### Miscellaneous -->

### Runtime changes

#### Support for namespaces and fully qualified names

New method overloads have been introduced to support running codeunits, pages, and reports using their fully qualified names. Additionally, `RecordRef.Open` can now be invoked with the fully qualified name of a table.

```al
codeunit 10 MyCodeunit
{
    procedure MyProcedure()
    var
        rec: Record Customer;
        recRef: RecordRef;
    begin
        // Run codeunit by fully qualified name
        Codeunit.Run('MyNamespace.CodeunitName');

        // Page methods by fully qualified name
        Page.Run('MyNamespace.PageName');
        Page.RunModal('MyNamespace.PageName');

        // Report methods by fully qualified name
        Report.Run('MyNamespace.ReportName');
        Report.RunModal('MyNamespace.ReportName');
        Report.Execute('MyNamespace.ReportName', 'foo', rec);

        // Load record by fully qualified name
        recRef.Open('MyNamespace.TableName');
    end;
}
```

Record and RecordRef instances now expose a `FullyQualifiedName` property.


```al
codeunit 10 MyCodeunit
{
    procedure MyProcedure()
    var
        rec: Record Customer;
        recRef: RecordRef;
    begin
        Message(rec.FullyQualifiedName);
        Message(recRef.FullyQualifiedName);
    end;
}
```

### Visual Studio Code Editor changes

#### Run tests from VSCode

It is now possible to use the VSCode Text Explorer to run tests. **Note:** This feature is under active development, and more functionality may be added or existing functionality changed. It should be considered as an experimental feature.

Currently, only tests in the active workspace are added to the Test Explorer. The tests have to be published beforehand to a BC server before being run.

Running tests is only supported on BC28 and newer, on both sandboxes and local servers.

#### New AL Tools Available for Agents

The following AL development tools are now accessible to agents:

| Tool Name | Purpose |
|-----------|---------|
| `al_build` | Build the current AL project. |
| `al_buildall` | Build all AL projects in the workspace including the complete dependency tree. |
| `al_download_symbols` | Download symbols for the current project. |
| `al_get_package_dependencies` | Retrieve app's dependencies for the current project. |
| `al_download_source` | Download source code for the current AL project.|
| `al_clear_credentials_cache` | Clear cached authentication credentials.|
| `al_insert_event` | Insert an AL event subscriber or publisher.|
| `al_clear_profile_codelenses` | Clear profile code lenses in the current workspace.|
| `al_initalize_snapshot_debugging` | Initialize a snapshot debugging session.|
| `al_finish_snapshot_debugging` | Finish an active snapshot debugging session.|
| `al_go` | Initialize a (new) AL project (AL: Go!).|
| `al_new_project` | Create a new AL project.|
| `al_incremental_publish` | Perform a rapid application publish with debugging.|
| `al_debug_without_publish` | Start a debug session without publishing the extension.|
| `al_full_package` | Create a package including the full dependency tree for the active project.|
| `al_generate_cpu_profile_file` | Generate a CPU profile file for performance analysis.|
| `al_generate_manifest` | Generate a manifest file for the current project.|
| `al_generate_permissionset_for_extension_objects` | Generate a permission set AL object for current extension objects. |
| `al_generate_permissionset_for_extension_objects_as_xml` | Generate a permission set XML file for current extension objects. |
| `al_open_Event_Recorder` | Open the AL Event Recorder UI. |
| `al_open_Page_Designer` | Open the AL Page Designer. |
| `al_package` | Package the AL project. |
| `al_publish` | Publish the built AL package to the target environment. |
| `al_publish_without_debug` | Publish the AL package without starting a debug session. |
| `al_publish_existing_extension` | Publish an already packaged existing extension. |
| `al_snapshots` | Open the snapshots view. |

These tools streamline common AL development workflows and improve automation capabilities for agents.
**Note:** These tools are experimental and subject to change in future updates.

#### Tool Workflow Suggestions

AL tools now suggest logical next steps after execution, streamlining common task sequences and reducing context switching.

#### AL Tools Enhanced Error Handling

Improved error diagnostics with better categorization, actionable hints using `get_errors` tool for automated error retrieval, and comprehensive guidance for common issues.

### AL Code Analyzers changes

#### CodeCops
- CodeCop rule [AA0247](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/analyzers/codecop-aa0247) has been enabled by default.

### Miscellaneous
- Added new compiler error [AL0896](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/diagnostics/diagnostic-al896) for detecting FlowField definitions that are recursively dependent and could cause infinite evaluation.

#### Attach to agent session

It is now possible to attach to agent sessions and debug the AL code they are executing.
To do so, the new client type `Agent` has been introduced along with two new launch configurations to attach to an agent session on a cloud sandbox or your own server.

#### Quick uptake of namespaces

A new code action has been introduced to fix CodeCop rule [AA0247](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/analyzers/codecop-aa0247) by adding namespaces to .al files that are missing them. The namespace is resolved in the following order:

1. Read and parse the newly added `al.namespaceTemplate` setting. The `<parentFolder>` placeholder can be used to dynamically insert the directory of an AL file.
2. If `namespaceTemplate` is not defined or any part of it does not resolve to a valid identifier name, the system attempts to deduce the namespace from sibling files (AL files in the same folder) by parsing their namespaces and using the longest common part.
3. If there are no sibling files, they do not specify a namespace, or there is no common part, the fallback is `publisher.projectname`.
4. If `publisher.projectname` does not resolve to a valid namespace name, no namespace is added.

<!-- ### AL Language changes
Make a subheading for the change, write an introductory paragraph that addresses what's added, and what the usage scenario is, and if relevant, add a code example or screenshot.

#### Miscellaneous -->

# Business Central 2025 release wave 2

## Version 16.2

### Miscellaneous
- Relaxed compiler error [AL1032](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/diagnostics/diagnostic-al1032) to allow duplicate translation files targeting the same language, as long as they are targeting different original apps.
- Fixed crashes in `aldoc` for projects without namespaces or with external business events (methods marked with the ´ExternalBusinessEvent` attribute).

## Version 16.1

### Reporting
- Fixed an issue where the compiler updated the Microsoft Word layouts with the namespace for the extended custom xml document and not the standard custom xml. This caused document rendering to fail for repeaters.


## Version 16.0

### Support for new `ExtendedDataType` value: `Document`

The [ExtendedDataType property](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/properties/devenv-extendeddatatype-property) for `Media` and `MediaSet` fields now also supports the `Document` value.
On pages, these fields can only be used on ListPart and CardPart page types, allowing the client to correctly render elements in FactBoxes, such as displaying a PDF as a portrait image.

### Introducing MaskedType enum field-level property.

A new [MaskType enum property](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/properties/devenv-masktype-property) is introduced with the values `Concealed` and `None`.  The default value is `None`.
When set, `MaskType` instructs the web client to display the field with its value hidden by default, allowing users to toggle visibility and view the value in plain text.
The use of the `MaskType` property is restricted by [AW0017](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/uicop-aw0017?wt.mc_id=d365bc_inproduct_alextension), which prohibits setting this property on fields inside repeater controls.

### Allow copying nodes in the profile editor and support for hovering

In the profile editor, individual nodes can be copied and hovered to show the full text of the node. This allows for easier editing of long nodes, such as SQL queries.

### Cancel publish and package commands

Publishing and packaging AL applications can now be canceled from the Visual Studio Code UI.

### New Business Central Themes for Visual Studio Code

We are excited to introduce two new themes: **Business Central Light** and **Business Central Dark**. These themes prominently feature our favorite color; teal, and are included in the .vsix package. We hope you enjoy the refreshed look and feel they bring to your development experience!

### ALDoc: Improvements
Namespaces can now be documented and when they are, an "Overview" entry is added in the table of contents. The overview includes objects and events from the namespace. The recommended way to document a namespace is to include a source file named after the namespace with '.Namespace.al' appended just containing the documentation and the namespace declaration as the example below:

```
/// <summary>
/// Summary of the namespace functionality
/// </summary>
/// <remarks>
/// Some clever remarks
/// </remarks>
namespace MyCompany.MyNamespace;
```

The aldoc tool is updated to support the latest version of DocFx (2.78.3) when generating the `docfx.json` file. Existing documentation folders can be updated with the following command:

```
aldoc refresh -o <doc folder>
```

which adds a `"_disableToc": false` setting to the `globalMetadata` of the `docfx.json` file and refreshes the Business Central docfx templates.

### Summary System Part Support

With this release, we Introduce a new system part of type `Summary` that can be controlled on `Card`, `Document`, and `ListPlus` pages. This allows developers to hide or configure the Summary factbox when it's not needed.

Control the Summary part in page extensions using the identifier `DefaultSummaryPart`:

```al
pageextension 50101 MyPageExtension extends "Customer Card"
{
    layout
    {
        modify(DefaultSummaryPart)
        {
            Visible = false;
        }
    }
}
```

Or, define it explicitly in new pages like this:

```al
page 50101 MyPage
{
    layout
    {
        area(FactBoxes)
        {
            systempart(DefaultSummaryPart; Summary)
            {
                Visible = false;
            }
        }
    }
}
```

Note that there can only be one summary system part per page.

### ALTool: New "compile" Command Support

ALTool now supports invoking `alc` for compiling AL packages. The syntax is:

```
altool compile <alc arguments>
```

This feature is particularly useful when used with the [Business Central Development Tools NuGet package](https://www.nuget.org/packages/Microsoft.Dynamics.BusinessCentral.Development.Tools). The package is a [.NET tool](https://learn.microsoft.com/dotnet/core/tools/global-tools) that includes the AL development tools required for pipelines. Unlike the .vsix installation, it can easily be installed in a pipeline. When installed as a global tool, you can start a compilation by using the following command:

```
AL compile <alc arguments>
```
The `AL` command acts as a convenient alias for ALTool when installed via the NuGet package.

To explore all available commands for ALTool (or AL alias), run the tool without any arguments. Currently supported commands include:

| Command                        | Description                                           |
|--------------------------------|-------------------------------------------------------|
| `compile`                      | Compile a package using `alc.exe`.                   |
| `GetPackageManifest`           | Retrieve the manifest from a `.app` file.            |
| `CreateSymbolPackage`          | Create a symbol-only package from a `.app` file.     |
| `GetLatestSupportedRuntimeVersion` | Get the latest supported AL runtime version for a platform version. |
| `help`                         | Display detailed information about a specific command. |
| `version`                      | Display version information.                         |

This enhancement streamlines the AL development process, especially in CI/CD pipelines, by providing a more accessible and efficient way to compile AL packages.

### Go To Symbol in Workspace
The Visual Studio Code feature "Go To Symbol In Workspace" (Ctrl + T) has been extended to search for a broader range of AL symbols. In addition to application objects, it now includes procedures, events, global variables, page controls, page actions, table fields, and many more.

This new way of searching can be disabled under the setting "al.extendGoToSymbolInWorkspace.enabled". In addition, you can configure the maximum amount of symbols to display with the "al.extendGoToSymbolInWorkspace.ResultLimit" setting. Use the "al.extendGoToSymbolInWorkspace.IncludeSymbolFiles" setting to specify if the search should include the dependencies symbol files.

### RecordRef - Get field by name

New overloads are added to the `Field` and `FieldExist` methods, which allows searching for a field by its name.


### Editable fields in page customizations

You can now make page fields defined in page customizations **editable**. Previously, such fields were always read-only, unlike fields declared in pages or page extensions.
```al
pagecustomization MyPageCust customizes MyPage
{
    layout
    {
        addfirst(Content)
        {
            field(MyPageCustField; Rec.MyTableField) { Editable = true; }
        }
    }
}
```

To give AL developers more control over how table fields are used in customizations, new values have been added to the [AllowInCustomizations](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/properties/devenv-allowincustomizations-property) property:
- `Never` – still excludes a table's fields from the in-client designer.
- `AsReadOnly` – allows use in page customizations, but only as read-only.
- `AsReadWrite` – allows fields to be made editable in page customizations.

The default value `ToBeClassified` and the obsolete value `Always` both behave like `AsReadOnly`.

For efficiency, [AllowInCustomizations](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/properties/devenv-allowincustomizations-property) can now also be set at the table and table extension level. On table extensions, this only applies to fields declared in the table extension and does not affect the base table fields.

To support field classification, new analyzer rules are introduced: [AS0138](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0138), [AS0139](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0139), and [PTE0026](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/pertenantextensioncop-pte0026). These rules are currently optional and do not block AppSource submissions or PTE uploads. Learn more in the dedicated sections for analyzer rules.

### Semantic Highlighting Improvements
![Semantic Highlighting Improvements Demo](https://raw.githubusercontent.com/microsoft/AL/refs/heads/master/resources/SemanticHightlightingImprovements.gif)
- Code made inactive using #if/#else/#endif directives is now shown in the same color. This improves readability when using Conditional directives. There is a known issue with brackets (parentheses, begin/end, curly braces, etc.) if bracket pair colorization is active. Unless `"editor.bracketPairColorization.enabled": false`, brackets will still have colors when code is inactive.
- XML documentation comments now support Semantic Highlighting if the selected theme supports it. Try the Visual Studio 2019 Dark & Light themes.
- Obsolete symbols now also support Semantic Highlighting.

### Reporting
- Allow empty dataitems when emitting Excel layouts with multiple datasheets (error if no data items contains columns which would result in a workbook with no data sheets).
- Add new layout information fields in the aggregated metadata sheet for the Excel layout template (object caption, local date. and UTC timezone offset).
- Updated report Word layout XML, enabling layouts to be compatible with the new data picker in the Word add-in; and it now includes the 'Obsolete State' attribute for Report Column and DataItem elements.

### ALDoc Improvements
- New option (--includeinternals) to include internal symbols in the generated documentation.
- Fixed navigational links to other reference symbols
- Reference to other objects contains object type.
- New fallbacks in case of missing symbol documentation
  - Promote `AboutText` property to page or report summary
  - Promote `Tooltip` property to table fields summary
- New ALDoc option (--targetpackageslist) accepts space-separated values to support target package names containing commas (unlike --targetpackages).
  For example, `--targetpackageslist "TechCore,Inc" "Fintech Corp" "Global Solutions, Ltd"`

### TestType Property in AL tests

We have introduced a new `TestType` property in test codeunits, which allows engineers to specify the primary purpose and scope of the test.

The property can be used to group tests for execution and reporting in CI/CD pipelines.

### RequiredTestIsolation Property in AL tests

We have introduced a new `RequiredTestIsolation` property in test codeunits, which allows engineers to set the required TestIsolation for the test codeunit to run in. If the selected TestRunner does not satisfy the test codeunit's `RequiredTestIsolation` property, then the tests might fail.

The property can be used to group tests for execution and reporting in CI/CD pipelines.

If a test codeunit has `RequiredTestIsolation = None`, then it can run by a TestRunner with any TestIsolation.

If a test codeunit has `RequiredTestIsolation = Codeunit`, then it requires a TestRunner with Codeunit TestIsolation.

If a test codeunit has `RequiredTestIsolation = Function`, then it requires a TestRunner with Function TestIsolation.

If a test codeunit has `RequiredTestIsolation = Disabled`, then it requires a TestRunner with Disabled TestIsolation.

### AppSourceCop
- New rules [AS0136](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0136) and [AS0137](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0137) which will allow the change of field IDs for tables and table extensions under specific conditions. The feature is enabled only for Microsoft applications for now.
- New rule [AS0138](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0138) validating that table fields are classified with a value different from `ToBeClassified` and `Always`. This rule will not fail AppSource submissions as it is not enabled by default and requires a ruleset to be enabled.
- New rule [AS0139](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0139) validating that **newly added** table fields are classified with a value different from `ToBeClassified` and `Always`.  This rule will not fail AppSource submissions as the default severity is `Warning`.
- Relaxed rule [AS0018](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0018) to allow removal of non-obsolete procedures referencing an obsolete removed table or a removed application application within an array parameter or array return type.

### PerTenantExtensionCop
- New rule [PTE0026](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/pertenantextensioncop-pte0026) validating that table fields are classified with a value different from `ToBeClassified` and `Always`. This rule will not fail PTE uploads as it is not enabled by default and requires a ruleset to be enabled.

### GitHub Issues
- [#7885](https://github.com/microsoft/AL/issues/7885) No object ID suggested when namespace is used
- [#8004](https://github.com/microsoft/AL/issues/8004) PageCustomization IntelliSense - Fields of PageExtensions missing
- [#7741](https://github.com/microsoft/AL/issues/7741) AA0198 is not reported for return variables of procedures
- [#7949](https://github.com/microsoft/AL/issues/7949) Convert page control tooltip to table control tooltip does not work for non-Rec variables.
- [#7988](https://github.com/microsoft/AL/issues/7988) AL0155 is raised for ReportExtension but not on other extension objects
- [#8020](https://github.com/microsoft/AL/issues/8020) Unable obsolete usercontrol
- [#8002](https://github.com/microsoft/AL/issues/8002) False positive AA0210 on CustomTable SystemId SetRange
- [#7874](https://github.com/microsoft/AL/issues/7874) False positive for AA0206 when using DateTime.Date() or DateTime.Time()
- [#8005](https://github.com/microsoft/AL/issues/8005) AA0137 missing warning for global variables on report extensions
- [#8078](https://github.com/microsoft/AL/issues/8078) dotnet tool al returns exit code 1 when displaying help information
- [#7477](https://github.com/microsoft/AL/issues/7477) Semantics are lost on Enum values if AsInteger has no parentheses
- [#7867](https://github.com/microsoft/AL/issues/7867) AA0248 in Pageextensions not working as expected
- [#7996](https://github.com/microsoft/AL/issues/7996) Snapshot debugging via "Help & Support" doesn't work if .vscode folder exists
- [#7985](https://github.com/microsoft/AL/issues/7985) No AA0218 warning on certain role center actions
- [#8015](https://github.com/microsoft/AL/issues/8015) Error 85132273 during Publish and Install application
- [#8039](https://github.com/microsoft/AL/issues/8039) generateCrossReferences not working - System.AggregateException due to System.NullReferenceException
- [#8036](https://github.com/microsoft/AL/issues/8036) Unable to authenticate to BC on Linux [#8036](https://github.com/Microsoft/AL/issues/8036)
- [#8059](https://github.com/microsoft/AL/issues/8059) Analyzer 'Microsoft.Dynamics.Nav.CodeCop.Design.Rule139DoNotAssignToStringWithSmallerCapacity' threw an exception of type 'System.InvalidCastException'
- [#8058](https://github.com/microsoft/AL/issues/8058) ALDOC fails when app publisher name contains a comma
- [#8061](https://github.com/microsoft/AL/issues/8061) Debugger does not show named return variable
- [#8069](https://github.com/microsoft/AL/issues/8069) AL Language Opens Problem Pane on Every Project Open

### Miscellaneous
- Error diagnostic for defining methods with an empty name.
- RAD publishing will stop if there are no detected application object changes.
- Implicit conversion from `TestFilterField` to `Variant` or `Joker` is no longer allowed, correcting for a previous issue where such conversions would result in a runtime error.
- Fixed an issue where it was not possible to refer to members (eg. fields) added by page extensions via a page customization on the same application.
- Fixed an issue where return values which collided with global variables did not produce a warning.
- Fixed an issue where AL:Package copied an empty app file to other projects in the same workspace that were referencing the packaged one. The issue only occured when the `compilationOptions` `outFolder` was set to a relative path.
- When the manifest file is saved, analyzer diagnostics will no longer disappear.
- Fixed some cases where diagnostics would be emitted for an older version of the source.
- The methods `Visible()` and `Enabled()` are now available on `TestPart` objects.
- `UpdateAuditFields` on `DataTransfer` is now in Cloud scope.
- More diverse tokens for semanticTokenColorCustomizations
- Added new CodeCop rules to ensure `AutoFormatType` and `AutoFormatExpression` properties are correctly specified for decimal fields:
  - [AA0471](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/codecop-aa0471): `AutoFormatType` must be specified for decimal fields on pages.
  - [AA0472](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/codecop-aa0472): `AutoFormatExpression` must be specified for decimal fields on pages when `AutoFormatType` is 1, 2, or 10.
  - [AA0473](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/codecop-aa0473): `AutoFormatType` must be specified for decimal fields on tables.
  - [AA0474](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/codecop-aa0474): `AutoFormatExpression` must be specified for decimal fields on tables when `AutoFormatType` is 1, 2, or 10.

  These rules are disabled by default and must be enabled via a ruleset.
- Add support for Truncate on Record and RecordRef, and a CodeCop rule to ensure it is only used where applicable.
  - [AA0475](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/codecop-aa0475): `Truncate` can only be used on normal tables without media fields and outside of try functions.
- Add support for custom Microsoft Entra ID authentication overrides in settings. The new setting is `al.entraIdAuthentication`, a complex type consisting of one or more of the following properties: `endpoint` (ex. https://login.microsoftonline.com), `clientId` (ex. 41839ce3-4041-4bac-8c17-0941f25d7aaf), `redirectionUri` (ex. https://developer.businesscentral.dynamics.com), `scope` (ex. https://api.businesscentral.dynamics.com/.default). See [Public client and confidential client applications](https://learn.microsoft.com/en-us/entra/identity-platform/msal-client-applications) for reference on creating a public client.
- Fixed an issue where entering credentials after failed requests would not respect user's request to cancel (pressing Esc).
- Compilation will now fail more gracefully when the `app.json` file is malformed.
- Fixed an issue where `Label` type variables coming from dependency apps would be displayed as __MissingTypeSymbol__ if the label has MaxLength defined.
- Supports having collections with RecordRefs
- Add `Guid.CreateGuid` (same as `CreateGuid`) and `Guid.CreateSequentialGuid` which creates a new unique GUID which is more performant when used in a table key.
- Add `LockTimeoutDuration` allow increasing/lowering lock timeout instead of only disabling/enabling it.
- Fixed an issue where the altpgen tool would fail if the project contained references to apps with relevant table extensions.

# Business Central 2025 release wave 1

## Version 15.3

### GitHub Issues
- [#7771](https://github.com/microsoft/AL/issues/7771) Table fields with AllowInCustomizations = Never are not visible when added to a page extension
- [#8011](https://github.com/microsoft/AL/issues/8011) Formatter issue with AL Language Extension on save

### AppSourceCop
- Updated rule [AS0034](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0034) to allow tables to transition from temporary to normal.

### Miscellaneous
- Fixed an issue where scheduling a PTE for the next major would fail with [PTE0004](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/pertenantextensioncop-pte0004) error in certain cases.

## Version 15.2

### Allow deprecating external business events
We have added support for deprecating `ExternalBusinessEvent` type events.

The process follows the standard obsoletion steps for procedures with one additional requirement:

Step 1: Mark the event as obsolete pending
 - Decorate the procedure with the `[Obsolete('<Reason>','<Tag>')]` attribute.
 - Prefix the `DisplayName` of the `ExternalBusinessEvent` attribute with an `[OBSOLETE]` marker.

Step 2: Remove the obsolete pending event in an upcoming version

#### Example code

```AL
codeunit 10 MyCodeunit
{
    [ExternalBusinessEvent('MyEvent', '[OBSOLETE] MyEventDisplayName', 'Description', EventCategory::MyValue, '1.0')]
    [Obsolete('The event will be replaced by version 2.0 of MyEvent', '27.0')]
    procedure MyEvent()
    begin
    end;

    [ExternalBusinessEvent('MyEvent', 'MyEventDisplayName', 'Description', EventCategory::MyValue, '2.0')]
    procedure MyEvent2()
    begin
    end;
}
```

#### Remarks

It is also possible to obsolete the containing object without deprecating the external business event itself. This is because external business events are identified by their (app ID - event name - event version) triplet from the external subscriber's perspective, independent of their containing object or procedure within AL.
In such scenarios, you must relocate the event within the same app while following the standard obsoletion process for the original containing object.


### Implicit conversion between Record and RecordRef
We have introduced support for implicit conversion between `Record` and `RecordRef` instances, allowing direct assignment between these types.

```AL
codeunit 10 RecordAndRecordRefConversion
{

    procedure RecordToRecordRef()
    var
        Customer: Record Customer;
        RecRef: RecordRef;
    begin
        RecRef := Customer;      // Similar to RecRef.GetTable(Customer);
        ProcessRecord(Customer); // Argument conversion
    end;

    procedure RecordRefToRecord()
    var
        Customer: Record Customer;
        RecRef: RecordRef;
    begin
        Customer := RecRef;      // Similar to RecRef.SetTable(Customer); This will cause an error if the table is different
        ProcessCustomer(RecRef); // Argument conversion.
    end;

    procedure ProcessCustomer(r: record Customer)
    begin
        Message('Process Customer');
    end;

    procedure ProcessRecord(rr: RecordRef)
    var
        Customer: record Customer;
    begin
        case rr.Number of
            Database::Customer:
                Message('Process Customer');
            else
                Error('Unable to process record');
        end;
    end;
}
```

### AppSourceCop
- Updated rule [AS0018](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0106) to allow removing or renaming events in extension objects when the event name conflicts with the name of the events defined in the target object.
- Updated rules [AS0034](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0034) and [AS0039](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0039) to allow modifying the [InherentEntitlments](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/properties/devenv-inherententitlements-property) on tables.
- Updated rule [AS0106](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0106) to allow removing protected global variables conflicting with built-in members. For instance, variables named `Language` on reports which conflict with the built-in [Language](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/methods-auto/report/reportinstance-language-method) method.
- Updated rule [AS0034](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0034) to be more strict about the `Compressed` property, because changing it could lead to extensions not being able to update. Now it will be an error to change the property from `true` to `false` and vice versa. The default value is `true`, so adding the property with `false` will similarly be considered a breaking change.
- Adding new AppSourceCop configuration settings enabling validation of breaking changes on objects which are Obsolete, marked with OnPrem, or marked with Internal accessibility. By default, these objects are not validated by AppSourceCop nor by the AppSource technical validation process. For more info, see [AppSourceCop Configuration](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop#configuration).
- New rule [AS0134](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0134) to detect breaking changes of the version attribute parameter of external business events. The rule will not fail AppSource submissions as the default severity is `Warning`.
- New rule [AS0135](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0135) to validate that external business events are correctly obsoleted prior to removal.

### GitHub Issues
- [#7790](https://github.com/microsoft/AL/issues/7790) Support for multiple extensions to same target introduces the translations bug

### Miscellaneous
- Introduced a new Warning Error that is thrown when a field from a table extension is referenced from a key in another table extension, which extends the same base table. This will become an error from Business Central 2026 Wave 2.  Learn more about the limitation described in our [docs](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/devenv-table-keys#keys-in-table-extension-objects).
- Fixed issues with .ToText formatting on `Decimal`, `Boolean`, `Byte`, and `Guid` data types. Added text methods to the `TextConstant` data type and removed static methods on the `Label` type.
- When authenticating using Entra ID, interactive login is now the default. This uses MSAL (Microsoft Authentication Library) and opens authentication in the system's default browser, which means it does not respect the AL extension settings for browser selection or incognito mode during the interactive authentication flow. You can go back to device authentication by setting `"useInteractiveLogin" : false`.
- Updated the maximum allowed CSV length to 2048 to resolve import errors in the Bank Reconciliation Journal via Data Exchange Definition.

## Version 15.1

### Pass SecretText to control-addins

It is now possible to pass a value of type `SecretText` to control add-in procedures. This permits the integration of credentials with JavaScript-based authentication solutions.

### New method to add SecretText values to JSON objects - `WriteWithSecretsTo`
A new method was added to the `JsonObject` type, which allows developers to add SecretText values. To use it, the AL developer first creates a JSON object with placeholder values for their secret values. Then they provide paths to the values in the JPath format as well as the values themselves. Finally, the method produces a new `SecretText` value with the credentials replaced.

```
procedure CreateSecretBody(ApiKey: SecretText, SecretSalt: SecretText) : SecretText
var
    JsonBody: JsonObject;
    Secrets: Dictionary of [Text, SecretText];
    Result: SecretText;
begin
    // Create a debuggable body
    JsonBody.Add('type', 'Some type');
    JsonBody.Add('api_key', 'placeholder');
    JsonBody.Add('salt', 'placeholder');

    // Prepare the replacements
    Secrets.Add('$.api_key', ApiKey);
    Secrets.Add('$.salt', SecretSalt);

    // Produce the secret body
    JsonBody.WriteWithSecretsTo(Secrets, Result);
    exit(Result);
end
```

### GitHub Issues
- [#7993](https://github.com/microsoft/AL/issues/7993) Using HttpClient.UseServerCertificateValidation requires to use return value, but only in method usage.

## Version 15.0

### Mocking HTTP calls in AL tests

We have introduced a new handler type `HttpClientHandler` to allow mocking the response of HTTP requests in test codeunits. This feature allows for more controlled and easier testing of modules that interact with external services. The feature is limited to OnPrem instances only.

#### HttpClientHandler

When an `HttpClientHandler` is added to a test method, every HTTP request that occurs during the execution of that test will be intercepted and routed to the handler. The handler method signature is as follows: it receives a `TestHttpRequestMessage` that contains information about the HTTP request, as well as a `TestHttpResponseMessage` that contains the mocked HTTP response values that should be updated by the handler. The Boolean return value indicates whether to fall through and issue the original HTTP request (true) or to use the mocked response (false).

#### TestHttpRequestPolicy Property

We have also introduced a new property on test codeunits called `TestHttpRequestPolicy`. This property determines how outbound HTTP requests are treated during test execution and has the following possible values:

- **BlockOutboundRequests**: Any HTTP request issued during the test execution that is not caught and handled by an HTTP client handler will raise an exception.
- **AllowOutboundFromHandler**: All HTTP requests issued during the test execution are required to be caught by an HTTP client handler. The handler is allowed to explicitly fall through to issue the original request to the external endpoint.
- **AllowAllOutboundRequests**: All outbound HTTP requests issued during the test execution are allowed.

#### Example code

```AL
codeunit 10 MyCodeunit
{
    procedure MethodWithHttpRequest()
    var
        Client: HttpClient;
        Response: HttpResponseMessage;
    begin
        Client.Get('http://example.com/', Response);
    end;
}

codeunit 11 MyCodeunitTests
{
    Subtype = Test;
    TestHttpRequestPolicy = AllowOutboundFromHandler;

    [Test]
    [HandlerFunctions('HttpClientHandler')]
    procedure TestUnauthorizedResponseHandled()
    var
        MyCodeunit: Codeunit "MyCodeunit";
    begin
        MyCodeunit.MethodWithHttpRequest();
    end;

    [HttpClientHandler]
    procedure HttpClientHandler(request: TestHttpRequestMessage; var response: TestHttpResponseMessage): Boolean
    begin
        // Mock a '401 Unauthorized' response for the 'GET http://example.com/' request
        if (request.RequestType = HttpRequestType::Get) and (request.Path = 'http://example.com/') then begin
            response.HttpStatusCode := 401;
            response.ReasonPhrase := 'Unauthorized';
            exit(false); // Use the mocked response
        end;

        // Fall through and issue the original request in case of other requests
        exit(true);
    end;
}
```

### Searchable downloaded symbols and using them as context in Copilot Chat

Objects from downloaded symbol packages can now be added as context when using the Github Copilot Chat extension (prerelease version 0.24.2024121201) and Visual Studio Code Insiders (version 1.97 and later). It will also be possible to search and navigate to objects coming from downloaded symbol packages via the 'Open Symbol by Name' functionality (`Ctrl + T`). Additionally, the performance of searching workspace symbols has been improved to support the now larger amount of available symbols.

### UserControlHost PageType

We have introduced a new PageType `UserControlHost`. This page type can be used to only render a single usercontrol in the client. With the `UserControlHost` page type, the layout is optimized by the client to maximize the available space for the usercontrol.

This new page can **only** have a single control of type `usercontrol` within the layout `Content` area.

Actions cannot be specified on this page, and limited properties and triggers are available for it. It is also not extensible.

### Multiline strings
AL now has support for multiline string literals. A multiline string must be prefixed with @.

```AL
var
    t: Text;
begin
    t := @'This is
a
multiline
string
';
end;
```

### Continue statement

From runtime version 15, it is possible to use the `continue` keyword in loops to continue to the next iteration.

### Preview support in File
Two new methods to open and view a file on the client.

```AL
[Ok :=] File.ViewFromStream(Stream: InStream, FileName: String [, AllowDownloadAndPrint: Boolean]);
[Ok :=] File.View(FilePath: String [, AllowDownloadAndPrint: Boolean]);
```

### New methods access properties and array elements
We have improved the API for accessing JSON data with a new set of methods that will avoid always to read data through a JsonToken.

For JsonObject instances we have added:

```AL
value := GetBoolean(Key: Text [; DefaultIfNotFound: Boolean])
value := GetByte(Key: Text [; DefaultIfNotFound: Boolean])
value := GetChar(Key: Text [; DefaultIfNotFound: Boolean])
value := GetInteger(Key: Text [; DefaultIfNotFound: Boolean])
value := GetBigInteger(Key: Text [; DefaultIfNotFound: Boolean])
value := GetDecimal(Key: Text [; DefaultIfNotFound: Boolean])
value := GetOption(Key: Text [; DefaultIfNotFound: Boolean])
value := GetDateTime(Key: Text [; DefaultIfNotFound: Boolean])
value := GetDate(Key: Text [; DefaultIfNotFound: Boolean])
value := GetTime(Key: Text [; DefaultIfNotFound: Boolean])
value := GetDuration(Key: Text [; DefaultIfNotFound: Boolean])
value := GetText(Key: Text [; DefaultIfNotFound: Boolean])
value := GetArray(Key: Text [; DefaultIfNotFound: Boolean])
value := GetObject(Key: Text [; DefaultIfNotFound: Boolean])
```

For JsonArray instances we have added:
```AL
value := GetBoolean(Index: Integer [; DefaultIfNotFound: Boolean])
value := GetByte(Index: Integer [; DefaultIfNotFound: Boolean])
value := GetChar(Index: Integer [; DefaultIfNotFound: Boolean])
value := GetInteger(Index: Integer [; DefaultIfNotFound: Boolean])
value := GetBigInteger(Index: Integer [; DefaultIfNotFound: Boolean])
value := GetDecimal(Index: Integer [; DefaultIfNotFound: Boolean])
value := GetOption(Index: Integer [; DefaultIfNotFound: Boolean])
value := GetDateTime(Index: Integer [; DefaultIfNotFound: Boolean])
value := GetDate(Index: Integer [; DefaultIfNotFound: Boolean])
value := GetTime(Index: Integer [; DefaultIfNotFound: Boolean])
value := GetDuration(Index: Integer [; DefaultIfNotFound: Boolean])
value := GetText(Index: Integer [; DefaultIfNotFound: Boolean])
value := GetArray(Index: Integer [; DefaultIfNotFound: Boolean])
value := GetObject(Index: Integer [; DefaultIfNtFound: Boolean])       o
```

### New Command in VSCode to start a new project from a template
We have added a new command AL.NewProject. From this it is possible to start a new project from a template.

### New IncStr method overload
A new overload of the `IncStr` method was added to support an arbitrary positive increment. This allows for incrementing number series or other similar series by more than one position in one go.

### New VS Code actions from the Web Client
Two new actions have been added to the **Extension Management** page. One to generate launch configurations in your local AL project to match the environment, and another to select installed extensions and download them as dependencies.

### GitHub Issues
- [#7787](https://github.com/microsoft/AL/issues/7787) Rule AA0234 implemented inconsistently?
- Added warning [AL0864](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/diagnostics/diagnostic-al864) when having controls of `ChartPart` type, since they are not supported by the web client. From runtime version 16.0, this will turn into the error [AL0855](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/diagnostics/diagnostic-al865).
- [#7746](https://github.com/microsoft/AL/issues/7746) Misleading ToolTip on RunTime in App.Json
- [#7873](https://github.com/microsoft/AL/issues/7873) False positives for warning AA0234
- [#7880](https://github.com/microsoft/AL/issues/7880) Interface XML comments are not properly handled. They are ignored
- [#7898](https://github.com/microsoft/AL/issues/7898) AA0205 is fired for assigned variables when combined with THIS keyword
- [#7846](https://github.com/microsoft/AL/issues/7846) Wrong tooltip in TableRelation when table name matches top-level namespace name
- [#7924](https://github.com/microsoft/AL/issues/7924) AA0242 is thrown when "Rec.AddLoadFields" is used after "Rec.SetLoadFields"
- [#7769](https://github.com/microsoft/AL/issues/7769) The AL Server crashed 5 times in the last 3 minutes
- [#7801](https://github.com/microsoft/AL/issues/7801) AA0218 not working as expected for dependent fields
- [#7965](https://github.com/microsoft/AL/issues/7965) ALDoc - Referenced module not loaded. Name:'Application'
- [#7968](https://github.com/microsoft/AL/issues/7968) AS0064 is thrown even if interface is Access=Internal
- [#7963](https://github.com/microsoft/AL/issues/7963) The AL compiler builds invalid permission XML files when it contains only few permissions
- [#7969](https://github.com/microsoft/AL/issues/7969) Missing AL0185 for page parts
- [#7964](https://github.com/microsoft/AL/issues/7964) Error AS0003 when compiling any app with AppSourceCop enabled - MacOS
- [#7974](https://github.com/microsoft/AL/issues/7974) InlayHint fails
- [#7979](https://github.com/microsoft/AL/issues/7979) ALDoc skips documentations for objects with ampersand
- [#7885](https://github.com/microsoft/AL/issues/7979) No object ID suggested when namespace is used
- [#7981](https://github.com/microsoft/AL/issues/7981) ALDoc skips documentation if procedure param record has ampersand

### AppSourceCop
- Updated rule [AS0128](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0128) to allow removing a previously obsoleted interface from the list of extended interfaces.
- New rule [AS0130](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0130) that warns against duplicate object names across namespaces.
- Updated rule [AS0064](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0064) to allow removing a previously internal interface from the list of implemented interfaces.

### PerTenantExtensionCop rules
- New rule [PTE0025](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/pertenantextensioncop-pte0025) that warns against duplicate object names across namespaces.

### Reporting
- Added the `ObsoleteState`, `ObsoleteReason`, and `ObsoleteTag` properties to the Report Layout to enable marking a layout as obsolete.
- Added the `ExcelLayoutMultipleDataSheets` property to the Report Layout to specify whether an Excel layout should be rendered with multiple or a single data sheet.
- Add new Excel data sheet when adding root level data items and the layout uses multiple data sheets.
- Add new layout information fields in the aggregated metadata sheet for the Excel layout template (layout name, caption and id). Also add Company Display name to the same table.
- Add a new report trigger OnPreRendering to handle additional platform processing of the generated report artifact.
- Add a new report property TargetFormat that gets the current output format.
- Fixed a problem with multiple sheet Microsoft Excel layout generation, when root DataItems had names containing special or whitespace characters (Excel required table repairs before the workbook could open).

### HttpClient
- Added the `UseServerCertificateValidation` property to the HttpClient data type to selectively disable server certificate validation on HTTP requests. Default value is true.

### Miscellaneous
- Added SetAutoCalcFields on the RecordRef data type.
- Deprecated Debugger.EnableSqlTrace
- When the `AddText` or `Read` methods are used on a non-assignable target of type `BigText`, the produced values will be discarded instead of causing a crash.
- Interfaces cannot contain methods whose signatures collide with the methods from the extended interfaces. It is also not possible to extend an interface with other interfaces whose methods collide.
- Allow having a dictionary where the value type is an interface.
- [BCIdea](https://experience.dynamics.com/ideas/idea/?ideaid=6392e5fb-bf39-ed11-97b1-0003ff45a617) Hovering over labels will additionally reveal if they are locked. Enums will show ordinal values. Codeunit hover text will contain the subtype (if it is a test or install codeunit etc.) and if it is a single instance.
- [BCIdea](https://experience.dynamics.com/ideas/idea/?ideaid=db0e5a74-25c0-e911-b083-0003ff68d32d) Support modification of `CardPageID` on `PageExtension`s. If the property is already specified on the base page, the value in the `PageExtension` will override it. If multiple `PageExtension`s modify the property, the last extension to be applied will take effect.
- [BCIdea](https://experience.dynamics.com/ideas/idea/?ideaid=29cf8e3d-8dfd-ea11-b5d9-0003ff688ba0) Added ToText method to simple types (BigInteger, Boolean, Byte, Date, DateTime, Decimal, Duration, Guid, Integer, Time, Version) for simple conversion to text. Continue to use FORMAT for advanced formatting options.
- Added a new ValidateServerCertificate property in the launch.json file. Default value is true. When set to false the connection to the Business Central service will no longer validate the server endpoint certificate.
- [BCIdea](https://experience.dynamics.com/ideas/idea/?ideaid=ef198658-bf39-ed11-97b1-0003ff45a617) It is now possible to 'Peek references' by clicking CodeLenses
- [CodeLens references](https://raw.githubusercontent.com/microsoft/AL/master/resources/CodeLensReferences.gif)
- OptimizeForTextSearch will now cause an error if used on non-normal tables or fields.
- Fixed an issue with "Publish Full Dependency For Active Project" where publishing would fail to use the correct port if a port was specified in the server URL in the `launch.json` file.
- Fixed an issue where moved fields would cause an ambiguous reference error when used in TestFilters.
- When autocompleting overloads for methods, if all of them have the same deprecation reason, the description will contain it.
- Fixed issues with the "Implement Interface" codefixer. Methods with interfaces parameters are generated correctly. Variable/Parameters type casing is aligned to Pascal Case. Fully qualified names are only used if needed i.e. respecting namespace-declaration and using-statements.
- Fixed issue with deep structured code would cause StackOverflowException
- Added support to display the default value of boolean properties on hover and in IntelliSense suggestions.
- Actions that have the `RunObject` property specified will use the [Caption](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/properties/devenv-caption-property), [ToolTip](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/properties/devenv-tooltip-property), [AboutText](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/properties/devenv-abouttext-property), and [AboutTitle](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/properties/devenv-abouttitle-property) properties of the targeted application object if none of these properties are specified. In support of this, the ToolTip property has also been added to Reports.
- It is now possible to specify layout on the GetUrl command.
- Fixed an issue where object IDs were not recommended with namespaces.
- Added support for getting the current callstack by using the following statement `callstack := SessionInformation.Callstack`.
- Fixed an issue where Rapid Application Development (RAD) publishing would break when workspace changes consisted only of deleted files.
- Continue keyword is now recommended by intellisense.
- New CodeCop rule [AA0249](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/codecop-aa0249) to warn about unused page field triggers.

# Business Central 2024 release wave 2
## Version 14.3

### Yaml-support in JsonObject
Support for YAML is add to the JsonObject. YAML can be read into a JsonObject and be manipulated using the JsonObject API.

Two new methods are added to read YAML into a JsonObject instance:

```AL
[Ok :=] ReadFromYaml(String)
[Ok :=] ReadFromYaml(InStream)
```

And two new methods are added to write a JsonObject instance as YAML:

```AL
[Ok :=] WriteToYaml(String)
[Ok :=] WriteToYaml(OutStream)
```

### AppSourceCop
- It will now be possible to delete table extensions which depend on Microsoft tables which are obsoleted for removal if the app source submission targets releases newer or equal to 2024 release wave 1 (version 24).

## Version 14.2

### Resources in extensions
Resource files can now be packaged as part of an extension. To add resources to your extension, the following property has to be set in your app.json:

```JSON
"resourceFolders": [<list of folders that contain resources>]
```

The folders should be listed relative to the root of your project. For example:

```JSON
"resourceFolders": ["Resources"]
```

This will include all files under the folder 'resources'. The resource folders themselves can contain additional subfolders. For example, you could have the following folder structure:

```
MyApp
| - Resources/
  | - Images/
    | - MyImage.png
  | - Configuration/
    | - MyConfiguration.json
| - src/
  | - MyCodeunit.codeunit.al
```

Access to these resources is done through the `NavApp.GetResource("resource name": Text; var instream: Instream; [optional] encoding: TextEncoding)` method. The name of a resource is its path from the root of its resource folder. So for the folder structure above, you can do:

```AL
procedure MyProc()
var
    resultStream: Instream;
    jsonText: Text;
begin
    NavApp.GetResource("Images/MyImage.png", resultStream);
    // Do stuff with the blob in the resultStream object

    NavApp.GetResource("Configuration/MyConfiguration.json", resultStream, TextEncoding::UTF8);
    jsonText := resultStream.Read(jsonText);
end
```

There are also the methods `NavApp.GetResourceAsText("resource name": Text; [optional] encoding: TextEncoding): Text` and `NavApp.GetResourceAsJson("resource name": Text; [optional] encoding: TextEncoding): JsonObject` that directly retrieves resources as `Text` or `JsonObject` types.

The method `NavApp.ListResources([optional] filter: Text)` is also provided to allow for iteration over resources. The `filter` value for the method can contain wildcards. If it does not contain wildcards, then any resources with the filter text within its name will be returned. For example:

```AL
/**
* For the following resource structure:
* Resources/
*     Images/
*         SampleImage1.png
*         SampleImage2.png
*         SampleImage3.jpg
*         TemplateImage.jpg
*     Snippet/
*         SampleSnippet.txt
*         TemplateSnippet.txt
*/

// This will return: ["Images/SampleImage1.png","Images/SampleImage2.png","Images/SampleImage3.jpg", "SampleSnippet.txt"]
NavApp.ListResources("Sample");

// This will return: ["Images/SampleImage1.png","Images/SampleImage2.png"]
NavApp.ListResources("Images/*.png")
```

Resources can only be accessed within the scope of the app that contains them. This means that there is no way to access the resources of another app.

### AppSourceCop
- Addressed issues executing page breaking change validation rules [AS0029](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0029), [AS0035](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0035), and [AS0040](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0040) on pages whose source tables jave been moved tables to another extension, for instance 'No. Series'.

### Miscellaneous
- Fixed an issue where race conditions would occur if a code action that is invoked on project or workspace scope tried to change large number of files.
- Fixed an issue that caused the runtime to fail, when calling methods from extended interfaces on an instance of the derived interface.

## Version 14.1

### Miscellaneous
- Support for runtime version 14.1

## Version 14.0

### Pull extension source from Git when opening Visual Studio Code from the web client
This feature allows users to pull source code from a Git repository or a specific build using the `source` metadata in the extension’s manifest. This is particularly useful if access to extension code is blocked by IP resource exposure protection.

From the `Extension Management` list and `Page Inspector` (`Extensions` tab) pages, a new “Open Source in VS Code” option is available in the context menu for an extension. When selected, Visual Studio Code will open and prompt you to clone or open the Git repository for the extension and synchronize it with the commit version used to compile it, using the repo metadata included in the extension. It will also remember the local path where the repository is located for easier access. This feature empowers support, consultants, and developers to navigate code, hotfix builds, or sync to get the latest changes for investigation or development.

### Support for SaveAsJson on the Query object
We have added support for SaveAsJson on the Query object.
This functionality is now available alongside the existing SaveAsXml and SaveAsCsv methods.

```
procedure Test();
var
    result : Boolean;
    os: OutStream;
begin
    result := Query.SaveAsJson(10, os);
end;
```

### Ternary operator `?:` in AL
We have added the ternary (conditional) operator to the AL language. The ternary operator ? : known from other programming languages streamlines conditional operations in code, enhances readability, and reduces verbosity. It's particularly useful for simple conditions, promoting code clarity, and intent-focused programming.

The following examples show how the code in `GetBooleanText()` can be rewritten using the ternary operator to be less verbose and more succint.

Without the ternary operator

```
procedure GetBooleanText(b: Boolean): Text;
begin
    if b then
        exit('True')
    else
        exit('False');
end;
```

With the ternary operator

```
procedure GetBooleanString(b: Boolean): Text;
begin
    exit(b ? 'True' : 'False');
end;
```

### Wildcard search in AL Explorer
We have improved the search functionality in AL Explorer by supporting `*` and `?` wildcards.

`*` means zero or more characters
`?` means any single character

Here are some examples
Pattern | Description | Examples
-|-|-
Customer* | Starts with **Customer** | 'Customer Card', 'Customer'
*Card | Ends with **Card** | 'Customer Card', 'Item Card', 'SomeCard'
Customer*Card | Starts with **Customer** and ends with **Card** | 'Customer Card', 'Customer Accounts Card'
\*Customer\* | Customer anywhere | 'Customer', 'Apply Customer Entries'


### New Date/Time/DateTime methods
We have modernized the Date/Time/DateTime APIs for extracting sub-components of the types.

Type | New method | Existing | Description
-|-|-|-
Date | `MyDate.Day`| `Date2DMY(MyDate, 1)` | Gets the day of month from `MyDate`
Date | `MyDate.Month`| `Date2DMY(MyDate, 2)` | Gets the month from `MyDate`
Date | `MyDate.Year`| `Date2DMY(MyDate, 3)` | Gets the year from `MyDate`
Date | `MyDate.DayOfWeek`| `Date2DWY(MyDate, 1)` | Gets the day of week from `MyDate`
Date | `MyDate.Year`| `Date2DWY(MyDate, 2)` | Gets the week number from `MyDate`
Time | `MyTime.Hour`| `Evaluate(i, Format(Time, 2, '<HOURS24>'))` | Gets the hours `MyTime` (0..23).
Time | `MyTime.Minute`| `Evaluate(i, Format(Time, 2, '<MINUTES>'))` | Gets the hours `MyTime` (0..59).
Time | `MyTime.Second`| `Evaluate(i, Format(Time, 2, '<SECONDS>'))` | Gets the hours `MyTime` (0..59).
Time | `MyTime.Millisecond`| `Evaluate(i, Format(Time, 3, '<THOUSANDS>'))` | Gets the hours `MyTime` (0..999).
DateTime | `MyDateTime.Date` | `DT2Date(MyDateTime)` | Gets the date part of `MyDateTime`
DateTime | `MyDateTime.Time` | `DT2Time(MyDateTime)` | Gets the time part of `MyDateTime`

There are no changes to the existing APIs.

### Type testing and casting operators for interfaces
In this version, we’ve introduced support for type testing and casting interfaces in the AL language. Two new operators; `is` and `as`, have been added to facilitate these operations.

#### The `is` operator
The `is` operator allows you to test whether an instance of an interface or the content of a variant supports a specific interface. Here’s the syntax for using the `is` keyword:


```
procedure TestInterface(intf: Interface IFoo)
begin
    if intf is IBar then
        Message('I also support IBar');
end;
```

You can also use the `is` operator with variants:

```
procedure TestVariant(v: Variant)
begin
    if v is IBar then
        Message('I support IBar');
end;
```

#### The `as` operator
The `as` operator is used for casting an instance of an interface to a specific interface. If the source interface does not implement the target interface, it will throw an error at runtime. Here’s an example:

```
procedure CastInterface(intf: Interface IFoo): Interface IBar
begin
    exit(intf as IBar); // Throws an error if 'intf' doesn't implement 'IBar'
end;
```

Similarly, the `as` keyword works with variants:

```
procedure CastInterface(v: Variant): Interface IBar
begin
    exit(v as IBar); // Throws an error if 'v' doesn't implement 'IBar'
end;
```


### Support for extending interfaces
It is now possible to extend one or more existing interfaces when you declare an interface.
When implementing an interface that extends other interfaces the implementor must also implement all methods from all extended interfaces.

The syntax is
```
interface IFoo
{
    procedure Foo();
}

interface IBar
{
    procedure Bar();
}

interface IFooBar extends IFoo, IBar
{
    procedure FooBar();
}

codeunit 10 TheImplementor implements IFooBar
{
    // Must implement IFoo, IBar, IFooBar
}
```

In the example above the `TheImplementor` can be used as both `IFoo`, `IBar`, and `IFooBar`.
The feature also works with the testing and casting operators.

### `This` keyword
We have added support for the `this` keyword for self-reference on all objects. The main benefits are

* Allow codeunits to pass a reference to `this` as an argument to another method.
* Improve readability by signaling that a referenced symbol is a member on the object itself.

We have added a CodeCop rule [AA0248](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/codecop-aa0248) that is enabled by default with severity 'hidden'. 'Hidden' means that it shows up as three dots in the editor, but not as a diagnostics in the Problem view or in pipelines.
There is also a CodeFixer to add the `this` keyword.

### New command - Package full dependency tree for active project

We have added a new command that packages the active project and its entire dependency tree. Its purpose is to assist local development by allowing a developer to forcefully rebuild all the packages required for a single project.

### Introduced new type PageStyle

The type can be used to get the valid values for StyleExpr, found on page controls. Here is an example of how to use it:
```AL
layout
{
    area(Content)
    {
        field(Name; rec.Name)
        {
            StyleExpr = nameStyle;
        }
    }
}

var nameStyle : Text;

local procedure ChangeNameStyle(newPageStyle : PageStyle)
begin
    nameStyle := format(newPageStyle);
end;
```

### Support for profile extension objects
It is now possible to define profile extension objects. They can be used to modify the target profile's caption, role center, or even include/remove it from the role explorer. Finally, it is also possible to add page customizations to a specified profile. For more information, see [Profile Extension Object](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/devenv-profile-extension-object).

```
profileextension MyProfileExt extends "O365 SALES"
{
    Caption = 'Profile Extension Caption';
    ProfileDescription = 'Profile Extension Description';
    Enabled = true;
    Promoted = true;
    RoleCenter = 9027;
    Customizations = SalesOrderCustomization, SalesQuoteCustomization;
}
```

### Deprecate legacy report layout functions
The legacy report layout methods `DefaultLayout`, `RdlcLayout`, `WordLayout`, and `ExcelLayout` have been deprecated. Replace usage of these methods with layout selection and 'Report Layout List' lookup. See [Upgrading reports](https://go.microsoft.com/fwlink/?linkid=2284102&clcid=0x409) for more information.

### Defining a positive list of elements in page customizations

Profiles and page customizations can be used to tailor the interface for users of a specific role. Since page customizations can hide elements such as controls, actions, or views, they are suited for defining a negative list of elements. However, any visible element that is not referenced by the page customization would be shown on the page, including elements defined in other extensions.

It is now also possible to create a positive list of elements to be shown on the page using the properties [ClearActions](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/properties/devenv-clearactions-property), [ClearLayout](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/properties/devenv-clearlayout-property), and [ClearViews](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/properties/devenv-clearviews-property).

For instance, the following code reduces the `Customer Card` to only the customer's `Name` and the promoted `Email` action.

```AL
pagecustomization MyCustomerCardCust customizes "Customer Card"
{
    ClearActions = true; // Hide all actions on the page
    ClearLayout = true; // Hide all layout elements on the page

    layout
    {
        modify(Name) { Visible = true; } // Show the Name
    }

    actions
    {
        modify(Email_Promoted) { Visible = true; } // Show the Email action
    }
}
```

Note that you can also control the availability of the `Create`, `Edit`, and `Delete` system actions using the properties  [InsertAllowed](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/properties/devenv-insertallowed-property), [ModifyAllowed](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/properties/devenv-modifyallowed-property), and [DeleteAllowed](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/properties/devenv-deleteallowed-property).

### GitHub Issues
- [#7751](https://github.com/microsoft/AL/issues/7751) [Copilot] AW0005 should not be shown for PromptGuide actions
- [#7644](https://github.com/microsoft/AL/issues/7644) Package cache doesn't support subfolders with .app files.
- [#7670](https://github.com/microsoft/AL/issues/7670) TableExtension BlankZero
- [#6997](https://github.com/microsoft/AL/issues/7672) Intellisense doesn't work with foreach statement
- [#7672](https://github.com/microsoft/AL/issues/7672) Word Layout compilation bug
- [#7697](https://github.com/microsoft/AL/issues/7697) Command "AL: Publish with Debugging" does not open browser when incognito Edge is explicitly specified in settings.json
- [#7695](https://github.com/microsoft/AL/issues/7695) Issue with Loading Projects after Downloading Symbols in Erroneous Network
- [#7689](https://github.com/microsoft/AL/issues/7689) Incorrect Symbol Info shown in VS Code for Enum Values
- [#7492](https://github.com/microsoft/AL/issues/7492) BC22 error AL0196: The call is ambiguous between the method Dictionary
- [#7704](https://github.com/microsoft/AL/issues/7704) al/createPackage fails due to invalid custom xml part
- [#7691](https://github.com/microsoft/AL/issues/7691) Cannot suppress diagnostic AL1080 via ruleset.json file
- [#5866](https://github.com/microsoft/AL/issues/5866) Duplicated entries in xlf file
- [#7723](https://github.com/microsoft/AL/issues/7723) ALDoc Exception if app name contains illegal folder chars
- [#7731](https://github.com/microsoft/AL/issues/7731) AA0181 rule warning for Codeunit.Find method
- [#7764](https://github.com/microsoft/AL/issues/7764) Intellisense in Query- Objects
- [#7722](https://github.com/microsoft/AL/issues/7722) Error: Specified argument was out of the range of valid values. (Parameter 'index')
- [#7659](https://github.com/microsoft/AL/issues/7659) Namespaces causing issues while generating permission sets in vscode
- [#7712](https://github.com/microsoft/AL/issues/7712) Unexpected warning AL0697 when an object is added to an entitlement through a permissionsetextension
- [#7715](https://github.com/microsoft/AL/issues/7715) Symbol Error AL0443 - "Allow Data Analysis Mode."
- [#7800](https://github.com/microsoft/AL/issues/7800) Publish fails with usage of `as` keyword
- [#7793](https://github.com/microsoft/AL/issues/7793) Diagnostic AL0780 not working as expected
- [#7798](https://github.com/microsoft/AL/issues/7798) Spelling mistake: "ErrorBehavior::Collect" tooltip
- [#7788](https://github.com/microsoft/AL/issues/7788) Error AS0036 raised when modifing a tooltip at table level

### AppSourceCop
- Updated rule [AS0031](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0031) to also allow removing groups from promoted area on pages that no longer supports promoted areas. See [AL0788](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/diagnostics/diagnostic-al788).
- Updated rule [AS0031](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0031) to allow removing non-obsolete page actions whose name conflicts with a new action from the base page.
- Updated rule [AS0032](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0032) to allow removing non-obsolete page controls whose name conflicts with a new control from the base page.
- Updated rule [AS0033](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0033) to allow removing non-obsolete page views whose name conflicts with a new view from the base page.
- Updated rule [AS0072](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0072) to support adding parameters to an obsoleted event without triggering a diagnostic.
- Updated the rules [AS0072](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0072), [AS0073](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0073), [AS0074](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0074), [AS0075](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0075), [AS0076](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0076) to support the scenario of modularizing an object by using extensions in the same app.
- Updated rule [AS0036](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0036) to allow modifying tooltip property on table fields.
- Updated rule [AS0029](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0029) to allow removing pages and page extensions whose source table comes from a dependency and the table has been marked with ObsoleteState Removed.
- Updated rules [AS0035](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0035) and [AS0040](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0040) to allow changing the SourceTable property if the new version of the source table used of the baseline page comes from a dependency and the table has been marked with ObsoleteState Removed.

### Miscellaneous
- Add 'Tenant Entra Id' to Excel layout template in the Report Request table. Map report metadata and request properties to defined names for easy use.
- Added a new commandline argument to alc.exe called `errorsonlyinconsole`. If this argument is used, then only error diagnostics from the compilation are sent to the console output. This is useful for projects that have a large number of Warning and Info level diagnostics that fill the console output.
- Fixed an issue where `CurrReport.Preview` usage outside of a procedure would cause the extension to crash.
- Fixed an issue where setting `compilationOptions.outFolder` to a relative path would result in the package file not being found when publishing.
- Added warning [AL0845](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/diagnostics/diagnostic-al845) when having matching `APIVersion`, `APIPublisher`, `APIGroup`, and `EntityNames` or `EntitySetName` property values across API Pages. From runtime version 16.0, this will turn into the error [AL0846](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/diagnostics/diagnostic-al846).
- Added IntelliSense for foreach statements.
- Added an indicator for obsoleted fields in the hover tooltip for records.
- Fixed an issue where IntelliSense would suggest namespaces from other publishers when declaring namespaces.
- Fixed an issue where the code action for converting explicit 'with' statements would carry over comments to the fully qualified statements.
- Allow downloading symbols using an Attach type launch configuration.
- Allow having a list of interfaces
- Fixed an issue where the compiler could not select the most specific overload based on interfaces being used as parameters. Now the most specific interface is selected.
- Updated DocumentFormat.OpenXml dependency to version 3.0.2.
- Option variables no longer get the captions when assigned from a table field.
- Fixed an issue where the code action for converting explicit 'with' statements would remove comments from the beginning of the statement when it is a block statement.
- Updated [AA0194](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/codecop-aa0194) and [AA0218](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/codecop-aa0218) to validate actions of `FileUploadAction` type.
- Added an GetCallerCallstackModuleInfos API for getting app information for extensions that contain the currently running method in the callstack.
- Added code actions to fix all [AL0604](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/diagnostics/diagnostic-al604) warnings in the document, project, or workspace scope.
- Added error [AL0852](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/diagnostics/diagnostic-al852) when subparts in API pages contain circular references.
- Added support for modifying the properties [InsertAllowed](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/properties/devenv-insertallowed-property), [ModifyAllowed](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/properties/devenv-modifyallowed-property), and [DeleteAllowed](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/properties/devenv-deleteallowed-property) from page extensions and page customizations.
- Added a new property "OptimizeForTextSearch" on table fields of textual type, which specify if the field is included in a text optimized search index for faster word based filtering. A property "IsOptimizedForTextSearch" has also been added on FieldRef to check if a field is included in text optimized index.
- Added support to use Copilot prompt actions on `Document`, `Card`, and `ListPlus` pages.
- Fixed issue where InStream/OutStream used in Dictionaries would cause a runtime failure by blocking them at compilation time with diagnostic [AL408](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/diagnostics/diagnostic-al408?wt.mc_id=d365bc_inproduct_alextension)
- Fixed an issue where CodeCop rule [AA0175](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/codecop-aa0175) would report false positive warnings in `repeat`, `while`, and `for` loops.
- Fixed issue with having a list of interfaces as a global variable.
- Fixed issue with having a named return value of type List
- Added support for moving all tooltips from page controls within a document or project to their related table fields using a code action.
- Added ToolTip property to query columns.
- Added AI token count on session information.
- Fixed issue with name clash with runtime functionality
- Fixed an issue where permission set extensions in the same application would not be accounted for when validating if an object is added to entitlements
- The command for generating permission sets is now compatible with namespaces.
- Fixed an issue where code actions would insert additional unnecessary new lines.
- Fixed an issue where wrong code would be generated when invoking a method on an interface produced by casting with the `as` operator.
- Statements in a block can now start with a parenthesized expression to support invoking methods on casted interface, for example: `(foo as IFoo).Method();`.
- Fixed an issue where the code action for converting explicit 'with' statements would remove comments from the body of the 'with' block if it does not contain statements.
- Added support for the ClientService option value in the BreakOnNext property within launch.config, aiding in debugging tests with BCContainerHelper’s Run-TestsInBcContainer; requires a compatible 2024 release wave 2 or newer platform.
- Added support for the [Scope](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/properties/devenv-scope-property) property on [Enums](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/devenv-extensible-enums) and [Interfaces](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/devenv-interfaces-in-al)
- Added AL method to HttpClient for PATCH Http requests.
- Added support for specifying a table in SelectLatestVersion to only disregard caching for a single table.
- Fixed an issue where nested parts with duplicate entity names would cause an error.
- Fixed an issue where members of object extensions would not be recommended when they were originating from other projects in the workspace.
- Fixed an issue where packages created via the pre-release would not be backwards compatible with previous compilers.

# Business Central 2024 release wave 1
## Version 13.1

### GitHub Issues
- [#7714](https://github.com/microsoft/AL/issues/7714) Unexpected warning AS0098 when adding an enumextension to an enum within the same AppSource app
- [#7745](https://github.com/microsoft/AL/issues/7745) Debugger crashes at random points

### AppSourceCop
- Updated rule [AS0032](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0032) to allow removing non-obsolete page fields using as source a table field marked with obsolete state Removed.
- Updated rule [AS0032](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0032) to allow removing non-obsolete page part controls using as source a page part which has been removed.
- Updated rule [AS0106](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0106) to allow removing non-obsolete protected variables, defined in extension objects, whose names are conflicting with the names of variables defined in the target object.
- Updated the rules [AS0011](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0011) and [AS0098](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0098) to allow for skipping affixes if an extension objects extends a base object from the same publisher.
- Updated the rules [AS0011](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0011) and [AS0098](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0098) to allow for skipping affixes if an object is defined in a namespace.
- Updated the rule [AS0013](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0013) to allow for using the ID range of a base table, when a table extension targets a base table from the same publisher.
- Added the rule [AS0127](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0127) to recommend that two-level namespaces should be used

## Relaxing AppSource affix and ID range validation for apps

Affixes no longer need to be added to extension members on apps from the same publisher. Furthermore, table extension fields will be able to use the ID range of the base table, if the base table is from the same publisher. The purpose of affixes and ID ranges is to ensure there are no conflicts between apps from different publishers. With this change, publishers have more flexibility in designing their apps, but will also have to ensure that there are no conflicts
within their own apps. You can see this in detail in our [documentation](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-checklist-submission-faq#questions-about-names-affixes-and-id-ranges).

### Miscellaneous
- Fixed an error that was thrown when handling the `textDocument/documentSymbol` request.
- The [AL1156](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/diagnostics/diagnostic-al1156) warning diagnostic was added when comments are used in the manifest file of an application. Its purpose is to help the interoperability of AL with various CI/CD integrations which may not support comments in json files, a scenario which leads to failures that are hard to detect and debug. The warning can be suppressed via a ruleset or the `suppressWarnings` property in the manifest file.
- Fixed an issue where the compiler would sometimes fail with internal errors during the validation of an interface implementation.
- When using "Attach debugger to this session" and "Explore page in Visual Studio Code" links form the web client, the configuration in VS Code will use the environment's runtime version instead of the latest available.
- RAD publishing could fail in scenarios a new file was added.
- Fixed an issue where compilation could fail with MissingTypeSymbol after changing a dependency's name or publisher

## Version 13.0

### Support for multiple extensions to same target and extensions and target in same app

We have expanded the support for extension objects to help achieve better separation of concerns in large apps. The following changes have been made:

* Extensions can now exist in the same app as their target.
* Multiple extensions to the same target can exist in the same app.

For table extensions in the same app as their target, the fields and keys will be moved to the base table to prevent SQL-joins at runtime.

Since extension objects from a given app are applied on the target following the extension object ID, the following compiler validation was introduced:

* The base object cannot reference members from extension objects.
* Extension objects can reference members from other extension objects in the same app only if the other extension object has a lower object ID.

### Changes to AL Table Proxy Generator tool (altpgen)
AL Table Proxy Generator tool (altpgen) now requires two additional arguments: `ClientId` and `RedirectUri`. Due to security measures, the default Microsoft Entra application is removed from the tool. Users are now required to register their own Microsoft Entra application as described at aka.ms/altpgen.

### Script/Css/Image paths on control add-ins can be relative to the control add-in source file.
Control add-in resources can also be stored relative to the file containing the control add-in source.

The search order for resources is now:

1. Relative to the project root
2. Relative to the control add-in source.

The following example shows the two options.

file: MyControlAddIn.al
```
controladdin MyControlAddIn
{
    Scripts = './js/myscript.js';
    StyleSheets = 'css/mystyle.css';
    ...
}
```
Resources are relative to project root:
```
.
[src]
    MyControlAddIn.al
[resources]
    [js]
        myscript.js
    [css]
        mystyle.css
app.json
```

Resources are relative to controladdin source:
```
.
[src]
    MyControlAddIn.al
    [resources]
        [js]
            MyScript.js
        [css]
            MyStyle.css
app.json
```

### New "Create AL Project" button
When no folders are opened, the Primary Side Bar for Explorer now has a button named "Create AL Project". Clicking this button invokes the `AL:Go` command to create a new project.

### Isolated Storage - New method overloads for use with the SecretText type
We have introduced new overloads for the built-in methods of `IsolatedStorage` type to allow its use with the `SecretText` type. When values are added as `SecretText`, the runtime will ensure they can only be retrieved in the same type. This makes it possible to ensure that they are protected from debugging throughout their entire lifetime. In addition, a new overload to the `Contains` method was added to allow checking if a value was added as a `SecretText`.

### AlDoc supports overwrite files
Generated documentation can be updated or augmented by including markdown files during build. E.g. a summary can be added during the AlDoc build process to the following enum
```
namespace MyNS;
enum 50100 MyEnum
{
}
```
by including a markdown file with the following content
```
---
uid: O:Enum::MyNS#MyEnum
summary: This is my new comment
---
```

### Support ended for debugging Business Central server versions less than 20
Business Central server versions released before the April 2022 release (version 20) cannot be debugged with AL extension package versions that are greater than or equal to version 13.

### Folding usings
It's now possible to use the "editor.foldingImportsByDefault" setting. When set to `true` it collapses all of the `using` statements when a file is opened.

### New AlterKey on database
Added new AL database api for disabling and re-enabling keys within the current transaction.

### Tooltips on table fields
Introduced the tooltip property on table fields, which like the caption will be applied on page controls that reference the table field.
This includes a code action that helps with moving the tooltip from page controls to table fields or cleans them up from the page in case of duplicates.

### FileUploads and Drag & Drop
Added new action type and a new file type for handling uploading files.
```AL
fileUploadAction(MyUploadAction)
{
    trigger OnAction(files: List of [FileUpload])
    begin
        // Insert code here.
    end;
}
```

### Placeholder text on Page Fields
Page fields can now leverage the `InstructionalText` and `InstructionalTextML` properties to define placeholders. These values will be showed when the field would otherwise be empty.

Using this new capability, you can provide example values to your users. This feature is currently supported only for text types like `Text`, `BigText`, `Code`, and `Guid`.

### Prompt Guides
**PromptDialog** pages now support defining a prompt guide, which contains a list of pre-defined text prompts. This allows users to easily select a prompt guide to use as input to generate content, rather than creating their own prompt from scratch. Prompt guides are written in AL as standard actions within the `PromptGuide` action area as follows.

```
page 50100 MyCopilotPage
{
    PageType = PromptDialog;
    PromptMode = Prompt; //Prompt guides are only rendered on prompt mode.
    Extensible = false;

    layout
    {
        area(Prompt)
        {
            field(NLField; Input)
            {
                // Hint users to use prompt guides
                InstructionalText = 'Select a prompt guide to get started';
            }
        }

        //..
    }

    actions
    {
        area(PromptGuide)
        {
            action(OrderFromDescription)
            {
                Caption = 'Order from description';

                trigger OnAction()
                begin
                    Input := 'The prompt is set in the NL field';
                    CurrPage.Update();
                end;
            }
            //..
        }
    }

    var
        Input: Text;
}
```

### Copilot prompt actions
Introduced the Copilot prompt actions to promote AI capabilities of a Business Central solution. These will be rendered in a floting action bar in your pages that nudges users to use relevant Copilot features. Copilot actions are written in AL as standard actions within the `Prompting` action area as follows.

```
actions
{
    area(Prompting)
    {
        action(MyPromptAction)
        {
            RunObject = page "Copilot Marketing Text";
        }
    }
}
```

### New Cookie DataType
- Introduced a new Cookie datatype. This datatype represents an HTTP cookie.
- Added an AL interface to handle cookies in HttpResponseMessage and HttpRequestMessage data types.

### AppSourceCop
- Added rule [AS0124](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0124) for detecting breaking changes when changing the target of an extension object. The rule currently only validates page extensions and page customizations, because other extension objects do not support the ObsoleteState properties and cannot be deprecated.
- Updated rule [AS0105](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0105) to allow references to obsolete table, table fields, and table keys in upgrade codeunits.
- Updated diagnostic message and description of rule [AS0080](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0080) to not mention primary key fields validation anymore, because the primary key fields validation is performed by rule [AS0118](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0118).
- Added rule [AS0125](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0125) for detecting translation ID breaking changes. The rule is enabled by default with its severity set to 'Info'.
- Added rule [AS0126](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0126) for detecting when the publisher name specified in 'internalsVisibleTo' is not the one of the current extension.
- Refactoring of breaking change validation rules to support multiple extension objects for the same target and extension objects and target in same app.
- Updated rule [AS0098](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0098) to also check for keys on table extension fields.

### GitHub Issues
- [#7512](https://github.com/microsoft/AL/issues/7512) Report unknown triggers defined in 'modify' changes in page extensions.
- [#7423](https://github.com/microsoft/AL/issues/7423) [AL Explorer] Add object name in event subscribers.
- [#7464](https://github.com/microsoft/AL/issues/7464) Action "Generate Permission Set" Breaks Comment Formatting.
- [#7516](https://github.com/microsoft/AL/issues/7516) Region folding / stickyscroll not working
- [#7542](https://github.com/microsoft/AL/issues/7542) Find Event does Not Open
- [#7525](https://github.com/microsoft/AL/issues/7525) Unexpected value 'BadExpression' of type 'Microsoft.Dynamics.Nav.CodeAnalysis.BoundKind'
- [#7535](https://github.com/microsoft/AL/issues/7535) Quick fix for parenthesis (AL0008) is not working correctly
- [#5124](https://github.com/microsoft/AL/issues/5124) Snippet for page part doesn't include applicationarea property
- [#7576](https://github.com/microsoft/AL/issues/7576) Code 'BO' is not a valid ISO 3166-1 alpha-2 code
- [#7553](https://github.com/microsoft/AL/issues/7553) Go To Defention + ReName not working for TableRelation with primary key specified
- [#7571](https://github.com/microsoft/AL/issues/7571) Page Fields (Controls) added via ReportExtension are missing on RequestPageHandler
- [#7571](https://github.com/microsoft/AL/issues/7536) al.compilerOptions.outFolder does not work as expected for "Publish full dependency tree..." command
- [#7558](https://github.com/microsoft/AL/issues/7558) A `[TryFunction]` that implements an interface returns wrong values
- [#7598](https://github.com/microsoft/AL/issues/7598) Procedure declaration should not end with semicolon
- [#7547](https://github.com/microsoft/AL/issues/7547) New PTE Rule: Table Extension fields should be in app id ranges. This is covered by the newly introduced [PTE0022](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/pertenantextensioncop-pte0022) and [PTE0023](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/pertenantextensioncop-pte0023).
- [#7613](https://github.com/microsoft/AL/issues/7598) Implicit conversion is being performed from Enum to Option
- [#7650](https://github.com/microsoft/AL/issues/7650) Compiling App against Next Major shows AL0186 error
- [#7614](https://github.com/microsoft/AL/issues/7614) Compiler Bug: Inconsistent accessibility is not enforced
- [#7635](https://github.com/microsoft/AL/issues/7635) AL0749 misses internal/local IntegrationEvent triggers
- [#7593](https://github.com/microsoft/AL/issues/7593) System.ArgumentNullException: Value cannot be null. (Parameter 'key')
- [#7653](https://github.com/microsoft/AL/issues/7653)  Never-Ending 'Loading Workspace' Issue with 'jsonc' Format in 'app.json'
- [#7605](https://github.com/microsoft/AL/issues/7605) Regions no longer work since Update 11
- [#7664](https://github.com/microsoft/AL/issues/7664) Sending notification workspace/didChangeConfiguration failed.
- [#7681](https://github.com/microsoft/AL/issues/7681) AS0124 error for unchanged pageextension
- [#7688](https://github.com/microsoft/AL/issues/7688) Page Customization breaks translations for Page Extension
- [#7661](https://github.com/microsoft/AL/issues/7661) The ID for the Field is not valid. It should be withing the range which is allocated to the application.

### Miscellaneous
- Added warning [AL0804](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/diagnostics/diagnostic-al804) when referencing actions defined in page customizations in event subscriptions. From runtime version 14.0, this will turn into the error [AL0575](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/diagnostics/diagnostic-al575).
- Event Subscriber snippet copied in the Explorer will now use the new identifier syntax when possible and correctly produce the string version as well.
- Removed diagnostic [AL0249](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/diagnostics/diagnostic-al249) reported on missing page parts in favor of [AL0185](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/diagnostics/diagnostic-al185) for missing application objects because the message for [AL0249](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/diagnostics/diagnostic-al249) was never formatted correctly.
- Fixed multiple cases where using nested function calls as the value of data item columns would cause runtime crashes.
- Go To Definition on Interfaces declared in a dependency is working again.
- Added error [AL0814](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/diagnostics/diagnostic-al813) when using a FlowFilter as the source of a column in queries. From runtime version 14.0, this will turn into the error [AL0815](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/diagnostics/diagnostic-al814).
- Fixed diagnostic [AA0228](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/codecop-aa0228) to handle methods with quotes in their name. Previously, methods with quotes in their name would always be reported as unused.
- Fixed collisions of Events in extension objects. Introduced new Warning error [AL0818](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/diagnostics/diagnostic-al818) that after runtime version 15.0 will be turned into [AL0819](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/diagnostics/diagnostic-al819).
- Add semanticHighlighting to page part names and targets of actionsrefs.
- Fixed diagnostic message for [AL0424](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/diagnostics/diagnostic-al424) to mention that multilanguage syntax should not be used when translation files are used by the extension.
- Added compiler validation of arguments provided to AddAction method on ErrorInfo and Notification. A warning will now be raised if the referenced codeunit could not be resolved and if the method is not available or doesn't have the required signature.
- Fixed a bug where the `Find Event` command would lead to a crash if there was an event on an extension object whose target could not be resolved.
- Added error [AL0408](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/diagnostics/diagnostic-al408) when using `Media` or `Mediaset` as collection type arguments.
- Added support for requesting a range of numbers from a NumberSequence.
- Added support for restarting a NumberSequence from a given seed.
- Added error [AL0827](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/diagnostics/diagnostic-al827) to report passed-in fields of `FlowFilter` and `FlowField` class to the `Record.CalcSums` method which is not allowed.
- Added a code action to fix warning [AL0729](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/diagnostics/diagnostic-al729) about promoted properties used on page types which do not support promoted actions.
- Added support for suppressing the diagnostics [AL0254](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/diagnostics/diagnostic-al254), [AL0659](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/diagnostics/diagnostic-al659), [AA0074](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/codecop-aa0074), [AA0100](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/codecop-aa0074), [AA0470](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/codecop-aa0470) and [AA0218](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/codecop-aa0218) per instance, per document, per project, or per workspace.
- Fixed collection types that were showing as not recognized when their type argument wasn't valid.
- Symbol operations like Go to Definition, Rename etc. now work correctly with table names in table relations and calculation formulas.
- A new diagnostic is added for when an interface is implemented via a try function, which will not be supported in the future.
- Fixed explicit with statement converter when dealing with TestPages
- Marked `Dialog.LogInternalError` as deprecated.
- Fixed issue where protected variables of a report could not be used in its report extensions' requestpage.
- Fixed inconsistencies between the local and server compilation when evaluating paths when using Images, Scripts, and StyleSheets properties on control add-ins.
- Added warning [AL0598](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/diagnostics/diagnostic-al598) when adding and modifying a table field within the same table extension.
- Fixed an issue where not all manifest diagnostics would show up in the Problems window of Visual Studio Code.
- Fixed issue where Queries with UsageCategory would not be included to the Search in SaaS.
- Added support for translating page list views using translation files.
- Added support for having lists of In- or OutStreams.
- Add [AL0837](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/diagnostics/diagnostic-al837) to detect translation ID conflicts involving TextConst variables.
- Modified the missing debug configuration error message to allow for the selection of a debug configuration (local or cloud) to be added to the launch.json file.
- Fixed an issue that caused fields from table extensions to fail to bind for `RunPageLink` and other similar properties.
- Updated [AA0217](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/codecop-aa0217) to only report diagnostics if literals contain alphabetic characters.
- Fixed an issue where the `with` statement converter would silently crash when encountering procedure invocations by assignment.
- Added configuration flag `al.semanticFolding.enabled`, in the settings.json file, for controlling if the extension should provide the folding ranges, or if the strategy from Visual Studio Code should be used.
- Support report extensions when generating Excel layout template and emit a default data row using column default values (type specific).
- Added AL interface to enable UseResponseCookies in HttpClient.
- Various fixes were made to ensure that RAD works more reliably in workspaces that use namespaces.
- Added code actions to fix all [AL0606](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/diagnostics/diagnostic-al606) warnings in the document, project, or workspace scope.
- New CodeCop rule [AA0234](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/codecop-aa0234) to make sure table fields have a ToolTip specified.
- Added warning [AL0835](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/diagnostics/diagnostic-al835) when updating the same layout file in different layouts.
- Disabled CodeCop rule [AA0072](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/codecop-aa0072) by default. In order to enable it, you must now include it in a ruleset, see [Ruleset for the code analysis tool](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/devenv-rule-set-syntax-for-code-analysis-tools).
- Added warning [AL0803](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/diagnostics/diagnostic-al803) when the names of two events or event subscribers conflict within the same object. Whitespaces in names are internally replaced with an underscore during compilation, such that two different names can collide. For example, "my event" and "my_event" are conflicting names. From runtime 15.0, an error will be reported with [AL0757](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/diagnostics/diagnostic-al757).
- The extension will no longer wait forever when there are comments in the manifest file.
- Fixed an issue which caused the workspace settings to not update dynamically.
- Added support for passing an integer parameter to a method that has one overload with an Option and another overload with an Enum parameter. This call used to be ambiguous, but the method with the Option parameter will now be selected.


# Business Central 2023 release wave 2

## Version 12.7
- [#7643](https://github.com/microsoft/AL/issues/7643) DotNet exceptions with CodeAnalysis - 'codeLens/resolve' failed with error
- [#6401](https://github.com/microsoft/AL/issues/6401) Multiple Report objects can refer to / update the same Layout, causing error/race/unpredictable updates

## Miscellaneous
- Fixed an issue where codeLens would crash due to trying to resolve a field on report extensions.

## Version 12.6
## GitHub Issues
- [#7583](https://github.com/microsoft/AL/issues/7583) Pinning the AL Explorer or AL Home in VS Code does not work permanently
- [#7543](https://github.com/microsoft/AL/issues/7543) Unable to attach session to vs code
- [#7545](https://github.com/microsoft/AL/issues/7545) Intellisense doesn't work when using global object enum for enum

### Miscellaneous
- Fixed issue where a malformed permission value could lead to a crash.
- Fixed an issue where `AL:Go!` would generate a namespace name based on the project name and config even if they result in an invalid namespace name.
- Align Excel report layout template with current runtime and emit caption, translation and metadata sheets for use in layouts.

## Version 12.5

### GitHub Issues
- [#7513](https://github.com/microsoft/AL/issues/7513) AL0679 Does not take InherentEntitlements into account
- [#7586](https://github.com/microsoft/AL/issues/7513) False positive from AS0034: Not allowed to change `InherentPermissions` property of `table` object

### Miscellaneous
- Fixed a bug in snapshot debugging for the scenario when multiple application objects were defined in the same file containing namespace definitions.
- The `AL0679` warning will not be reported if the object has inherent entitlements.
- Features specified to ALC are stored in the built app.

## Version 12.4

### GitHub Issues
- [#7586](https://github.com/microsoft/AL/issues/7513) False positive from AS0034: Not allowed to change `InherentPermissions` property of `table` object

- ### Miscellaneous
- Fixed a bug in snapshot debugging for the scenario when multiple application objects were defined in the same file containing namespace definitions.
- Features specified to ALC are stored in the built app.

## Version 12.3

### GitHub Issues
- [#7513](https://github.com/microsoft/AL/issues/7513) AL0679 Does not take InherentEntitlements into account

### Miscellaneous
- Fixed "Go To Reference" for key fields on table extensions, when the fields are only defined on the base table.
- Disabled **Source** button on AL Explorer for those objects where it is not possible to navigate to its source definition.
- "Explore field in VS Code" navigates to fields defined in table extensions.
- The `AL0679` warning will not be emitted if the object has inherent entitlements.
- Updated the default `AL:Go!` al file to define a namespace, based on the project name, if the runtime version is greater than 12.0.

## Version 12.2

### PromptDialog page
Introducing the new page type **PromptDialog**, which allows developers to seamlessly integrate Copilot capabilities into their custom scenarios. Use this page to create generative AI experiences that look and feel unmistakably Copilot, including signature visuals, and built-in safety controls for customers. You can build these pages directly in AL using a special page syntax, which includes new area and action controls, as described in the code sample below. To get started, simply type `tpage` and pick the **Page of type Prompt Dialog** snippet.

```
page 50100 MyCopilotPage
{
    PageType = PromptDialog;
    PromptMode = Prompt; // Specify the starting prompt mode. Default value is Prompt.
    IsPreview = true;
    SourceTable = TempInputData;

    // Mandatory properties
    SourceTableTemporary = true;
    Extensible = false;

    layout
    {
        area(Prompt) { /*The input to Copilot. Accepts any control.*/ }

        area(Content) { /*The output of Copilot. Accepts any contol.*/ }

        area(PromptOptions) { /*The input options. Only accepts option fields.*/ }
    }

    actions
    {
        area(SystemActions)
        {
            // Pre-defined system actions (Generate, Regenerate, Attach, Ok, Cancel). Can only use system actions on this page.
            systemaction(Generate)
            {
                trigger OnAction()
                begin
                    // The code triggering the Copilot interaction.
                end;
            }

            systemaction(Ok)
            {
                Caption = 'Accept the suggestion'; // The Caption and Tooltip of system actions can be modified.
            }
        }
    }

    trigger OnInit()
    begin
        // The prompt mode can be changed at runtime.
        // CurrPage.PromptMode := PromptMode::Generate;
    end;
}
```

### Sparkle Image
Added a new option to the `Image` property, **Sparkle**, which you can use to highlight the presence of your AI-powered features. For example, place it on actions that open a prompt dialog page.

### AppSourceCop
- Added rule [AS0008](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0009) for reserved namespaces check.

### PerTenantExtensionCop
- Added rule [PTE021](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/analyzers/pertenantextensioncop-pte0021) for reserved namespace check.

### UICop
- [AW0016](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/uicop-aw0016) - The page type **PromptDialog** accepts a rich text editor control as an immediate child of the `Content` area. For other page types the rich text editor control still needs to be inside a top level group.

### Github issues
- [#7467](https://github.com/microsoft/AL/issues/7467) Missing compiler error on declaring TableNo in an upgrade codeunit. - New error introduced.

### Miscellaneous
- Fixed an issue on resolving the correct line on GoToDefinition (F12) when debugging DAL files.
If you are running on CU1 on premise and are experiencing issues in line resolution while debugging a dependency app, make sure you run the Repair-NavApp command on the dependency app.
- The properties `ContextSensitiveHelpPage` and `HelpLink` are available for query objects.
- Fixed "go to definition" for field group changes in table extensions.
- Added various snippets related to fieldgroups.
- Fixed hovering over field group fields in table extensions.
- Fixed IntelliSense on fieldgroup names to suggest the available fieldgroups.

## Version 12.1

### GitHub Issues
- [#7461](https://github.com/microsoft/AL/issues/7461) Creating an additional key to an existing table with "Clustered = true" is not rejected by the compiler.

### AppSourceCop
- Added rule [AS0007](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0007) for namespace breaking changes.
- Added rule [AS0123](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0123) for detecting the addition of a clustered key as a breaking change.

### Bugs fixed
- Use correct configuration for downloading symbols on production environments when triggered from the web client.
- The severity of `AL0792` can be adjusted through a ruleset now.
- Remove data sheet prefix from Excel data sheets when using the `ExcelLayoutMultipleDataSheets` property.
- aldoc unpacks templates correctly on linux.

### Miscellaneous
- The `AnalysisModeEnabled` property is now supported on pages of type `Worksheet`.
- Change Snippets for Reports and layouts to suggest Excel.
- Added tenant parameter to generated configurations from "Explore in VS Code" and "Attach debugger to current session" links in the web client.
- Fixed default location app files are written to using Alc, to the project.

## Version 12.0

### Introducing Namespaces: A New Way to Organize Your AL Code
We are excited to announce that AL for Business Central now supports namespaces. Namespaces are similar to other code languages, and they allow you to group your objects and code in a logical and hierarchical way. With namespaces, you can avoid naming conflicts between different extensions, and make your code easier to maintain and understand. You can also see the relationship between different objects at a glance, and use the dot notation to access them. For example, you can use `MyNamespace.MyTable` to refer to a table object in your namespace. Namespaces are optional, but we highly recommend using them to improve your coding experience and productivity. To learn more about how to use namespaces in AL, please check out our documentation here [Namespaces in AL](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/devenv-namespaces-overview?wt.mc_id=d365bc_inproduct_alextension)

### Open Visual Studio Code from web client
This feature simplifies the process of setting up Visual Studio Code environments for investigation and troubleshooting by allowing one-click access from the web client, available in both from the **Page Inspection** and **Help & Support** pages. You can choose to create a new project or update an existing one, which is configured to match your running instance, including launch configurations and dependencies in the app.json file. Users can download required symbols, easily navigate to source definitions, and seamlessly attach to the current session for regular and snapshot debugging, eliminating manual setup efforts. For more information, see [Troubleshoot in Visual Studio Code directly from the web client](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/devenv-troubleshoot-vscode-webclient?wt.mc_id=d365bc_inproduct_alextension).

### Introducing ALDoc: a new command line tool for generating reference documentation for AL extensions
ALDoc works with DocFx to create a static website that contains detailed information about the objects, methods, properties, and events in one or more .app files. You can use ALDoc to document your own extensions or explore the APIs of other extensions. To learn more about how to use ALDoc, visit [Generating help with the ALDoc tool](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/help/help-aldoc-generate-help?wt.mc_id=d365bc_inproduct_alextension)

### Workspace support for Code Fixes
Addition of workspace support for Code Fixes, which allows to invoke Code Fix actions on a workspace.

### New SecretText type

The new type `SecretText` is introduced to protect credentials and other sensitive textual values from being revealed through debugging. New method overloads are added to
`HttpClient` and other related types to make use of the new type.
```al
// The return value and parameter will not be debuggable
procedure Send(ContentTxt: SecretText; Credential: SecretText; TargetUri: SecretText)
    var
        Request: HttpRequestMessage;
        Response: HttpResponseMessage;
        Client: HttpClient;
        Headers: HttpHeaders;
        Content: HttpContent;
    begin
        Request.SetSecretRequestUri(TargetUri);
        Content.WriteFrom(ContentTxt);
        Request.GetHeaders(Headers);
        Headers.Add('Authorization', SecretText.SecretStrSubstNo('Bearer %1', Credential));
        Request.Content := Content;
        Client.Send(Request, Response);
    end;
```

### Added report property ExcelLayoutMultipleDataSheets

Added a new Boolean report property [ExcelLayoutMultipleDataSheets](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/properties/devenv-ExcelLayoutMultipleDataSheets-property?wt.mc_id=d365bc_inproduct_alextension) that controls how Excel data sheets are created when using an Excel layout.
Use this property to emit root data items to separate Excel sheets or to a single sheet named Data.
Multiple sheets will be named #DataItemName, where DataItemName is the dataitem name used in the report design. Adding new empty Excel layouts to the report will use the property value to determine the sheet structure.

The default is to use a single sheet for all data.

### New FieldRef.IsEnum method
Addition of the new `FieldRef.IsEnum` method, which allows to check if a field is an enum.

### Enhancing External Business Events with Versioning Capability
A version parameter has been introduced as an optional parameter to the external business event attribute. Version of an external business event serves to handle modifications to the event signature that could impact its consumers. If the version is not specified for an event, it is assumed to be version 0.0.

### Ability to define fields in page customizations
We have added the ability to add groups and page fields using a table field as source expression in page customizations.
```al
pagecustomization MyPageCust customizes MyPage
{
    layout
    {
        addfirst(Content)
        {
            field(MyPageCustField; Rec.MyTableField) { }
        }
    }
}
```

A new property [AllowInCustomizations](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/properties/devenv-allowincustomizations-property) was introduced for table fields in order to specify whether they can be used as source expression for page fields created in page customizations. By default, table fields can be used as source expression for page fields created in page customizations.

### Introducing SamplingInterval feature to Sampling type of Profiling
With the new parameter `profileSamplingInterval` in your `launch.json` snapshot configuration, you can specify the interval at which the sampling will be collected. The default value is 100ms.

### Creating Rich Text Editor Controls
The `ExtendedDataType` has been extended to allow the new value, `RichContent`, which will tell the web client to render a Rich Text Editor. For now, the setting `ExtendedDataType = RichContent` is only allowed on page fields. The Rich Text Editor will only render if it is the only control in a root-level group in a page area (also known as a FastTab group); when creating the control you must also specify that `MultiLine = true`. and it's backing data type must be either `Text` or `BigText`. You can refer to the [sample code available for rich text editor](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/devenv-richtext-content-controls?wt.mc_id=d365bc_inproduct_alextension) for guidance on how best to utilize this control.

### Add SetBaseLoadFields record API
Adds the ability to select all fields defined on the base table for initial loading on a record, only delay loading fields defined in table extensions.

### Method Overloads - Smarter method signature recommendations

The language extension will now prioritize relevant overloads when the developer starts typing a method invocation. If the typed expression corresponds to a valid overload, it will always be the first recommendation and the correct active parameter will be highlighted. The rest of the recommendations will be sorted in the order of relevance based on the provided parameters.

### AnalysisModeEnabled property
We have introduced the [AnalysisModeEnabled](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/properties/devenv-analysismodeenabled-property?wt.mc_id=d365bc_inproduct_alextension) property on list pages, which allows to enable or disable data analysis mode on the page. For more information, see [Analyze list data using data analysis mode](https://learn.microsoft.com/dynamics365/business-central/analysis-mode?wt.mc_id=d365bc_inproduct_alextension).

### New supported types for Variant - List, Dictionary
It is now possible to assign `List` and `Dictionary` to a `Variant`. The `Variant` type has been augmented with two new properties `IsList` and `IsDictionary` to
allow for detecting if it contains the relevant types.

### Inlay Hints
Sometimes it is not obvious from the look of a method call, which parameters the arguments map to, so with the use of inlay hints, the name of the parameters can be written next to the arguments.
That is one of the scenarios supported, have a look at these settings:
```JSON
"al.inlayhints.functionReturnTypes.enabled": true,
"al.inlayhints.parameterNames.enabled": true
```
### IntelliSense in the debug console
The debug console is used to evaluate variables in the AL debugger. With this release we have added AL-based IntelliSense support to the debug console.
Unfortunately this is only true for the console window as the watch window does not yet have IntelliSense integration support.
Also completion does not work based on keyboard input, but only on the mouse click.

### Extend the default fieldgroups even when they are not defined on the base table
It is now possible to extend the 'Brick' and 'Dropdown' fieldgroups even when they are not defined on the base table. This is achieved by
creating a table extension for the table and adding fields to the fieldgroups with the `addlast` keyword. If a fieldgroup already exists,
the fields will be appended to the end of its field list. If it doesn't exist, it will be created automatically with these fields only.
If multiple extensions are defined on the same fieldgroup, the fields will be unique and their order will depend on the order of resolution
of the applications.

### Properties for exploring queries in the web client
We have enabled the properties UsageCategory, AboutTitle(ML), and AboutText(ML) for query objects as part of the support to explore queries from the web client.

### GitHub Issues
- [#7306](https://github.com/microsoft/AL/issues/7306) AS0056 warning reported for supported country code with unexpected casing.
- [#6931](https://github.com/microsoft/AL/issues/6931) A TryFunction can explicitly return a value - but that value is discarded.
- [#7353](https://github.com/microsoft/AL/issues/7353) Special Char (&) in Object name makes DocComments.xml invalid
- [#7296](https://github.com/microsoft/AL/issues/7296) Fix icon alignment when using fileNesting
- [#7107](https://github.com/microsoft/AL/issues/7107) ControlAddIn/usercontrol in page loses its actual type when referenced in a pageextension, breaking passing to procs
- [#7381](https://github.com/microsoft/AL/issues/7381) Unalbe to go to definition on PermissionSet
- [#7389](https://github.com/microsoft/AL/issues/7389) AS0062 error on Reports with ApplicationArea assigned at the object level
- [#5173](https://github.com/microsoft/AL/issues/5173) Cannot convert Variant to List
- [#7437](https://github.com/microsoft/AL/issues/7437) Processing of message 'al/createPackage' failed with error: 'One or more errors occurred.
- [#7361](https://github.com/microsoft/AL/issues/7361) Folding of regions does no longer work
- [#7444](https://github.com/microsoft/AL/issues/7444) Analyzer exception when validating obsolete tags on field groups in table extensions
- [#7453](https://github.com/microsoft/AL/issues/7453) AL Developer Fails To Remember Cached Credentials - Every request needs a new devicelogin
- [#333](https://github.com/microsoft/AL/issues/333) Make reference count also work on trigger that have AL methods related
- [#2742](https://github.com/microsoft/AL/issues/2742) Support for event subscribers in codeLens/references for field/table triggers
- [#5453](https://github.com/microsoft/AL/issues/5453) Find OnInsert/OnModify/OnValidate... usages in Visual Studio Code
- [#6918](https://github.com/microsoft/AL/issues/6918) RunPageView and SubPageView `where` suggests fields from wrong (parent) table
- [#7293](https://github.com/microsoft/AL/issues/7293) Confused compiler looks in wrong path for dependencies in multi-root workspaces
- [#7200](https://github.com/microsoft/AL/issues/7200) _ALException is <Out of Scope> in Section "Watch"
- [#7398](https://github.com/microsoft/AL/issues/7398) VS Code looses focus when Publishing

### AppSourceCop
- Added a new AppSourceCop.json setting `ObsoleteTagMinAllowedMajorMinorOnSourceSymbols` to enable [AS0105](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0105) to also report diagnostics on references to obsolete pending source symbols. For backward compatibility, the default value is `false` and the rule is only reporting diagnostics on references to obsolete pending reference symbols.
- Fixed validation of local and internal events with [AS0073](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0073).
- Fixed validation of ObsoleteReason for keys, views, field groups, page customizations, report extensions, permission sets, permission set extensions, and entitlements with [AS0072](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0072), [AS0073](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0073), [AS0074](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0074), [AS0075](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0075), and [AS0076](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0076).
- From runtime 7.2, [AS0092](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0092) will enforce the usage of `applicationInsightsConnectionString` over `applicationInsightsKey`. This means that extensions using `applicationInsightsKey` will now get a warning and should use `applicationInsightsConnectionString` instead.
- Added rule [AS0118](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0118) for handling primary key fields length changes.
- Added rules [AS0035](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0035) and [AS0040](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0040) to validate property breaking changes done on pages. More properties will be covered by these rules over time. Their default severity is set to Warning, but it will be changed to Error in the future.
- Updated rules [AS0082](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0082) and [AS0083](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0083) validating breaking changes on enum extension values to allow fixing conflicts with enum values introduced in the base enum.

### Miscellaneous
- Fixed IntelliSense recommending non-extensible objects when writing an extension.
- A new warning, [AL0775](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/diagnostics/diagnostic-al775) , is shown when using an explicit return value for Try methods, since the value is ignored.
- [AL0758](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/diagnostics/diagnostic-al758) warning diagnostic has been introduced for when the names of two object members conflict. Whitespaces in names are internally replaced with an underscore during compilation, such that two different names can collide. For example, "my variable" and "my_variable" are conflicting names. From runtime 13.0, an error will be reported with [AL0757](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/diagnostics/diagnostic-al757).
- Fixed an issue where the developer would need to reload the entire project when renaming a directory which contains AL files.
- Shorten the text of code actions to lower the risk of them getting truncated.
- Global launch configurations now appear in the configuration picker when creating a new AL:Go! project.
- Fixed issue that the numeric property on table fields were not used.
- Added a warning about invoking `ModifyAll` on fields with `FieldClass = FlowField`. This warning will become and error at a later date.
- Dotnet control add-in access from page extensions is being deprecated as it is not supported by the runtime.
- Fixed issue of an unexpected exception thrown when running AL Table Proxy Generator tool (altpgen).
- CaseOf constructs with hundreds or even thousands of cases should no longer cause a crash.
- Prevent the use of [TestPage.Prev](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/methods-auto/testpage/testpage-prev-method) and [TestPart.Prev](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/methods-auto/testpart/testpart-prev-method) in favor of [TestPage.Previous](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/methods-auto/testpage/testpage-previous-method) and [TestPart.Previous](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/methods-auto/testpart/testpart-previous-method) from runtime version 13.0.
- Fix the order of which dataitems are executed when you have more than one dataitem added at the same anchor within Report Extensions.
- Fix issue that Translating other apps OptionCaption, didn't work if the field was based on an enum.
- Fix the issue of invoking a code actions on a workspace where the code action was applied only to one project.
- Added support for setting the [Editable](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/properties/devenv-editable-property) property of page fields to false from page customizations.
- [AA0219](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/codecop-aa0219) diagnostic no longer reports that page actions must start with 'Specifies', since actions generally don't specify something.
- GoTo Implementation now provides results for procedures from dependent apps.
- When viewing enums in source code from other apps, the implemented interfaces for the enums are shown as well.
- Outline window and Sticky Scroll now works with added or moved controls, actions, etc.
- Added configuration 'al.algoSuggestedFolder' to specify the suggested folder when using AL:Go!
- Added configuration `"al.compilationOptions": { "outFolder": "C:\\Temp" }` to specify which folder the built project should be written to.
- Adding new properties to the manifest to track source control and build system information.
- Better error handling for malformed Word layouts.
- Semantic highlighting is enabled by default. To control it add this to your settings: `"[al]": { "editor.semanticHighlighting.enabled": true }`
- Added CodeLens support for controls/actions/views defined in page extensions and page customizations.
- Added CodeLens support for triggers to find references in the related triggers (i.e. OnInsert <-> OnAfterInsert), in event subscribers that are using identifiers for the event and element names (i.e. OnInsert <-> OnAfterInsertEvent), and in system methods (i.e. OnInsert <-> Rec.Insert).
- Added Find References (Shift+F12) support on trigger events in event subscriptions to find the related trigger definition, related triggers, other subscriptions to this event, and references from system methods.
- Added Find References (Shift+F12) support on system methods to find the relevant system method calls, the related triggers, and the related tigger events in event subscriptions. This means that you can now search for references of a system method for a given object instance, for instance finding all inserts on the Customer table.
- Improve hovering over Labels and Textconsts by showing their value.
- Added ID property on CompanyProperty to retrieve the company ID.
- IntelliSense for the SetCurrentKey method now suggests table keys instead of table fields.
- Add option to specify tooltips for Notification/ErrorInfo actions.
- From runtime version 13.0, the warnings [AL0700](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/diagnostics/diagnostic-al700?wt.mc_id=d365bc_inproduct_alextension) and [AL0702](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/diagnostics/diagnostic-al702?wt.mc_id=d365bc_inproduct_alextension) about specifying an explicit dependency on 'Application' and 'System' using the 'dependencies' properties in the app.json file will turn into errors. Instead, you should use the dedicated manifest properties 'Application' and 'Platform'.
- Added new virtual table "Extension Database Snapshot" for showing extensions that are synced in the database.
- RunObject property supports running a query object.
- Added warning [AL0805](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/diagnostics/diagnostic-al805?wt.mc_id=d365bc_inproduct_alextension) when using a quoted integer to refer to an object by its ID. An integer literal should be used instead. This syntax will be deprecated in version 14. A code fix was also added to automatically fix instances of this issue.
- Fixed an issue where making a field protected on a table could cause a crash.
- An issue has been fixed related to packaging that reproduces when within a workspace the `outFolder` and `cachePackageFolder` are the same.
- Queries will show up in search in the web client.
- When missing objects are referenced in the permissionset `Permissions` property, all will be highlighted and not just the first one.
- Fixed an issue related to packing that reproduces when within a workspace the `outFolder` and `cachePackageFolder` are the same.
- Fixed an issue where making a field protected on a table could cause a crash.
- Fixed application of enum captions on report extension dataset columns.

# Business Central 2023 release wave 1
## Version 11.6

### GitHub Issues
- [#7456](https://github.com/microsoft/AL/issues/7456) VSCode- /Complier exception in report if DataItemLinkReference references a table instead of the dataitem variable

### Miscellaneous
- Adding a non-existing dataitem as the value of the `DataItemLinkReference` will no longer crash the extension.


## Version 11.5

### GitHub Issues
- [#7435](https://github.com/microsoft/AL/issues/7435) Action Find Event generates wrong EventSubscriber for Events declared in TableExtension

### AppSourceCop
- Adding rule [AS0115](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0115) that disallow a single step obsoletion on tables, fields, and clustered keys.

### Miscellaneous
- Adding diagnostic [AL0788](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/diagnostics/diagnostic-al0788) when defining a Promoted area on a page type that doesn't support promoted actions.
- Fixed an issue where consecutive continue events were not handled correctly by the snapshot debugger.
- Unify the DAL preview file name seen by the debugger and the definition provider subsystem (go to definition).
- Add an error message [AL1153](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/diagnostics/diagnostic-al1153) in case that a referenced module is attempted to be loaded with a mismatching compiler version.
- The `Find Event` command will now fill in the correct object type when the event is exposed by an extension object.
- The compiler will no longer crash in specific cases where an interface definition cannot be found.
- Changed the default runtime version when it is not explicitly specified in the manifest (app.json). It changes from the latest supported by the compiler to the first runtime version of the current major. For BC 2023 release wave 1, since we have already released a compiler version with `11.1` as default runtime version, the default will exceptionally remain as `11.1`. However, when runtime `11.2` will be introduced, the default will not change and you will have to explictly sepcify `11.2` if this runtime is required by your app.

## Version 11.4

### Bugs fixed
- [#7449](https://github.com/microsoft/AL/issues/7449) Fixed issue with Just-In-Time debugger window appearing during publish.

## Version 11.3

### Miscellaneous
- Support for Group entitlement type for entitlements activated by the signed-in user being a member of a specific Azure AD group.
- Improved token handling for Azure AD authentication scenarios with multiple workspaces open at the same time.
- Fixed project dependency resolution within workspaces when the dependency project has higher version than the reference specified in the dependant project app.json file.

### GitHub Issues
- [#7383](https://github.com/microsoft/AL/issues/7383) Debugging the Base app showing "No content available" message for some objects.

## Version 11.2

### GitHub Issues
- [#7388](https://github.com/microsoft/AL/issues/7388) Debugger stops at first breakpoint and wont move on in VSCode 1.78.
- [#7373](https://github.com/microsoft/AL/issues/7373) usePublicURLFromServer ignores port from launch.json/workspace
- [#7385](https://github.com/microsoft/AL/issues/7385) Update AppSourceCop list of support countries/regions for rule [AS0056](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0056).

### Bugs fixed
- The port from the 'server' property in the launch configuration is no longer ignored.
- Package warnings which are suppressed in the "suppressWarnings" property in the manifest are now correctly suppressed.
- The code actions to refactor application areas and to convert explicit with statements no longer leave redundant new lines.

### Miscellaneous
- You can use the new `teventexternal` snippet to quickly create an external business event.
- Fixed parameters of the DotNet type being displayed as __MissingTypeSymbol__ in event signatures.

## Version 11.1

### Bugs fixed
- Multiple bugs fixed in ReportExtensions that resulted in visible stack traces in the output window.

## Version 11.0
### External Business Events
The new attribute `ExternalBusinessEvent` can mark a procedure to be an external event which will raise an event that an external service like dataverse can subscribe to it. This attribute can be used together with `RequiredPermissions` to add extra required permissions to subscribe to the event.

### AL Explorer & Home
- The new AL Explorer allows for better discoverability and easy navigation between AL objects.
- AL Home brings you news about AL development to a place close to you.

### Inherent Permissions
The new property `InherentPermissions` was added to objects that can have assigned permissions. AL developers can mark an object with this property, to take it out of the permissions system.

### Actionable errors
The new methods `AddAction` and `AddNavigationAction` was added to the ErrorInfo type. AL developers can use these to make errors easy to fix for users.

### Per File Code Analysis - Code Analysis Performance Overhaul
A major change has been made to the way we run code analyzers for large projects. The default behavior was changed so that we will only be running
code analysis rules on the currently focused file on the VSCode editor instead of on the entire project. This dramatically decreases the time
required to calculate the diagnostics for each file and significantly improves the total performance of the editor. On large projects, we have observed that calculating diagnostics
for a specific file can now happen up to 40 times faster. This is because the time required now depends on the size of the active file, as compared to the size of the project.
This change effectively allows real-time code analysis diagnostics on large projects.

The new behavior is controlled by the `backgroundCodeAnalysis` setting which has been extended to also control the scope of the code analyzers. The default value for the setting is `File` which
corresponds to the new behavior. To revert to running all the analyzers, the `Project` value can be set in the user or workspace settings.

### Code Analyzer Statistics
We have added the ability to see statistics for the runtime performance of the different code analyzer rules. By enabling the new setting
`outputAnalyzerStatistics` on a project and building, developers will be able to see a helpful summary of the percentage of time spent by each analyzer
and the related diagnostics that were produced by this rule. They can then selectively turn off rules which are too expensive by suppressing their
diagnostics in a ruleset file.

### Removed Legacy Runtime
The setting to use the legacy runtime has been deprecated and no longer has any effect. Setting files which include `"al.useLegacyRuntime": true` will report a deprecation warning, and the option should be removed.

### GitHub Issues
- [#7067](https://github.com/microsoft/AL/issues/7067) AL0746 now throws an error when more than one auto-increment field has been defined in a table.
- [#7145](https://github.com/microsoft/AL/issues/7145) Improve the error message for AL0505
- [#7139](https://github.com/microsoft/AL/issues/7139) AL0432 fails to warn for use of Obsoleted enum values in properties e.g. InitValue, TableRelation, FlowField CalcFormula
- [#7184](https://github.com/microsoft/AL/issues/7184) Presence of unrelated XML file(s) causes AppSourceCop/PTECop rules AS0094/PTE0014 to throw exceptions instead of just ignoring them
- [#7159](https://github.com/microsoft/AL/issues/7159) Rule AS0098 is now enforced for protected variables.
- [#7190](https://github.com/microsoft/AL/issues/7190) Intellisense is very slow.
- [#6530](https://github.com/microsoft/AL/issues/6530) '#pragma warning' is not indented and hinders expand/collapse
- [#6810](https://github.com/microsoft/AL/issues/6810) Better code visibility for Temporary Table
- [#657](https://github.com/microsoft/AL/issues/657) Foreach on Text- Adding support for `foreach` statement for Text, Code, Label and TextConstant types. Introduced with Runtime version `10.2`.
- [#7196](https://github.com/microsoft/AL/issues/7196) Code Action : Convert to use new ActionRef syntax ... is truncated?
- [#7041](https://github.com/microsoft/AL/issues/7196) Case inside "Quoted Identifier" is syntax-highlighted as case keyword and start of block. Ditto begin, end, etc.?
- [#6140](https://github.com/microsoft/AL/issues/6140) AA0232 The FlowField XXX of "TableName" should be added to the SIFT key.
- [#7359](https://github.com/microsoft/AL/issues/6140) #pragma warning disable AL0432 is ignored when backgroundCodeAnalysis is set to "File"
- [#7357](https://github.com/microsoft/AL/issues/7357) Query Column with Count, Month or Year Method returns None as Data Type
- [#7116](https://github.com/microsoft/AL/issues/7116) Snapshot Debugging: VS Code "Specified argument was out of the range of valid values. (Parameter 'index')"

### New AppSourceCop rules
- [AS0106](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0106) - Protected variables cannot be renamed or removed.
- [AS0107](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0107) - Protected variables cannot be made less accessible.
- [AS0108](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0107) - Protected variables cannot be change type.
- [AS0109](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0109) - The type of a table should not be changed from Normal to Temporary, because synchronizing the app will fail if the table contains data. Make sure to remove all data from the table before changing the table type to temporary.
- [AS0114](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0114) - The name attribute parameter of an external business event cannot be changed because it might break external subscribers.

### New PerTenantExtensionCop rules
- [PTE0020](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/pertenantextensioncop-pte0020) - Use the 'application' property instead of specifying an explicit dependency on Base Application. This rule is currently reporting as a warning, but it will report as an error in a future release.

### Change in behavior of Abs(integer)
Fixing the issue where integer division didn't return a decimal. The new behavior is now the following:
```al
local procedure TestDivision()
    var
        i: Integer;
        j: Integer;
        d: Decimal;
    begin
        i := 5;
        j := -2;
        d := i / Abs(j); // d will be 2.5
    end;
```

### New UICop rule
- [AW0015](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/uicop-aw0015) - When targeting runtime versions lower than 10.0, actions with scope repeater must be promoted in order to appear on the repeater in the web client. From runtime version 10.0, actions with scope repeater are rendered also when they are not promoted.

### Updated UICop rule
- [AW0012](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/uicop-aw0012) - When targeting runtime versions higher or equal to 11.0, the AboutText and AboutTitle properties will not be flagged as not supported for actions and action groups inside parts.

### New CodeCop rule
- [AA0246](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/codecop-aa0246) - When suppressing diagnostics using `#pargma warning disable`, the code(s) of the diagnostics to suppress must be specified instead of suppressing all analyzer diagnostics and compiler warnings.

### Bugs fixed
- Fixed issue where duplicate error messages would be shown when a key vault url has multiple violations (AL1078).
- Fixed issue where code actions may not be returned for a specific document, due to incorrect diagnostics being used for their discovery.
- Optimized Code Action discovery to not run analysis on the entire project for every click, but only on the active document.

### RecordRef.SetTable supports ShareTable
New overload for SetTable that supports specifying ShareTable, to share the same underlying table for temporary records.

### Media.FindOrphans & MediaSet.FindOrphans
New methods for finding media and media sets that are no longer referenced, and can be deleted.

### ReadIsolation on Record and RecordRef
New property that sets a record's read isolation level. This influences what isolation level is used when reading from the database.

- Default: Follows the table's isolation behavior, same behavior as not choosing an isolation level.
- ReadUncommitted: This behavior makes the record return uncommitted rows when reading. Also called dirty reads, as well as any new rows added.
- ReadCommitted: Only allows for reads committed data, but does not guarantee that rows read will stay consistent throughout the entirety of the transaction.
- RepeatableRead: Guarantees that two subsequent reads of the same rows will return the same data.
- UpdLock: Useful if you are planning to write later in the transaction. No one else can take a UpdLock isolation level at the same time on the same record, meaning you avoid new rows being added during the transaction. Otherwise same guarantees as RepeatableRead

### Report FormatRegion property

New report property for setting the format region for the report. The format region is specified using the .Net culture tag name (as en-US).

- Set the default format region in the report object

```al
report 50000 TestReport
{
    FormatRegion = 'da-DK';
}
```

- Set the format region at runtime with an AL property for a report instance.

```al
local procedure TestDivision()
var
    report: Report TestReport;
begin
    report.FormatRegion := 'da-DK';
end;
```

- Set the format region at runtime in a report trigger.

```al
trigger OnAfterGetRecord()
begin
    CurrReport.RegionFormat := 'da-DK';
end;
```

### New virtual table to support Language selection

The following virtual table is added to allow drop down selection of languages and regions in pages (and request page):

* **Language Selection** (ID 2000000050)
  -  This table contains information about languages display name, language id, culture tag and application enabled. Primary key is "Name" (the display name).

### URLs can be used as the ruleset location

A url can now be used as the location for both the `al.rulesetPath` setting and for included rulesets.
This makes it possible to upload a ruleset to a centralized location and re-use it for different projects.
The feature can be turned off for security reasons through the `al.enableExternalRulesets` setting.

An example for how to enable the feature:
```
"al.rulesetPath": "https://bcartifacts.azureedge.net/rulesets/appsource.default.ruleset.json"
```

An example of how it can be used in a ruleset:
```
{
    "name": "Personal Project ruleset",
    "description": "A list of project specific rules",
    "includedRuleSets": [
        {
            "action": "Default",
            "path": "https://bcartifacts.azureedge.net/rulesets/appsource.default.ruleset.json"
        }
    ],
    ...
    ]
}
```
This feature can be used from alc as well by including the `-enableexternalrulesets` argument.

### InStream ResetPosition method

Add a method `ResetPosition` that will reset the position on the InStream instance and allow AL code to read all content from the beginning.

```al
local procedure ResetStream();
var
    instr : InStream;
    b : Boolean;
begin
    b := instr.ResetPosition();
end;
```

### InStream Position and Length properties

Adds the Position and Length properties that will return the current stream position and length.

```al
local procedure StreamProperties();
var
    instr : InStream;
    Position : BigInteger;
    Length: BigInteger;
begin
    Position := instr.Position();
    Length := instr.Length();
end;
```

### Go-To Implementation

To find which codeunits or enums implement an Interface, it is now possible to use the "Go To Implementations" command.

If the command is invoked on a procedure, it will find the implementations of that procedure on other codeunits as well.

### Type Hierachy

If you want to figure out where are the extension objects to a given object, you can now use the "Type Hierarchy" functionality in VSCode to do so.

### Code actions for refactoring Application Area property

A new code action is introduced that sets the default value for application area on a page or a report and clean up the duplicates this code action can be applied to an object, a document, a project or a workspace.

A new code action is introduced that cleans up the redundant application areas if a default value is set on a page or a report. This code action can be applied to an object, a document, a project or a workspace.

### Go-To definition for Event Publisher in Event Subscriber

We have improved the syntax of event suscribers to allow specifying identifiers to reference the event you are subscribing to, and to reference the target element for trigger events.

The new syntax is as follows:
```
[EventSubscriber(ObjectType::Page, Page::MyPage, OnAfterActionEvent, MyAction, true, true)]
```

This syntax allows to navigate from the subscriber to the event and to see the event hover information. You can now also see who is subscribing to your events.

In order to facilitate the conversion, code actions have been introduced to convert one, some, or all event subscribers in your project or workspace to the new syntax.

### Support for multiple package caches

The `al.packageCachePath` setting now supports specifying multiple directories to search for cached symbol packages. To specify multiple directories, use the following syntax:

```json
{
    "al.packageCachePath": [".\.alpackages", ".\.alternativeCacheDirectory"]
}
```

When downloading symbols, the first entry in the list will be used as the directory to store newly downloaded symbols.


### Support for overriding the PublicWebBaseURL server setting OnPrem

A new `usePublicWebURLFromServer` option has been added to the launch.json. If set to `false`, the PublicWebBaseURL server setting will be overriden with the `server` parameter of the launch.json when launching the browser as part of a `launch` configuration. This option only affects launch debug sessions to OnPrem servers. If set to `true` the PublicWebBaseURL server setting will be used. The default for this is `true`.

### New `customaction` types: `FlowTemplate`, `FlowTemplateGallery`
Add two new [`CustomActionType`](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/properties/devenv-customactiontype-property)s, `FlowTemplate` and `FlowTemplateGallery`. The actions trigger web the client to open the Power Automate integration to create a new Power Automate flow from a specifc template or selection of templates.

#### `FlowTemplate`
Opens the Power Automate template wizard. The user can follow the wizard to create a flow using the specified template.

```al
customaction(DirectAction) {
    CustomActionType = FlowTemplate;
    FlowTemplateId = '69569e22-054f-4577-870a-e905860e4319';
    FlowCaption = 'My New Flow';
}
```

Property | Type | Required? | Description
-|-|-|-
[`FlowTemplateId`](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/properties/devenv-flowtemplateid-property) | guid | Yes | The ID of the template to open.
[`FlowCaption`](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/properties/devenv-flowcaption-property) | string | No | The default caption of the newly created flow.

#### `FlowTemplateGallery`
Opens the Power Automate template gallery, filtered to a specific category. The user can follow the wizard to create a flow using a template selected from the gallery.

```al
customaction(DirectAction) {
    CustomActionType = FlowTemplateGallery;
    FlowTemplateCategoryName = 'd365bc_instant';
    FlowCaption = 'My New Flow';
}
```

Property | Type | Required? | Description
-|-|-|-
[`FlowTemplateCategoryName`](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/properties/devenv-flowtemplatecategoryname-property) | string | Yes | The category of template to display.
[`FlowCaption`](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/properties/devenv-flowcaption-property) | string | No | The default caption of the newly created flow.

### Attach to session and user debugging
Now the normal debugger is able to connect to ongoing sessions and to the next session for any specified user. For more information check [AL debugging.](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-debugging)

### Miscellaneous
- New warning when using of Obsolete properties on page areas and page action areas. From runtime 13.0, an error will be reported.
- New warning when exposing a public method that has a parameter or a return value whose types have internal accessibility.
- Improved the connection error messages triggered by the snapshot debugger.
- XML files in an unsupported encoding will no longer cause code analyzers to crash.
- When discovering code actions, only analyzers with code fixes will be executed.
- New warning when making procedures of the same name as a built-in procedure.
- Fixed RAD instabilities when working with large projects.
- Fixed issue using Blob table fields in XmlPort objects.
- Added documentation for system options and system option values on hover and when using IntelliSense.
- Fixed an issue where overloads of DotNet functions with extra optional parameters would be considered ambiguous.
- Fixed a crash that would occur when specifying a column as a target for a report extension's addfirst/addlast modifier.
- Added support for suggesting first available ordinal value for enum values in enums and enum extensions.
- Marked `UpdateKey` parameter from `RecordRef.FindSet`and `Record.FindSet` as deprecated.
- Added an indication that a table or record is temporary when hovering over definitions, variables and parameters.
- New method on the database indicating whether or not you are in a write transaction.
- [AA0194](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/codecop-aa0194) - Warning is no longer raised when a `customaction` does not define the `FlowId` property. Instead, a compiler warning will be raised if the `FlowId` property is not defined for `customaction`s of type `Flow`. This warning will become an error in version 13.0.
- Fixed crash when dependencies in the manifest are missing App name or publisher.
- Improved the time to resolve assemblies from probing paths, especially for directories with a large number of assemblies.
- For the Images, Scripts, and StyleSheets properties for control add-ins, it is now possible to specify multiple files within the same path string by using a combination of a valid literal path and wildcard characters (* and ?).
- Syntax highlighting will no longer highlight bracket keywords when they are inside a quoted identifier.
- Added a new warning for table fields with leading/trailing spaces as it can cause publishing failures.
- Fixed an issue that would cause incomplete diagnostics to be emitted in the case of a project without AL files.
- Fixed a crash that would occur when invoking a method on a protected array as part of an expression.
- Fixed a crash that would occur when using a protected variable as an index on an array as part of an expression.
- Fixed an issue where diagnostics would get stuck when using project mode.
- Fixed an issue where multi-project workspace diagnostics may not be updated.
- Fixed an issue where declaration diagnostics would ignore pragma and ruleset suppressions.
- Deprecating `InDataSet` attribute used for global variables in Pages.
- AL0754 diagnostic has been introduced for when the name of an object member conflicts with an internal member, which can lead to runtime issues. From runtime 14.0, an error will be reported.

# Business Central 2022 release wave 2


## Version 10.5

### Miscellaneous
- Fixed an issue in the AS0014 AppSourceCop rule, which prevented it from appearing in the diagnostics for the manifest file.
- With runtime 10.2 in SaaS, you can use additional methods for assessing assigned entitlements for the current user in context of an application from the NAVApp type.
- Fixed Intellisense recommending non-extensible objects when writing an extension.
- Fixed an issue when Business Central server is configured to use Kerberos authentication, which prevented extension from connecting to the server.

### GitHub Issues
- [#7205](https://github.com/microsoft/AL/issues/7205) Reference by name in calculation properties not working on RunPageLink

## Version 10.4

### GitHub Issues
- [#5667](https://github.com/microsoft/AL/issues/5667) Run code analysis in the Azure DevOps Pull Request- Documenting analyzer and app arguments to alc.exe.
- [#7215](https://github.com/microsoft/AL/issues/7215) Alc.exe parameter 'preProcessorSymbols' is not documented

### Miscellaneous
- An issue was fixed which prevented nested method calls to be used as the values of page fields or report columns, if any of them produced a record.
- Enhancements to the profile-generated files by the AL Profiler for better visualization and navigation, including new shortcuts.

## Version 10.3

### GitHub Issues
- [#7156](https://github.com/microsoft/AL/issues/7156) Improvements on AA0241 to not validate Action and Label data types, [RunObject](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/properties/devenv-runobject-property) property values, Enum table fields, and [Permissions](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/properties/devenv-permissions-property) property values.
- [#7255](https://github.com/microsoft/AL/issues/7255) Code action: Convert promoted actions to modern action bar fails when specifying 'NoPromotedActionProperties'.
- [#7239](https://github.com/microsoft/AL/issues/7239) Issue with fullDependencyPublish
- [#7299](https://github.com/microsoft/AL/issues/7299) Update AppSourceCop list of support countries/regions for rule [AS0056](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0056).

### Miscellaneous
- New warning for when the names of two dataitems or two actions conflict. Whitespaces in names are internally replaced with an underscore during compilation, such that two different names can collide. For example, "Action name" and "Action_name" are conflicting names. From runtime 12.0, an error will be reported.
- Fixed an error which could prevent full-dependency publish.
- Fixed missing validation of duplicate enum values defined in enum extensions.
- Fixed AppSourceCop validation to not report diagnostic [AS0034](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0034) when the [CompressionType](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/properties/devenv-compressiontype-property) property changes on a table.
- Fixed an issue in the AS0014 AppSourceCop rule which prevented it from appearing in the diagnostics for the manifest file.

## Version 10.2

### Future change in behaviour
An issue in integer division was found by the community and it will be fixed with the next major release of the compiler- Version 11. Until then we are introducing a new warning [AL0756](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/diagnostics/diagnostic-al756) that will notify AL developers so they can adapt the change. The faulty behavior occurs only in the following scenario when `j` is of integer type:
```al
local procedure TestDivision()
    var
        i: Integer;
        j: Integer;
        d: Decimal;
    begin
        i := 5;
        j := -2;
        d := i / Abs(j); // d will be 2 instead of 2.5
    end;
```


### GitHub Issues
- [#7123](https://github.com/microsoft/AL/issues/7123) Word layouts keep randomly getting changed when compiling application.
- [#7207](https://github.com/microsoft/AL/issues/7207) PageCustomization IntelliSense not picking up actionref keywords
- [#7143](https://github.com/microsoft/AL/issues/7143) Text overflow is not caught at build or runtime if implicitly converting Guid to Text or Code, AND it changes MaxStrLen!


### Miscellaneous
- Word layouts will now only be updated if there are changes in the structure of the report or report extension that includes them.
- Intellisense will suggest tables for report extension data-items.
- An issue was fixed where project wide code fixes would not work.

## Version 10.1

### Support for global and workspace launch configuration
AL developers are now able to add a `launch` property to their `code-workspace` or `settings.json` file and it will be taken into account. A local `launch.json` file overrides the workspace and global configuration. A workspace `launch` configuration overrides the `launch` configuration specified in the global `settings.json` file.

In case that the local `launch.json` file doesn't contain a valid AL launch configuration, we'll try to find one in the `code-workspace` first, and then in the `settings.json` files. However, if the `launch` property is specified in the `code-workspace` file even without specifying a valid AL configuration, the global `settings.json` file will not be able to override it.

### Report.PrintOnlyIfDetail
- The [PrintOnlyIfDetail method](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/report/reportinstance-printonlyifdetail-method) is now supported for Business Central online.

### GitHub Issues
- [#6514](https://github.com/microsoft/AL/issues/6514) Viewing variables in debug breaks session
- [#6930](https://github.com/microsoft/AL/issues/6930) CalcFields and CalcSums auto-complete/IntelliSense stops working after the first two fields, i.e. broken on third onwards
- [#7077](https://github.com/microsoft/AL/issues/7077) AL allows/suggests "Enum Name"::"First Value Name"::"Another Value Name"::"Etc"::"Etc"
- [#7146](https://github.com/microsoft/AL/issues/7146) Support sticky scroll with a more complete model, meaning for instance, the sticky scroll line is not the attribute of a procedure but the name of it.
- [#7156](https://github.com/microsoft/AL/issues/7156) Rule AA0241 should not report a warning on object types.
- [#7133](https://github.com/microsoft/AL/issues/7133) There should be a Compiler Error for setting the Editable Property of a part in a PageExtension
- [#7155](https://github.com/microsoft/AL/issues/7155) Unable to cast object of type 'Microsoft.Dynamics.Nav.CodeAnalysis.Symbols.ObjectTypeSystemOptionTypeSymbol' to type 'Microsoft.Dynamics.Nav.CodeAnalysis.Symbols.OptionTypeSymbol'
- [#7166](https://github.com/microsoft/AL/issues/7166) Copies wrong SQL statement
- [#7190](https://github.com/microsoft/AL/issues/7190) Intellisense is very slow.
- [#6977](https://github.com/microsoft/AL/issues/6977) Doc for "Table System fields" says audit fields like SystemCreatedAt can be used in keys, but AL gives errors (AL0306)
- [#7220](https://github.com/microsoft/AL/issues/7220) Unexpected value 'BadExpression' if using Enum class as Parameter with Next Minor Version of BC21

### Miscellaneous
- Deprecated the usage of 'Extension' and 'Internal' targets in the app.json manifest in favor of 'Cloud' and 'OnPrem' from runtime version 11.0.
- [AW0012](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/uicop-aw0012) - When targeting runtime versions higher or equal to 10.0, the AboutText and AboutTitle properties will not be flagged as not supported for parts and controls inside of factboxes.
- Fixed issue in the snapshot debugger that resulted in skipping each snappoint, except the first one set on an application object, when there were multiple application objects in one source file.
- Improved IntelliSense to suggest the name of the 20 synthesized promoted categories when creating a new action group in the promoted area.
- Improved IntelliSense and hover display for the promoted category `Category_Process` to mention that this category is the `Home` category.
- Added a new feature "NoPromotedActionProperties" in the app.json to enforce the usage of the promoted area and actionref syntax in the extension.
- The username and password input boxes will no longer disappear when the editor window goes out of focus during authentication.
- [AW0008](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/uicop-aw0008) - Expanded the set of page types where repeaters are not supported to match the behavior of the web client. AW0008 will be reported when a repeater is added to any page or page extension which is not a List, ListPart, Worksheet, or API page.
- Generated translation file again contains PromotedActionCategories when the property is used.
- Better support for copying variable expressions to the watch window and debug console.
- Fixed an issue in the workspace logic where opening a file would always trigger a recompilation of the entire project.
- Reports and report extensions can no longer have dataitems whose names are only quotes and whitespace (e.g. "" and " ").

## Version 10.0

### GitHub Issues
- [#7083](https://github.com/microsoft/AL/issues/7083) The AL:Go! project template now has "implicit with" switched off by default. This is visible in the app.json file where the project feature "NoImplicitWith" is present.
- [#7057](https://github.com/microsoft/AL/issues/7057) AS0098 should allow any character instead of space when validating report extensions columns affixes
- [#7072](https://github.com/microsoft/AL/issues/7072) AL0432 is shown in triggers of obsolete fields
- [#7073](https://github.com/microsoft/AL/issues/7073) The outline window now handles RDLCLayout, WordLayout and ExcelLayout properties.
- [#7107](https://github.com/microsoft/AL/issues/7107) ControlAddIn/UserControl in page loses its actual type when referenced in a pageextension, breaking passing to procedures
- [#7127](https://github.com/microsoft/AL/issues/7127) Compiling app using NextMajor version is failing with AL compiler error
- [#7141](https://github.com/microsoft/AL/issues/7141) Rule AS0098 is now enforced for report labels.

### Data Transfer
The new AL object `DataTransfer` has been introduced, which enables bulk data transfer operations in upgrade code via set-based SQL operations instead of using row-by-row operations.

### Use of Option Access syntax in formulas

The AL language now supports using option access syntax in formula properties. This removes the need for hard coded integer values and improves the readability and the maintainability of the code.

```al
page 50100 MyCustomerReportSelectionPage
{
    SourceTable = "Custom Report Selection";
    SourceTableView = where("Source Type" = const(Database::Customer));
}
```

### New UICop rule
- [AW0014](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/uicop-aw0014) - A warning is reported when an action group with its visibility set to false contains the target actions of one or many actionrefs. This rule is similar to [AW0013](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/uicop-aw0013), but for pages using the new action bar syntax.

### The snapshot debugger shows all the lines hit by a snapshot session
All the lines that were collected by a snapshot debugging session are marked with a vertical line in the left gutter of the editor.
The appearance of the gutter is controlled by the al.snapshotDebuggerLinesHitDecoration configuration setting.

### Debugger Enhancements
We have added new options to control when the debugger should break on errors or record writes.

**BreakOnError**: This takes now one of the following values: [true, false, "All", "None", "ExcludeTry"].
- false/None: Does not break on any errors.
- true/All: Breaks on all errors.
- ExcludeTry: Breaks on errors **only** if they occur outside of the context of a Try function.

**BreakOnRecordWrite**: This takes one of the following values: [true, false, "None", "All", "ExcludeTemporary"]
- false/None: Does not break on any record writes.
- true/All: Breaks on all record writes.
- ExcludeTemporary: Breaks on record writes **only** if they are not on a temporary table.

### PermissionSet - New ExcludedPermissionSets Property
The new property `ExcludedPermissionSets` was added to permission set objects, allowing the definition of excluded permission sets in extensions.
See more here: [ExcludedPermissionSets](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/properties/devenv-excludedPermissionSets-property)

### Inherent Permissions
The Inherent Permissions attribute allows now for elevating entitlements and/or permissions in the given method scope. This is achieved by specifying an optional argument called `InherentPermissionsScope`.

### Apply a code action to document, project, or solution scope
We have added the ability to fix all occurrences of an issue in document, project or solution scope. If a code action supports 'fix all occurrences', then there will be more suggestions on the list, for each extra supported scopes, where user can choose to apply the fix to the current instace of an issue or to apply the fix to all the occurances in a chosen scope.

### ResourceExposurePolicy - New ApplyToDevExtension Property
A new property `ApplyToDevExtension` has been added to the `ResourceExposurePolicy` in the `app.json` file. If this flag is set to `true`, all resource exposure policies specified for the extension will also apply to developer extensions.

### Run Power Automate flows from page actions
We have added the ability to define page actions triggering a Power Automate flow using custom actions. The syntax is as follows:
```al
customaction(MyFlowAction)
{
    CustomActionType = Flow;
    FlowId = '<the-GUID-identifying-the-Power-Automate-Flow>';
    FlowEnvironmentId = '<the-GUID-identifying-the-Power-Automate-environment>';
}
```

### Render a group as a split button
We have introduced the ability to render some groups as split buttons. This type of control gives you a fast one-click access to the first action visible and enabled in a menu by using the left button part and also provides access to other related actions by using the right dropdown part.

Split buttons can be defined using the new property [ShowAs](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/properties/devenv-showas-property).

### New Promoted Action Syntax
We have introduced a new area named `Promoted` and a new concept of action references, in replacement of the [Promoted](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/properties/devenv-promoted-property) properties. This allows you to explicitly define the order of the actions in the promoted side of the action bar.

The syntax looks as follows:
```al
    area(Promoted)
    {
        group(MyPromotedGroup)
        {
            actionref(MyActionRef; MyAction)
            {
            }
        }
    }
```

For more information about the new AL Syntax for the action bar, see:
- [Promoted Actions](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/devenv-promoted-actions)
- [Actions Overview](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/devenv-actions-overview)
- [Adding Actions to a Page](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/devenv-adding-actions-to-a-page)

In order to help you convert your extensions, we have added an AL code action to convert pages using the legacy action syntax to use the new `actionref` syntax. This code action allows you to convert, a single page, all pages in a document, all pages in your project, or even all pages in your workspace.

### New UICop rule
Similarly to [AW0013](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/uicop-aw0013), we have introduced a new UICop rule [AW0014](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/uicop-aw0014) that reports a diagnostic when an action group with its visible set to false contains or one or many actions with action references.

### Inherent Object Entitlements
The new property `InherentObjectEntitlements` was added to objects that can have assigned permissions. AL developers can mark an object with this property, to take it out of the permissions system.

### Miscellaneous
- The SystemRowVersion (timestamp) field is now available for tables. Added `LastUsedRowVersion()` and `MinimumActiveRowVersion()` to use in combination with the SystemRowVersion field.
- Added a new parameter to the launch.json file that allows opening a specific company when deploying from Visual Studio Code.- The `treport` snippet now includes the `DefaultRenderingLayout` property.
- The 'al.enableCodeActions' setting is now enabled by default.
- Option types are now always considered equal since they are a wrapper of the Integer type.
- Fixed a bug that prevented loading dotnet types, which were subject of [type forwarding](https://learn.microsoft.com/dotnet/standard/assembly/type-forwarding).
- Fixed hover display for properties defined in action groups and action separators.
- Intellisense now suggests keys for the SourceTableView property on XmlPort table elements and the DataItemTableView for Report DataItems.
- Controls and Actions now inherit the [ApplicationArea](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/properties/devenv-applicationarea-property) defined on the page/report level. The analyzer rules [AS0062](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0062) and [PTE0008](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/pertenantextensioncop-pte0008) have been updated accordingly.
- Added command to generate permission set as an AL object, al.generatePermissionSetForExtensionObjects. The previous functionallity of creating a permissionset xml file, is moved into the command al.generatePermissionSetForExtensionObjectsAsXml.
- The AL:Go! project template now has allowDebugging, allowDownloadingSource, and includeSourceInSymbolFile switched on by default. This is visible in the app.json file where the project resourceExposurePolicy is set.
- AppSourceCop Error AS0093 has been discontinued. AppSource submissions can now contain entitlement objects.
- Improved performance when background code analysis and code actions were both enabled.
- New warning [AL0732](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/diagnostics/diagnostic-al732) regarding the use of non-public procedures in interfaces. This will become an error [AL0733](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/diagnostics/diagnostic-al733) in a later release.
- Fixed issue that case conditions could generate invalid code for the server.
- Fixed a bug that prevented running CodeCop rule [AA0241](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/analyzers/codecop-aa0241).
- Added more validation for key vault urls; Validation of key vault URLs at compilation time are now aligned with runtime validation.
- New feature 'AllTranslationItems' in the app.json manifest. It creates all possible translation units. This should also be used when another app want to translation this app, in order to give them all translation labels.
- Fixed IntelliSense crashing for enums UnknownValueImplementation property.
- 'Go To Definition' now works for Rec, xRec, CurrReport, CurrPage, CurrQuery and CurrXMLport.
- Deprecated the usage of 'Extension' and 'Internal' targets in the app.json manifest in favor of Cloud' and 'OnPrem' from runtime version 11.0.

# Business Central 2022 release wave 1


## Version 9.5

### GitHub Issues
- [#6582](https://github.com/microsoft/AL/issues/6582) Wrong indentation level of repeat/until loop directly under case option label
- [#6429](https://github.com/microsoft/AL/issues/6429) Code like if FindFirst() then; gets wrong line-break/indentation within case block
- [#6920](https://github.com/microsoft/AL/issues/6920) code within a CASE's ELSE BEGIN block is indented by 1 tab too far

## Version 9.4

### Inherent Permissions
- InherentPermissions attribute is now available in the scope "Cloud" when using 9.2 as runtime version in the app.json of the extension.

## Version 9.3 Update 3

### GitHub Issues
- Fixing [#7081](https://github.com/microsoft/AL/issues/7081) AA0244 should not warn about event publisher arguments with same name as global variable
- Fixing [#7104](https://github.com/microsoft/AL/issues/7104) AL VSIX is not respecting the new vscode telemetry settings

## Version 9.3 Update 2

### GitHub Issues
- Reverted [#7081](https://github.com/microsoft/AL/issues/7081) AA0244 should not warn about event publisher arguments with same name as global variable
- Reverted [#6582](https://github.com/microsoft/AL/issues/6582) Wrong indentation level of repeat/until loop directly under case option label
- Reverted [#6429](https://github.com/microsoft/AL/issues/6429) Code like if FindFirst() then; gets wrong line-break/indentation within case block
- Reverted [#6920](https://github.com/microsoft/AL/issues/6920) code within a CASE's ELSE BEGIN block is indented by 1 tab too far
- Reverted [#6488](https://github.com/microsoft/AL/issues/6488) AA0198 should also observe procedure parameters - Introducing new CodeCop rules to cover such cases.
- Reverted [#6238](https://github.com/microsoft/AL/issues/6238) Wrong SETRANGE statement can be run with strange behavior

## Version 9.3 Update 1

### GitHub Issues
- [#7081](https://github.com/microsoft/AL/issues/7081) AA0244 should not warn about event publisher arguments with same name as global variable
- [#6582](https://github.com/microsoft/AL/issues/6582) Wrong indentation level of repeat/until loop directly under case option label
- [#6429](https://github.com/microsoft/AL/issues/6429) Code like if FindFirst() then; gets wrong line-break/indentation within case block
- [#6920](https://github.com/microsoft/AL/issues/6920) code within a CASE's ELSE BEGIN block is indented by 1 tab too far

### New UICop rule
- [AW0013](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/uicop-aw0013) - A warning is reported when an action group with its visibility set to false contains one or many promoted actions. We have also added a code action in order to fix this diagnostic from Visual Studio Code.

## Version 9.2

### GitHub Issues
- [#6318](https://github.com/microsoft/AL/issues/6318)+[#6959](https://github.com/microsoft/AL/issues/6959) Stop reporting AA0210 for suboptimal indexes on virtual tables
- [#7000](https://github.com/microsoft/AL/issues/7000) RDLC report paths in Mac OS vscode
- [#7006](https://github.com/microsoft/AL/issues/7006) Do not report AA0001 when the line ends with a comment and next line is the second argument of a binary operator.
- [#7027](https://github.com/microsoft/AL/issues/7027) AS0088 should not validate enum extensions because they cannot be marked as obsolete
- [#7025](https://github.com/microsoft/AL/issues/7025) When you create a new report using the treport snippet, it always assigns UsageCategory = Administration; Should that not be UsageCategory = ReportsAndAnalysis;?
- [#6238](https://github.com/microsoft/AL/issues/6238) Wrong SETRANGE statement can be run with strange behavior
- [#6979](https://github.com/microsoft/AL/issues/6979) Syntax analyzer is broken - Report Labels
- [#6488](https://github.com/microsoft/AL/issues/6488) AA0198 should also observe procedure parameters - Introducing new CodeCop rules to cover such cases.
- [#7035](https://github.com/microsoft/AL/issues/7035) Rule AA0240 recognizes a GUID as Phone No. or E-Mail
- [#7030](https://github.com/microsoft/AL/issues/7030) New semanticHighlighting - Function's begin-end in RED

### Miscellaneous
- Fixing an issue that caused dependencies to be incorrectly marked as unsatisfied after downloading symbols.
- Fixing an issue where a propagated project reference would update its application references on the referred project.

## Version 9.1

### GitHub Issues
- [#6857](https://github.com/microsoft/AL/issues/6857) Missing error on compile upgrade codeunits being run by code
- [#7010](https://github.com/microsoft/AL/issues/7010) F12 does not find the AL file that contains the definition
- [#6972](https://github.com/microsoft/AL/issues/6972) Unable to debug files with a forward slash in the name
- [#6978](https://github.com/microsoft/AL/issues/6978) broken Intellisense/auto-complete for begin/end of a procedure returning a record type


### Miscellaneous
- Fixing crash when accessing a report layout using a variable of the Report data type. Note that report layouts cannot be accessed by using a variable based on the Report data type.
- Fixing an issue that occurred if the version of a project, in an already opened workspace, had changed, any projects that were depending on it failed to load if set to active. The only solution was to trigger the reload window command.
- Update warnings about dependency on Application and System in the 'dependencies' manifest property. The recommended style is to use the dedicated manifest properties: 'application' and 'platform'.
- Removed a duplicate entry for the "Generate Profile File" option from the Visual Studio Code command palette.

## Version 9.0

### New sampling option for the AL profiler
The AL profiler supports a new profiling option called Sampling. Sampling captures method calls at predefined, repeated intervals that can be set on OnPremise versions of BC in the SamplingInterval server settings. This has a smaller performance load on the BC server, but also provides less accurate measurements. One can define what profiling session to execute in the profilingType entry of a snapshot configuration file. The default is 'Instrumentation'.

### Multiple Report Layouts

Report and Report Extensions now supports defining multiple layouts in a single object using the new `rendering` section. The syntax is as follows:

```al
report 50100 MyReport
{
    DefaultRenderingLayout = RDLCLayout;

    rendering
    {
        layout(RDLCLayout)
        {
            Type = RDLC;
            LayoutFile = 'layout.rdl';
            Caption = 'Nice RDLC Layout';
        }

        layout(...
    }
```

Old reports using the previous property-based layout specification can be converted to use this section with a new code action. Ensure code actions are turned on in your AL extension settings and place the cursor on any of the old layout properties to use the action. Layouts of type RDLC, Word, Excel, and Custom can be specified with the new rendering syntax.

### Workspace Publishing

Publishing large workspaces with interdependent projects can be done with the new `Publish full dependency tree for active project` command. This can be triggered through the command palette or by using the shortcut `Shift+Alt+W`. This will calculate the correct order in which to compile and publish the dependencies of the current project and publish them using the `launch.json` option selected from the current active project.

### Support for Excel Layouts on reports
Report objects now support Excel layouts. They can be added either in the `rendering` section or through the `ExcelLayout` property. If they refer to an existing file, the layout is validated based on the schema of the report dataset. If no file exists, a starter template is generated upon compilation.

### New InherentPermissions attribute
Added a new ability to elevate user permissions during the specific method execution. The attribute should be defined with the use of a new AL `PermssionObjectType` enum.

### New Isolated event attribute
Events definitions now support an isolated mode, in which they will be executed with isolated transaction schematics. Allowing all events to be executed, even if one fails, and allow the calling code to also continue executing.Events definitons now support an isolated mode, in which they will be executed with isolated transaction schematics. Allowing all events to be executed, even if one fails, and allow the calling code to also continue executing.

### New AppSourceCop rules
As part of our efforts to improve the validation of AppSource submissions, we worked on making the AppSourceCop more reliable, but we have also introduced new rules based on the new AL languages capabilities, customer incidents, and feedback from the community:
- [AS0101](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0101) - An error is reported when an 'Isolated' event argument is changed, added, or removed.
- [AS0103](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0103) - A warning is returned when table definitions in your extension are missing a matching permission set. This was suggested with Github issue [#6503](https://github.com/microsoft/AL/issues/6503).
- [AS0104](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0104) - An error is returned when the extension name is not valid in SaaS.
- [AS0105](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0105) - An informational diagnostic is reported when you are referencing an object pending obsoletion with an ObsoleteTag lower than what you specified in your AppSourceCop.json. By enabling this rule, you can validate if your app is ready for a given release of Business Central.

For more information, see [AppSourceCop Analyzer Rules](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop).

### Bug fixes
* Copying values from the debuggers variable panel, now supports identifiers with quotes.
* Fixed a rare issue where relative file paths for resources could not be resolved properly.
* Detecting duplicate permissions in permission sets and adding an error if there is any duplications.
* Usage of constant dates in a case statement is fixed.
* Ambiguouity in the cases that parameters of a function are interfaces are fixed.
* Errors in loading a workspace (e.g. due to circular dependencies in the projects) are now surfaced as an error.
* Emitting error when dividing by 0 using DIV keyword.

### GitHub Issues
- [#6899](https://github.com/microsoft/AL/issues/6899) IntelliSense/auto-complete for ShowMandatory property doesn't work correctly/same, e.g. won't offer members of Rec
- [#6970](https://github.com/microsoft/AL/issues/6970) Cannot obsolete views on a pageextension
- [#6803](https://github.com/microsoft/AL/issues/6803) How to remove a page extension of a removed page?

### Miscellaneous
- Improving documentation when hovering on attributes and triggers.
- Adding a new parameter to alc.exe - `reportSuppressedDiagnostics` that includes `#pragma` disabled diagnostic messages to the error list.



# Business Central 2021 release wave 2

## Version 8.4

### Validation of runtime breaking changes

In order to call AL procedures, the Business Central runtime relies on a unique ID assigned to each procedure. When a procedure changes its signature, its method ID changes too and dependent extensions which are referencing it must be recompiled in order to use the new ID. Some signature changes do not have an impact on the compilation of dependent extensions, but are still causing the generation of a new method ID. For example, adding a var parameter, or adding a return type. These changes are called runtime breaking changes.

In order to prevent runtime issues caused by runtime breaking changes and provide a better experience to customers in SaaS, a new AppSourceCop rule [AS0102](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0102) has been introduced and the severity of the rules [AS0077](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0077) and [AS0078](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0078) has changed from `Warning` to `Error`.

These changes have already been applied to the technical validation of AppSource submissions in Partner Center.

### GitHub Issues
- [#6892](https://github.com/microsoft/AL/issues/6892) Implementing Interface with Complex Return Type Creates Incorrect Signature
- [#6927](https://github.com/microsoft/AL/issues/6927) Cannot remove obsolete controladdin
- [#6872](https://github.com/microsoft/AL/issues/6872) Can't Go To Definition of fields used in key
- [#6851](https://github.com/microsoft/AL/issues/6851) AL0697 - Valid Fieldtype Fielref.Value() --> New Cast AsGuid, As DateTime

### Warnings that will turn into errors in the next releases

Over the last periods, we have introduced multiple warning diagnostics that will turn into an error in a future release. You can find a summary below:

- Warning [AL0660](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/diagnostics/diagnostic-al660) will become an error with Business Central 2022 release wave 2.
- Warning [AL0677](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/diagnostics/diagnostic-al677) will become an error with Business Central 2022 release wave 2.
- Warning [AL0692](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/diagnostics/diagnostic-al692) will become an error with Business Central 2022 release wave 2.
- Warning [AL0694](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/diagnostics/diagnostic-al694) will become an error with Business Central 2022 release wave 1.
- Warning [AL0697](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/diagnostics/diagnostic-al697) will become an error with Business Central 2022 release wave 2
- Warning [AL0711](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/diagnostics/diagnostic-al711) will become an error with Business Central 2023 release wave 1.
- Warning [AL0715](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/diagnostics/diagnostic-al715) will become an error with Business Central 2022 release wave 2.

#### Miscellaneous
The way projects are loading in a workspace has changed. While the active project and its project references are loaded no compilation-based information like IntelliSense, symbols are available.
Depending on the number of files in the project reference closure of the active project, this operation can be time-consuming.
Projects in a workspace that are not loaded are marked with letter N. A project will load if it is made active by opening an AL file, or the app.json.

## Version 8.3

### New AppSourceCop rule

In order to simplify and improve the dependency handling in Business Central, it is now required to use the `application` property in the app.json file of AppSource apps.
A dedicated AppSourceCop rule has then been created to validate it, see [AS0100](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0100).

### Miscellaneous
* New timestamp format in Output window when starting and finishing compilation.
* Added support for generating profile files in the right-click context menu on snapshots, which was previously only possible through the Command Palette.
* Added CodeLens support for collected frames in the profiler.
* Improved profile generation performance.

### GitHub issues
- [#6888](https://github.com/microsoft/AL/issues/6888) Code 'UA' is not a valid ISO 3166-1 alpha-2 code
- [#6848](https://github.com/microsoft/AL/issues/6848) Analyzer throws Rule0242PartialRecordsDetectJitLoads exception

## Version 8.2

### Miscellaneous
* Added support for watch window evaluation of variables in the snapshot debugger.
* Fixed an issue where debugging OnPrem installations would fail if the Public Base Web URL was not set.
* Added hyperlinks for diagnostics. These can be seen in the problems panel, or when you hover over a squiggly line.

### GitHub issues
- Fixed Code Actions reported in [#6849](https://github.com/microsoft/AL/issues/6849) and [#6842](https://github.com/microsoft/AL/issues/6842)
- [#6844](https://github.com/microsoft/AL/issues/6844) Find Event crashes

## Version 8.1

### New AppSourceCop rules

Based on your feedback on Yammer, two AppSourceCop rules have been introduced:
- [AS0098](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0098) validates the use of affixes on report extension object members and on enum values defined in enum extensions.
- [AS0099](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0099) validates that the ID of fields defined in tables and the ID of values defined in enum extension is within the allowed range for extensions.

These rules are reported as Warning (AS0098) and Information (AS0099) to raise awareness regarding potential name and ID collisions in customer environments, but not complying with these rules will not fail your submission in AppSource.
### Bug fixes

#### Miscellaneous
* In certain scenarios involving loops the hit count was not computed correctly for the Profiler.
* Reference resolution has been optimized for scenarios with application references having non-existing secondary references in the package cache path.
* Built-in methods Import and Export for Blob type fields will be available only for OnPrem from runtime version 9.0.
* New overloads on the TestField and FieldError methods to include an ErrorInfo object to enable collecting errors.
* Fixed issue with feature "GenerateCaptions" where it wouldn't work for Page Captions.

#### GitHub issues
- [#6812](https://github.com/microsoft/AL/issues/6812) Publish Extension without building does not take into account EnvironmentName.
- [#6731](https://github.com/microsoft/AL/issues/6731) AppSourceCop AS0064: removing an obsoleted Interface in combination with public objects implementing that one is considered a breaking change.
- [#6786](https://github.com/microsoft/AL/issues/6786) Adding new attribute to the compilation options `continueBuildOnError` which specifies if build should continue even if errors are found. The default and recommended value from a performance point of view is `false`. It can also be passed to our CLI client using `continuebuildonerror [-/+]`.

# Business Central 2021 release wave 2

## Version 8.0

### Allowing the Name and Publisher of extensions to be changed

Extensions can now have their Name and Publisher properties changed between versions. To do this, the version of the extension must be increased, and the app ID must remain the same. Any other extensions that depend on the changed extension will compile against the new extension without any update necessary to the dependencies their app.json file. Downloading symbols will also fetch the changed version of the app.

Note: If you are using workspaces with multiple projects and change the name or publisher of an extension in the workspace, the dependencies in the app.json file must be updated with the new name and publisher or you may encounter issues with reference resolution.

Read more about [App Identity](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/devenv-app-identity)

Two AppSourceCop rules have been introduced in order to validate the changes done on the identity of extensions based on your current extension's runtime version:

- [AS0096](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0096) validates extension renames.
- [AS0097](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0097) validates publisher renames.

### Fully automated technical validation of AppSource submissions

From the 1st of October, the [technical validation](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/devenv-checklist-submission) of AppSource extensions will be fully automated. This means that the technical validation of your extensions will be also processed outside business hours of the technical validation team, including on weekends and holidays.

The validation results will be directly displayed in Partner Center. For extensions using Azure Application Insights telemetry (by using `applicationInsightsConnectionString` or `applicationInsightsKey` in their app.json), traces with detailed information are logged as part of the validation. For more information, see [Analyzing AppSource Submission Validation Trace Telemetry](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/administration/telemetry-appsource-submission-validation-trace).

Join the [AppSource yammer group](https://www.yammer.com/dynamicsnavdev/#/threads/inGroup?type=in_group&feedId=41498640384) for more information or questions about the AppSource validation process.

### Specify Synchronization Mode when installing or upgrading an extension

Using the built-in cmdlets targeting an on-premises installation of Business Central, you can now synchronize your extension in the same step as installing or upgrading it. Furthermore, you can clean your extension while uninstalling it. For more information, visit the [cmdlet documentation](https://learn.microsoft.com/powershell/business-central/overview?view=businesscentral-ps-19).

### Getting more control over availability of resources and source code and dynamically override the policy

We are listening to your ideas. Now, you have more control over availability of the resources and source code of an extension; by adding `resourceExposurePolicy` to the extension's manifest you can specify if the source code would be available for download, or if the source code can be debugged from other extensions. You can also control if the source code is included in the downloaded symbols.

Moreover, these values can be overridden for the users of a specific AAD tenant, even after the extension is published. In this way you can enable one or few of the properties for a period for the users of an AAD tenant.

Learn more about it here, [Resource Exposure Policy](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/devenv-security-settings-and-ip-protection)

### Support for profiling AL code

With the AL Profiler in Visual Studio Code you can investigate the time spent on AL execution in profiler views. Performance profiles are generated from snapshots taken using the AL:Generate profile file command. The resulted file can be opened with one of two editors showing the bottom-up, respectively the top-down graph. Once opened in one view it is possible to switch to the other view.
For more information, see [AL Profiler Overview](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/devenv-al-profiler-overview).

### Bug fixes

#### IntelliSense

- Added IntelliSense for change add symbols in RequestPages.
- Fixed IntelliSense suggestions the anchors of move and modify controls in Pages.

#### GitHub issues

- [#6659](https://github.com/microsoft/AL/issues/6659) Fixing the wrongly shown AppSourceCop rule errors about access property of fields within tables.
- [#12219](https://github.com/microsoft/ALAppExtensions/issues/12219) More verbose error message when you are trying to use an object that has been marked with Scope OnPrem and you are in a Clould extension.
- [#6648](https://github.com/microsoft/AL/issues/6648) Fixing the problem where you can't refer DataItem defined in ReportExtension in local procedure living in the same ReportExtension.
- [#6314](https://github.com/microsoft/AL/issues/6314) Fix the bad json produced by the compiler CLI when errorlog argument is added.
- [#6689](https://github.com/microsoft/AL/issues/6689) Fix the suggestion of the next ID for report extension.

More issues that we found through our internal testing and validation have been fixed. Mainly in the area of ReportExtension and Emit for different types. We have worked on making the ReportExtension object more mature and robust.

# Business Central 2021 release wave 1 update 3

## Version 7.4

### Property modification on report extensions

* Report extensions will now allow you to modify the RequestFilterFields and CalcFields properties of dataitems on the base report. These properties will be modified additively, adding to any fields that were specified in the base report. [#6704](https://github.com/microsoft/AL/issues/6704).

```al
reportextension 50100 MyReportExtension extends MyReport
{
    dataset
    {
        modify(BaseDataItem)
        {
            RequestFilterFields = Field1, Field2;
            CalcFields = Field3, Field2;
        }
    }
}
```

### Fixes of code emitting issues

* We fixed an issue that causes the compilation to fail when using complex types as a return value from Case statements [#6679](https://github.com/microsoft/AL/issues/6679).
* Protected variables declared in base application objects are now accessible from their extension in source and property expressions [#6711](https://github.com/microsoft/AL/issues/6711).
* Using certain system functions in expressions would produce invalid code.
* Emitting user controls for request pages in reports and report extensions.
* Fixing how arrays of JsonObject are initialized [#6279](https://github.com/microsoft/AL/issues/6279).

### Allowing Record.Copy(FromRecord: Record)

This allows to you to copy temporary records returned from a procedure [#6695](https://github.com/microsoft/AL/issues/6695).

```al
procedure CopyTemporaryRecord()
    var
        bufferProvider: Codeunit BufferProvider;
        buffer: Record Buffer temporary;
    begin
        buffer.Copy(BufferProvider.GetBuffer(),true);
    end;
```

where GetBuffer has the following signature:

```al
procedure GetBuffer() buffer: Record Buffer temporary
```

### AppSourceCop Improvements

* We fixed an exception that was thrown when validating procedure breaking changes for extensions targeting a runtime version lower than 7.0.
* The rule [AS0025](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0025) only allowed to add a new parameter in last position of the parameter list for local events. Adding a parameter in any other position triggered a diagnostic. This has been fixed and it is now possible to add a new parameter in any position.

Note that from the 3rd of August, the [technical validation](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-checklist-submission) of AppSource extensions enforces the analyzer rules around procedure breaking changes (rules AS0018 to AS0028) in order to provide a better experience for our customers in SaaS.

### Miscellaneous bug fixes

* Fixing the CLI client of the compiler to not produce broken xml format when generating .dgml file [#6639](https://github.com/microsoft/AL/issues/6639).
* Validating the path passed to WordLayout and RDLCLayout properties. Validating whether the path is relative to the root of the project [#6359](https://github.com/microsoft/AL/issues/6359).
* Extensions to a request page that used InDataSet variables were not being registered, causing a runtime error. [#6359](https://github.com/microsoft/AL/issues/6359).
* Request pages that were using variables on the parent report in some properties were not working unless the InDataSet attribute was specified on the variable. [#5623](https://github.com/microsoft/AL/issues/5623).

Note that from version 8.0 warning AL0613, reported for invalid trigger signatures, will be turned into an error.


## Version 7.3

For this update there is one new feature and bug fixes in several areas.

### Application Insights connection string
The new app.json property `applicationInsightsConnectionString` allows you to specify the full connection string provided in your Azure Application Insights dashboard. The previously introduced `applicationInsightsKey` is still supported, we do, however recommend using `applicationInsightsConnectionString` in new projects.

### Fixes of code emitting issues
* Procedures can now be invoked within DataSource expressions in columns in Reports and Pages.
* [#6235](https://github.com/microsoft/al/issues/6235). Protected members of one extension object are now accessible by other extensions objects.

### Validating keys in table extensions
[#6680](https://github.com/microsoft/al/issues/6680). Validating if a field added to a key is not obsolate and also limiting the number of fields that can be added to a field.

### Validating trigger signatures
We now report warnings for all invalid trigger signatures. From Version 8.0 all these trigger signature warnings will turn into errors, because invalid trigger signatures may cause runtime errors.

# Business Central 2021 release wave 1 update 2
## Version 7.2

### 'Generate Captions' feature changes
The feature flag 'GenerateCaptions' would generate trans-units in the template translation file for procedures in codeunits. That is not the case any more. If you want that for your web service metadata then add the Caption attribute to the procedure.

# Business Central 2021 release wave 1 update 1
## Version 7.1
For this update there are bug fixes and changes around a few different areas.

### Snapshot debugging
Snapshot debugging allows recording built-in codeunit based stack traces if there is a snappoint defined in the al file containing the subscription to the built-in code unit trigger event.

### Reports extensions
* Parameters and captions are now supported report layouts in report extensions
* Debugging supported added for report extension
* Added support for modify on dataitems with a set of triggers to go along with it.
* There were a couple of issues around adding dataitems into the correct position, which caused layouts to not work correctly.
* The checks for duplicate usage of identical names did not catch all cases.

### Built-in functions and types
* [#6568](https://github.com/microsoft/al/issues/6568). The deprecation warning has been removed from UploadIntoStream
* [#6570](https://github.com/microsoft/al/issues/6570). The type ModuleInfo now contains a PackageId.
* If the StartSession with the timeout was to be used, it required a record and company. That has been changed so they are not required.

### Go to Definition
* When a package has ShowMyCode set to false, then the editor will show a generated view from the symbol information available. That has been improved to include more objects.


# Business Central 2021 release wave 1 update
## Version 7.0.0
### Report Extensibility
We have introduced `reportextension` objects to the language that allows extension of report objects. Some of the operations that can be performed are:
* Adding new dataitems to the base report's dataset
* Adding new columns to a base report's dataitem
* Extending the request page (e.g. adding new fields)
* Defining additional report triggers
* Defining additional request page triggers
* Defining additional layouts that will be made available for the base report
Use the `treportextension` snippet to get started!

### Return complex types from methods
We now allow complex types to be returned from methods. This includes user-defined types like codeunits and records, but also most built-in types. The syntax is similar to variable/parameter declarations.

```
procedure GetCustomerByName(Name: Text) Customer: record Customer;
begin
end;

procedure GetHttpClient(): HttpClient;
begin
end;
```

### Permission sets and permission set extensions
With this release we now support defining permission sets in AL objects. Among the benefits are
* Deployed as metadata and hence easy to update
* Easy to read source format
* Support for IntelliSense, comments, navigation, and diagnostics

The new permission set objects are extensible. An existing permission set can be extended with additional permissions to easily grant more access to users that already are assigned the permission set.

Use the `tpermissionset` or `tpermissionsetextension` snippet to get started!

### OnAfterLookup trigger
We have added a new trigger on page fields with `TableRelation` properties to support scenarios where you in code want to set others fields based on the selected record.

```AL
field(ItemNo; Rec.No)
{
    trigger OnAfterLookup(Selected: RecordRef)
    var
        Item: record Item;
    begin
        Selected.SetTable(Item);
        Rec.Description := Item.Description;
    end;
}
field(ItemDescription; Rec.Description)
{
    TableRelation = Item.Description;

    trigger OnAfterLookup(Selected: RecordRef)
    var
        Item: record Item;
    begin
        Selected.SetTable(Item);
        Rec.ItemNo := Item."No.";
    end;
}
```

The OnAfterLookup trigger supports split-relations.

### Interface Obsoletion
Interfaces can now be obsoleted using `ObsoleteState`, `ObsoleteReason`, and `ObsoleteTag`.
For interface procedures, the obsolete reason and tag can be specified in the `Obsolete` attribute: `[Obsolete(<Reason>,<tag>)]`

### Support for Access Property on Enums and Interfaces.
It is now possible to mark Enums and Interfaces as `internal` to a module.

### Control if locked labels should generate translation entries
When the "TranslationFile" setting is enabled, a template file with labels that can be sent for translation is generated. In previous versions, labels marked with `Locked = true` would be included in the template file, but marked so that they would be excluded from translation. With this change, these entries will no longer, by default, be included. If the flag `GenerateLockedTranslations` is added to the feature list in the app.json file, however, these entries are generated.

### Added cross-reference information generation
Compiling from the command line using the /generatecrossreferences or /xref option generates DGML and JSON files containing a serialized representation of the cross-reference graph.
DGML files can be loaded in Visual Studio for advanced visualizations and manipulation using the Code Map feature.

### Added IntelliSense to Control Add-in script files
IntelliSense is now available in JavaScript files for the global `Microsoft.Dynamics.NAV` object making it easier to explore the Control Add-in API and use methods such as `InvokeExtensibilityMethod`, `GetImageResource`, and `GetEnvironment`.
This behavior can be turned off by changing the setting `al.enableScriptIntelliSense` to `false`.

### Improvements to the AppSourceCop analyzer

As a continuation of the previous releases, we improved existing AppSourceCop code analyzer rules based on partner feedback and added new ones covering additional scenarios. More information can be found in our [online documentation](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop). We also introduced a new configuration setting to specify a dedicated folder for the baseline packages to be used for breaking changes validation. For more information, see [AS0003](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0003) and [AS0091](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0091).

# Business Central 2020 release wave 2 update 5
## Version 6.5
### Bugs fixed
* Fixed an issue which caused some labels and captions to not be translated in a dedicated language extension.
* Error "Constant value XXX is outside of the valid ordinal range for this Enum type" is no longer thrown when using an extended enum field with ValuesAllowed property.

# Business Central 2020 release wave 2 update 4
## Version 6.4
### Bugs fixed
* Add a message to sandbox publishing that extensions which have been published from Visual Studio Code are removed when the environment is updated or relocated within our service.
* Set compatibility for NavigationPageId and Multiplicity to 6.3. Github issue: https://github.com/microsoft/AL/issues/6436
* Use DropDown instead of Dropdown. Github issue: https://github.com/microsoft/AL/issues/6428
* Interface implementation validation sometimes falsely logs an error if a member is already implemented.
* Use of obsolete page variables are not showing warnings when used as variables.
* Full diagnostics are sometimes not reported when .NET types are included.
* Fixed report column decimal places format. Github issue: https://github.com/microsoft/AL/issues/5880
* Fix compatibility definition of certain properties. Github issue: https://github.com/microsoft/AL/issues/6368
* Fixed naming of XMLPort. https://github.com/microsoft/AL/issues/6304
* Add equivalence between Visual Studio Code 'Start Debugging' command and al.publish, respectively 'Run without Debugging' command and al.publishNoDebug command.
* 'Trigger Parameter Hint' (Ctrl+Shift+Space) command is not working. Github issue: https://github.com/microsoft/AL/issues/6379
* Support for variables larger then 1 Kb on the debug console.

# Business Central 2020 release wave 2 update
## Version 6.0.0
### SnapshotDebugger
We have introduced the ability to record AL execution on a Business Central server, also called snapshot debugging. To do snapshot debugging, you must be a delegated admin and part of the "D365 Snapshot Debug" permission group. When the AL execution has ended, you can download the recorded snapshot file and debug it with the new snapshot debugger in Visual Studio Code.
F7 will initialize a snapshot debugging session, Shift+F7 provides status such as when the end-user connects to the Business Central server using the client and then if a snapshot debugging request was saved for that user, the user's AL code in the specific client session will be recorded, and Alt+F7 ends snapshot debugging on the Business Central server and produces a debuggable snapshot file.
In connection with this addition, please note that the existing “al.downloadsource” command for F7 has been remapped to Alt+F6.

### Debugging Upgrade and Install code
It is now possible to debug upgrade and install codeunits. A new command "Publish extension without building" has been introduced that will allow for apps to be published while debugging. To debug upgrade or install code, first initiate an attach debug session. After the debugger has attached, invoke the new command or use Ctrl+F5 to publish the app file. If the version of the app has not been incremented, install codeunits will be invoked. If the version of the app has been incremented, or the `forceUpgrade` flag has been set to `true` in the `launch.json` file, upgrade codeunits will be invoked.

### Indication of overloads in IntelliSense.
IntelliSense now includes the number of additional overloads together with the signature of the first method. Selecting the method allows you to browse through the different overloads.

### Global warning suppression from app.json and the alc command-line
Warnings can be suppressed globally using the "suppressWarnings" option in the app.json file. The option takes a list of warning IDs as argument.

```
"suppressWarnings": [ "AL0604", "AA0215" ]
```
We also support global warning suppression from the alc command-line using the the /nowarn switch.

### Captions for OData
With this release we have added a new attribute Caption that can be applied to procedures that are ServiceEnabled or defined in an API page. It makes it possible to provide translations in the OData metadata for procedures. Furthermore, we have added two new properties EntityCaption and EntitySetCaption that enable providing different translations for entities.

### Documentation Comments
With this release we support documentation comments for AL similar to C#. Documentation comments are structured comments preceded with a three slashes (///) instead of the usual two slashes (//). The documentation comment a special syntax that contains XML text. The documentation comment must immediately precede a user-defined type that it annotates, for example a codeunit, table, or interface, or a member such as a field or method.
There is IntelliSense support for writing documentation comments. Most importantly providing a template documentation comment when writing the third slash in the triple slash.
Documentation comments are visible when hovering over source symbols, in completion lists, and in signature help.
Improve your source code by adding documentation comments.

### Preprocessor directives
AL now supports three types of preprocessor directives
* Conditional directives (conditional compilation)
* Regions (expand/collapse regions of code)
* Pragmas (disable/enable warnings and implicitwith)

### Improvements to the AppSourceCop and its documentation

Since the release of Business Central 2020 release wave 1, we have been working on the AppSourceCop code analyzer. We gathered the feedback we received on existing rules in order to improve them and create a more reliable experience. We have also added new rules covering aspects that were previously missing and improved our [online documentation](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop) to be contain more examples and actionable information.

# Business Central 2020 release wave 1 update
## Version 5.0.0
### AL Interfaces
We have introduced the interface concept in AL which allows developers to apply polymorphism and code against abstraction. Codeunits can implement multiple interfaces by adding the ´implements´ keyword and a list of all the implemented interfaces to the codeunit declaration. IntelliSense suggests you a list of available interfaces. We have added a code action which adds the missing members of an interface to the implementer codeunit.
We also introduced AppSourceCop rules to detect any breaking changes. Adding, deleting, or modifying a procedure in an interface might break the implementers of your interface. AppSourceCop generates an appropriate error for each case.

### Enum implements interfaces
We have added interface support to enums where an enum can implement multiple interfaces and set a default implementer codeunit for each of them. An enum value assigned to an interface variable can initialize the interface.

### Debugger changes
We have added support to view values of Lists and Dictionaries in the debugger.
We have simplified the evaluation of array index expressions in a watch window. Until now the NAV debugger evaluation syntax was used in a watch window for an array index expression, like array."[1]" . Now array[1] would also evaluate.
We have extended the support on hovering for evaluation when debugging. Both parts of a simple non-composed member access expression would evalute. We also
support hovering on quoted identifiers.
An example is when hovering on "My Customer Rec" and also "No." would evaluate on an expression like "My Customer Rec"."No."

### Workspace changes
We have added support for goto definition when multiple launch configurations are defined for a project. A new (per workspace folder) setting is defined called
al.defaultConfigurationName which is going to be used to resolve the server name in scenarios that involve multiple configurations and the need to request information from a server.
We have fixed the issue that Al projects cannot coexist with other project types in a workspace.

### Specifiying the data access intent of objects

You can now choose to run selected reports, queries, and web service calls on a read-only replica of the database. This way, analytical workloads will not have any impact on the primary database.

The Page, Report, and Query objects now have a property called `DataAccessIntent` that can take the values `ReadOnly` or `ReadWrite`. This property works as a hint for the server, which will connect to the secondary replica if possible. When a workload is executed against the replica, insert/delete/modify operations are not possible for ReadOnly objects.

### Object obsoletion tag

On top of the `ObsoleteState` and `ObsoleteReason` properties, it is now possible to specify an additional free-form text to support tracking of where and when the object was marked as obsolete, for example, branch, build, or date of obsoleting the object. This can be done through the `ObsoleteTag` property on AL objects.
For procedures and variables, the obsolete tag can be specified as an optional parameter in the `Obsolete` attribute: `[Obsolete(<Reason>,<tag>)]`.

### Select the intial state of repeater controls displayed as trees

We introduced the ability to specify the initial state of the records in repeater controls displayed as a tree structure in the web client by using the `TreeInitialState` property.
They can now be either fully expanded (`ExpandAll`) or fully collapsed (`CollapseAll`). This property can be modified in the web client and changes can be persisted using the designer.

### Declare multiple variables in the same declaration

Variable declarations of the same type can now be a comma-separated list of variable names. This improves readability of the code by allowing variables of the to be grouped together and thereby reducing the number of lines.

### New tool to generate CDS/CRM proxy tables

We have added a new command-line tool `altpgen.exe` to generate .al proxy tables for CDS/CRM. This tool replaces the `New-NAVCrmTable` powershell cmdlet. The new tool and the runtime supports extending an existing CDS/CRM table with additional fields through a tableextension.

### .NET Core runtime
With this release, we have switched from running the language server on the .NET Framework runtime to running it on the .NET Core 3.0 runtime.
This switch has allowed us to take advantage of the many [performance improvements made in .NET Core 3.0](https://devblogs.microsoft.com/dotnet/performance-improvements-in-net-core-3-0/) and has resulted in drastically improving the compilation time.
You can fallback to the legacy .NET Framework runtime by setting `al.useLegacyRuntime` to `true`. You must restart Visual Studio Code before the option will take effect.

### Support for "application" reference
You can now use the `application` property in your extension's manifest to express a dependency on an extension called `Application`. This allows you to remove direct dependencies on Microsoft's `Base Application` and "System Application" and to enable your extension to compile against any extension called `Application`.

### Support for propagated dependencies
You can use the `propagatedDependencies` manifest option to specify whether the dependencies of this project should be propagated as direct dependencies of projects that depend on this one. Default is false. If set to true then any dependencies of the current package will be visible to consumers of the package. For example, if A depends on B that depends on C, by default, A will not be able to use types defined in C. If B has "propagateDependencies" : "true", then A will be able to use types defined in C without taking a direct dependency.

### Fine-tune the behavior of the language server
The AL compiler and language server provide, by default, multiple productivity features such as background compilation, IntelliSense, Go to Definition, Find All References, and much more. All these features require additional computational resources and they can be especially taxing when working on very large projects.
We have added the following options to fine-tune the behavior of the language server:
```
"al.compilationOptions": {
        "parallel": true,
        "delayAfterLastDocumentChange": 800,
        "delayAfterLastProjectChange": 4000,
        "maxDegreeOfParallelism": 2
}
```

By default, the language server uses as many threads as the system allows to compile your solution. You can also control the number of threads that the language server uses by using the option `al.compilationOptions.maxDegreeOfParallelism`. Setting this to a higher value will use a higher number of threads, while lower values will use a lower number of threads.
By setting the `al.compilationOptions.parallel` option to `false` you will instruct the language server to use a single thread.
The `al.compilationOptions.delayAfterLastDocumentChange` and `al.compilationOptions.delayAfterLastProjectChange` options can be used to trade-off compiler responsiveness for resource consumption. Setting these options to higher values will increase the delay between when a change is made in Visual Studio Code and when the compiler processes it while reducing resource consumption.

### Launch queries from Visual Studio Code
You can now run queries when you publish an AL project (F5 and Ctrl+F5) from Visual Studio Code. Simply modify the launch.json file of the project to include the `"startupObjectType" = "query"` and `"startupObjectId" = "<QueryID>"` settings, replacing <QueryID> with the ID of the query that you want to run.

### Support for Microsoft Edge Beta
We have added support for launching the Microsoft Dynamics 365 Business Central Web Client in the Microsoft Edge Beta internet browser from Visual Studio Code.
This feature can be enabled by setting `al.browser` to `EdgeBeta` in your settings.

# Business Central 2019 release wave 2 update

## Version 4.0.0

Welcome to version 4.0.0! We are finally out of the Developer Preview stage, and this comes with a lot of new features.

### AL:Go! Version Selection

The AL:Go! command now allows you to choose which version of Business Central you wish to target. Because Business Central 4.0 comes with changes in how the Base Application is structured, AL:Go! seamlessly takes care of setting up the correct dependencies for extension development based on your target environment.

### Access Modifiers

We have added access modifiers to the AL language. Access modifiers can be used to specify access to language elements to facilitate encapsulation.

- Codeunits, Tables, and Queries can be marked as internal to the extension by specifying `Access = Internal` property.
- Procedures can now also be marked as internal or protected similar to the existing local keyword.
- Global variables can be marked as protected.
- Table fields can be marked as internal, protected, or local.

The different access modifiers are defined as:

- `Public` is accessible to all.
- `Internal` is only accessible from within the same extension.
- `Protected` is only accessible within the defining object and object extensions to the same object.
- `local` is only accessible from within the same object.

It is possible to grant access to internals to referencing extensions by specifying them in the internalVisibleTo section of the app.json file.

### Object Obsoletion

We have added the capability to mark most objects and members for obsoletion. The following can be made obsolete by specifying the `ObsoleteState = Pending` property. Optionally, the `ObsoleteReason = 'Reason'` property can also be specified to provide a more detailed warning message to users of the object.

- Codeunit
- Enum
- EnumValue
- Page
- PageAction
- PageActionArea
- PageActionGroup
- PageActionSeparator
- PageArea
- PageChartPart
- PageField
- PageGroup
- PageLabel
- PagePart
- PageSystemPart
- Query
- QueryColumn
- QueryDataItem
- QueryFilter
- Report
- ReportColumn
- ReportDataItem
- RequestPage
- XmlPort

The following can also be made obsolete by specifying the `[Obsolete(<Reason>)]` attribute:

- Procedure
- Variable

If an object marked for obsoletion is used, this will trigger a compiler warning that specifies the reason for obsoletion (if provided).

### Multiple sandboxes

Sometimes a single sandbox isn't enough, so with the opportunity to create sandboxes it is now possible in the launch.json file to specify which sandbox the extension should be installed to, simply by adding the parameter "SandboxName".

### Translate other extensions using Xliff

Translating objects outside the extension was possible before using .txt files but the support for that has been removed in favor of using Xliff files.
Take the generated xliff file of the extension that you want to change and translate it.
In the root of the extension, create a directory named "Translations" and place the translated xliff there.
Now publish the extension and make sure to change the language in 'My Settings' to see the new translations in the UI.

### Working in a workspace with projects and project references
We have added support for working with project references within a work space and also the ability to publish sets of changed projects that are in a dependency relation within a work space.
A project reference in a work space is a project that is defined as a dependency in the app.json file for a given project.
No UI semantics are presented for a project reference, like in Visual Studio. There is no need to download symbols to reolve project references.
They will be resolved from within the work space. Example: Assuming that one works with a Test project referencing a base project, if one adds a method to Base it should be immediately seen in TestProject(s).
One does not need to build the base for this.
Publishing within Visual Studio Code has also changed a lot. We now have the possibility to publish changed dependency sets. Dependency sets are packaged in *.dep files. We consider a project changed if it is RAD changed; meaning that a project is considered changed if it has at least one application object that is part of the RAD file or will be part of the RAD file, had it been built. When a publishing operation is requested all changed projects within a dependency set are published. Example if you work in a TestProject and change TestProject and then change Base then both will be packaged and published. RAD publishing obeys dependency set publishing. In the scenario above if you RAD publish TestProject with Base changed both will be RAD published.

### Attaching to the next BC session
We have added support to attach to the next BC session from Visual Studio Code.
We support attaching to a web client, background, and web API sessions for on-premise deployments and only web API for sandbox-based deployments. We also support debugging the new async page background tasks.
In order to get started one needs to first create an attach configuration. We have created two predefined templates that can be chosen from, one to create an attach configuration for sandboxes, and one for on-premise.
The attach configuration contains a breakOnNext enum that will determine which next client session the debugger will attempt to attach to. Pressing F5 will start an attach debugging session, if an attach configuration is selected. The first session type that has been specified in the breakOnNext enum will break on the breakpoints specified in Visual Studio Code. Only the user who has started an attach session in Visual Studio Code can later be attached to a session executing on the server.

### New profile capabilities

We introduced new properties on profiles to support translating them in AL. You can now use the properties Caption/CaptionML to specify a user-friendly name for the profile and use Description/DescriptionML to add some more information about the profile.

You can also decide whether your profile is by default proposed to end-users in 'My Settings' using the `Enabled` property and whether it should contribute to the Role Explorer by setting the `Promoted` property.

Discover the new profile capabilities by using the snippet `tprofile`.

### Improving the Navigation bar of your Role Center

It is now possible to extend the navigation bar of your profile's Role Center from page customizations. This is done by adding a new actions in the Sections or Embedding area of the page customization applied on your Role Center.

```
profile MyProfile
{
    Caption = 'My Business Manager Profile';
    RoleCenter = "Business Manager";
    Customizations = MyRoleCenterCustomization';
}

pagecustomization MyRoleCenterCustomization customizes "Business Manager"
{
    actions
    {
        addfirst(Embedding)
        {
            action(NewNavigationAction)
            {
                RunObject = page MyNewPage;
            }
        }
    }
}
```

While it was only possible to run List Pages from the actions defined in the Navigation bar, it is now also possible to run any type of Pages, Codeunits, Reports, and XmlPorts.

### SharedLayout for Views

As part of the April ‘19 release, we introduced a new model for creating page views, offering a simple way to define alternative views of list pages using filtering and sorting of the records, but also layout changes.

In order to offer more flexibility and design different experiences for end-users, it is now possible to specify whether a view shares the same layout than the base page or defines its own layout.

By setting the `SharedLayout` property of your view to true, your view follows the layout of the base page (`All`, in the web client) and any user personalization made on `All` or any of the views marked with SharedLayout are applied on the view.

On the other hand, by setting the `SharedLayout` property to false, the view defines its own layout and is independent from all other views. The view is detached. Any changes coded in the layout sections are applied in the view. User personalization made on the page are not applied on that view.

You can get snippets for both types of views by writing `tview`.

### Upgrade DEV extensions from VS Code

As part of this release, it's now possible to upgrade your developer extensions from Visual Studio Code. If you have an extension installed with version `1.0.0.0` and publish another version of this extension where the version is higher than `1.0.0.0`, the extension will be upgraded. This allows you to test your upgrade procedures using the developer endpoint, and gives you a faster feedback loop for testing your extension compared to, for example, testing upgrade through the management client. The extension upgrade will only be triggered if you don't use schema update mode `Recreate`. If you use `Recreate`, your old extension will be uninstalled and your new one will be installed.

### Symbol Searching now supports searching by ID

When using `Ctrl+T` in Visual Studio Code with the `#` character prefix, you can now search for objects by their ID in your AL projects. This enables you to faster navigate your codebase and hopefully will increase your productivity when developing AL extensions.


# Business Central April ‘19 update (2019/04)

## February 2019 update
Welcome to the February edition of the Developer Preview. The biggest announcement this month is that we are publishing a preview of the base application fully on AL language.

There is a new Docker image, which contains this version here: `bcinsider.azurecr.io/bcsandbox-master:14.0.28630.0-al`. Currently this image is not automatically refreshed. We will manually push new images with the country code `al` (and new version number) until we have a process in place to do this for all country codes. If you do not have bcinsider credentials, please reach out to dyn365bep@microsoft.com. Please note that:
- The upcoming April ‘19 2019 release of Business Central is still based on C/AL and C/SIDE, as communicated at Directions Fall 2018 and other events. This means that, just like now, on-premise code customization is done in C/AL and C/SIDE, whereas extensions for on-prem or SaaS are authored in AL and Visual Studio Code.
- The AL Docker Preview is exactly that, a peek into the future.
- The fact that the AL preview image has version 14.0 is just because the preview is an auto-generated AL version of the C/AL master code repository for the upcoming C/AL April ‘19 release which is version 14. Once we have branched internally for April ‘19, future AL preview images will be version 15. There will not be an official AL version of the application for the April ‘19 release.

Having the base application fully converted to AL means that it is one big extension with almost 6000 files. To make it easier to work with such a big extension we've developed a series of features.

### Rapid Application Development (RAD)

RAD is a C/SIDE term used for changing an application object, compiling it, and seeing the results instantaneously in the client.

We have tried to replicate a similar experience for extension development in AL Language in VS Code. More specifically it is about publishing only the AL objects that changed since the last full publish took place. This is especially useful when working on large projects with several thousands of objects.

We will use the terms "incremental publish" and "RAD publish" or just "RAD" interchangeably.
We have introduced two new commands for doing incremental publishing/debugging. These are:
- **Ctrl+Alt+F5** for incremental publish
- **Alt+F5** for incremental publish and invoking debugging

Please note that:
- You need an app to be fully published at least once before you can use incremental publish for the same app.
- You cannot change the version, publisher, and name of the app if you do an incremental publish
- If things fail for incremental publishing you would need to do a full publishing (Ctrl+F5) before using the RAD features again.
- A tracking file (rad.json) that captures which files have changed for the purposes of incremental build and publish is created and updated on any developer action that involves a build process for anything that involves a build (not Save and this is by design), like build (Ctrl+Shift+B), or any of the deployment or debugging tasks.
- A RAD published file will not contain the following files that are normally packaged during regular publishing:
    - translation files,
    - permissions files,
    - custom word and report rdlc layout files,
    - table data, and
    - web service definition.
- RAD does not replace full publishing.

### New schema update mode - ForceSync
In this release we've added a new data schema synchronization mode. It’s very similar to the existing ‘Synchronize’ schema update mode but with more freedom to make schema changes while retaining data:
- In the launch.json file, set the parameter `schemaUpdateMode` to `ForceSync`
- Keep your current  app version
- Iterate knowing the sync process will let you do everything while preserving data in all of your unchanged tables and fields

Data will be preserved in almost all cases. The only exception is changing the main table's Primary Key in which case the data from the extension tables will be lost.

Field renames are allowed and supported in this mode, but the data can only be preserved if you maintain the same ID. If you change both the name and the ID of the field than data will be lost.

Please note that this schema update mode is only meant for testing/development and should never be used in production.

The new mode is exposed both through the `schemaUpdateMode` setting in launch.json in VS Code as well as through the powershell cmdlet (`Sync-NavApp –Mode ForceSync`).

### Debug without publishing
A new command has been added - Ctrl+Shift+F5 - which will start the debugger attached to the Visual Studio Code launched client session.

Please be aware that if you start debugging without publishing you will be debugging the last published code of your app.

Firefox has also been added to the list of supported browsers that will open a client for a VS Code debugging session.

### Debugger info for HTTP, JSON etc

![Debugger Objects](https://community.dynamics.com/cfs-file/__key/communityserver-blogs-components-weblogfiles/00-00-00-16-25/DebuggerObjects.png)

Variable value inspection has been added for:
- HttpClient, HttpRequestMessage, HttpResponseMessage, HttpHeaders
- JsonValue, JsonToken, JsonObject, JsonArray
- XmlElement, XmlDocument, XmlNode, XmlText, XmlComment, XmlCData, XmlAttribute

### Code actions
Code Actions is a VS Code feature providing the user with possible corrective actions right next to an error or warning. If actions are available, a light bulb appears next to the error or warning. When the user clicks the light bulb (or presses Ctrl+.), a list of available Code Actions is presented. We introduced the extensible framework to provide the actions feature support in AL. There are two code actions available in the current version:
- Multiple IF to CASE converting code action
- Spell check code action.

### TableRelation extensibility
The TableRelation property on table fields can now be modifed in a table extension. The modifications to the TableRelation is additive and are evaluated after the existing value. The primary use case is conditional table relations based on conditional enums. For example, in one app a table is defined like below:

```
enum 50120 TypeEnum
{
    Extensible = true;

    value(0; Nothing) { }
    value(1; Customer) { }
    value(2; Item) { }
}


table 50120 TableWithRelation
{

    fields
    {

        field(1; Id; Integer) { }
        field(2; Type; enum TypeEnum) { }
        field(3; Relation; Code[20])
        {

            TableRelation =
            if (Type = const (Customer)) Customer
            else if (Type = const (Item)) Item;
        }

    }
}
```

Another app could then extend both the enum and modify the table relation to also handle the extended enum with the code below:

```
enumextension 50133 TypeEnumExt extends TypeEnum
{
    value(10; Resource) { }
}



tableextension 50135 TableWithRelationExt extends TableWithRelation
{
    fields
    {

        modify(Relation)
        {
            TableRelation = if (Type = const (Resource)) Resource;
        }
    }
}
```

The combined table relation is evaluated top-down. That means that the first unconditional relation will prevail, i.e. you cannot change an existing TableRelation from Customer to Item, since the original table relation is unconditional.

### Views
Views offer a way to improve user productivity when working with list pages by proposing an alternative view of the page that contains:
- Filtering of the data on multiple table fields.
- Sorting of the data on multiple table fields (but only in one direction: ascending/descending).
- Layout changes in the Content area: modifying page columns, moving them, etc.

#### Defining views in AL
Unlike V1 views which were defined as part of the RoleCenter, V2 views in AL are now defined on the list page itself.  Views are defined in a dedicated views section that contains an ordered list of views.

Note:  You can use IntelliSense and the `tview` snippet in order to help you get started!

![Views](https://community.dynamics.com/cfs-file/__key/communityserver-blogs-components-weblogfiles/00-00-00-16-25/views_5F00_1.png)

Views are also integrated in the extension model. It is then possible to create, re-order, or modify views in a page extension or in a page customization. With the version, you get the development story for creating views, later the end-user will be able to create views using Designer.

![View](https://community.dynamics.com/cfs-file/__key/communityserver-blogs-components-weblogfiles/00-00-00-16-25/view_5F00_2.png)

#### Filtering and sorting
Filtering in views is achieved by using the new property Filters. The property syntax is similar to the other properties you can use to apply filtering on a page in AL (like SourceTableView on a page, or RunPageView on an action).

The syntax is composed of a where clause with a list of filters defined with a filter name, the equal sign, the type of filter and the filter value to be applied:

![Syntax filters](https://community.dynamics.com/cfs-file/__key/communityserver-blogs-components-weblogfiles/00-00-00-16-25/syntax_5F00_filters.png)

#### Ordering
Ordering is achieved by using the property OrderBy. The property syntax is similar to the OrderBy property that exists on a Query. It is used to specify one sorting direction on a set of table fields. Currently the language allows you to specify only one sorting direction.

![Syntax order by](https://community.dynamics.com/cfs-file/__key/communityserver-blogs-components-weblogfiles/00-00-00-16-25/syntax_5F00_orderby.png)

Note: The filters are applied on the table fields, not on the page fields. It is then possible to filter on a table field even if this table field is not shown in the page. However, if a page field has a variable as a source expression, it is not possible to use it.

#### Modifying the page layout
Views enable you to modify properties on page controls from the control area and/or moving them.

Views can be seen as a page customization embedded at the page level and that is triggered when pressed in the UI. As a consequence, the capabilities (but also the limitations) of a view are similar the ones of a page customization:
- It is not possible to create new controls for a page from a view.
- The control properties that are modifiable in a view are the same ones as the properties that are modifiable in a page customization independently of where the view has been defined (page, page extension, or page customization level).
- It is not possible to use variables or methods in a view. When writing client side expression for properties like Visibility, it will only be possible to use constant values or table field references.

#### Modifying views from extensions/customizations
Like action and controls, views can be moved using the moveafter, movefirst, movelast and movebefore constructs. It is also possible to modify the visibility of a view and to modify its caption. Those are the only two properties that are available for modification from extensions in a view. If a developer wants to modify a view's filter, the advised approach is for him to create his own copy of the view.

When modifying views from extensions, IntelliSense can also help you to know what you can do or not.

![IntelliSense](https://community.dynamics.com/cfs-file/__key/communityserver-blogs-components-weblogfiles/00-00-00-16-25/intelli_5F00_views.png)

#### Visualizing Views in the Web client
V2 views are rendered below any V1 views in the filter pane of the Web client. They are always visible on the view page no matter how the page was accessed.

![Views in client](https://community.dynamics.com/cfs-file/__key/communityserver-blogs-components-weblogfiles/00-00-00-16-25/views_5F00_in_5F00_client.png)

### AllObj and AllObjWithCaption no longer contains obsolete Tables
The `AllObj` and `AllObjWithCaption` virtual tables no longer contains obsolete tables.

### Context Sensitive Help

It is now possible to define help links for new created Pages, Reports / XmlPorts in a more maintainable way using two new properties.

The first one , `contextSensitiveHelpUrl`, is a manifest property which defines the base URL to be used for all pages and request pages of the extension. The other one, `contextSensitiveHelpPage`, is defined on the object level and sepcifies the exact documentation resource to use. In case, the contextSensitiveHelpPage is not defined, the contextSensitiveHelpUrl will be used as default.

Example:

```
  "contextSensitiveHelpUrl": "https://www.mydocumentationwebsite.com/{0}/business-central/",
  "supportedLocales": [
       "da-DK"
  ]
```

```
page 50100 MyPage
{
    ContextSensitiveHelpPage = 'help-topic';
}
```

The help link for the page MyPage will then be: `https://www.mydocumentationwebsite.com/{0}/business-central/help-topic`.

This new feature also enables you to define specific help links for new controls added in a page extension:

```
pageextension 50100 MyPageExtension extends "Customer Card"
{
    ContextSensitiveHelpPage = 'about-extension';

    layout
    {
        field(MyField; 'New field') { }
    }
}
```

## December 2018 update
This December marks the two year anniversary of the very first AL Developer preview back in December 2016. And we want to use this opportunity to say "Thank you!" to all the partners that have dived into AL, installed the Visual Studio Code, and AL Language tools. We are now at 47K downloads, and an impressive 20K installs and the numbers keep growing. Thank you for providing us with feedback on GitHub, submitting Ideas, bugs, as well as enhancements to make the product even better. Some of your suggestions have already shipped in the product.

With this December preview we are mainly releasing bug fixes (closed bugs in December), as the whole team is working hard on the process of converting the base application to AL, improving tools performance when working with large projects and building the infrastructure pieces allowing us to eventually switch to working in AL on W1 and country/region versions of the base application. We still have a couple of new features, though, read more about these below.

We have lots of exciting news to come in the next year, so we encourage you to keep up the work and continue providing feedback. Please do, however, notice the recent change of feedback channels described here: https://community.dynamics.com/business/b/financials/archive/2018/12/04/find-the-right-resources-and-provide-feedback. To recap, the AL GitHub from now on only accepts bug reports related directly to AL and developer tools for Business Central insider builds. Bugs for shipped versions should go through support. App and event requests should go to: https://github.com/microsoft/ALAppExtensions and ideas to https://aka.ms/bcideas to allow other partners to vote for these.

This Developer Preview is available only through the Ready to Go program. Read more at http://aka.ms/readytogo. To get all fixes and features described in this blog post, please make sure that you are running an image with build number 26685 or newer.

### HttpClient support for Windows Authentication (NTLM)

In an on-premises environment, you can now use one of the two new methods introduced on the HttpClient to authenticate using Windows Authentication. You can decide if you either want to specify user name, password and optionally domain yourself or if you want to authenticate as the currently logged in user in Windows.

![Auth1](https://community.dynamics.com/cfs-file/__key/communityserver-blogs-components-weblogfiles/00-00-00-16-25/win_2D00_auth_2D00_1.png)

![Auth2](https://community.dynamics.com/cfs-file/__key/communityserver-blogs-components-weblogfiles/00-00-00-16-25/win_2D00_auth_2D00_2.png)

### Pruning dependencies for extensions created in the Designer

As part of the multiple bug fixes we did over the last month, we also worked on the extension dependency issue of the Designer. Until now, when creating a new extension from the Designer, the extension would take a dependency on all extensions installed on the server, even if it actually did not need all of them. It was then not possible to publish a new version of any of the extensions taken as dependency without uninstalling and re-installing the Designer extension. The upgrade process of tenants for our internal teams was also harder due to these extra dependencies created by Designer extensions.

We have now fixed the Designer in order to take a dependency only on the extensions that are actually needed. The fix is available in the daily deployments from our master branch, but also as part of the Fall 2018 CU2 release. If you haven't saved your Designer extension (by giving it a name and a publisher) and you want its dependencies to be pruned, just move one control, revert the change and it will be done automatically. If your Designer extension has been saved already, you need to update its dependencies manually in the app.json file from VS Code. We hope this will help you saving time developing, but also help us during the future upgrades of your tenants.

That was it for 2018. Happy holidays and best wishes for the year to come!

## November 2018 update

We are ready with the November update of the Developer Preview, our first blog post on the Dynamics 365 community blog, which is where you will find us going forward. So, make sure to bookmark it (it is currently best viewed using, for example, Edge as your browser). With this release, we bring you several new features that help building your solutions as extensions. Again this month we have fixed a large number of GitHub issues, see what's been closed here: closed bugs in November.

This Developer Preview is available only through the Ready to Go program. Read more at http://aka.ms/readytogo. To get all fixes and features described in this blog post, please make sure that you are running an image with build number 26070 or newer.

### AL GitHub
In the period since the Business Central Fall 2018 release until now we have focused primarily on bringing down the number of active issues on AL GitHub repo. We have reduced the backlog from close to 900 active issues down to ~320. This was achieved through a combination of delivering ~350 fixes in the November update, close follow up on any outstanding questions and input-needed issues as well as by process change.

 The process change is that AL GitHub from now on accepts only bug reports and feature requests related directly to AL and developer tools for Business Central insider builds. This means that:

 - Any application related inquiries or requests should be directed to https://github.com/microsoft/ALAppExtensions

 Any general questions should be directed to our support team or community forums:
 - [Business Central Community](https://community.dynamics.com/business/f/758)
 - [mibuso forum](https://forum.mibuso.com/categories/nav-three-tier)
 - [Dynamics User Group](https://dynamicsuser.net/nav/f/developers)

Any issues related to already released versions of the product should be directed to our support team. You can open Support Request to CSS through PartnerSource portal or contact your Service Account Manager (SAM) in the local subsidiary to understand what is included in your contract as of support incident and PAH (Partner Advisory Hours). Your SAM might also step by step direct you how to open a support request or how to get credentials if this is the first time for you/your company.

![GitHub issues activities](https://community.dynamics.com/cfs-file/__key/communityserver-blogs-components-weblogfiles/00-00-00-16-25/githubactiveissues.png)


### Option to avoid new session upon deployment with CTRL + F5
A new launch.json option has been introduced - launchBrowser. This property indicates whether or not to open a new session - a new tab in your browser - upon publishing your AL extension. If the value is not specified or set to true, the session is started. If the value is explicitly set to false, the session is not started unless you launch your extension in debugging mode.

![Launch browser](https://community.dynamics.com/cfs-file/__key/communityserver-blogs-components-weblogfiles/00-00-00-16-25/launchbrowser.png)

### .NET Control Add-Ins
Legacy .NET Control Add-Ins can be used from AL through .NET interoperability. This type of add-ins is only supported in the Windows client and going forward we recommend that you convert your existing .NET and Javascript add-ins to native AL controladdins.

Given the following stub definition of the "Microsoft.Dynamics.Nav.Client.PingPong" .NET add-in:

```
namespace Microsoft.Dynamics.Nav.Client.PingPong
{
    /// <summary>
    /// Add-in for pinging the server from the client. The client will respond with a pong.
    /// </summary>
    [ControlAddInExport("Microsoft.Dynamics.Nav.Client.PingPong")]
    public class PingPongAddIn : WinFormsControlAddInBase {…}

}
```

We add the type declaration in AL making sure to reference the full type name and to set the IsControlAddIn property to true:

```
dotnet
{
    assembly("Microsoft.Dynamics.Nav.Client.PingPong")
    {
        type("Microsoft.Dynamics.Nav.Client.PingPong.PingPongAddIn";PingPongAddIn)
        {
            IsControlAddIn = true;
        }
    }
}
```

We can now use it from a page as a native control add-in.
```
page 50100 MyPage
{
    layout
    {
        area(Content)
        {
            usercontrol(PingPongControl; PingPongAddIn)
            {
                trigger Pong()
                begin
                    Message('Pong received.');
                end;

                trigger AddInReady()
                begin
                    Message('Ready');
                end;
            }
        }
    }
}
```

If you have a native add-in and a .NET add-in with the same name, inside a project, the .NET add-in will be the one used.

### Testing Reports in AL
If you need to validate if a report produces correct data, you should use - Codeunit 131007 “Library - Report Dataset”. Extensions cannot use the file share as we used in the existing tests, so we need to save the reports to stream.

#### Usage
To initialize the class, you can use two methods:
- (Preferred) RunReportAndLoad – will run the report and initialize the Library - Report Data Set class
- LoadDataFromInStream – if you want to run the report separately and load the data in the instream manually
To verify the output you can use these two methods:
- AssertElementWithValueExists
- AssertElementWithValueNotExist
The other methods in the library should work as well as long as they do not contain “Tag” in the name.

#### Code Example

```
// Exercise: Run the Report Remittance Advice - Journal.
XmlParameters := REPORT.RUNREQUESTPAGE(REPORT::"Remittance Advice - Journal");

LibraryReportDataset.RunReportAndLoad(REPORT::"Remittance Advice - Journal",GenJournalLine,XmlParameters);

// Verify: Verifying Total Amount on Report.
LibraryReportDataset.AssertElementWithValueExists('Amt_GenJournalLine',GenJournalLine.Amount);

RUNREQUESTPAGE is optional, it may be used to control the request page parameters. You need to implement RequestPageHandler in this case:

[RequestPageHandler]
PROCEDURE RemittanceAdviceJournalRequestPageHandler@4(VAR RemittanceAdviceJournal@1000 : TestRequestPage 399);
BEGIN
// Empty handler used to close the request page. We use default settings.
END;
```

Any changes done in the handler above will result in the XmlParameters being changed and applied automatically when the report runs. Examples of the implementation in the existing tests can be found in  Codeunit 133770 and Codeunit 134141.

#### Technical details
TestRequestPage SaveAsXML is using a different format than REPORT.SAVEASXML or REPORT.SaveAs. The reason is that the TestRequestPage.SaveAsXML is serializing the output of Report Previewer. This component will be deprecated at some point in the future; the new methods should be used for new tests. TestRequestPage SaveAsXML requires files to be saved to disk and loaded, while other methods work in memory, thus they are more efficient.

Because we need to support the existing tests, the codeunit is supporting both formats for now. TestRequestPage SaveAsXML is using Tags for values, while the new format uses attributes. This means we cannot use any public method that contains Tag in the name to test the reports generated in the memory.


### AL Language Extension is now also supported on MacOS
Finally! After having been work in progress for more than 2 years, the distributed .vsix file is now supporting both Windows and MacOS.

The MacOS version contains the same functionality as the Windows version. There are, however, a few differences/limitations compared to the Windows version.
- Windows authentication is not supported.
- AAD authentication is using device login (http://aka.ms/DeviceLogin) to authenticate. The user experience is different. Instead of getting a login dialog, a notification window is shown in the lower right corner. The window shows the device login URL and the device code. Clicking the 'Copy and Open' button will place the code on the clipboard and open a browser on the device login page.

![DeviceLoginPopup](https://community.dynamics.com/cfs-file/__key/communityserver-blogs-components-weblogfiles/00-00-00-16-25/DeviceLoginPopup.png)

- RDL editing is not supported on Mac. ReportBuilder is Windows only, and there is no other available tool for editing the RDL.
- Word editing is limited. The "XML Mapping Pane" feature is not available in the MacOS version of Word so it is not possible to add fields to the document.
- Reports datasets, code, and requestpage can still be designed, modified, and deployed using the MacOS version.

The MacOS version must be 10.12 (Sierra) or newer.

### Outline View
The Outline view is a separate section in the bottom of the File Explorer. When expanded, it will show the symbol tree of the currently active editor.

![Isolated Storage](https://community.dynamics.com/cfs-file/__key/communityserver-blogs-components-weblogfiles/00-00-00-16-25/isolatedstorage.png)

The Outline view has different Sort By modes, optional cursor tracking. It also includes an input box which finds or filters symbols as you type. Errors and warnings are also shown in the Outline view, letting you see at a glance a problem's location.

### Isolated Storage
Isolated Storage is a data storage that provides isolation between extensions, so that you can keep keys/values in one extension from being accessed from other extensions. Keys/values in the Isolated Storage are accessible through an API. The involved data type is DataScope.

The methods supported for the DataScope data type are:
|Method|Description|
|--------------|-----------------|
|ISOLATEDSTORAGE.SET|Sets the value associated with the specified key within the extension.|
|ISOLATEDSTORAGE.GET|Gets the value associated with the specified key within the extension.|
|ISOLATEDSTORAGE.CONTAINS|Determines whether the storage contains a value with the specified key within the extension.|
|ISOLATEDSTORAGE.DELETE|Deletes the value with the specified key from the isolated storage within the extension.|

The DataScope Option Type Identifies the scope of stored data in the isolated storage.

|Member|Description|
|--------------|-----------------|
|Module|Indicates that the record is available in the scope of the app(extension) context.|
|Company|Indicates that the record is available in the scope of the company within the app context.|
|User|Indicates that the record is available for a user within the app context.|
|CompanyAndUser|Indicates that the record is available for a user and specific company within the app context.|

DataScope is an optional parameter and if it is not passed the value would be Module.

![Isolatedstorage code](https://community.dynamics.com/cfs-file/__key/communityserver-blogs-components-weblogfiles/00-00-00-16-25/isolatedstoragecode.png)

### Multi ID Ranges
Support for multi ranges for application object IDs. You can add an "idranges" property to the app.json which is an array of "idrange". The "idrange" is still valid but you must either use "idrange" or "idranges" in the app.json file. For all objects outside the range, a compilation error will be raised. When you create new objects, an ID is automatically suggested from the first available range. Overlapping ranges are not supported and generates a compilation error will be raised.

![Multiidranges](https://community.dynamics.com/cfs-file/__key/communityserver-blogs-components-weblogfiles/00-00-00-16-25/multiidranges.png)

### Update to the AL reference documentation

Maybe you’ve already noticed, but last week, we refreshed the documentation with a new set of reference help for methods. We now have a 100% reflection of the methods that are available in AL with their syntax, parameters, return value and more. This is only a step on the way to having the same for properties and triggers, we will be working on this in the coming months. For now, explore the new methods here: https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/library.

## August 2018 update
Once again it is our pleasure to announce the August update of the Developer Preview. With this release, we bring you several new features that help building your solutions as extensions. We also include a large number of resolved GitHub issues. See the list of closed bugs here: [closed bugs in August](https://github.com/Microsoft/AL/milestone/19?closed=1).
This Developer Preview is available only through the Ready to Go program. Read more at [http://aka.ms/readytogo](http://aka.ms/readytogo). To get all fixes and features described in this post please make sure you are running an image with a build number 2.0.41872 or newer.

## New virtual tables for Report Data Items and all Page Control Fields

The following two new virtual tables are added to reflect more info about request pages and reports:
* **All Control Fields** (ID 2000000202)
    * This table contains information about page controls on regular pages, as well as on request pages in reports and XMLports. The primary key is "Object Type", "Object ID", and "Control ID", where "Object Type" could have a value of Report, XMLport, or Page.
* **Report Data Items** (ID 2000000203)
    * This table reflects information about individual data items in a report, for example: "Indentation Level", "Related Table ID", "Request Filter Fields", etc.

With the help of these new tables, it is possible now, for example, to generate the report parameters XML string without actually invoking the report request page.


## Translating Base App Help using AL extensions
It is now possible to create AL extensions that override the default help link for Business Central and re-direct users pressing the Help button to another website. This also enables translating the help link for Base App objects.

In order to do so, we've introduced two new properties in the manifest of AL extensions: 'helpBaseUrl' and 'supportedLocales'. The 'helpBaseUrl' property represents the URL that will be used to override Microsoft's default help link (https://learn.microsoft.com/{0}/dynamics365/business-central). This URL must contain a place holder '{0}' for the locale culture used by the user and must point to a website that must be forked from https://github.com/MicrosoftDocs/dynamics365smb-docs in order to follow the same structure that Microsoft's help follows. The property 'supportedLocales' is used to specify the list of locales (in the format language2-country2/region2) that are supported by the URL provided and then by the translation app. If the user's current locale is among the 'supportedLocales' of your extension the user will be re-directed to the help base URL that you specified.  The settings in the app.json file look like this:
```
  "helpBaseUrl": "https://www.mydocumentationwebsite.com/{0}/business-central/",
  "supportedLocales": [
       "da-DK"
  ]
```

**Note:** This feature is not available for per-tenant extensions and a rule has been implemented for it in the PTE analyzer. See [PerTenantExtensionCop Analyzer.](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-codeanalyzer-pertenantextensioncop-rules)

## Adding help links with user locale on new created objects
We previously added the ability to add static help links in new created pages, reports, or XMLports. For more information, see [Adding Help Links from Pages, Reports, and XMLports.](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-adding-help-links-from-pages-tables-xmlports)
It is now also possible to include a placeholder for the user locale in these links. From code, you will define the HelpLink as follows, including the {0} placeholder:

```
page 50100 MyPage
{
    HelpLink = 'https://www.mydocumentationwebsite.com/{0}/business-central/my-page';
}
```

And the placeholder is then filled in according to the app.json file locale setting:
```
  "supportedLocales": [
    "da-DK", "en-US"
  ]
```
In case the user is using one of the supported locales, the supported locale will be inserted in the help link. If the user is not using one of the supported locales, the first locale specified in the 'supportedLocales' setting will be considered default and be inserted in the URL.

## Field group extensiblity
Field groups can now be extended from a table extension with the use of the **addlast** construct. It allows for adding more fields to the end of a field group.

## AL Language Extension is now also supported on MacOS
Finally! After having been work in progress for more than 2 years, the distributed .vsix file now supports both Windows and MacOS.

The MacOS version contains the same functionality as the Windows version. There are, however, a few differences/limitations compared to the Windows version.
* Windows authentication is not supported.
* AAD authentication is using device login (http://aka.ms/DeviceLogin) to authenticate. The user experience is different. Instead of getting a login dialog, a notification window is shown in the lower right corner. The window shows the device login URL and the device code. Clicking the 'Copy and Open' button will place the code on the clipboard and open a browser at the device login page.
* RDL editing is not supported on Mac. ReportBuilder is Windows only, and there is no other available tool for editing the RDL.
* Word editing is limited. The XML Mapping Pane feature is not available in the MacOS version of Word, so it is not possible to add fields to the document.
* Report datasets, code, and request page can still be designed, modified, and deployed using the MacOS version.

**Note:** The MacOS version must be 10.12 (Sierra) or newer to run the AL Language Extension.

## Report substitution is possible from extensions
Extensions can now replace built-in reports by subscribing to the **OnAfterSubstituteReport** event emitted by **Codeunit 44 - ReportManagement**. Substitution is possible whenever a report is invoked as the result of the user activating a page action that has the **RunObject** property set to a report or a report is invoked through one of the following static methods on the **Report** data type:
* Run
* RunModal
* SaveAsHtml
* SaveAsXml
* SaveAsPdf
* SaveAsExcel
* SaveAsWord
* RunRequestPage
* Execute
* Print
* SaveAs

Substitution is performed by setting the value of the NewReportId parameter to the ID of the report that should replace the report with ID ReportId. In the following example, I replace Report 2 with Report 4.

If the value of the NewReportId parameter is different from the value of the ReportId parameter and different from -1, it means that the report has already been substituted by another subscriber of this event.
The event is called 'OnAfterSubstituteReport' to match the pattern followed by other events in the ReportManagement Codeunit, but the subscriber will be invoked before the substitution takes place.


# July 2018 Update (2018/07/30)

Welcome to the July update of the Developer Preview. With this release, we bring you several new features that help building your solutions as extensions. We also include over 90 resolved GitHub issues. See the list of closed bugs here: [https://github.com/Microsoft/AL/milestone/18?closed=1](https://github.com/Microsoft/AL/milestone/18?closed=1).

This Developer Preview is available only through the Ready to Go program. Read more at [http://aka.ms/readytogo](http://aka.ms/readytogo). To get all fixes and features described in this post please make sure you are running an image with a build number 13.0.32492.0 or newer.


## OData-bound actions in AL
It is now possible to declare OData bound actions in AL. A new attribute [ServiceEnabled] and new AL types WebServiceActionContext and WebServiceActionResultCode have been introduced to achieve this.

Here is an example of how to declare a new OData bound action on a page exposed as a web service:

```
[ServiceEnabled]
procedure CreateCustomerCopy(var actionContext : WebServiceActionContext)
var
    createdCustomerGuid : Guid;
    customer : Record Customer;
begin
    actionContext.SetObjectType(ObjectType::Page);
    actionContext.SetObjectId(Pages::Customer);
    actionContext.AddEntityKey(customer.fieldNo(Id), createdCustomerGuid);
    actionContext.SetResultCode(WebServiceActionResultCode::Created);
end;
```
Note that similarly to C/AL approach the function's parameter has to be named 'actionContext' to be correctly picked up by the OData framework.

More details can be found in Developer and IT-Pro Help here: [https://learn.microsoft.com/en-us/dynamics-nav/walkthrough-creating-and-interacting-odata-v4-bound-action](https://learn.microsoft.com/en-us/dynamics-nav/walkthrough-creating-and-interacting-odata-v4-bound-action)

## Event discovery using a recorder
A core aspect of creating extensions is to subscribe to events. However, a common challenge is understanding which events are available in a given user flow. Debugging can help, but will only show events already being subscribed to. To aid in the discoverability of events and extension points, there is a new event tracer in the client. With this, a user flow can be recorded to list events that are raised, and the developer can have subscriber code for the event generated for easy copy into AL code.

To get the list of all events raised during a given session use the new **Event Recorder**:
1. Navigate to the Event Recorder page using the Search in the client or by using the command 'AL: Open Events Recorder' in VS Code.
2. Press the Start button in order to start recording events.
3. Now, perform the actions required for your scenario.
4. Press the Stop button to get the list of all recorded events.
5. Choose the event that suits you the best and get an AL snippet to use in VS Code by choosing **Get AL Snippet**.

## Extensible Enums
In this Developer Preview, we're also adding the ability to add and extend enums. This section introduces the concept.

### Declaration
Enum is a new concept that over time is meant to replace the existing Option type. It is a new top-level type and is declared like this:
```
enum 50121 Loyalty
{
    Extensible = true;
    value(0; None) { }
    value(1; Bronze) { }
    value(4; Silver) { }
    value(5; Gold)
    {
        Caption = 'Gold Customer';
    }
}
```

Enums require an ID and a name. In the preview the IDs are not validated against any license, but they must be within your assigned object range. An enum contains a list of values. The value corresponds to the individual elements of the OptionString on an Option. The value has an ID and a name. The ID is ordinal value used when persisting the enum and hence they must be unique. The name is used for programmatic access and is a fallback for the caption. Enums are pure metadata and can't contain any kind of code.

Enums can be marked as extensible. If an enum is extensible; you can add more values to the original list of values. The enumextension syntax looks like this:

```
enumextension 50130 LoyaltyWithDiamonds extends Loyalty
{
    value(50130; Diamond)
    {
        Caption = 'Diamond Level';
    }
}
```

### Usage
Enums can be used as table fields, global/local variables, and parameters. They are referenced using the following syntax:
```
enum Loyalty
```
For example, as a table field type:
```
field(50100; Loyal; enum Loyalty) {}
```
Or as a variable:
```
var
    LoyaltyLevel: enum Loyalty;
```

### In C/SIDE
Since most of the enums that are currently relevant for extensibility are on table fields in the base-app, we have made it possible to mark a table field in C/SIDE as Extensible.

To extend a table field option you must set up your development environment to run C/SIDE and AL side-by-side as described here: [https://learn.microsoft.com/en-us/dynamics-nav/developer/devenv-running-cside-and-al-side-by-side](https://learn.microsoft.com/en-us/dynamics-nav/developer/devenv-running-cside-and-al-side-by-side). Once the feature is out of preview we will allow requesting base application enums to be made extensible through GitHub requests similar to event requests.

### Conversions
Conversions to/from Enums are more strict than for Options.

* An enum can be assigned/compared to an enum of the same type.
* To be backwards compatible we support conversion to/from any Option, but we may in the future be more strict.

Known Issues in the July preview
* No runtime checks for ID collisions.
* Declare C/SIDE enums with the same ID on multiple table option fields will break symbol generation.

That's it for now. As usual we encourage you to let us know how you like working with these additions and keep submitting suggestions and bugs. You can see all the filed bugs on our GitHub issues list [https://github.com/Microsoft/AL/issues](https://github.com/Microsoft/AL/issues).


# June 2018 Update (0.17.23984 - 2018/06/25)

Welcome to the Developer Preview for June. In this release we have a number of new features for you that are introduced below. We have also spent time burning down outstanding bugs reported through GitHub. See the list of closed bugs here: https://github.com/Microsoft/AL/milestone/17?closed=1.

## Debugger enhancements
We have added support for the following  debugger options that have also been available in the Dynamics NAV debugger. The options are:
- breakOnError. The default is true.
- breakOnRecordWrite. Breaks before a write action. The default is false.

These settings are part of the configuration settings in the launch.json file.

We have added the possibility to go to definition on base app code or any reference code that has been published with showMyCode enabled. The "Go to definition on base app symbols" on local server scenarios requires that the AL symbols are rebuilt and downloaded from C/SIDE.

You can also set breakpoints in methods of downloaded content. This refers to both base application-based C/AL content and extension V2 based reference content where the showMyCode flag has been set to true when the package was deployed. Note that the base application-based C/AL is partly modified to render in the Visual Studio Code AL editor, and that object metadata is shown at the end of the file.

## Permission Set creation
We have added some utilities to make working with permissions easier for you. You can now export selected app and/or tenant permission sets which you have created in the client so that you can package them for your extension. This allows you to use the client instead of having to edit the XML by hand. Once you publish, you can see the permission sets in the client again, make more changes, and then export again.

1. On the Permission Sets page, select a few permissions that you want to export and then choose the Export Selected Permissions action.

2. Choose whether you want to export only app, tenant, or both types of permissions.

3. And then save the file to your extension folder.

You can now also generate a permission set file which contains permissions to all the files in your extension. This will make it easier to start setting up permissions for your app. Previously you had to do it by hand for each object and make sure you didn't forget something.

1. Simply create your extension with some objects.

2. Invoke the Visual Studio Command with Ctrl+Shift+P and then select AL: Generate permission set containing current extension objects.  Please note that if you do this repeatedly, Visual Studio Code will probe for overwriting the file, there is no support for merging manual corrections into newly generated content.

3. Now, you have your XML file with default permissions to all your objects.

## .NET Interoperability

We have added the posibility of using .NET types from AL. .NET interoperability will only be available for solutions that target on-premise deployments.
To create an extension that uses .NET interoperability you must first:
- Open the extension's app.json file and set the "target" property to "OnPrem"
- Open the settings for your current workspace and specify any folders that should be searched for assemblies by setting the "al.assemblyProbingPaths" property.

You can now start using .NET interoperability by declaring the .NET types that you will be using in a dotnet{} package and referencing them from code as in the example below. For more information, see [Get Started with .NET Interoperability from AL](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-get-started-call-dotnet-from-al).

## Backwards compatibility
We are working on making one single Visual Studio Code AL extension which is compatible with multiple versions of the server.

This means that in the near future you will be able to install the AL Language extension from the Visual Studio Code marketplace and use it to develop solutions for:
- Microsoft cloud sandbox
- Business Central, April 2018 release
- Business Central, Fall 2018 release
- And more

Please note that at the moment there are no plans to make this AL Language extension version backwards compatible with Dynamics NAV. For Dynamics NAV development, the traditional method should be used – install the VS Code extension from the ALLanguage.vsix file shipped on the DVD.

The first bits of this feature are out in the preview now.

In the app.json file, a new attribute "runtime" is added. This attribute defines the platform version that the extension is targeting. Depending on the runtime version, certain features become available or on the contrary – not allowed. For example, .NET interopability can only be used when the runtime version is 2.0 or higher.

# May 2018 Update (0.17.16611 - 2018/05/25)

Welcome to the May 2018 Developer Preview update. In this release we have focused primarily on burning down the outstanding bugs reported through GitHub. This milestone contains ~300 events and bug fixes and brings the number of outstanding bugs close to 0. See the list of closed bugs here: https://github.com/Microsoft/AL/milestone/16?closed=1. We have also added a few small features, please see more details below.

## Help links from IntelliSense
We improved the help experience of all properties in AL, both on hover and in IntelliSense, adding help links that redirects you to the related online documentation.

## Improved support of the Image property
We also improved the support around the Image property in the extension. This includes improving the suggestion of images to only propose the ones that can be used in the current context, displaying a warning for images that cannot be used in the current context, but also the possibility to preview images when using IntelliSense and on hover.

## Contextual information in XLIFF files
We have added contextual information in the XLIFF file that describes which object and element a given string applies to. This helps translators get a better overview of where a string is displayed in the UI thereby increasing the quality of the translation.

# Dynamics 365 Business Central Spring 2018 Release (0.15.18771 - 2018/03/23)

We are happy to announce the following great features:

## Static Code Analysis
Specifying `"al.enableCodeAnalysis": true` in your settings, static code analysis will be enabled for AL projects. 3 analyzers have been implemented that will support general AL, AppSource and Per-Tenant Extension analysis. Analyzers can be individually enabled by specifiying the rulesets in the al.codeAnalyzers setting.
```json
"al.enableCodeAnalysis": true,
"al.codeAnalyzers": [
        "${CodeCop}"
]
```
You can create and customize your own ruleset but adding a file <myruleset>.ruleset.json to the project. Using the
snippets **truleset** and **trule** will get you started quickly.

For more information, see [Using the Code Analysis Tool](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-using-code-analysis-tool).

## Help for new pages
When creating new Pages, Reports, and XMLports in V2 extensions, it is now possible to specify the help link that will be used when the user presses the help button in the UI.

You can do this by using the property HelpLink on Pages:
```
page 50100 MyPageWithHelp
{
    HelpLink = 'https://www.github.com/Microsoft/AL';
}
```
And by using the property HelpLink on the request page of Reports and XMLports:

```
report 50100 MyReportWithHelp
{
    requestpage
    {
        HelpLink = 'https://www.github.com/Microsoft/AL';
    }
}
```
For more information, see [Adding Help Links from Pages, Reports, and XMLports](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-adding-help-links-from-pages-tables-xmlports)

## Creating Role Center Headlines
You can set up a Role Center to display a series of headlines, where headlines appear one at a time for a predefined period of time before moving to the next. The headlines can provide users with up-to-date information and insights into the business and their daily work.

For more information, see [Creating Role Center Headlines](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-create-role-center-headline). 

## Improved experience for event subscribers
We improved the snippets and IntelliSense around event subscribers, for both the attribute arguments and the method parameters. It is now working for trigger, integration, and business events. In case of business and integration events, the suggestion of the method parameters is made based on the attributes of the event publisher in order to know if the global variables and/or the sender should also be suggested.

## Working with data?
You can now inspect the contents of a table when you publish an AL project (F5 and Ctrl+F5) from Visual Code. Simply modify the launch.json file of the project to include the `"startupObjectType" = "table"` and `"startupObjectId" = "<TableID>"` settings, replacing <TableID> with the ID of the table that you want to see. The table will display in the client as read-only.

From the client, you can also view a specific table by appending the URL with "&table=<ID>", such as:
https://businesscentral.dynamics.com/?company=CRONUS%20Inc.&table=18

For more information, see [Viewing Table Data](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-view-table-data).

## Choose your cue layout on Role Centers
We now offer a wide layout option for cues. The wide layout is designed to display large values and gives you a way to emphasize a group of cues. When set to the wide layout, a cue group will be placed in its own area, spanning the entire width of the workspace.

For more information, see [Cues and Action Tiles](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-cues-action-tiles).

# February Update (0.14.17461 - 2018/02/15)

Let's kick start 2018 with a great set of features.

## Synchronize data on F5

When doing subsequent publishing from Visual Studio Code, it is now possible to keep the data entered into tables specified in the extension.

The two possible values are: Recreate and Synchronize.

**Recreate** is the behavior you have experienced so far; all the tables and table extensions are recreated at every publish, meaning that all the data in those tables is lost.

**Synchronize** is the new behavior that tries to synchronize the current state of the database with the extension that is being published. This means that, for example, if a field is removed then it cannot be synchronized and you have to either use the other mode (Recreate) or write upgrade code and follow the steps for that.

For more information, see [Upgrading Extensions](https://learn.microsoft.com/en-us/dynamics-nav/developer/devenv-upgrading-extensions).

## Adjustable column width in the Web client
Using Designer, you can now adjust the width of columns in lists that are displayed by a List, ListPart, ListPlus, or WorkSheet type page. For more information, see [Designer](https://learn.microsoft.com/en-us/dynamics-nav/developer/devenv-inclient-designer).

## Report RDL and Word layout development with AL
We have enabled the scenario to develop RDL Report Layouts and Word Report Layouts by using the AL Extension and the editor for the files. Now, when you specify the path to the layout in the report using either WordLayout or RDLCLayout property.

The extension will generate the .rdl file in the specified path.
The scenarios are the same for both RDL and Word development.
You specify the file and it is created.
You make changes to the file in Word or SQL Server Report Builder or you change the dataset in AL code and the layout files stay in sync with the AL extension.
You can use the existing RDL and Word files which you export from your codebase and use it with this new development scenario.

## Enabling Dynamics 365 for Sales tables for extension development
The creation of Dynamics 365 for Sales tables is now available for extension development to allow you to create extensions that integrate with Dynamics 365 for Sales. Dedicated properties, along with IntelliSense and diagnostics, are also available to enable field mapping with the tables you use in Dynamics 365 for Sales.

## Autonumbering of objects
We have improved the object Id IntelliSense so that it suggests the next available ID for a given object type. The next available ID is determined based on the Id range defined in app.json and based on all occupied Ids by objects that are within the compilation scope (i.e. the current project and its dependencies).
Simply press Ctrl + Space after an object keyword to get the next available ID.

## Multi root workspace support
Visual Studio Code recently introduced the so-called multi root workspace support which allows you to organize your work in multiple top level folders. See the details on how to add multiple folders to a workspace in https://code.visualstudio.com/docs/editor/multi-root-workspaces
The AL Language extension now also supports the multi root functionality. This feature-set allows you to work with multiple top level AL folders (roots/projects) within one workspace. Not all roots have to be AL-based - you can mix all kinds of roots/projects together. Each AL project will now have its own configuration values for the following settings:

    a. al.packageCachePath
    b. al.enableCodeAnalysis
This allows you to create a package cache path relative to each project or use the same absolute path to share the same packages across different projects.

# Anniversary Update (0.13.15836 - 2017/12/20)

To celebrate that it is exactly one year ago that we shipped the first Developer Preview release we have an extra update for you before the end of the year. Here are the new features.

## Debugger Changes:
The performance of the debugger has been improved by:
1. The Visual Studio Code debug adapter has been refactored to lazily evaluate globals and locals.

2. Text constants are not shown anymore as part of global symbols.

## New Language Feature - Method Overloading:
The AL language now supports method overloading. It is possible to have a procedure with the same name, but with different parameter lists.

## More Control Add-Ins Now Available
A number of built-in control add-ins can now be used in AL extensions:
* Microsoft.Dynamics.Nav.Client.VideoPlayer
* Microsoft.Dynamics.Nav.Client.WebPageViewer
* Microsoft.Dynamics.Nav.Client.PageReady
* Microsoft.Dynamics.Nav.Client.BusinessChart

**Note**: Business Chart can currently only be configured through table Business Chart Buffer (485), which internally uses .NET interop to set up the chart.

All new control add-ins are available in the newest Application symbols package, therefore they can simply be referenced in the user control field:

## Working with Camera

A new base page Camera Interaction (1910) has been added to encapsulate the interaction with the device camera (if available). .NET interop code is no longer needed to take a selfie in AL as illustrated in the code sample below:

## More System Tables Unblocked
A number of system and virtual tables have been unblocked for extension development:
* License Permission
* Permission Set
* Permission
* Aggregate Permission Set
* All Profile
* Profile
* Profile Metadata
* Add-in
* Chart

# December Update (0.12.15359 - 2017/12/06)

Welcome to another installment of our development updates. We have the pleasure of announcing the following great features.

## AL Formatter

The AL Language Visual Studio Code extension now offers users the option to automatically format their source code. The auto-formatter can be invoked to format an entire AL document or a pre-selected range.

In an existing project, open the document you want to format, right click - inside the document, and run "Format Document".

To format a range, in an already opened project, open the document you want to modify, select the specific range you want to format, right click it, and run "Format Selection" command.

![Formatter](https://learn.microsoft.com/en-us/dynamics-nav/developer/media/format-document.gif)

## Show My Code

The manifest has a new setting: Show My Code. It controls whether the source code is visible when other extensions debug it.

For example, an amazing library is developed and shared on AppSource for other people to use but the author doesn't want the users to see the code when they try to debug into it from their extension. The author will with the use of ShowMyCode make sure that the code is not shown when the user tries to debug into it. By default ShowMyCode is false but can be overriden in the app.json to true.

## Pages/reports show up in Search in the Web client

Each page and report has a new property called UsageCategory, which accepts the following values: None,Lists,Tasks,ReportsAndAnalysis,Documents,History,Administration. If this value is not set to none then the page/report will appear in Search.

There are two more properties added if the UsageCatgeory is set; ApplicationArea and AccessByPermission. These are used to control whether or not a page will appear, or if the page can be launched from Search.

Example:
```
page 70050088 SimpleCustomerCard
{
    PageType = Card;
    SourceTable = Customer;
    UsageCategory = Documents;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("No.";"No.") {}
                field(Name;Name) {}
                field(Address;Address) {}
            }
        }
    }
}
```

## Generating symbols from C/SIDE and using them in VS Code.

In order to allow the server to accept symbols from C/SIDE you must enable the EnableSymbolLoadingAtServerStartup flag in the server's configuration file.

You can generate symbols from C/SIDE with the generatesymbolreference command. Example:
```
finsql.exe command=generatesymbolreference,database=<Dabasename>servername<server>,logfile=<path to log file>
```
This operation is lengthy. It should normally take a full application object compile time.

Once symbols are generated they can be downloaded from Visual Studio Code.

This new feature also allows that symbols changed in C/SIDE are immediately updated on the server. Therefore any change can be instantly downloaded with a new symbol download command from Visual Studio Code.

For this to happen you must start finsql with a special flag called generatesymbolreference.
Example:
```
finsql.exe generatesymbolreference=yes
```
If C/SIDE is started with this flag then a compilation of any application object would also update generate a new symbol reference for the changed application object.


# November Update (0.11.14434 - 2017/11/08)

Welcome to the November Update. We have several exiciting changes to announce.

## Multi-country/region extensions

It is no longer necessary to specify application locale in app.json. Your AL package will be compiled against the application that is present on the server that you connect to. This allows you to write a single AL extension for multiple country/region versions as long as you don't depend on country/region-specific code. If you do depend on country/region specific code you should only try to compile your app against a server set up for that country/region.

The application property in app.json has changed its format accordingly.

Old:
```
"application": {
    "version": "11.0.0.0",
    "locale": "US"
}
```
New:
```
"application": "11.0.0.0"
```
## Runtime packages

For On-Prem app distribution purposes it is now possible to generate "Runtime" packages that don't contain any AL code. Instead they contain the compiled output files that the server uses.

It first requires to have an extension developed and published to an on-premise instance. Then for generating the package, it connects to the server and finds the extension by the following powershell command:

```
Get-NavAppRuntimePackage
```

For publishing and installing the package the following powershell commands are used:

```
Publish-NavApp
Install-NavApp
```

This comes with the limitation that it only works for on-premise installations, the debugging experience is very limited since no source code is available and it can't be used for submissions to AppSource.


## Translations

We have now improved the translations feature with the support of Xliff files. To enable it open the app.json file and enter:

```
  "features": "TranslationFile"
```

Then invoke the package command (Ctrl + Shift + B) in Visual Studio code and there will be a directory "Translations" with the .xliff files ready to filled out with a new language.
The generated xliff file can be used within many of the free or commercial tools for translators.
All labels, label properties (Caption, Tooltip etc.) and report label will be included in the xliff file and be ready for translation.
After you have specified the target language and translated your labels, include the renamed xliff file in the Translations folder.
Make sure the name is not the same as the file which is being generated as it will be overwritten.
On next publishing of your extension the translations will be included in the package and picked up by the server.

Some things to note: ML properties, old report label syntax and TextConst do not get included in the xliff file and will not be translated. Make sure to update your code from the old ML syntax (=ENU='asd';DEU='qwe') to the new label syntax.

The label syntax is as follows (example for Caption property):
Caption = 'Developer translation for %1',  Comment = '%1 is extension name', locked = false, MaxLength=999;

The `comment`, `locked` and `maxLength` attributes are optional and the ordering is not enforced.
Use the same syntax for report labels

```
labels
{
    LabelName = 'Label Text', Comment='Foo', MaxLength=999, Locked=true;
}
```

And label data types:

```
var
    a : Label 'Label Text', Comment='Foo' MaxLength=999, Locked=true;
```

# October Update (0.10.13928 - 2017/10/12)

We are excited to announce the following changes in the October Update:

## Web client add-ins

It is now possible to develop JavaScript control add-ins in AL. The new AL type controladdin serves both as a replacement for the old XML manifest (https://msdn.microsoft.com/en-us/library/dn182591(v=nav.90).aspx) and as a replacement for the .NET interface as for bidirectional JavaScript-to-AL communication.
-  The JavaScript APIs remain the same as in Extensions V1: https://msdn.microsoft.com/en-us/library/dn182584(v=nav.90).aspx.
- There is no need for creating a DLL, signing it and creating a .zip file anymore. All development happens within the VS Code AL project and the control add-in gets deployed as part of the extension (Ctrl + F5).

## Dictionary and List
This update adds two new, highly requested AL types: List and Dictionary. For the first time in AL, you will be able to work with strongly typed lists and dictionaries.
At the moment, these types can only be used with simple types, for example, you can have a List of [Integer], but not a 'List of [Blob]'. The list of supported types is fairly long, but the main point is that: if you can use it as the return type of a procedure, you can use it in a list.

## ForEach is back
We've added support for iterating over expressions of enumerable types in AL using the foreach statement. At the moment, you can use the foreach statement to iterate over expressions of type List, XmlNodeList, XmlAttributeCollection, and JsonArray.

## New translation syntax
We have added support for the new Label syntax which will prepare you for using the new translation process which decouples translation from source code. You will be able to specify a default translation in code with some attributes and then in the next update we will provide you with generating a standard format translation file which is widely supported for translating. When you get your translation back, you simply package it with the extension and you now have a multilanguage extension!

We encourage you to start transitioning to this new syntax, so that you’re ready when we update the compiler.
You cannot use Caption and CaptionML at the same time. This applies to the rest of the classic multilanguage properties.

# September Update (0.9.12794 - 2017/09/07)

Welcome to the September update for the Developer Preview.

## We have a new developer preview image ready for you. To get up and running, follow these steps:
- Navigate to http://aka.ms/navdeveloperpreview to launch the September update of the Developer Preview.
- Specify Resource group, Vm Name, and Admin Password and then select which country/region version you want.
- When deployment has succeeded, you'll see following the landing page (Open the Virtual Machine DNS Name URL in a browser).
- You can connect to the Virtual Machine using Remote Desktop and Open VS Code to develop like before. Or, you can develop using VS Code on your local computer. To do this you must download the self-signed certificate and install it in the Local Machine Trusted Root Certification Authorities. Having downloaded and installed the certificate, you can download the AL Language Extension and install it into your local VS Code.
Use AL GO! and replace the corresponding lines in launch.json and app.json with the lines you see on the landing page. Download symbols, compile, deploy, and debug.

In addition to the next batch of [fixed issues](https://github.com/Microsoft/AL/milestone/9?closed=1) we announce the following changes:
- The .navx file extension for AL packages has been changed to .app
- The developer endpoint on the Dynamics NAV server now performs license checks when publishing AL projects. Developer Preview environments offer a free demo range of **50100-50149**. Dynamics 365 for Financials sandboxes have a more permissive license that lets you use range 50000-99999 as well as the 70000000-75000000 range.
- The developer endpoint on the Dynamics NAV server now performs permission checks to see if the user who is trying to publish an AL project has the rights to do so. The indirect insert permission into the Nav App table is validated. This permission is a part of the **"D365 EXTENSION MGT"** permission set.
- It is now possible to define Watches and conditional breakpoints in the new debugger. In the Activity Bar in Visual Studio Code, choose the Debugging icon to bring up the Debug view and add Watches. Use the Debug Menu to set breakpoints in the code.

# August Update (0.8.11706 - 2017/08/16)

The Developer Preview August Update is now live! We're excited to announce the new features for this month as well as share our progress on [fixing the issues](https://github.com/Microsoft/AL/milestone/8?closed=1) reported by you.
Please keep the feedback coming, we really appreciate your engagement.

As usual, you can provision the latest environment at [https://aka.ms/navdeveloperpreview](https://aka.ms/navdeveloperpreview)

## This update brings the following changes:
-   In this update, based on your requests, you can work with three different country/region versions of the application database. This is provided through hosting them on the Dev Preview VM; each with their own NST. The services that are available and the names that you should use in serverInstance setting in launch.json file are the following: “US”, “GB”, and “CA”. The US, GB, and CA versions correspond to the Dynamics 365 for Financials user experience and application database.
If you need to code against W1, you will have to enable the developer service endpoint in the Administration Console for the NAV serverInstance and use “NAV” in the serverInstance setting in launch.json file. Note, that the NAV serverInstance is using UserPassword authentication and the other instances are using Windows Authentication.

-   We continue to add replacements for highly requested .NET types. This update adds a new AL type, TextBuilder, that wraps the most commonly used functionality of the System.StringBuilder type in the .NET Framework.

    ```
    procedure ConcatenateString()
    var builder : TextBuilder;
        textResult : Text;
    begin
        builder.AppendLine('We can append new lines');
        builder.Append('... or just characters to the current line');
        builder.Replace('Text can also be', 'replaced');
        textResult := builder.ToText();
    end;
    ```

- We've also enriched the built-in Text data type with a bunch of new functions - for a full list, see the [documentation](https://msdn.microsoft.com/en-us/dynamics-nav/developer/datatypes/devenv-text-data-type).

## Our VS Code extension comes with new capabilities again this time:
-   The popular "Go To Definition" for dependencies gives you a generated version of the application objects, such as which fields a table has, and the datatypes of the fields. Simply place your cursor on the type and press F12.

-   We've added a preview of the new debugging experience.

    The semantics of pressing **F5** in the VS Code has changed - now it will start a debugging session. To start the client without debugging, use **Ctrl+F5**.
    To hit the breakpoints in the debugger, you just trigger the relevant actions in the web interface.

-   New authentication methods are now available. The property `windowsAuthentication` in the launch.json file is deprecated, although it will still work.

    Instead, set the new `authentication` property to the following values:
    -   Windows
    -   UserPassword
    -   AAD


# July Update (0.7.11459 - 2017/07/12)

Welcome to the Developer Preview July Update! We're excited to announce the new features for this month as well as share our progress on [fixing the issues](https://github.com/Microsoft/AL/milestone/7?closed=1) reported by you.
Please keep the feedback coming, we really appreciate your engagement.

As usual, you can provision the latest environment at [https://aka.ms/navdeveloperpreview](https://aka.ms/navdeveloperpreview)

## This update brings the following changes:
-	We're addressing the most highly requested .NET replacement, namely XML handling. This update brings a set of new native AL types that let you create, read, update and output XML documents using the XML DOM model. The most important new types include:
    -	XmlDocument
    -	XmlElement
    -	XmlAttribute

    Documentation for these new types can be found [here](https://go.microsoft.com/fwlink/?linkid=851979).

-	Completing the functionality around tenant-specific profiles originally announced in June Update we now offer new AL object types Profile and Page Customization. These new objects let you define a set of pre-defined profiles and include them in your extension. Page Customization object is very similar to a Page Extension but more restricted. As of now Page Customization can only include moving of controls and actions as well as setting Visiblity to true/false. It cannot contain variables, functions or triggers.

-	Our VS Code extension now offers signature help for all syntax elements that have structured parameters, for example:
    ```
    field(Name;Expression)
    key(Name;Field1, Field2, Field3)
    ```

-	The RecordRef type has been reworked and made available for extension development. When used from extensions RecordRef.Open will only let you open records with Id less than 2 billion.

-	The Permission property has been reworked and made available for extension development. In the first iteration the property lets you only reference objects added within your own extension. However, this will be expanded in the future releases.


# June Update (0.5.10663 - 2017/06/20)

The June update for Developer Preview is now live! We've had a month with new features and a lot of time spent on improving quality, especially trying to iron out the bugs you have submitted to us via GitHUb. Here is a [full list of fixes](https://github.com/Microsoft/AL/milestone/6?closed=1). Thanks again to everyone who has contributed and, please keep that feedback coming.

## This month's update includes
- 	In the in-app designer you can now reposition or hide a Cue tile or Cue Group on any page by using the jewel menu.
-	We've focused on making the boundary between the in-app designer and Visual Studio Code smoother.
    -	Pressing F6 in Visual Studio Code will open the current extension and allow you to add more changes using the in-app designer. For example, start in VS Code, define a page extension, press F6 to open the web client, then use the in-app designer to move the fields around and finally save your extension to files.
    -	Pressing F7 in Visual Studio Code to pull changes made by the in-app designer and add them as code back into your source. For example, start in VS Code, write a page extension, press F6, and move fields. Then switch back to VS Code and press F7. The new field order will update in the source code.

-	Added fixes to the txt2al.exe converter utility. We now support .DELTA files conversion and the command line format has changed to:
```
Copyright (C) 2017 Copyright (c) Microsoft Corporation. All rights reserved.
-source=Path	Required. The path of the directory containing the TXT files.
-target=Path	Required. The path of the directory into which the converted AL files will be placed.
-rename	Rename the output files to prevent clashes with the source .txt files.
-type=ObjectType	The type of object to convert. Allowed values: Codeunit, Table, Page, Report, Query, XmlPort
-extensionStartId	The starting numeric ID of the extension objects (Default: 70000000). It will be incremented by 1 for each extension object.
-help	Display this help screen.
```

- You can now include translation files and table data files in Extensions V2. To include a language, include the TXT file in the project directory. Press F5 will generate a .navx package that includes the captions. Note, that you can export captions using the following cmdlet https://msdn.microsoft.com/en-us/dynamics-nav/microsoft.dynamics.nav.model.tools/export-navapplicationobjectlanguage. The same approach goes for data and you can use this cmdlet https://msdn.microsoft.com/en-us/dynamics-nav/microsoft.dynamics.nav.management/export-navdata to export your data to file and then include in the .navx package.
- 	Following a community suggestion from GitHub, IntelliSense has been improved to help writing pages faster (and other objects which have fields based on source tables)
When coding the page fields, use the snippet tfieldpage, then position your cursor as shown and invoke IntelliSense (Ctrl+Space) to choose which field to populate.

- Tenant-specific profiles

   With this update, we introduce the system capability to define tenant-specific profiles. This has been one of the most requested features by partners who create extensions. You'll be able to use full capability of this feature in upcoming developer preview when we deliver compiler support to define a new tenant-specific profile directly in AL code. This update delivers only the underlying platform capability enabling extensions to define profiles.

   As a consequence of adding this feature we expanded the UI around Profile creation and selection to differentiate system-wide profiles from tenant-specific profiles. Now the page which is listing profiles identifies profile scope which is either System or Tenant. Additionally, in case a profile is introduced when installing an extension, you'll be able to see the extension name on that list.
   The profile card has been changed in similar way. Now you must choose the scope of new profile depending on a need to create a profile which is common for all tenants or tenant-specific.

   *Note: in Dynamics 365 for Financials the System option isn't available – a tenant administrator is not able to create System profiles, which would be shared with other tenants. The only option is to create a tenant-specific profile.*


   Stay tuned until the next update when you will be able to fully use this feature in your extensions.

- Other notable fixes:
    - Highly requested virtual tables are now available: User, Field, AllObj, AllObjWithCaption etc.
    - Powershell cmdlet support for exporting objects into new syntax.

# April Update (0.4.9209 - 2017/04/21)

Welcome to the April update for the Developer Preview. Again this month we've been working on a lot of exciting stuff. Check out the list of what's new below.
- GitHub reported issues fixed in this release: https://github.com/Microsoft/AL/milestone/5?closed=1
- Query and XmlPort objects have been added to the compiler.
- This update contains a conversion tool that allows you to take existing Dynamics NAV objects that have been exported in .txt format and convert them into the new .al format. It's a two-step process; firstly exporting the objects from C/SIDE in a cleaned format, and secondly converting them to the new syntax. Give it a try by following these steps:
Export the objects using the command line. The client GUI doesn't have the switch available, so you must use the command line, for example for table with ID 225:
   ```
   finsql.exe Command=ExportToNewSyntax, File=exportedObjects.txt, Database="Demo Database NAV (10-0)", ServerName=.\NAVDEMO ,Filter=Type=table;ID=225
   ```

   Run the txt2al.exe converter tool. The tool is located in the ..\Program Files (x86)\Microsoft Dynamics NAV\100\RoleTailored Client folder. Usage:
   ```
   txt2al <Source directory> <Destination directory> [-rename]
    -rename - Name the output files based on the object name.
   Important: The conversion tool should only be used for export. Importing objects that have been exported can damage your application!
   ```
- You can now embed Permission Sets, Tenant Web Service definitions, and Custom Report Layouts in Extensions V2. The process is similar to the one that you used for Extensions V1 and you can follow the existing documentation: https://msdn.microsoft.com/en-us/dynamics-nav/how-to-export-data-for-an-extension.
- AL:Go! startup is under development to start supporting the choice between online and local development. For now, just select the Local server option.
Typing Ctrl+Shift+P opens the command palette where you can execute the AL: Go! command. This will still prepare an empty project for you to start with and now includes a step for choosing if you're working locally or against a cloud instance.

   *Note: When you do an F5 deploy you may be asked to enter your Azure account. This is a bug and because we haven't been able to set 'local' for your debug environment. To set this yourself, select the debug button from the left-hand menu and pick the local in the drop-down list for the configuration.*

- In the Designer, drag and drop a page part to reposition it on the Role Center or FactBox pane. You can also hide an individual part. For now, the only way to make the hidden part visible again is to uninstall the extension or modify the extension using Visual Studio Code.

- You can now reposition the Freeze Pane on any list page or part by using the jewel on the column header.
- The new Query and XmlPorts objects have snippet support as well. Take a look at tquery and txmlport. Here is an example of an XmlPort object in the new syntax:

# March Update (0.2.8249 - 2017/03/28)

Welcome to the March update for the Developer Preview. We continue to fix bugs reported by you on our GitHub issues list [https://github.com/Microsoft/AL/milestone/3?closed=1] and made other improvements.
Here's what's new:
- We're making you more productive in the Designer! You can now reorder columns with a simple drag and drop, and you can hide or show columns. Try it out on any page with columns, such as worksheets, sales documents, or lists.
- Report application objects join the list of supported objects! Create reports using new syntax and include them in your extensions.
Reports do support both Word and RDLC layout.
Layouts are now saved as external files. Save your layouts in a subdirectory of your VS Code project and then point to the file with the property wordlayout and rdlclayout.

   *Note: At this time we have basic support for reports. Reports can be authored and they compile and run, but we're aware there are advanced scenarios that may not work. We're working hard to fix these and also encourage you to file issues you find to our GitHub project.*

   *Note: Report development does not include an integrated designer experience i.e., integration with Visual Studio for RDLC is missing but the Word editor will show fields in the XML Mapping from the Developer tab.*

   Sample code has been updated on the Azure VM to include Report 101 - Customer List.

- You may define a dependency on another extension by listing it in the app.json configuration file. Taking a dependency will allow you to code against objects including page extension object and table extension objects in that extension. Symbols from the extension will show up in IntelliSense.

# February Update (0.2.7308 - 2017/02/16)

Welcome to the February update for the Developer Preview.As in the last two updates, we've fixed bugs reported by you on our GitHub issues list (https://github.com/Microsoft/AL/milestone/2?closed=1) and made other improvements.

You can see a list of what's new below:
- Finishing your design work in the client now offers two options on saving, allowing you to save the changes to the tenant for all users, or to save the changes to a file that you can work on later in VS Code.Performance of the designer has improved and is snappier.

- To guide users towards a better page design, we've been adding a few rules in the in-client designer. For example, you can only drop media fields onto card part pages. Also, you cannot drop a field under a repeater control, because this is not the design that list pages were intended for.

- Getting started in VS Code has been streamlined. Once you've installed the visx file, just enter AL: Go! in the command palette (Ctrl+Shift+P) and you'll be offered a new folder to build a solution in. The preset values are configured for your Azure Gallery instance and if you're missing the symbols for the project, VS Code will offer to download them for you. Note, we've introduced a shortcut for this too - Alt+A, Alt+L. Enjoy!

- We've made improvements in IntelliSense with contextual support for keywords in all objects - and we've added autocompletion and IntelliSense for setting values for the CalcFormula and TableRelation properties.
- You can now reference Query objects from the base application. This gives you the ability to declare variables of the type Query and call AL functions on them.
- References by symbols have been implemented meaning that you can find all references in an inline editor.Pressing Shift+F12 on top of a symbol will open a view that lets you jump to all instances of that symbol.Furthermore,selecting a symbol and pressing F2 allows you to rename all instances of that symbol. Note, that symbolic rename is cleverer than text matching and will only change the current symbol. For example, it will replace all instances of variable Foo, but not rename function Foo.
- Several AL variable types have been introduced mapping to the HTTP Client and JSON types. Using HttpClient, HttpResponseMessage, JsonObject, JsonToken, and JsonValue will allow you to access Azure functions and other Web services.

# January Update (0.2.6084 - 2017/01/14)

We've been bowled over by the positive comments from the community supporting this development effort. The team has read every suggestion, bug submitted, and idea and we're enthusiastic that you're so interested. That's why we're even happier to announce an update to the developer tools preview.

## The following is included in the update
- Fixed various bugs reported by the community in the in-client designer.
- You can now reference Report and XMLPort objects from the base application. This gives you the ability to use these objects in the RunObject property, as well as, declare variables of the types Report and XMLPort, and call AL functions on them.
- Improved IntelliSense for Pages and Tables. IntelliSense will offer keywords in Pages and Tables. The supported keywords will be offered in the correct context and are intended to help build the object correctly.
- IntelliSense for attributes. The list of available attributes will be displayed after typing '['. Each attribute will also include signature help showing the number and types of expected parameters. Also, IntelliSense for the EventSubscriber attribute offers lookup for the event name and the field/action name parameters which helps discover the available event publishers.
- Fixed miscellaneous bugs reported to us. Issues submitted to the GitHub project issue list that have been fixed have been marked as included in the January update.

# December Preview Release (0.0.1 - 2016/12/20)

We're excited to introduce you to the new tools you'll use to build extensions and apps in and for Dynamics NAV. This December preview is meant as an appetizer and way for you to try out what we have so far. We've been looking forward to showing you what the new tools look like and let you take them for a spin.
The tools that you'll be using come in two flavors and both are available in preview from today.

## The in-client designer

Make an extension in the client itself. Business consultants and UX designers will love using this drag-and-drop interface. Rearrange fields, rename groups, and reposition elements to build a perfect extension to support an industry-specific solution or implement a business process optimization.

## Visual Studio Code

Use the AL Extension for NAV in Visual Studio Code to build powerful extensions based on tables, pages, and codeunits using the new objects: Page Extensions and Table Extensions. Follow this route to build rich extensions that reuse and extend core business logic in your application.

## I'm keen! How do I get started?
Two steps to get set up and then you can put rubber to the road. First you need an Azure Subscription. If you don't have one, you can get a free 30-day trial from https://azure.microsoft.com/free/ that will give you access to everything you need. If you do take the trial, you will need to provide a telephone number and credit card, but these are for ensuring you're not a bot and you won't be charged.
Secondly, head over to http://aka.ms/navdeveloperpreview. Login to your Azure Subscription. Select your subscription, resource group, location, name, and a VM Admin Password. Leave the remaining fields as their defaults. Accept the terms, Pin to dashboard and select Purchase. The instance takes about 5 minutes to set up, and the VM will be ready about 15 minutes after Azure says Deployment Succeeded. So go get a coffee and come right back.

## How do I learn more?
Great question! We were hoping you'd ask that. Check out our docs:
- [Tools overview](https://go.microsoft.com/fwlink/?linkid=835954)
- [Getting Started guide](https://go.microsoft.com/fwlink/?linkid=835955)
- [Object overview and AL language changes](https://go.microsoft.com/fwlink/?linkid=835956)

## This is great - how do I share the love?
Are you as excited as we are? Then blog or tweet using the tags #dyndev365, #msdynnav, and #code. Collaborate with us by adding your product ideas. Do that in GitHub https://github.com/microsoft/al/issues.

## I found a bug - what do I do?
We're sorry - we're still in preview and still learning too. It would help us so much if you can track down the bug and tell us. During the preview, the best way to let us know is to file it as an issue in GitHub https://github.com/microsoft/al/issues. The sooner we know, the sooner we can patch it and get it back out there.

## New builds! Where do I get a new build?
While we're in preview we're going to be fixing as many of those bugs as we can and we'll be working on new features too. We'll update the image on Azure Gallery about every month and let you know here on the blog when we do. We're also working on a process to get them out faster but with Christmas and the New Year coming up, it might just take a bit longer the first time.
Another warning, when we do provide a new gallery image, we won't be able to provide any upgrade tools between the versions. We'll try our best to avoid breaking changes but there are no promises.
