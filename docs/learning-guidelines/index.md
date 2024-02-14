# Learning guidelines

This guideline is more like a summary of how we approach learning new technologies and frameworks.

It all comes down to your precious lifetime, that's what you have very limited amount. That's why we have created this self defence style of learning new technologies, to invest as little of that lifetime as possible.

## How it was back then?

Learning new technologies is not really what it used to. Back in 1990's or 2000's when you've learned something, it really stayed with you for years to come. For example, if you started learning .NET Framework in 2003, the knowledge was applicable up to, say, 2015, only then the framework started to change a bit more.

In Javascript world, if you have learned jQuery in 2005, you can still use it in 2024.

Back then, technologies were not climbing over each other like a pack of hungry zombies, trying to get and top and falling down to be forgotten and lost forever. Back then, there was a limited number of technologies you could focus on. Back then, technologies were something you knew, if you invested your lifetime, it would give you more power over them, more control, it would bring you success.

The amount of knowledge you could learn had virtual boundaries, it was just up to you to invest enough to learn it. And this was how you got on top, how you got respect and fame.


## How it is today?

We are living in a completely different world now. Just look at [this Javascript library/framework benchmark](https://krausest.github.io/js-framework-benchmark/index.html), there is like 30 of libraries and frameworks. They are all trying to get on top, but most of them could and will die just tomorrow, next week or next year. 

The main problem is that back in the days of few frameworks, these frameworks were usually completely proprietary or at least an open source project backed by big companies. And since there were just few open-source projects, developers were working just on them. That has changed dramatically. We now have hundreds, thousands, maybe even tens of thousands of open source projects (libraries, frameworks, tools). Focus of open source developers is too fragmetalized these days, they have less time for each project, and quite often these projects die because of that, and that just adds to overall frustration with working on an open source project.

Another reason is that open source projects are controlled by people, that for some reason stop taking care of them, as an example we can look at [popular NuGet server](https://github.com/loic-sharma/BaGet). Its owner has not accepted any pull request from other developers, or made any commits to its repository for 2 years. It's a project on GitHub with 2500 stars, and nothing can be done about it.

!!! note "Real life example"

    Back in 2019, notice we talk about 2019 like it was millenia ago, if you wanted to create a `VueJS v2` project you would use Webpack compiler/bundler, it was so complicated to set up properly, almost endless depth of documentation and knowledge.

    Then it was replaced with [RollupJS](https://rollupjs.org), the next best thing for compilation/bundler. Completely incompatible with Webpack. A year or two later came [ViteJS](https://vitejs.dev), yet again a replacement for Rollup, but this time it partially shares Rollup configuration.
    Now we are preparing for next best thing, we expect it to come any day now. Perhaps [Bun.sh](https://bun.sh), replacement of NodeJS, will bring that.

    VueJS v2 has also switched to VueJS v3. Projects are being created differently and they use different Javascript packages.

    So it's 2024, we had a project from 2020 in VueJS and Webpack, and we have to completely rewrite it to the new thing, because we are not even able to compile it anymore, or download the tools for compilation.

    __4 years old project and it's obsolete and needs a rewrite. This is the new reality we live in.__ 

## Where does this leave us?

So how to live and learn in this new world of non-lasting technologies and frameworks.

- first learn to distinguish what technology is going to last and which is not
  - this can be deduced by who is backing it up, is it a huge community, is is a big company like Google
  - check the GitHub repository to see when was the latest commit and if there are any active forks
- try not to jump on every buzz technology. Very few of them will survive more than just few years
- ready yourself that your beloved technology might be abandoned or transformed to something else at any point in time
- if you really want to be safe, go with big boys. Use technologies used by Microsoft, Google, Apple, Amazon and so on, or with technologies that are here for a long time. For example, PostgreSQL, Erlang OTP, Java, .NET
- also notice how complicated the technology is. As much as some programmers have a fetish for complexity and mastering it, usually the technology that is quite complicated and harder to use won't survive. People like simple things, in the end

!!! note "Real life example"

    In 2008, Microsoft came up with Windows Presentation Foundation (WPF), replacement for Windows Forms, which were with us from 2002. Both of these technologies are still usable, they are still relevant. We are actively using WPF for a bigger app for one of our clients. It's not going anywhere. 

    On the other hand, Microsoft came up with Universal Windows Platform (UWP), sort of replacement of WPF, in 2019, with claims of this being the next best thing, and __only after 2 years__, they deprecated UWP and moved to .NET Multi-platform App UI (.NET MAUI), once again claimed to be the next best thing. Let's see, how long this technology will be around.


## From deep to shallow

With technologies dying and being created every day, we don't have the luxury to learn them deeply. First, it's pointless, it's usually a waste of time, secondly, they get updates so rapidly, we are not really able to learn them properly.

That's why we stick to technologies that are here for long time. .NET, Erlang OTP, PostgreSQL and when it comes to Javascript world we stick with [Svelte.dev](https://svelte.dev) because it's simple enough to survive in this world, and it's with us for several years.

In any case, whatever technology you pick, we suggest to learn in iterations, do not try to comprehend it all at once, there's no time for that anymore, and there's no point doing so.
