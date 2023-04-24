# Pet Store project stuff

## What it is

Sample project with

- Animal store
- Database with
  - Users (with auth)
  - Animals
- can buy animals

## General stuff

- Remember to use PRs for feature things
- When generating stuff (`mix phx.gen.thing`, but also `mix phx.new`) use
  - One commit for generation
  - A second commit for edits -> makes edits explicit
- Always sign commits with gpg key -> in usb private/public keys

## Project

REST json-only project

### Commit format

```
filename: short changes

verbose thing

Sign-off-by: name
```

Using `git commit -S -s`

- `-S` -> git config
- `-s` -> vscode config

### Auth

Check if standard generation for authentication `mix phx.gen.auth`
only works with html stuff or is useful for API things as well

#### Result

```
mix phx.gen.auth must be installed into a Phoenix 1.5 app that
contains ecto and html templates.

    mix phx.new my_app
    mix phx.new my_app --umbrella
    mix phx.new my_app --database mysql

Apps generated with --no-ecto or --no-html are not supported.
```

It is still possible to run the generation on an html project and then try porting the changes
to this api-only project, but it's currently tbd.

### Releases

Generate dockerfile
`mix release --docker`

### Validations

Data should be checked before insertion e.g. `:age >= 0`

## Who can do what

### Anyone

Query animals - external
Log in
Create account

### User

Buy animals
Check their own order history

> Maybe consider (same) account deletion in the future

### Admins

Query animals - internal (arrived: datetime)
Insert new animals
See all the transactions

## Structure

### Animals

Attributes

- Name
- Birth
- Species
- Color
- Arrival

### User

Attributes

- email
- hash_password
- last login:utc_datetime
- deleted_at:utc_datetime

### Admin

Attributes

- id
- hash_password
- hiring_date

> They never get fired for now
