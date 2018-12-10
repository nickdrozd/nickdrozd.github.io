---
title: "Real-World Uses for Dynamic Scope"
date: <span class="timestamp-wrapper"><span class="timestamp">&lt;2018-12-10 Mon&gt;</span></span>
layout: post
categories:
tags:
---
Say I have the following function:

{% highlight emacs-lisp %}
(defun f ()
  (+ a 2))
{% endhighlight %}

What do I get from evaluating `(f)`? Of course, `a` isn't defined, so I'll get some kind of variable lookup error.

What about `(let ((a 5)) (f))`? In a language with **static scope**, this would again raise a lookup error. With static scope, *the meaning of a variable is determined by the context in which that variable is defined*. Here, `f` is defined at the top-level context, and `a` isn't defined there. `(let ((a 5)) (f))` opens a new scope wherein `a` is bound to 5, but that isn't the scope in which `f` was defined, and so it cannot affect the value of `a` there.

In a language with **dynamic scope**, on the other hand, *the meaning of a variable is determined by the context of its caller*. In the case of `(let ((a 5)) (f))`, the `let` opens a context wherein `a` is bound to 5, and the call to `f` is executed in that context. The value of `a` in the body of `f` is found to be 5, and therefore the whole expression evaluates to 7.

Here's another function:

{% highlight emacs-lisp %}
(defun g (a)
  (f))
{% endhighlight %}

What do I get from evaluating `(g 5)`? Well, `a` still isn't defined in the context in which `f` is defined, so in a statically scoped language this would again raise a lookup error. And again, the call to `g` opens a scope wherein `a` is bound to 5, so in a dynamically scoped language, the call to `f` will find that value for `a` and the expression will evaluate to 7.

Say that I don't like `a` as the name for the parameter in `g`, and I decide to rename it:

{% highlight emacs-lisp %}
(defun g (b)
  (f))
{% endhighlight %}

What do I get from evaluating `(g 5)` now? In a statically scoped language, parameters can be renamed with impunity, but not so with dynamic scope. If `g`'s parameter is renamed from `a` to `b`, then `f` will no longer be called in a context wherein `a` is bound, and so a lookup error will be raised.<sup><a id="fnr.1" class="footref" href="#fn.1">1</a></sup>

Perverse, right? What should be a simple code transformation can have dire effects at runtime. **Why would anyone want something like that?** In fact dynamic scope comes up in Emacs Lisp fairly often, and it can come in handy in the right circumstances.

Consider the primitive function `insert`. It takes any number of string or character arguments and then inserts them into the current buffer. A typical call looks like `(insert "<" string-1 ":" string-2 ">")`, and that will insert (for example) `<name:value>` into the buffer.

Say I want to insert a name-value pair into the current buffer, but the buffer is read-only, and I want to keep it that way; in other words, I want to perform a one-off insertion job. One way to do this is to mutate the variable `buffer-read-only` to `nil`, insert, and then mutate it back to `t`<sup><a id="fnr.2" class="footref" href="#fn.2">2</a></sup>:

{% highlight emacs-lisp %}
(setq buffer-read-only nil)
(insert "<" string-1 ":" string-2 ">")
(setq buffer-read-only t)
{% endhighlight %}

This construction is ugly and unwieldy and prone to error if used in general. What if I forget to set `buffer-read-only` back to `t`? And what if other functions need to use that variable?

In a language with static scope, the only alternative to global variable mutation is passing arguments. In this case, `insert` would have to be rewritten to include an `override-read-only` flag. But there could be a thousand other functions also concerned with a buffer's read-only status. Should they all be required to take this flag? And conversely there could be a thousand other buffer properties that might affect `insert`. Where would the flags end?

Dynamic scope offers a third solution. Instead of mutating a global variable or passing another argument, we just open a scope wherein `buffer-read-only` is nil:<sup><a id="fnr.3" class="footref" href="#fn.3">3</a></sup>

{% highlight emacs-lisp %}
(let ((buffer-read-only nil))
  (insert "<" string-1 ":" string-2 ">"))
{% endhighlight %}

We avoid all the risks associated with global mutation, and we also avoid a potential explosion of passed arguments.

Here are some other cases in Emacs where dynamic scope can be put to good use:

{% highlight emacs-lisp %}
(let ((fill-column 70))
  (fill-paragraph))

(let ((visible-bell t))
  (ding))
{% endhighlight %}

Overall, it looks like **dynamic scope is good when it comes to global variables and bad when it comes to local variables**. A good compromise between static and dynamic scoping would be to explicitly mark certain variables as being dynamically scoped, and use static scoping everywhere else<sup><a id="fnr.4" class="footref" href="#fn.4">4</a></sup>. And indeed, this is exactly how Common Lisp does it. Traditionally Emacs Lisp used dynamic scope everywhere, but lexical scope was introduced in 2012, and the hybrid Common Lisp approach to scoping is ubiquitous in modern Emacs packages.

# Footnotes

<sup><a id="fn.1" href="#fnr.1">1</a></sup> Let-binding `a` will still work, however, and `(let ((a 7)) (g 5))` will evaluate to 9.

<sup><a id="fn.2" href="#fnr.2">2</a></sup> This assumes that its initial value really was `t`, which it may not have been. The safer and uglier approach would be

{% highlight emacs-lisp %}
(let ((temp buffer-read-only))
  (setq buffer-read-only nil)
  (insert "<" string-1 ":" string-2 ">")
  (setq buffer-read-only temp))
{% endhighlight %}

<sup><a id="fn.3" href="#fnr.3">3</a></sup> Note the similarity between the dynamic `let` scope and Python's `with` operator. The ugly and error-prone

{% highlight python %}
fd = open("file.txt")
print(fd.read())
fd.close()
{% endhighlight %}

is better rewritten as

{% highlight python %}
with open("file.txt") as fd:
    print(fd.read())
{% endhighlight %}

<sup><a id="fn.4" href="#fnr.4">4</a></sup> A bad compromise used by some early Lisp dialects was to use dynamic scope for interpreted code and static scope for compiled code. I've never used a system like that, but it sounds horrible.
