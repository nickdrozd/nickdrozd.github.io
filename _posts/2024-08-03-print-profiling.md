---
title: "Print Debugging and Print Profiling"
date: <span class="timestamp-wrapper"><span class="timestamp">&lt;2024-08-03 Sat&gt;</span></span>
layout: post
categories: 
tags: 
---

**Print debugging** is the technique of debugging by inserting print statements into code and watching their output. For example, if my program seems to be getting stuck somewhere, I might put in some print statements like this:

{% highlight python %}
print("start")
f()
print("passed f")
g()
print("passed g")
h()
print("end")
{% endhighlight %}

If I see `start` and `passed f` in the output but not `passed g`, then I can deduce that execution is getting stuck in `g`.

Print debugging is not a sophisticated debugging method. Some say that programmers would be better off if they stopped print debugging and instead learned how to use a real debugger with breakpoints and all that. I don't know how to use a debugger effectively, so for all I know they may be right. But print debugging is often effective enough, and most importantly, **it is immediately available at all times to everyone**.

Print debugging is widely known. There is a similar but less widely known technique that I will call **print profiling**. This is the use of print statements to guide performance work.

Say I have a function that does some expensive computation on some argument. I would like to avoid doing this expensive computation if possible, so I will first check to see if the argument is suitable and then return early if it isn't. There may be multiple such checks.

{% highlight python %}
def f(arg):
    if not suitable_1(arg):
        return

    if not suitable_2(arg):
        return

    do_expensive_computation(arg)
{% endhighlight %}

Say I am running this function against lots of different input args and I am concerned with reducing the total time of the whole operation. I may want to modify the suitability checks to cast a wider net and exit early more often. But to know if my changes are effective I need to know if the early returns are actually taken more often. And this means I need to **collect some stats**.

Now in principle the best thing to would be to learn how to use a real profiler or tracer, etc. But I just want some quick info right now. So as with print debugging, print profiling just means adding in some print statements:

{% highlight python %}
def f(arg):
    if not suitable_1(arg):
        print("early return 1")
        return

    if not suitable_2(arg):
        print("early return 2")
        return

    print("expensive computation")
    do_expensive_computation(arg)
{% endhighlight %}

So then I run it again, and the output will contain these various messages. The data still needs to be analyzed, and specifically I want to know how many times each message showed up. There are lots of ways this can be done, and because we are working in the realm of quick and dirty and convenient, the best way to do it will be up to personal preference.

The way I do it is: I run the command in [Emacs compilation mode](https://www.gnu.org/software/emacs/manual/html_node/emacs/Compilation-Mode.html), so the output is sitting in an Emacs buffer. Then for each output message, I run the Emacs command `how-many`, aka `count-matches` (possibly with regexp matching) and write down the numbers.

With this data in hand I can make a change to the code and then do it again. I compare the new numbers with the old numbers and see if the changes makes things better or worse or make no impact at all.

**And that's print profiling.** It isn't pretty, but it's easy to do and it often works well enough.

Note that the line between print debugging and print profiling is not sharp. In this example, I may find that `early return 2` never shows up in the output, and therefore that branch never gets taken at all. That kind of thing likely indicates a bug, or at least a mistaken assumption somewhere along the line.
