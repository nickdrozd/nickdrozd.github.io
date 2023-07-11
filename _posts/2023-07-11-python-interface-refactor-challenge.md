---
title: "Python Interface / Refactor Challenge"
date: <span class="timestamp-wrapper"><span class="timestamp">&lt;2023-07-11 Tue&gt;</span></span>
layout: post
categories: 
tags: 
---



# Scenario

I have a smallish Python codebase. There is a type that is used ubiquitously throughout: `Count`. The current definition of the `Count` type is quite simple:

{% highlight python %}
Count = int
{% endhighlight %}

That is to say, `Count` is just a **type alias**.

Right now, a `Count` is nothing other than a number. However, I would like to start using **algebraic expressions** alongside actual numbers. For instance, instead of the actual number `9`, there might be an expression like `(4 + 5)`. Note that **these expressions will be used alongside numbers, and not instead of them**. Numbers and expressions will need to interact with each other, and the exact nature of a particular variable might not be known until runtime. Possibly other kinds of objects might be used later on as well.

Callsites for `Count` are mostly type-annotated with `Count`, but occasionally with `int`. This is because **Mypy** can't (or won't) distinguish between a type alias and its defintion. At the same time, there are functions annotated with `int` that really do require an actual number. So for example, there might be annotations like this:

{% highlight python %}
Count = int

def one_plus_square(x: Count) -> Count:
    return 1 + square(x)

def square(x: int) -> Count:  # int should be Count
    return x ** 2

def print_times(x: Count, n: int) -> None:  # true int
    for _ in range(n):
        print(x)
{% endhighlight %}


# Challenge

**Come up with an outline for a class or interface or whatever that extends the `Count` type to include `int`-like objects.** Ideally this should not require extensive changes to existing use-sites. Additionally, **come up with a strategy for actually implementing the changes** (tools to use, etc). Obviously the details of the scenario are rather vague, so the solution can be similarly vague.

**Solutions to the challenge will be judged by me according to the following criteria:**

1.  Can I, with a reasonable amount of effort, understand and implement the approach?
2.  Can it be implemented without requiring too many changes to the rest of the code?

**Winning entries will be posted to this blog at a later date, where they will be read by perhaps a few dozen people. Fame and glory await.**

I am primarily interested in **concrete Python-specific** solutions. However, entries of the form *"Python sucks, here's how I would do it in langauge X"* will be considered if they are interesting enough.
