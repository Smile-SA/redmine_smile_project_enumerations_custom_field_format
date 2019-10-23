redmine_smile_project_enumerations_custom_field_format
=================================================

Redmine plugin that adds new custom field format,
that allows to have **Enumerations** whose values are
**set in the project**

# How it works

## What it does

* Adds a new value in the CustomFiels types : **Project Enumeration**

* Adds a new premission : **manage_project_enumerations**

This permissions allow to edit Project Enumerations values for the project.
When a user has this permission a new tab appears in the Project Settings.

* Tested with **Redmine V4.0.3**

## How it is implemented

- Adds new **Redmine::FieldFormat::ProjectEnumerationFormat** derived form **RecordList**

- 🔑 Extends Projects Controller **settings** action

- 🔑 Extends Projects Helper **project_settings_tabs** method

- Adds new Project **shared_enumerations** method

# TODOs

* Test with other than Issue Custom Field (Project, ...)
* Add Admin view for all Project Enumerations
* Use status column, or remove it
* Add Tests (in progress)
* Fix TODOS

# Changelog

* **V1.0.4**  Tests added on issue show
* **V1.0.3**  Tests initialized

```console
# From plugin root, redmine_test mysql database must exist
scripts/test_it.sh
```

* **V1.0.2**  shared_enumerations fixed (namespaces)
* **V1.0.1**  Fixed redirect to Project enumerations tab after update
Project Enumeration status editable at creation
* **V1.0**  Initial version


Enjoy !

<kbd>![alt text](https://compteur-visites.ennder.fr/sites/36/token/githubpe/image "Logo") <!-- .element height="10%" width="10%" --></kbd>
