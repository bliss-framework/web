# Coding guidelines

In this section, we'd like to explain our general principles that you can find in our framework. Our code structure is easy to understand and we can use real life examples to explain it.

The [Impureim sandwich principal](../learning-guidelines/functional-vs-OOP-programming.md#impureim-sandwich-principal) section described main principle our code structure. Most of our code is written in pure style and so it's easy to write, test and most importantly trust it.

## To divide and conquer

Before we tell you about out code structure, we need to have a discussion about why should you bother to divide code into small pieces, like we'll show you later. 

Why bother when you can write everything in one file, in one function even, right?

Over the years, we have written dozens of different apps, and if we were to write them all in one file, without any separation of reusable parts, it would take us a lot more time than necessary. We value our lifetime and so we write reusable code.

When you start programming, you have nothing, but with each project, you add a little reusable piece of code to your own library, library that with each new project gets bigger and bigger, and that makes you faster and faster. 

Reusable code makes you a ninja, quick and deadly to any task thrown at you.

So divide and conquer.
