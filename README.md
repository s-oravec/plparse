# plex

PL/SQL Lexer - far from 100% bulletproof, but good enoug for me.

1. plex.initialize
1. plex.next_token
1. plex.next_token
1. ...

or 

1. plex.intialize
1. plex.tokens

## `plex.initialize`

Initialize Lexer with `source_lines`

**Parameters**

- `source_lines` - source lines of stored procedure (package, function, ...)

## `plex.next_token`

Get next token and then next ...

**Return**

- `plex_token` - single token

## `plex.tokens`

Get all tokens

**Returns**

- `plex_tokesn` - table of `plex_token`

## Package scripts

Connect as DBA or privileged user (`SYS` is the best) and

### create

Create schema for **plex** as configured in `package.sql`

```
SQL> @create configured <environment>
```

Or create in interactive mode 

```
SQL> @create manual <environment>
```

**Choose from &gt;environment&lt; values**

- `development` - for development of **plex** package - schema receives more privileges
- `production`  - if you just want to use **plex**

### grant

Or you may wish to install plex in already existing schema. Then use the `grant.sql` script to grant privileges required by **plex** package.
Pass **environment** parameter to grant `development` or `production` privileges.

```
SQL> @grant <packageSchema> <environment>
```

### drop

Again either configured or manual. **And it drops cascade. So be carefull. You have been warned**

```
SQL> @drop configured
```
or
```
SQL> @drop manual
```

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

## Use plex from different schemas

When you want to use **plex** from other schemas, you have basically 2 options
- either reference objects granted to `PUBLIC` with qualified name (`<schema>.<object>`)
- or create synonyms and simplify everything (upgrades, move to other schema, use other plex package, ...)

These scripts will help you with latter, by either creating or dropping synonyms for **plex** package API in that schema.

### set_dependency_ref_owner

Creates depenency from reference owner.

```
SQL> conn <some_schema>
SQL> @set_dependency_ref_owner  <schema_where_plex_is_installed>
```

### unset_dependency_ref_owner

Removes depenency from reference owner.

```
SQL> conn <some_schema>
SQL> @unset_dependency_ref_owner  <schema_where_plex_is_installed>
```
