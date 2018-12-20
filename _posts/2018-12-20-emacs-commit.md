---
title: "My First Emacs Commit"
date: <span class="timestamp-wrapper"><span class="timestamp">&lt;2018-12-20 Thu&gt;</span></span>
layout: post
categories:
tags:
---
I just landed **my first commit in Emacs**. Hooray! And I don't mean some external package ([I've done that](https://github.com/Wilfred/helpful/pulls?utf8=%25E2%259C%2593&q=is%253Apr+author%253Anickdrozd)) or some weird Emacs fork ([I've done that too](https://github.com/Wilfred/remacs/pulls?utf8=%25E2%259C%2593&q=is%253Apr+author%253Anickdrozd)), but **real-deal core GNU Emacs**. Gaze upon it, glorious commit [5d6258518e4ba5312fc7d6564bba2232e06bf0a6](https://github.com/emacs-mirror/emacs/commit/5d6258518e4ba5312fc7d6564bba2232e06bf0a6)!

Besides whitespace, it adds just four characters: `else`. To explain what the commit does, let's take a step back and look at the structure of Emacs as a whole.

Most Emacs code (including all external packages) is written in a Lisp dialect known as **Emacs Lisp** or **Elisp**. Org Mode, Magit, [Eww](https://nickdrozd.github.io/2018/10/17/web-scraping.html), Calc, Tetris, all the hits, all the classics, all written in Elisp. Elisp is not self-hosting, however &#x2013; its interpreter is written in **C**. This is partly for portability, but mostly for speed. Here's [ **Richard Stallman** on the design of Emacs](https://www.gnu.org/gnu/rms-lisp.html):

> Well, if you didn't have the Lisp compiler you couldn't write the whole editor in Lisp — it would be too slow, especially redisplay, if it had to run interpreted Lisp. So we developed a hybrid technique. The idea was to write a Lisp interpreter and the lower level parts of the editor together, so that parts of the editor were built-in Lisp facilities. Those would be whatever parts we felt we had to optimize&#x2026;[M]ost of the editor would be written in Lisp, but certain parts of it that had to run particularly fast would be written at a lower level&#x2026;C was a good, efficient language for portable programs to run in a Unix-like operating system. There was a Lisp interpreter, but I implemented facilities for special purpose editing jobs directly in C — manipulating editor buffers, inserting leading text, reading and writing files, redisplaying the buffer on the screen, managing editor windows.

Emacs Lisp code is **introspectable**, and can be read, poked at, and rewritten on the fly, but the C code is not. Most of it is strictly behind the scenes and is completely inaccessible to the user once it is compiled. Straddling the line between Lisp and C are **primitive Lisp functions**. These are functions that for the most part act as normal Lisp functions but are defined in C code.

Now, like Python, Elisp is **strongly, dynamically typed**. This means that although a variable's type may not be known in advance, it is checked at runtime before performing certain operations, with an error being raised if the types don't match up. You might wonder how a Lisp function could be written in C, given that C is **weakly, statically typed** (types must be known in advance, but they can often be coerced if they aren't quite right). The way around this is to use a **tagged union**. In its simplest form, this is a struct with two fields, one to hold primitive data, and one with an enum indicating how the data field should be interpreted (for instance, whether a set of bits should interpreted as an int or a float or a pointer). This is the datatype used by primitive Lisp functions defined in C &#x2013; all inputs and outputs are of type `Lisp_Object`.

That takes care of Lisp's dynamic typing. The strong typing is handled by **type checks** executed in primitive functions. Take the exponent function `expt` for instance:

{% highlight c %}
DEFUN ("expt", Fexpt, Sexpt, 2, 2, 0,
       doc: /* Return the exponential ARG1 ** ARG2.  */)
  (Lisp_Object arg1, Lisp_Object arg2)
{
  CHECK_NUMBER (arg1);
  CHECK_NUMBER (arg2);

  /* Common Lisp spec: don't promote if both are integers, and if the
     result is not fractional.  */
  if (INTEGERP (arg1) && !NILP (Fnatnump (arg2)))
    return expt_integer (arg1, arg2);

  return make_float (pow (XFLOATINT (arg1), XFLOATINT (arg2)));
}
{% endhighlight %}

Before any calculations are made, both arguments are passed through `CHECK_NUMBER`. If either argument is something other than a float or an int, a type error will be raised.

Finally, my commit. The primitive function `insert-char` (which by default is bound to `C-x 8 RET`) takes two arguments, one of which is optional (actually it can take a third optional argument, but that doesn't matter here). The first argument is a code for the character to be inserted into the current buffer, and the second argument, if supplied, is the number of times to insert it. If the second argument is not supplied (or if it is null), the character will be inserted once. Thus `(insert-char #x732b)`, `(insert-char #x732b 1)`, and `(insert-char #x732b nil)` will each insert `猫`, while `(insert-char #x732b 3)` will insert `猫猫猫`.

Here is the type-checking code for `insert-char` (the arguments are called `character` and `count`):

{% highlight c %}
CHECK_CHARACTER (character);
if (NILP (count))
  XSETFASTINT (count, 1);
CHECK_FIXNUM (count);
{% endhighlight %}

In English: First, verify that `character` really is a character. Next, check whether `count` is null. If it is, set it to `1`. Finally, verify that `count` is an integer.

The problem is that there is an **unnecessary type check**. When `count` is null, it is set to `1`, and then it is verified to be an integer. But there is no need to check at that point, since it has just been set to `1`. So my commit simply changes the type check to only execute when `count` is nonnull:

{% highlight c %}
CHECK_CHARACTER (character);
if (NILP (count))
  XSETFASTINT (count, 1);
else
  CHECK_FIXNUM (count);
{% endhighlight %}

Okay, so this isn't a deep change. It also won't be very impactful: in the entire Emacs codebase, `insert-char` is called without a count argument only four times, and two of those are in games (the other two are in `lisp/elec-pair.el`). Still, it's gratifying to able to make even a small improvement in a well-trodden function that was initially written during the **Cold War**.
