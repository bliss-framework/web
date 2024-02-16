# Coding guidelines

In this section, we'd like to explain our general principles that you can find in our framework. Our code structure is easy to understand and we can use real life examples to explain it.

The [Impureim sandwich principal](../learning-guidelines/functional-vs-OOP-programming.md#impureim-sandwich-principal) section described main principle our code structure. Most of our code is written in pure style and so it's easy to write, test and most importantly trust it.

## To divide and conquer

Before we tell you about out code structure, we need to have a discussion about why should you bother to divide code into small pieces, like we'll show you below. Why bother when you can write it in one file, in one function even, right?

Over the years, we have all in our team written dozens of different apps, and if we were to write them all in one file, without any code division to reusable parts, it would take us so much more time.

When you start programming, you have nothing, but with each project, you create your own library of reusable pieces of code, library that in each next project you enrich, you reuse, you make your own go to library. This will make you a lot faster, and instead of a coder, which spends time writing the same code over and over, you'll become a programmer that appears like a magician.

So divide and conquer.

## The code structure

All our applications are divided to three basic layers.

- UI/input/output layer
- management layer
- data providers layer

