---
sidebar_position: 1
---

# Why use Seam?
Seam is three parts: states, animation, and component management.

Using states is a great way to solve many messy systems, especially frontend, because reactivity can be directly hooked into instances and components. You can use Seam to:
* Create source and reactive states to create a control flow for information
* Hook states directly to instances, which prevents you from manually needing to update instances
* Treat animation as states, resulting in an easy way to get things moving
* Create and use reusable components to simplify a codebase
* Explicitly define cause and effect, improving readability of code

Seam was originally built for UI and has since expanded to be for your entire game, both server and client. Seam states are simple and generic, meaning they can be used in many different places. Compared to other state libraries, Seam is much more feature-rich, flexible, and more performant.

# Comparison to other reactive state libraries
Seam has the ease of use of Fusion, the speed of Vide, and scalability of React-luau, plus additional features that no other state or UI library has. Take a peek at the chart below to see how Seam compares.

Looking for a mature and stable UI library for Typescript? It might be better to use React-luau. Otherwise, Seam might be for you!

| *(Library feature)* | Seam | Fusion | Vide | React-luau |
|---------------------|------|--------|------|------------|
| Reactive states | ![](../../static/img/yes.png)|![](../../static/img/yes.png)|![](../../static/img/yes.png)|![](../../static/img/yes.png)
| Has scopes | ![](../../static/img/yes.png) | ![](../../static/img/yes.png) | ![](../../static/img/yes.png) | ![](../../static/img/yes.png)
| Used by top developers | ![](../../static/img/yes.png) | ![](../../static/img/yes.png) | ![](../../static/img/yes.png) | ![](../../static/img/yes.png)
| Scalable for any team or game size | ![](../../static/img/yes.png) | ![](../../static/img/yes.png) | ![](../../static/img/yes.png) | ![](../../static/img/yes.png)
| Runs near vanilla speed | ![](../../static/img/yes.png) | ![](../../static/img/no.png) | ![](../../static/img/yes.png) | ![](../../static/img/yes.png)
| Supports hydration | ![](../../static/img/yes.png) | ![](../../static/img/yes.png) | ![](../../static/img/yes.png) | ![](../../static/img/no.png)
| Uses explicit declarations | ![](../../static/img/yes.png) | ![](../../static/img/yes.png) | ![](../../static/img/no.png) | ![](../../static/img/yes.png)
| Can be used on server | ![](../../static/img/yes.png) | ![](../../static/img/yes.png) | ![](../../static/img/no.png) | ![](../../static/img/no.png)
| Includes component system | ![](../../static/img/yes.png) | ![](../../static/img/no.png) | ![](../../static/img/no.png) | ![](../../static/img/yes.png)
| Built-in sequence functionality | ![](../../static/img/yes.png) | ![](../../static/img/no.png) | ![](../../static/img/no.png) | ![](../../static/img/no.png)
| Built into UI Labs‡ | ![](../../static/img/no.png) | ![](../../static/img/yes.png) | ![](../../static/img/yes.png) | ![](../../static/img/yes.png)
| Mature and guaranteed stability | ![](../../static/img/no.png) | ![](../../static/img/no.png) | ![](../../static/img/no.png) | ![](../../static/img/yes.png)
| Well-supported for Typescript | ![](../../static/img/no.png) | ![](../../static/img/no.png) | ![](../../static/img/no.png) | ![](../../static/img/yes.png)

‡ *You can use Seam in UI labs with the [SeamStoryUtils](https://praxis.igottic.com/api/SeamStoryUtils) library.*

## Assumptions made about you
All tutorials and examples assume the following:
* You are experienced with Luau enough to understand the nuances of syntax and more
* You know Roblox Studio

That being said, there is no expectation that you've ever tried a reactive state framework before, nor are you expected to be a top-tier expert in programming. Seam is easy to learn!