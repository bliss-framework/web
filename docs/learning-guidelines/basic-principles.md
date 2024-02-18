# Basic principles

Beside our own experiences, we of course learn from others, and this is a list of basic principles we live by.

## Don't repeat yourself

The most important one is [Don't repeat yourself](https://en.wikipedia.org/wiki/Don%27t_repeat_yourself). We find this to truly define what we are and what our Bliss framework is about.

This principal says you should avoid repeating your code at multiple places. In all places, a single file, application, project or projects.

Why not to do it? It's quite simple, it generates and leads to errors, and it's more work to maintain.

We are quite militant about this. 

For example, when it comes to string constants in code, we don't allow ourselves to repeat it even once. We immediately put it in _Constants_ folder, where it belongs and in all other places use it as a reference.


## Protection by abstraction

!!! warning "Remember"

    [There's no problem in Computer Science that can't be solved by adding another layer of abstraction to it](https://stackoverflow.com/questions/2057503/does-anybody-know-from-where-the-layer-of-abstraction-layer-of-indirection-q)


You can find [definition and details of abstraction here](https://www.indeed.com/career-advice/career-development/abstraction-in-computer-science), but the basic idea is this.

Abstraction could be also called Obfuscation, because you obfuscate technical implementation details behind easy to use facade.

In real life, you see abstractions everywhere. When you use light switch you are effectively using abstraction of power circuit, you don't know what the light switch does, or how it works inside, you just know it has two positions, ON/OFF, and that's all you need to know for using it effectively.

In our framework, abstractions are also present everywhere. As you will see in [Coding guides / Layers of application](../coding-guidelines/layers-of-application.md), each layer of code represents an abstraction of functionality below this level.

For example, Management layer has zero idea of what kind of database our applications is connected to, it is the database provider that knows such thing, nobody else needs to know. 

__Abstraction does not only bring you simplicity and clarity in your work, it also brings you safety and a lot less of work.__

What this mean in practice? In practice, it means, that any code that could lead to leak of technical details to upper layers of code, must be reworked to general code that gives no such details.

Imagine, your application is connected to MySQL database, you have not abstracted this detail behind a provider layer and generic models, and you use MySQL data types all over your code base. At some point you will decide to switch to PostgreSQL, as you should, what this means for you? 

It means you will have to rewrite basically whole application to get rid of MySQL types and code, and use PostgreSQL instead.

If you would have hidden your database calls behind generic database provider and returned plain data models with standard types, all you would have to change, when switching to PostgreSQL, would be one database provider.


## Use only what you need

!!! note "Back in 2006 when RUP was the next best thing"

    Back in 2006/7, [RUP (Rational Unified Process)](https://cs.wikipedia.org/wiki/Rational_Unified_Process) was the next best thing. It was THE WAY how to manage your project. If you haven't used it, you were destined to failure, or so it was presented.

    Although, RUP has certain values that were novel and definitely brought new wind to stale corporate development, it also brought misunderstanding of how it is supposed to be used.

    RUP described dozens of roles people in a project could be assigned to, but the main idea was to use only what you need. This basic idea was unfortunately 'lost in translation' and many projects tried to implement RUP to the letter, __unsuccessfully__.


When you start programming, you usually start by reading some book, or watch a tutorial on YouTube, or follow some Twitch streamer. They might show you this super cool way how to do stuff, or worse, they might tell you how things are supposed to be done, they might tell you that is the way it has to be.

Don't you think, we were different. Everyone falls for this trap. One way or the other.

For example, interfaces in C#, an abstraction of an abstraction, a tool very useful in cases when you want one functionality being implemented by multiple different providers. Example? _ICoffeeMaker_ with a method _MakeCoffee_ being implemented by _TurkishCoffeeMaker_, _IrishCoffeeMaker_, and so on.

The thing is, if you have only one provider of coffee in your application, there is zero sense creating an interface that will add yet another layer of abstraction, that is completely unnecessary at that point and will only slow you down while traversing or modifying your code. 

So use things only when you really need them, do not use them prematurely just because someone told you so.

