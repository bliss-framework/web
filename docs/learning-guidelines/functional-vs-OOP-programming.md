# Functional vs Procedural vs OOP programming

As you might already know, or as you'll learn over the course of your career, there are three main groups of programming languages. 

- [functional languages](https://en.wikipedia.org/wiki/Functional_programming), represented, for example, by Rust, F#, Swift, Scala, and many others
- [procedural languages](https://en.wikipedia.org/wiki/Procedural_programming), represented, for example, by C, Pascal and others
- [object-oriented languages](https://en.wikipedia.org/wiki/Object-oriented_programming), represented, for example, by C#, Java, and many others

We won't cover every little aspect of these groups, there are better comparisons already out there. We'll just focus on the discussion which one should you use, and ultimately which one is the best.

- [Differences between procedural and OOP programming](https://www.geeksforgeeks.org/differences-between-procedural-and-object-oriented-programming/)
- [Differences between functional and OOP programming](https://medium.com/@shaistha24/functional-programming-vs-object-oriented-programming-oop-which-is-better-82172e53a526)

## Types of programmers

There are basically three different types of languages explorers, programmers that don't stick to one language their whole life.

### Militant

Militant programmers are those that claims one language, or philosophy (functional, procedural, OOP), is better than the others, and if you are not seeing it that way, use something else and don't bother them.

Militant programmers are convinced everything is possible and best done in the language/philosophy they use, and they are willing to spend hours and hours trying to solve problem at hand with what they use rather than accept there might be a better way to do it.

### Promiscuous

Promiscuous programmers are those that have really no allegiance to any language or philosophy and they simply use what is currently available, or considered best at that time and place. 

We are not really against that, free love and all ☮, but this leads to very fragmented landscape of your projects. You cannot possible learn all of these languages, so you write, most probably, low quality code in all of them.

### Pragmatic

Pragmatic programmers accept there are better languages for different domains of problems, they accept every philosophy brings different pros and cons.

Pragmatic programmers don't jump around from one language to another, but stick with just 2 or 3. And even if they stick with just one, they can apply principles of one language to another, of one philosophy to another.

It's also important to realize there are better packages helping you with different sorts of problems, and by combining languages you can achieve victory faster and with less pain.

That's what we are. We use C# (console, ASP.NET, WPF) mostly in corporate environments, we use Erlang OTP/Elixir for low cost/high reliability apps and we use Go for small tools, like our [db-gen](https://github.com/KeenMate/db-gen), which is a small console app generating code for database communication.

## Impureim Sandwich principal

Even in C#, which is an OOP language, we use principles of functional programming. Some of these principles are quite useful to having concise and easy to navigate code, and it brings us a lot of benefits.

The biggest benefit, we see that you should also incorporate in your programming, is so called [Impureim Sandwich](https://www.destroyallsoftware.com/screencasts/catalog/functional-core-imperative-shell).

As much as functional programmers try to convince us that everything can be done in pure functional style, when you write your first real life application with screen/database interaction, you'll see it's not so simple.

Functional style of programming is great for processing of data, for keeping your code clean, without unnecessary side effects, and that's where Impureim Sandwich comes in.

This principal basically states you can have messy, OOP style of code in top/bottom/and where it's necessary layer of the code, but keeps everything between pure.

## What do you mean pure and impure?

In short, pure functions are those functions

- that for the same input(s) always return the same output
- that are single purpose, for example, calculate sum of order items, calculate VAT, delete file, send an email and so on
- that do not create side effects, for example, function that sends emails, doesn't also create an order in database, it just send an email, and there is another function that just creates order

Impure functions, are also necessary

- they usually combine pure functions to greater functional blocks, for example, create an order, send email about it, clean user's basket
- they are not single purpose, they combine single purpose methods to complex process

## Don't be militant programmer

So don't be a militant programmer that sticks to just one thing, you'll just make your life harder than it has to be.

As you'll see, our code structure is mostly written in pure style, but we are not afraid of impure methods, they also need to exist.

!!! note "Remember"

    Use the tool that is right for the job, don't stick to hammer.
