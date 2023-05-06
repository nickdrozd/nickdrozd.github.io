---
title: "The High Price of Abstraction in Python"
date: <span class="timestamp-wrapper"><span class="timestamp">&lt;2023-05-06 Sat&gt;</span></span>
layout: post
categories:
tags:
---

> Some say the price of holding heat is often too high \\
> You either be in a coffin or you be the new guy \\
> The one that's too fly to eat shoe pie
>
> &#x2013; MF DOOM

Suppose I am looping over a range of numbers to see if any of them matches some magic number:

{% highlight python %}
for i in range(1_000_000_000):
    if i == -1:
        break
{% endhighlight %}

On my modest desktop, this takes **60 seconds** to execute.

But as everyone knows, using [magic numbers](https://en.wikipedia.org/wiki/Magic_number_(programming)) in code is bad. It would be clearer and more maintainable to express the value as a variable:

{% highlight python %}
MAGIC_NUMBER = -1

for i in range(1_000_000_000):
    if i == MAGIC_NUMBER:
        break
{% endhighlight %}

On my modest desktop, this takes **70 seconds** to execute. Ten seconds longer &#x2013; that's not great!

Okay, so forget about variables. A better form of abstraction would be to get the comparison logic out of the loop and centralize it in a function:

{% highlight python %}
def number_matches(num: int) -> bool:
    return num == -1

for i in range(1_000_000_000):
    if number_matches(i):
        break
{% endhighlight %}

On my modest desktop, this one takes **110 seconds** to execute. The price to be paid for this minor organizational improverment is a **catastrophic degradation of performance**.

The situation is grim if you have some Python [hot spot](https://nickdrozd.github.io/2022/04/12/performance-hot-spots.html) code that needs to be cleaned up. Because it's a hot spot, any abstraction could have **dire consequences**, and so the range of acceptable changes is constrained.

On the other hand, this is great news if you have a hot spot that uses abstractions. **It may be possible to trade a little maintainability for a lot of speedup.** Inline some constants, inline some function calls, that kind of thing. It doesn't look nice, but hey, it's Python.
