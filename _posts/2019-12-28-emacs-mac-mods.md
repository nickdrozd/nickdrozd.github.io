---
title: "Modified Emacs Mac Modifiers"
date: <span class="timestamp-wrapper"><span class="timestamp">&lt;2019-12-28 Sat&gt;</span></span>
layout: post
categories:
tags:
---
Here's the layout of the bottom row of a standard **Mac keyboard**<sup><a id="fnr.1" class="footref" href="#fn.1">1</a></sup>:

{% highlight nil %}
+-----+-----+-----+-----+-------------------+-----+-----+
|     |     |     |     |                   |     |     |
|Fn   |Ctrl |Optn |Cmd  |       Space       |Cmd  |Optn | [arrows]
+-----+-----+-----+-----+-------------------+-----+-----+
{% endhighlight %}

Notice that there is **no Control key on the right side**. This is not normally a problem, as the keybindings for everyday actions on a Mac (cut, paste, find, refresh, etc) are the same as **CUA** keybindings but with the Control key replaced by the Command key (e.g. `Cmd-a` for select-all instead of `Ctrl-a`).

**Not Emacs though.** No, when Emacs says "Control", it means Control. Everything in Emacs runs through the Control key, and that means everything runs through your left pinky. It's an arthritic nightmare, like something out of a *Saw* movie. My hand hurts just thinking about it.

Some will grin and bear it and grind through the pain, perhaps thinking that this is just what it takes to use Emacs. **Don't do it. "Emacs pinky" is not a badge of honor. You deserve better.**

There's an easy solution to this horrible situation:

{% highlight emacs-lisp %}
(when (eq system-type 'darwin)
  (setq
   ns-command-modifier 'control
   ns-option-modifier 'meta
   ns-control-modifier 'super
   ns-function-modifier 'hyper))
{% endhighlight %}

With this, you can use the Command key instead of the physical Control key, improving the keyboard layout in two major ways. First, it makes it possible to use **either hand** to hit (what Emacs thinks is) the "Control" key, rather than just the left. Second, **thumbs** can be used instead of pinkies. **The ergonomic benefits of this change cannot be overstated.**

Oh, and then rebind CapsLock to Command at the system level. CapsLock is a dumbass key, and rebinding it will leave you with **three "Control" keys**.

**Perversely**, the version of Emacs that comes installed on Macs<sup><a id="fnr.2" class="footref" href="#fn.2">2</a></sup> does not allow for this change. If you want to use Emacs but you can't install an up-to-date version, you have no choice but to grind your left pinky into dust.

# Footnotes

<sup><a id="fn.1" href="#fnr.1">1</a></sup> This applies to Mac laptops as well as wireless Mac keyboards. Desktop Mac keyboards with a dedicated numpad have right-side Control keys, but those are relatively uncommon.

<sup><a id="fn.2" href="#fnr.2">2</a></sup> Version 22, from 2007. As I understand it, this was the last version of Emacs licesnced under GPLv2, and Apple won't use anything with GPLv3.
