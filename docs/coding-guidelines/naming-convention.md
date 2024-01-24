# Naming

## Class

Always use PascalCase for class names. Try to use noun or noun phrase for class name. Do not give prefixes. Do not use underscores.

```cs
public partial class About : Page
{
   //...
}
```

## Methods

Always use PascalCase for method names. Use maximum 7 parameters in a method.

```cs
public string GetPosts(string postId)
{
   //...
}
```

!!! warning
    Don't use name as all character in CAPS.

## Arguments and Local Variable

Always use camelCase with method arguments and local variables. Don't use Hungarian notation for variables.

```cs
public string GetPosts(string postId
{
   int numberOfPost = 0;
}
```

!!! warning
    Don't use abbreviations for any words and don't use underscore ( _ ) in between any name.

## Property

Use PascalCase for property. Never use Get and Set as prefix with property name.

```cs
private int _salary = 100;
public int Salary
{
    get
    {
        return_salary;
    }
    set
    {
        _salary = value;
    }
}
```

!!! warning
    Don't use name with start with numeric character.

## Interface

Always use letter "I" as prefix with name of interface. After letter I, use PascalCase.

```cs
public interface IUser
{
   /// <summary>
   /// Check user is exists or not
   /// </summary>
   /// <returns>return bool value</returns>
   bool ValidateUser();
}
```
