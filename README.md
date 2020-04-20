redmine_smile_project_enumerations_custom_field_format
=================================================

Redmine plugin that adds new custom field format,
that allows to have **Enumerations** whose values are
**set in the project**

# How it works

## What it does

* Adds a new value in the CustomFiels types : **Project Enumeration**

  To manage a **Key / Value list** whose possible values are configured in the project.
  The **key is stored** in the **custom_values** table

* Adds a new value in the CustomFiels types : **Project Values List**

  To manage a **Values list** whose possible values are configured in the project.
  The **value is stored** in the **custom_values** table

* Adds a new permission : **manage_project_enumerations**

  This permission allows to edit Project Enumerations values for the project.
  When a user has this permission, 2 new tabs appear in the Project Settings (depending if Custom Fields of the new type exist or not)
  - **Project Enumerations**
  - **Project List of Values**

* Manages Enumeration **statuses** like for Versions :

  If Enumeration is **locked** or **closed**, possible value will not be present in the dropdown list (depends on the Custom Field status configuration) :

  ![Example of status configuration](https://user-images.githubusercontent.com/540464/79513668-aefa6b80-8044-11ea-91a5-0158912c47fc.png "Example of status configuration") : 
  
* Splits Custom Field Project configuration **by Tracker**

  * **Rewrites** **app/views/projects/settings/_issues.html.erb**

    C.f. : [Redmine Patch : Project Custom Fields configuration : split by tracker](http://www.redmine.org/issues/30739)

  * Adds three **Hooks** in this **partial** :
    * **view_project_settings_tracker_before_checkbox**
    * **view_project_settings_tracker_after_checkbox**
    * **view_project_settings_issues_custom_fields**

* Tested with **Redmine V4.0.3**

## How it is implemented

- Adds new **FieldFormat** derived form **RecordList**
  - **Redmine::FieldFormat::ProjectEnumerationFormat**
  - **Redmine::FieldFormat::ProjectListValueFormat**

- 🔑 Rewrites Projects Controller **settings** action

  To manage : Project Custom Fields configuration, split by tracker (optimization)

- 🔑 Extends Projects Helper **project_settings_tabs** method

- Adds new methods to **Project** model
  - **shared_enumerations**
  - **shared_list_values**

- Adds new **Controller**
  - **ProjectProjectEnumerationsController**
  - **ProjectProjectListValuesController**

- Adds new **Views**
  - for **possible values** CRUD **edition**
    - in **views/project_project_enumerations**
    - in **views/project_list_values**
  - for **Custom Field** **Configuration**
    - in **views/custom_fields/formats**
  - 🔑 **Rewrites** partial **app/views/projects/settings/_issues.html.erb**

# Testing

```console
# From plugin root, redmine_test mysql database must exist
scripts/test_it.sh
```
* Tested with other than Issue Custom Field (Project, Version, ...)

# TODOs

* Add Admin view for all Project Enumerations
* Add more Tests
* Fix TODOS
* Edit position for shared values

# Changelog

* **V1.3.13** Compatibility with **Redmine Issue Templates plugin**

  Project settings tabs : manage controller in allowed_to? in **project_settings_tabs_with_project_enumerations**

* **V1.3.12** Fixed permission name : **edit_project_list_values** -> **manage_project_enumerations**
* **V1.3.11** Fixed Project settings **Issue Tracking** tab not visible for Redmine < 4

  With Redmine 4, **Trackers** / **Custom Fields** settings have moved to a new tab
  And **Modules** tab has been merged to **Information** tab

* **V1.3.10** Fixed error with Postgresql : is_for_all = 1

  PG::UndefinedFunction: ERROR:  operateur boolean = integer does not exist

* **V1.3.9**  Project Custom Fields configuration, split by tracker : optimization
* **V1.3.8**  Value field input : 40 -> 80 characters
* **V1.3.7**  Fix : Project enumeration on project, bug at project creation

  Fixed a native bug : Projet has project method (self) making think that it has project permissions to check !

* **V1.3.6**  Fix : scope enabled_on_project, test if project nil
* **V1.3.5**  Extends size of Project Enumerations value column : 60 -> 255 cars
* **V1.3.4**  Enable formats on UserCustomField
* **V1.3.3**  Lower constraint on rails version : 4 -> 3.4
* **V1.3.2**  Fix migration file name, remove one 0 at the end
* **V1.3.1**  Fixed missing partial **_custom_field_checkbox.html.erb**
* **V1.3.0**  Splits Custom Field Project configuration **by Tracker**

  * (+) Add 3 Hooks in **app/views/projects/settings/_issues.html.erb**

* **V1.2.2**  Manage **is_for_all** Custom Fields

  * (+) BugFix target_class : Model shared with ProjectEnumeration for ProjectListValueFormat

* **V1.2.1**  BugFix show only Project Enumeration values for project, or shared to project

  * (+) Show list of not enabled List Values Custom Fields
  * (+) Show tab in project settings only if at least one Custom Field of the type exists

* **V1.2.0**  Display not enabled project enumerations, single page to edit List Values like Enumerations

  * Display errors on project enumerations update.
  * Edit other than Issue Custom Fields project

* **V1.1.0**  Fix XSS issue with Project Enumeration value edition
* **V1.0.9**  Project Enumeration create, render model errors
* **V1.0.8**  Project Enumeration sorting by position, + create Project Enumeration at the end
* **V1.0.7**  Project Enumeration edition like Key/Value edition : single page by Custom Field
* **V1.0.6**  New Project List of Values type added
* **V1.0.5**  Tests added on issue edit, disabled possible values (locked, closed)
* **V1.0.4**  Tests added on issue show
* **V1.0.3**  Tests initialized
* **V1.0.2**  shared_enumerations fixed (namespaces)
* **V1.0.1**  Fixed redirect to Project enumerations tab after update

  Project Enumeration status editable at creation

* **V1.0**  Initial version


Enjoy !

<kbd>![alt text](https://compteur-visites.ennder.fr/sites/36/token/githubpe/image "Logo") <!-- .element height="10%" width="10%" --></kbd>
