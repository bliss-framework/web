# Layers of application

In this section we will show you how we divide code into layers. It's a system that works for us for decades, it's easy to understand and it's clearly defined.


## The trio that describes them all

All our applications are divided to three basic layers. These layers can be easily visualized layers of customer service in, say, McDonald's restaurant.

- Input/output layer
- Management layer
- Providers layer

The diagram below describes basically all applications and systems, we have encountered and written.

``` mermaid
sequenceDiagram
    User->>I/O: Gives request
    I/O->>Management: Accepts input
    Management-->>Management: Decides what to do?
    Management->>Provider A: Tells "Do something"
    Provider A->>Management: Returns result
    Management->>Provider B: Tells "Do something else"
    Provider B->>Management: Returns different result
    Management-->>Management: Combines results
    Management->>I/O: Returns results
    I/O-->>I/O: Repacks result to desired output
    I/O->>User: Returns output of whole processing    
```

If we look at this diagram from point of already mentioned McDonald's restaurant: 

- Kelly (customer/user) tells Peter behind counter what he wants to order
- Peter validates the order and if it's alright, creates an order ticket and gives it to Shay (manager)
- Shay checks the order and decides, based on the order, that two providers Otis (provider of ice cream) and Gabby (provider of burgers) have to work on that order
- When Otis and Gabby are done, not necessarily at the same time, they give their outputs, ice cream and burgers, back to Shay
- Shay waits for all outputs to be done, when they are, pack them together and returns them to Peter
- Peter packs the ice cream and burger into a bag, gives it back to Kelly

This example shows you that programming and real world can be quite close to each other and there is no real need to create more complex structures in absolute majority of applications.

But, now, just to be sure, let's look at bigger detail what each layer does.

### Input/output layer

Input/output layer is the layer that communicates with outside world in sense of communication with user, system, other tool and so on. This is the barrier between the system and outside world.

It's this layer that accepts inputs, validates them, send them to lower layer of the system, and then, when output is generated or processing is done, returns the result. It's this layer that repacks the output, if necessary, or compress it, or give a metadata about it. Until this point, data are coming in clean form from lower layers of the system.

### Management layer

Management layer is the layer that actually decides what needs to be done. It's this layer that communicates with different providers and tells them what to do.

You can have different managers for different tasks but their responsibility is only to tell others what to do. There is nothing more to it.


### Providers layer

Providers layer is the layer that actually does something. This is the layer that retrieves or store data to database, create or delete file, communicates with different systems, you name it.

There is a catch, though, the basic characteristic of providers is they have only single purpose and they don't know about other providers. For example, there is absolutely zero need for a provider of hamburgers to know what provider of ice cream does. That is manager's job. Providers do only what they are told.

!!! warning "Remember"

    It is absolutely crucial to keep providers separate from each other. There must be no calls between each providers. If the task requires work of two providers, or one provider needs output from another provider, then manager is the one that have to arrange that.

    ["Don't cross the streams"](https://www.youtube.com/watch?v=wyKQe_i9yyo)


## Side layer

"What side layer? This was not mentioned above, what are you talking about?" - we can clearly hear you.

Side layer is the layer that contains, generally speaking, not necessary, and yet helpful parts of your code. You could live without them, they usually have no impact on data processing, but they tend to make your life easier in long run, thanks to reusability of your code and conciseness.

Visually, you can imagine the side layer as a column standing next to the Trio of basic layers. It's a layer of code that is independent on those three.

As a general rule, we can say, that if you see a piece of code that has a potential to be repeated in different parts of your code, it belongs to side layer.

For example, imagine you want to ensure (create, if it doesn't exist already) a folder. You could put that piece of code in your provider, but it would be more useful to put it to `DirectoryHelper`, and call DirectoryHelper from provider instead. This way you can take that helper with you to another project, and the code to ensure directory is only at one place.

We are going to mention just few different types of objects in Side layer

### Models

Models as data containers that you have in your application. Models have no internal logic, they are mere vessels for data. Models ensure consistency of your data in the application.

For example, when you load data from database, you could just store them into an array, and retrieve them with index, but this is quite dangerous. What if the data structure in database changes, column order would be messed up. 

As was explained in [Learning guidelines / Protect yourself with abstraction and encapsulation](../learning-guidelines/basic-principles.md#protect-yourself-with-abstraction-and-encapsulation), by using plain models with standard types, you protect the rest of your application from future changes.

In real life, a model would be paper box (data container), where you put a burger (data).

### Mappers

Mappers transform data, either from one model to another, or to some other structure based on what is needed. You would typically use mappers when loading data from database.

In real life, this would the person that packs burgers into paper boxes.

### Helpers

Helpers are simple tools that do simple tasks that generic in nature. For example, you could have a _DateHelper_ that calculates time difference between two dates, or gives you date of next full moon.

Helpers really have no internal logic or memory, they are used only as tools, that's all they are.

In real life, a helper would be a person that puts lids on Coca Cola cups. Yes, a _DrinkProvider_ could do that job himself, but he can also delegate that work to a helper.

### Constants and Enums

As was mentioned in [Learning guidelines / Don't repeat yourself](../learning-guidelines/basic-principles.md#dont-repeat-yourself), we are quite militant about having string, or numeric, values stored deep down in code, we put everything in Constants, or Enums, folders and everyone knows where to look for them.
