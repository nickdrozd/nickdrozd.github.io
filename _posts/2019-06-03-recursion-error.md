---
title: "Recursion Error While Handling Recursion Error"
date: <span class="timestamp-wrapper"><span class="timestamp">&lt;2019-06-03 Mon&gt;</span></span>
layout: post
categories:
tags:
---
Here's a **Python** function. What happens when it gets called?

{% highlight python %}
def f():
    f()
{% endhighlight %}

If you guessed **`RecursionError`**, then congratulations.

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

Here's another one. What happens when it gets called?

{% highlight python %}
def g():
    try:
        g()
    except:
        g()
{% endhighlight %}

The correct answer here is **"Which version of Python?"**

In **Python 3**, the interpreter freaks out and bails.

{% highlight nil %}
>>> g()
Fatal Python error: Cannot recover from stack overflow.

Current thread 0x00007fd8ab90c740 (most recent call first):
  File "<stdin>", line 3 in g
  File "<stdin>", line 3 in g
  File "<stdin>", line 3 in g
  File "<stdin>", line 3 in g
  File "<stdin>", line 3 in g
  ...

Process Python aborted (core dumped)
{% endhighlight %}

More specifically, the interpreter hits a recursion error, then tries to back off and handle it. While handling the error, it hits another one. Knowing that it's already in stack limit recovery mode, the interpreter decides that the stack is unsalvageable and it **aborts**. (This, at least, is what I've been able to figure out from reading the CPython source.<sup><a id="fnr.1" class="footref" href="#fn.1">1</a></sup>)

Calling `g` in **Python 2** results in the interpreter apparently **hanging indefinitely**, unable even to respond to a keyboard interrupt. I'd show the REPL output, but nothing shows up after the call. A variation on `g` points to what is happening:

{% highlight python %}
def h(n):
    try:
        print 'try {}'.format(n)
        h(n+1)
    except:
        print 'except {}'.format(n)
        h(n+1)
{% endhighlight %}

Calling `h(0)` results in the following output:

{% highlight nil %}
>>> h(0)
try 0
try 1
try 2
try 3
...
try 993
try 994
try 995
try 996
try 997
except 997
except 996
try 997
except 997
except 995
try 996
try 997
except 997
except 996
try 997
except 997
except 994
try 995
try 996
try 997
except 997
except 996
...
{% endhighlight %}

As far as I can tell, what's happening is that the interpreter hits its stack limit, then tries to back off and keep going, then hits the limit again, and it just goes on **bouncing around the top of the stack like a paddle ball**, catching its own thrown exceptions, in an infinite loop. This loop does not include handling keyboard interrupts, which is why it's impossible to regain control with `^C`.

I know this sounds like a piece of **stupid programming language trivia**, but I actually came across this in real life. It occurs when you run **[Pylint](https://github.com/pycqa/pylint)** with a certain version of **[Astroid](https://github.com/pycqa/astroid/)** against some very specific and gravely erroneous Python code. I [opened an issue](https://bugs.python.org/issue34214) about this, which contains all the details. It was closed recently with the ruling that it is **not the interpreter's problem**.

**What's the appropriate behavior for an interpreter in this kind of situation?** The Python 2 response is clearly bad, but the Python 3 response isn't great either. `Process Python aborted (core dumped)` makes it sound like **the interpreter hit a bug**, but that isn't the case; the intended behavior is that the program won't continue when the stack gets into a certain state, and that's what happens.

**How do other languages handle it?** Thinking about this question brought me to the startling realization that I don't have a great grasp of error handling in very many languages! I have a passable understanding of how it works in **Emacs Lisp**, so let's look at that.. For reference, here's the function `f` to begin with:

{% highlight emacs-lisp %}
(defun f ()
  (f))
{% endhighlight %}

As expected, it hits a stack depth error:

{% highlight nil %}
ELISP> (f)
 *** Eval error ***  Lisp nesting exceeds ‘max-lisp-eval-depth’
{% endhighlight %}

And here's `g`, the one that causes Python 3 to abort and causes Python 2 to get stuck:

{% highlight emacs-lisp %}
(defun g ()
  (condition-case _
      (g)
    (error (g))))
{% endhighlight %}

In Emacs, this function seems to have the same behavior as in Python 2, except that it responds just fine to `keyboard-quit` (`C-g`). That is, it gets itself into a stack-bouncing loop, but it's easy to get out.

Here's the function `h` to give some visibility:

{% highlight emacs-lisp %}
(defun h (n)
  (condition-case _
      (progn
        (princ (format "body %s\n" n))
        (h (1+ n)))
    (error (princ (format "handler %s\n" n))
           (h (1+ n)))))
{% endhighlight %}

The output of `(h 0)` looks a lot like the output of `h(0)` in Python 2, though with a shorter stack<sup><a id="fnr.2" class="footref" href="#fn.2">2</a></sup>:

{% highlight nil %}
ELISP> (h 0)
body 0
body 1
body 2
body 3
...
body 259
body 260
body 261
body 262
handler 262
handler 263
handler 261
body 262
handler 263
handler 262
body 263
handler 263
handler 260
body 261
body 262
handler 263
handler 262
...
{% endhighlight %}

**Scheme** uses **tail-call elimination**, so the function `f` doesn't cause any kind of stack error. It uses a fixed amount of stack space, and it will happily execute as long as you let it:

{% highlight scheme %}
(define (f)
  (f))
{% endhighlight %}

The function `g` is not tail-recursive, so it will grow the stack. I can't come up with a more sophisticated example because I don't know how to do error-handling in Scheme:

{% highlight scheme %}
(define (g)
  (g)
  (g))
{% endhighlight %}

Running `(g)` in **Racket** causes my laptop to slow to a crawl, though it will eventually respond to a keyboard interrupt.

I don't know if it's even possible to state this problem in statically-typed languages like **Haskell** and **Rust**.

# Footnotes

<sup><a id="fn.1" href="#fnr.1">1</a></sup> From [`ceval.c`](https://github.com/python/cpython/blob/b7fade4f87e0d37d1686a4e8596141e55ecef099/Python/ceval.c#L697):

{% highlight c %}
int
_Py_CheckRecursiveCall(const char *where)
{
    _PyRuntimeState *runtime = &_PyRuntime;
    PyThreadState *tstate = _PyRuntimeState_GetThreadState(runtime);
    int recursion_limit = runtime->ceval.recursion_limit;
    // ...
    if (tstate->recursion_critical)
        /* Somebody asked that we don't check for recursion. */
        return 0;
    if (tstate->overflowed) {
        if (tstate->recursion_depth > recursion_limit + 50) {
            /* Overflowing while handling an overflow. Give up. */
            Py_FatalError("Cannot recover from stack overflow.");
        }
        return 0;
    }
    if (tstate->recursion_depth > recursion_limit) {
        --tstate->recursion_depth;
        tstate->overflowed = 1;
        _PyErr_Format(tstate, PyExc_RecursionError,
                      "maximum recursion depth exceeded%s",
                      where);
        return -1;
    }
    return 0;
}
{% endhighlight %}

<sup><a id="fn.2" href="#fnr.2">2</a></sup> I've seen the printed number get as high as 269, but that might be platform-dependent.
