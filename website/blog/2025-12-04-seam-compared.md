---
slug: seam-comparison
title: Why use Seam over other frameworks?
authors: miagobble
tags: [seam, comparison, discussion]
---

Seam is not the only UI framework on Roblox, with many other popular and great options (including React-lua, Fusion, Blend, and Vide) capturing a lot of adoption. So, when I present Seam to developers, I often get asked why Seam is better than the other options.

This blog post is going to be an overview of why I think Seam is worth trying, and what it's best for.

<!-- truncate -->

:::warning

Heads up! Seam is no longer just a UI library, so this blog post might be missing that context.

:::

## Seam is built to be simpler and easier
Unlike most UI frameworks, there aren't redundant features that focus on specifics. Instead, features in Seam are built to be used across multiple contexts, increasing flexibility. For example, most frameworks reserve an equivalent to `Computed` for just a simple state reaction. If you wanted to create dynamic children, you'd have to use a different constructor, which creates more clutter and confusion. In Seam, you can do *both* with `Computed`, since it acts how you would expect it to.

That's not the only reason Seam is simpler, though. More "complex" concepts, such as components or scopes, are not required to make UI with Seam. Often times, designers of UI frameworks get stuck in their own design philosphies, which may or may not be compatible with others. Seam is built to be simple in this way so that you can design UI how *you* would like to.

**The cherry on top is that you don't have to programmatically make your UI. You can pre-design your UI in Studio's UI editor, and attach Seam functionality to it!** This means UI designers can focus on the designing, and the frontend programmers can focus on the programming. One frustrating thing I find with frameworks like React-lua is that I can't do this, and it wastes a lot of time and creates bottlenecks that don't need to be there.

## Seam is here for Roblox devs, not web devs
Fun fact: Roact (Roblox's equivalent to React) only exists because Roblox wanted to poach developers from other companies such as Meta, so they designed it to mimic their main web UI framework.

Seam isn't trying to reinvent the way UI frameworks work, and instead is taking the best parts of everything else to create something more usable.
This means that beginners aren't going to have a hard time wrapping their head around how Seam works, but at the same time, Seam is just as easy and flexible for somebody who is experienced and looking to scale.

A big issue with open-source stuff in general is that people believe something new needs to completely reinvent what already exists to be meaningful. I disagree, since that isn't *always* true -- sometimes just making things better through a collection of smaller decisions and changes is all that is needed to be a meaningful alternative. Reinventing things can often lead to over-engineering or otherwise weird solutions.

## Seam is made for games of all sizes
Your game doesn't have to be small, nor does have it have to be scaled up. Because there is so little boilerplate and setup to using Seam, while also being rich with functionality, you can use it in projects of any size. Want to just animate some stuff in your solo project? Go for it. Need a proper built-in component system to scale? Seam has your back. Are you somewhere in-between? That's also fine!

For example, React-lua is built well for large-scale projects, but doesn't make a lot of sense for smaller or solo projects, simply because of the amount of boilerplate there is to it.

Seam also performs well on the backend, being on-par with some other frameworks like Vide, or in extreme test cases, performing up to 5x-17x better (such as when compared to Fusion).

Lastly, Seam also does not have strict usage with syntax or juxtaposition, so you can arrange and type stuff in many different ways to match your coding conventions.

## So, what do ya say?
Most major UI frameworks serve a purpose for a specific set of developers, and I won't disrespect or invalidate them. But, with that being said, Seam also has a reason for existing, and might be worth checking out for UI/UX needs in your Roblox game.

I'm always open to feedback, though, and Seam is always changing for the better. If you have me added on Discord, reach out to me there! Otherwise, message me on Twitter or Roblox DevForum.

Thanks for the read, guys!