# General naming conventions

Now, let's discuss how we approach naming conventions. As was mentioned in [Learning guidelines - Domain Driven Development](../learning-guidelines/basic-principles.md#domain-driven-development), all is based on common vocabulary that is shared among our programmers.


## Shared conventions between projects

The shared vocabulary is also shared between projects, as much as possible. User in one project, means the same thing in all other projects. 

Of course, every project has a unique set of words, but we try to share as many of these as possible, with other projects of similar type. 

## Singular vs Plural

We use singular and plural forms in natural form, for example, if we have a database provider working with users, the name of that provider would be _UsersProvider_, because it works with all users, and not just a single user.

## Same conventions through the system

Few more examples:

- REST endpoint would be _/api/users_
- Javascript provider calling that endpoint would be _usersProvider_
- Svelte component would be stored in folder _Users_ and it's name would be _Users.svelte_
- ASP.NET controller handling _/api/users_ endpoint would be called _UsersController_
- manager handling users would be called _UsersManager_
- provider handling users would be called _UsersProvider_
- database table would be called _\_user\_info\__, because _user_ is a keyword, but names of tables are in singular form
- database view joining users' data to complete view would be called _users_, names of views are in plural form
- database stored function to create a user would be called _create\_user_, to retrieve user would be called _get\_user_ and to retrieve all users would be called _get\_users_ 

As you can see in the example above, we keep the same naming convention for all the way through all layers of application, from client side, to database.

## Used verbs

This is a list of standard verbs we use to describe an action:

- Create
- Update
- Delete
- Get - get functions return object(s) as they are, in a complete set
- Search - search functions return object(s) based on criteria and paging settings (page size, page number)
- Process - process functions are used for mass processing of data, for example, when you import data to a _stage_ table and then run a function that process them to final data stored in _public_ table
- Map - map functions are used for mapping objects from one type to another, generally speaking, for data transformations

There are also some specific verbs we use to describe specific actions:

- Generate - generate functions generate data based on inputs
- Parse - parse functions parse input data, usually, CSV files, Excel sheets, text files, and others
- (Bulk)Copy - copy functions are special functions that, usually, copy data in big chunks to database with _COPY_ command
- Send - send methods are used for actions related to email, SMS or other notification service, for example, _SendEmail_, _SendNotification_, and so on

## Name structure

Names in our framework follow these simple rules:

- For object names: [noun in plural form] + [object type name], for example, _UsersController_, _UsersHelper_, _UsersManager_, and so on
- For endpoints: [noun in plural form], for example, /api/users, /api/groups, and so on
- For data tables: [noun in singular form], for example, _user_, _user_group_, _user_group_member_, _user_setting_, and so on
- For object methods and stored functions in database: [verb]+[noun, usually in singular form], for example, _CreateUser_, _DeleteUser_, _CopyUsers_, _ParseUserGroupMembersCSV_

There are also rules that specify hierarchy of names:

- For example, _User group member_ is divided in to primary object, and secondary object. Primary is _User group_, secondary _Member_
- When you name a method that creates a secondary object, use both names, for example, _CreateUserGroupMember_, do not omit primary object, be specific
    - If you create a provider named _UserGroupsProvider_, you can name the method _CreateMember_, because the primary object is defined by the provider name
- Do not use abbreviations, for example, _CreateUGMember_, use full primary and secondary object names
- If you create a database view, primary object name is in singular, secondary in plural, for example, _user\_group\_members_
- If you create a database function, primary object name is in singular, secondary in plural, for example, _search\_user\_group\_members_

## Language specific conventions

There are language/framework specific naming conventions for every language/framework we use. 

<div class="grid cards" markdown>

- [__C#/.NET__ ](../coding-guidelines-csharp/naming-conventions.md)
- [__Elixir__](../coding-guidelines-elixir/naming-conventions.md)
- [__PostgreSQL__](../coding-guidelines-postgres/naming-conventions.md)
- [__Svelte.dev__](../coding-guidelines-svelte/naming-conventions.md)

</div>