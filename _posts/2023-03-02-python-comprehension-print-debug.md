---
title: "How to Print-Debug Python Comprehensions"
date: <span class="timestamp-wrapper"><span class="timestamp">&lt;2023-03-02 Thu&gt;</span></span>
layout: post
categories:
tags:
---

**Comprehensions** are a fantastic language feature in Python. They are an elegant alternative to manually constructing and populating data structures. Comprehensions are **declarative** &#x2013; they just say what they are, as opposed to the implicit logic of manual looping. When it comes to simple object creation, **comprehension should be used whenever possible**. This goes not just for lists, but also for dictionaries and sets.

However, a widely perceived **drawback** to comprehensions is that they are **harder to debug**. When something goes wrong with a manual loop, the first thing to do is to print out the iterated values as they turn up. But the values of a list comprehension can't be accessed, so **print-debugging** isn't possible. To deal with this, it's common to **unravel the comprehension** into a manual loop. Manual loops are uglier and more complicated and more error-prone than comprehensions, but that's the price that must be paid for **debuggability**.

That's the perception at least, but it's wrong. In fact, **print-debugging comprehensions is easy**. The key fact to understand is that **`print` is a function, and it can occur anywhere that a function can occur**. In particular, `print` can occur in a **comprehension filter**.

As an example, here's some code that deals with graphs:

{% highlight python %}
Node = int
Graph = dict[Node, tuple[Node | None, ...]]

def exit_points(graph: Graph) -> dict[Node, set[Node]]:
    return {
        node: set(
            conn
            for conn in connections
            if conn is not None
        )
        for node, connections in graph.items()
    }
{% endhighlight %}

Notice the **nested comprehensions**: the dictionary comprehension contains set comprehensions as its values. Unraveling this into a manual loop would be **just awful**, but perhaps necessary to print the values as they show up:

{% highlight python %}
def exit_points_unraveled(graph: Graph) -> dict[Node, set[Node]]:
    ret = {}

    for node, connections in graph.items():
        print(f'{node=}: {connections=}')  # <-- print values

        val = set()

        for conn in connections:
            if conn is not None:
                print(f'{conn=}')  # <-- print values
                val.add(conn)

        ret[node] = val

    return ret
{% endhighlight %}

(As a side note, statements like `ret = {}` are a **code smell** and often an indication that a comprehension could be used instead.)

Rather than go through the hassle of unraveling the comprehensions, we can simply print the values as part of the comprehension filter. The `print` function always returns `None`, so it's just a matter of creating a **vacuously true filter** that touches every iterated value but doesn't discard any of them:

{% highlight python %}
def exit_points(graph: Graph) -> dict[Node, set[Node]]:
    return {
        node: set(
            conn
            for conn in connections
            if conn is not None and print(f'{conn=}') is None  # extra condition is vacuously true
        )
        for node, connections in graph.items()
        if print(f'{node=}: {connections=}') is None  # vacuously true
    }
{% endhighlight %}

**It isn't pretty. But then again, neither is print-debugging.**

This technique can be used in other places where debugging might be considered difficult, like in a **chain of boolean checks**:

{% highlight python %}
for item in sequence:
    if (test_condition_1(item)
            or test_condition_2(item)
            or test_condition_3(item)):
        return None

    do_stuff(item)
{% endhighlight %}

It might happen that all the items in the sequence are failing the test conditions, and so none of them make it to `do_stuff`. To see where they are being caught, `print` calls can be added **between the conditions**:

{% highlight python %}
for item in sequence:
    if (test_condition_1(item)
            or print('passed check 1')  # vacuously false
            or test_condition_2(item)
            or print('passed check 2')  # vacuously false
            or test_condition_3(item)):
        return None

    do_stuff(item)
{% endhighlight %}

(Note that this example uses an `or`-chain, and so the dummy `print` conditions need to be **vacuously false** rather than true.)

Again, this technique is possible because `print` is a function. In older versions of Python, `print` was a **statement**. That was a bad idea, and fortunately it was rectified. In general, statements are clunkier and less flexible than values. Python continues to improve with the addition of **value-oriented** language features like the **[walrus operator](https://nickdrozd.github.io/2022/12/14/walrus-while.html)**.
