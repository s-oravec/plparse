# plparse

PL/SQL Parser - only toplevel AST node types, but good enoug for me.

## Install scripts

You can install either from some privileged deployer user or from within "target" schema.

### set_current_schema

Use this script to change `current_schema`

```
SQL> @set_current_schema <target_schema>
```

### install

Installs module in `current_schema`. (see `set_current_schema`). Can be installed as 

- **public** - grants required privileges on module API to `PUBLIC` (see `/module/api/grant_public.sql`)

```
SQL> @install public
```

- **peer** - sometimes you may want to use package only by schema, where it is deployed - then install it as **peer** package

```
SQL> @install peer
```

### uninstall

Drops all objects created by install.

```
SQL> @uninstall
```

## Use plparse from different schemas

When you want to use **plparse** from other schemas, you have basically 2 options
- either reference objects granted to `PUBLIC` with qualified name (`<schema>.<object>`)
- or create synonyms and simplify everything (upgrades, move to other schema, use other plparse package, ...)

These scripts will help you with latter, by either creating or dropping synonyms for **plparse** package API in that schema.

### set_dependency_ref_owner

Creates depenency from reference owner.

```
SQL> conn <some_schema>
SQL> @set_dependency_ref_owner  <schema_where_plparse_is_installed>
```

### unset_dependency_ref_owner

Removes depenency from reference owner.

```
SQL> conn <some_schema>
SQL> @unset_dependency_ref_owner  <schema_where_plparse_is_installed>
```
