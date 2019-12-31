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

**Addendum <span class="timestamp-wrapper"><span class="timestamp">&lt;2019-12-31 Tue&gt;</span></span>**

[A commenter](https://github.com/nickdrozd/nickdrozd.github.io/issues/2) pointed out that **Japanese Mac keyboards** have a different bottom row layout, and therefore objected to my use of the word **"standard"**, suggesting that it be replaced with the less normative "US QWERTY". The bottom row on a Japanese Mac keyboard looks like this (the alignment will be off because I don't feel like using fullwidth characters):

{% highlight nil %}
+-----+-----+-----+-----+---------------+-----+-----+-----+
|     |     |     |     |               |     |     |     |
|Caps |Optn |Cmd  |英数  |     Space     |かな |Cmd  |Fn   | [arrows]
+-----+-----+-----+-----+---------------+-----+-----+-----+
{% endhighlight %}

This layout is unusual in a few ways:

1.  **CapsLock in the far corner.** CapsLock should be abolished entirely, but if must be included, the more marginal the location the better.
2.  **A very small Space key,** making room for an additional modifier key. I would love to have this, since personally I only use my right thumb for Space, and all my keyboards show a worn-down spot on the Space key below the N and M keys. Most of the Space key is wasted space, which I guess is appropriate in a horrible way.
3.  **The 英数 (*eisu*) key.** This toggles between Japanese and Roman characters. More generally, it might toggle betweeen Japanese and non-Japanese characters, but I have no idea how this works in practice.
4.  **The かな (kana) key.** This toggles between the Japanese hiragana and katakana syllabaries. It might also be used for kanjis? I don't know Japanese and I've never used one of these keyboards, but it's something like that.

Clearly this post will be of limited value to users of Japanese Mac keyboards. But what about the word "standard"? Well, [this list](https://keyshorts.com/blogs/blog/37615873-how-to-identify-macbook-keyboard-localization) purports to show all the available physical Mac keyboard layouts, and as far as I can tell, **every single Mac keyboard except for Japanese uses the same modifier key layout**. Based on this finding, I am comfortable labeling the Japanese layout as **"non-standard"**. There is no need to specify any further details ("US", "QWERTY", etc) because this post only deals with the bottom row, which is almost universal.

# Footnotes

<sup><a id="fn.1" href="#fnr.1">1</a></sup> This applies to Mac laptops as well as wireless Mac keyboards. Desktop Mac keyboards with a dedicated numpad have right-side Control keys, but those are relatively uncommon.

<sup><a id="fn.2" href="#fnr.2">2</a></sup> Version 22, from 2007. As I understand it, this was the last version of Emacs licesnced under GPLv2, and Apple won't use anything with GPLv3.
