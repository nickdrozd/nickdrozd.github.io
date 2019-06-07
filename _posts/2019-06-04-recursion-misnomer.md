---
title: "Python's `RecursionError` is a Misnomer"
date: <span class="timestamp-wrapper"><span class="timestamp">&lt;2019-06-04 Tue&gt;</span></span>
layout: post
categories:
tags:
---
A Python function with **unbounded recursion**. It raises a **`RecursionError`** when called:

{% highlight python %}
def f():
    f()
{% endhighlight %}

{% highlight nil %}
>>> f()
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
  File "<stdin>", line 2, in f
  File "<stdin>", line 2, in f
  File "<stdin>", line 2, in f
  [Previous line repeated 996 more times]
RecursionError: maximum recursion depth exceeded
{% endhighlight %}

`RecursionError`. The error is that the recursion is unbounded. **How does Python know what caused the error?**

[According to the docs](https://docs.python.org/3/library/exceptions.html#RecursionError), `RecursionError` "is raised when the interpreter detects that the **maximum recursion depth** (see `sys.getrecursionlimit()`) is exceeded."

{% highlight nil %}
>>> import sys
>>> sys.getrecursionlimit()
1000
{% endhighlight %}

The "maximum recursion depth" is 1000. **What if the call stack reaches that limit without recursion?** Has anyone ever done this real life? I haven't. Here's a function to set up an artificial example:

{% highlight python %}
def write_functions():
    with open('big_stack.py', 'w') as fd:
        fd.write('def f1():\n    pass\n\n')

        for i in range(1, 1000):
            fd.write(f'def f{i + 1}():\n    f{i}()\n\n')
{% endhighlight %}

Run that function and you'll get a file like this:

{% highlight python %}
def f1():
    pass

def f2():
    f1()

def f3():
    f2()

# ...

def f998():
    f997()

def f999():
    f998()

def f1000():
    f999()
{% endhighlight %}

Calling `f1` builds the stack to depth 1, calling `f2` builds it to depth 2, and calling `f999` builds it to depth 999.

{% highlight nil %}
>>> f1()
>>> f2()
>>> f999()
>>>
{% endhighlight %}

Calling `f1000` builds the stack to depth 1000. *You won't believe what happens next.*

{% highlight nil %}
>>> f1000()
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
  File "/home/nick/big_stack.py", line 2999, in f1000
    f999()
  File "/home/nick/big_stack.py", line 2996, in f999
    f998()
  File "/home/nick/big_stack.py", line 2993, in f998
    f997()
...
  File "/home/nick/big_stack.py", line 11, in f4
    f3()
  File "/home/nick/big_stack.py", line 8, in f3
    f2()
  File "/home/nick/big_stack.py", line 5, in f2
    f1()
RecursionError: maximum recursion depth exceeded
{% endhighlight %}

`RecursionError: maximum recursion depth exceeded`. **But there was no recursion!** It would be more accurate to say `StackLimitError: maximum call stack depth exceeded`.

`f1000` will run just fine if the "maximum recursion depth" (really, the maximum call stack depth) is adjusted:

{% highlight nil %}
>>> sys.setrecursionlimit(1001)
>>> f1000()
>>>
{% endhighlight %}


# Exercises for the reader

1.  Find a real-life example of the default stack limit getting hit without recursion.
2.  Do something interesting with the function `extract_stack` from the `traceback` module.


# Bonus tip!

You deserve something special for having read this far. Here's a trick that experienced Python programmers use to **optimize** their unboundedly recursive functions. Recall the definition of `f`:

{% highlight python %}
def f():
    f()
{% endhighlight %}

Now take a look at the **bytecode** of `f` using the `dis` function from the `dis` module:

{% highlight nil %}
>>> import dis
>>> dis.dis(f)
  2           0 LOAD_GLOBAL              0 (f)
              2 CALL_FUNCTION            0
              4 POP_TOP
              6 LOAD_CONST               0 (None)
              8 RETURN_VALUE
{% endhighlight %}

A Python function with no explicit return value will return `None`. That's the case with `f`. It calls itself, then discards the return value and loads and returns `None`. But we know that `f` returns `None`, so that's **two wasted instructions**. A variation of `f` tightens up the bytecode:

{% highlight python %}
def g():
    return g()
{% endhighlight %}

{% highlight nil %}
>>> dis.dis(g)
  2           0 LOAD_GLOBAL              0 (g)
              2 CALL_FUNCTION            0
              4 RETURN_VALUE
{% endhighlight %}

The `POP_TOP` and `LOAD_CONST` instructions are skipped by returning the value of the recursive call straightaway. `g()` will result in a `RecursionError` just the same as `f()`, but it will do so **a little more efficiently**.
