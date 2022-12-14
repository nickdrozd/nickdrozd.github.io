---
title: "The Walrus-While Python Pattern"
date: <span class="timestamp-wrapper"><span class="timestamp">&lt;2022-12-14 Wed&gt;</span></span>
layout: post
categories:
tags:
---

Suppose you are reading from an **unbounded data source** in increments of a certain size. This is a common sort of situation; for example, reading lines from stdin. The total length of the data source is not known in advance, so the only thing to do is **keep reading until there is nothing left to read**.

Up through Python 3.7, this kind of activity would usually be written with an **unbounded loop**:

{% highlight python %}
while True:
    line = getline()

    if line is None:
        break

    process(line)
{% endhighlight %}

This is a **clunky** way to express what's going on. On its face it says: do the following forever. But it clearly isn't meant to run forever. So really it's: do the following forever (but stop at some point).

It's also **misleading**. The `while True` idiom is often used in Python to indicate a loop that will run forever, like an event loop. But that isn't what this loop is. Instead, the loop will run until there are no more lines to get. So the loop condition **violates a common convention** and does something unexpected.

Python 3.8 (2019) introduced ***[assignment expressions](https://peps.python.org/pep-0572/)***, which allow for assigning values to variables in contexts where regular assignment would be illegal. The syntax used for assignment expressions `:=` vaguely resembles a walrus, and so it is known as the ***walrus operator***.

The line-processing code above can be **dramatically simplified** by using an assignment expression:

{% highlight python %}
while (line := getline()) is not None:
    process(line)
{% endhighlight %}

This code matches **the natural informal description of the process it implements**: *as long as there is a line to get, process it*.

The `while True` version implements the same process, but it includes some **extraneous details**. Namely, it explicitly and procedurally specifies the meaning of "as long as there is a line to get". But that's a low-level concern that doesn't have anything to do with line processing. And besides, it's obvious what that means, so why not just say it?

This is known as the ***walrus-while*** pattern.

Recently I went through the **Python standard library** and [updated all the instances of the unbounded loop pattern to the walrus-while pattern](https://github.com/python/cpython/pull/29347/files). Or at least, all the instances I could find. There ended up being thirty or so. That means thirty or so sites of loop-handling logic that could potentially get screwed up. **Thirty or so `break` statements deleted altogether**. Poof! Gone, just like that.

**Less code is better than more code**, and the walrus-while pattern results in a lot less code.


# Exercise for the reader

Rewrite the following snippet to use the walrus-while pattern:

{% highlight python %}
while True:
    s = input.read(MAXBINSIZE)
    if not s:
        break
    while len(s) < MAXBINSIZE:
        ns = input.read(MAXBINSIZE-len(s))
        if not ns:
            break
        s += ns
    line = binascii.b2a_base64(s)
    output.write(line)
{% endhighlight %}
