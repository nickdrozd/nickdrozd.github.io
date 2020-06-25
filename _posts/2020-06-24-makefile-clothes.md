---
title: "A Makefile for Getting Dressed"
date: <span class="timestamp-wrapper"><span class="timestamp">&lt;2020-06-24 Wed&gt;</span></span>
layout: post
categories:
tags:
---
I'm getting dressed to go to a wedding. My clothing is the typical "men's wear" for such an occasion, namely, a **suit and tie**.<sup><a id="fnr.1" class="footref" href="#fn.1">1</a></sup> But I don't normally dress fancy, and I always forget the **order** in which I need to put on the individual articles. Fortunately, I can use **`make`** to figure it out.

First, a brief primer on how **makefiles** work. A makefile consists of a series of ***targets***, which are things that need to happen. A target can have a list of instructions to execute, along with a list of ***prerequisites***. When a target is executed, its prerequisites are executed first. Each prerequisite's prerequisites are executed in turn, and so on.

**Sorting out dependencies is what `make` is all about**, and I have dependencies that need to get sorted out. For example, I don't want to put on my shoes before I put on my pants. If I do, my shoes won't fit through the pant legs, and I'll have to **backtrack** by taking off my shoes. Backtracking is bad, so I want to make sure that I put on only those articles of clothing whose prerequisite clothes I'm already wearing.

What I ultimately want is to specify a **list of clothing dependencies**, then have `make` spit out a **flat list** of articles of clothing that respects those dependencies. I can then take that list and put on the articles one at a time, and because the list respects the dependencies I've specified, I won't have to do any backtracking.

Here is a makefile for a **basic interpretation** of "suit and tie":

{% highlight makefile %}
all : suit tie shoes

suit : pants jacket

jacket : shirt
	@echo $@

pants :
	@echo $@

shirt :
	@echo $@

shoes : pants
	@echo $@

tie : shirt
	@echo $@
{% endhighlight %}

A few things to note:

-   `make` targets use the syntax `<NAME> : <DEP> <DEP> ...`, with instructions listed below.
-   `all` is the standard default target. If no other target is specified in the `make` command, `all` will get run.
-   `$@` is a macro that evaluates to the name of the current target.
-   Normally instructions are printed and then executed. But an instruction prepended with `@` will only get executed.

Here's what comes from running `make` with this file:

{% highlight nil %}
pants
shirt
jacket
tie
shoes
{% endhighlight %}

According to that list, I can put on my pants, then my shirt, then my jacket, then my tie, then my shoes. `shirt` is listed as a prerequisite for both `tie` and `jacket`, and those requirements are satisfied by this list.

It is not the only possible satisfactory ordering. Running **`make -j`** can cause targets to get processed in different orders while still respecting prerequisites. Here is another possible order:

{% highlight nil %}
shirt
pants
shoes
tie
jacket
{% endhighlight %}

But this list leaves out a lot. For instance, I'm not a GQ model, so I'll want to wear **socks** with my shoes. For reasons of general prudishness, I'll also wear **underwear** and an **undershirt**. Being fashionable, my suit is a three-piece, with a **vest**, and my pants are held up with **suspenders**, and my shirt cuffs are pinned together with **cufflinks**. Finally, fastidiousness requires that I wear both **collar stays** and **shirt stays**.

Adding all those in results in this makefile:

{% highlight makefile %}
all : suit tie shoes

collar-stays : shirt
	@echo $@

cufflinks : shirt
	@echo $@

jacket : vest cufflinks
	@echo $@

pants : underwear shirt-stays
	@echo $@

shirt : undershirt
	@echo $@

shirt-stays : shirt socks underwear
	@echo $@

shoes : socks pants
	@echo $@

socks :
	@echo $@

suit : pants jacket

suspenders : pants shirt
	@echo $@

tie : shirt collar-stays
	@echo $@

undershirt :
	@echo $@

underwear :
	@echo $@

vest : suspenders shirt
	@echo $@
{% endhighlight %}

Here are some possible sequences:

{% highlight nil %}
underwear
undershirt
socks
shirt
shirt-stays
cufflinks
pants
collar-stays
suspenders
shoes
vest
tie
jacket

##########

socks
undershirt
underwear
shirt
cufflinks
shirt-stays
collar-stays
pants
tie
suspenders
vest
jacket
shoes
{% endhighlight %}

The mathematical theory of **binary relations** provides a nice vocabulary for describing what's going on here. Let `≤` be read as "cannot be put on after", so that `pants ≤ shoes` is read as "pants cannot be put on after shoes". A prerequisite declaration like `jacket : vest cufflinks` can be written as the conjunction of `vest ≤ jacket` and `cufflinks ≤ jacket`.

`≤` has some nice properties. It is **transitive**: if `shirt ≤ vest` and `vest ≤ jacket`, then `shirt ≤ jacket`. It is **reflexive**: `x ≤ x` for all `x`; my shirt cannot be put on after my shirt. It is **antisymmetric**: if `x ≤ y` and `y ≤ x`, then `x = y`. All of this means that `≤` "points in one direction"; it does not point backwards, and it does not go in circles. A relation with these properties is called a **partial order**.

One property the relation lacks is **connexity**: that for any two distinct `x, y`, `x ≤ y` or `y ≤ x`. Certain items of clothing don't depend on each other. It doesn't matter whether I put on my cufflinks or my socks first, so neither `cufflinks ≤ socks` nor `socks ≤ cufflinks`. A connex partial order is called a **linear order**, and a linear order that maintains the same relationships of a partial order is known as a **linear extension** of that order.

**A linear extension of a partial order need not be unique.** `make` is given a partial order of prerequisites, but it can only address targets one by one. Thus the actual order in which the targets are addressed constitutes a linear extension of its dependencies. When I'm getting dressed, I need a list of items of clothing to put on. I don't care what the order is, so long as the prerequisites are satisfied.


# Discussion Questions

1.  It is inelegant for every target in the clothing makefile to list `@echo $@` as an instruction. **Is there another way to print all and only the target names?**

2.  If I run the clothing makefile in a directory in which there is a file called `underwear`, then the `underwear` target will not get built because `make` assumes that that file is the target's output, and that since the file exists, the target is up to date. Normally the way to get around this is to mark the target as "phony": `.PHONY : underwear`. However, it would be inelegant and error-prone to explicitly list every single article of clothing as a phony target. **Is there a way to implicitly mark all targets as phony?** `make -B` does not count as a solution.

3.  One of the targets in the makefile is `suit : pants jacket`, with no instructions. **Why doesn't `suit` have the same print instruction as the other targets?**

4.  Suppose that the wedding I'm attending is with old friends I haven't seen in a long time. I'm not as young as I used to be, so I decide to wear a girdle. **How should I modify the makefile so as to include a girdle?**

5.  I really, *really* don't want my pants to fall down, so I decide to wear a belt in addition to my suspenders. **How should I modify the makefile so as to include a belt?**

6.  **What kind of targets should get listed as prerequisites of `all`?**

7.  **What is the relationship between linear extensions and topological sorting?**

8.  **How many ways are there for me to get dressed?**

9.  **Why isn't `shirt` listed as a prerequisite for `jacket` in the longer makefile?**

10. **Should `tie` be a prerequisite for `jacket`?**

# Footnotes

<sup><a id="fn.1" href="#fnr.1">1</a></sup> Of course, this clothing is not just for "men". Anyone can wear it. I don't know if there is a more "inclusive" term for the kind of clothing "traditionally" worn by "men". Whatever its name, it is the style that includes suits and ties and does not include dresses.
