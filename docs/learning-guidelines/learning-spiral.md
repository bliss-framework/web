# Learning spiral

Imagine that all knowledge about certain technology, language or library is a plane, where different aspects of it goes to different directions, see example below. When you start learning it, you always start in the middle.

![ASP.NET Core - Example of your knowledge about it](../assets/images/aspnet_core_star_diagram.png){ align=left }

As you can always go only one direction, or two, you can never go more, and that's the biggest problem with learning something new. When you focus too much on one direction, you'll miss the rest of them.

That's why we learn in a spiral. We always start with the simplest thing possible, which is installation, and then we start collecting knowledge by small dips, here and there.

!!! warning "Remember"
    Knowledge is like a bucket of ice cream you just pulled out of your freezer. If you try to scrape too much of it with your spoon, or you go too deep, it will be too hard, almost impossible to do. If you go slow and shallow, you get to enjoy some of the ice cream, while the rest starts melting down on you, after a while you can go deeper and deeper.

## Repetitio est mater studiorum

!!! note "Bruce Lee said" 
    I fear not the man who has practiced 10,000 kicks once, but I fear the man who has practiced one kick 10,000 times.

There is no way around it, until you repeat something 10s, 100s and even 1000s of times, it won't be truly stored in your brain.

We understand, we live in the age of ChatGPT and Copilot, in times of easy code generation, it's almost like magic, but, in the end, you are just cheating yourself, you cannot learn something by watching someone else do it for you.

There is a silver lining in all of this, though. The more you repeat tasks in one technology, the easier is to learn another. Your brain will start to see patterns and similarities in different technologies, and with each technology it will be more simple and easier.

So buckle up, start with the basics, repeat them while always adding some small portion of something new.

An example of how to approach this:

    - create a Svelte application
    - delete it
    - create another Svelte application
    - delete it again
    - create yet another Svelte application
    - run it
    - delete it
    - create another Svelte application
      - at this point you start to wonder how to create them faster and start looking at the command line arguments
    - run it
    - see the outcome of build in your browser
    - change something in the generated page
    - check the outcome again
    - delete the app
    - start all over


This is the fastest way how get familiar with some technology, in spiral manner, and also create muscle memory that gives you confidence.


## Experience comes with time

Part of being a programmer is the rush of beating something complex, something hard to learn, something hard to program. This rush that comes from our ego is the main motivator of most programmers, the problem with it is, that it leads us on paths that are unnecessarily complicated and too hard to follow.

Another problem comes from our competitiveness, from measuring with others, usually much better programmers. This will not help you in any way. While seeing what is possible is certainly great, you cannot skip ahead of time.


The video below shows a furniture maker that built a marvelous workbench, it has all features possible, it's state of the art. It took this skilled furniture maker 2 months to build it. 

<iframe width="560" height="315" src="https://www.youtube.com/embed/pvVrVdqA9OE?si=HVc9nPo98_LTJj9N" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>

Young inexperienced carpenter might be tempted to build this on his own. After all, what can be better, why bother with simple workbenches you can build from construction lumber, this is the masterpiece, this is the final destination, right? 

__Wrong.__

Even if he was able to build it, trust us, it's MUCH harder than it looks on video, it would take him so too much time and in the end, he would not be able to appreciate what he has built, he would lack the experience and reasons to build a better workbench like this one.


!!! warning "Remember"
    
    You have to start with simple tools to be able to appreciate more complex ones.


## Can we actually teach you something?

Yes and No. As was stated above, even if we tell you to do something 100 000 times, you still won't be able to fully understand it and accept it. This will only come with time, so you have to trust us and our system.

This happened to us many times before, and it will happen many times in the future.

Great example.

If we tell you that this piece of code

=== "C#"

    ``` c#
    
    public bool CalculateHeroDamage(int baseAttackMin, int baseAttackMax, int baseArmor, int missChance = 5) {
      return new Random().Next(1, 100) <= missChance ? (new Random().Next(baseAttackMin, baseAttackMax) - baseArmor) : 0;
    }
    ```

is worse than this piece of code

=== "C#"

    ``` c#
    
    public bool CalculateHeroDamage(int baseAttackMin, int baseAttackMax, int baseArmor, int missChance = 5) {
        var random = new Random(DateTime.Now.Milliseconds);

        var missed = random.Next(1, 100) <= missChance;
        var attack = random.Next(baseAttackMin, baseAttackMax);
        var result = missed ? ( attack - baseArmor) : 0;
      
      return result;
    }

    ```

you will not believe us. Even if we tell you, it's better for debugging and the code is optimized by compiler, at some point in your career, you'll be tempted to use the first variant. The first variant is so slick and slim, the second one is for old programmers that cannot comprehend good, high quality code anymore. We get it, we've all been there.

After a while, you'll also start to prefer long term readability over coolness factor. It's a slow but natural process.