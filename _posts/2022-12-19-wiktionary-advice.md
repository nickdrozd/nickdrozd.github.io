---
title: "Some Advice for Browsing Wiktionary in Emacs"
date: <span class="timestamp-wrapper"><span class="timestamp">&lt;2022-12-19 Mon&gt;</span></span>
layout: post
categories:
tags:
---

**Emacs comes with a web browser built in**. Although it's often regarded as a novelty, *EWW* (as it's known) is a real browser, and **[I use it all the time](https://nickdrozd.github.io/2018/10/17/web-scraping.html)**. A lot of web browsing involves text, and Emacs is the ultimate text-handling platform, so it's obvioiusly a good match.

But as with many things in Emacs, EWW has some **irregularities**. For example, here is the **Wiktionary** entry for the word **"locus"** as viewed in EWW:

![img](/assets/wiktionary-advice/locus-eww-before.png)

**Five definitions are listed, but one of them is blank**. What is the missing definition? Is it important? I sure hope not. Dropping information from a web page without warning would be a serious problem!

Compare with the same page as viewed in **Firefox**:

![img](/assets/wiktionary-advice/locus-ff.png)

The Firefox version shows **only four definitions**, exactly the same ones shown in EWW. So it appears that rather than *dropping* a definition, EWW is *inserting* a blank one. That's not such a serious problem, but it's still **kind of annoying**.

To see what's going on, we need to look at the **HTML source**. (This can be obtained from within EWW by pressing `v`.) The word definitions are grouped in an ordered list `ol` with each individual definition showing up as a list item `li`:

{% highlight html %}
<ol><li>A <a href="/wiki/place" title="place">place</a> or <a href="/wiki/locality" title="locality">locality</a>, especially a <a href="/wiki/centre" title="centre">centre</a> of <a href="/wiki/activity" title="activity">activity</a> or the <a href="/wiki/scene" title="scene">scene</a> of a <a href="/wiki/crime" title="crime">crime</a>.
<dl><dd><div class="h-usage-example"><i class="Latn mention e-example" lang="en">The cafeteria was the <b>locus</b> of activity.</i></div></dd></dl></li>
<li class="mw-empty-elt"></li><li class="senseid" id="English:_set"><span class="ib-brac">(</span><span class="ib-content"><a href="/wiki/mathematics" title="mathematics">mathematics</a></span><span class="ib-brac">)</span> The <a href="/wiki/set" title="set">set</a> of all <a href="/wiki/point" title="point">points</a> whose <a href="/wiki/coordinate" title="coordinate">coordinates</a> <a href="/wiki/satisfy" title="satisfy">satisfy</a> a given <a href="/wiki/equation" title="equation">equation</a> or <a href="/wiki/condition" title="condition">condition</a>.
<dl><dd><div class="h-usage-example"><i class="Latn mention e-example" lang="en">A circle is the <b>locus</b> of points from which the distance to the center is a given value, the radius.</i></div></dd></dl></li>
<li><span class="ib-brac">(</span><span class="ib-content"><a href="/wiki/genetics" title="genetics">genetics</a></span><span class="ib-brac">)</span> A fixed <a href="/wiki/position" title="position">position</a> on a <a href="/wiki/chromosome" title="chromosome">chromosome</a> that may be occupied by one or more <a href="/wiki/genes" title="genes">genes</a>.</li>
<li><span class="ib-brac">(</span><span class="ib-content">chiefly&#32;in the <a href="/wiki/Appendix:Glossary#plural" title="Appendix:Glossary">plural</a></span><span class="ib-brac">)</span> A <a href="/wiki/passage" title="passage">passage</a> in <a href="/wiki/writing" title="writing">writing</a>, especially in a <a href="/wiki/collection" title="collection">collection</a> of <a href="/wiki/ancient" title="ancient">ancient</a> <a href="/wiki/sacred" title="sacred">sacred</a> writings arranged according to a <a href="/wiki/theme" title="theme">theme</a>.</li></ol>
{% endhighlight %}

Apparently the blank definition comes from an **explicitly empty list item**: `<li class="mw-empty-elt"></li>`. I don't know why Wiktionary includes that list item, and I don't know how Firefox knows not to display it.

**It's not obvious that it's a [bug](https://lists.gnu.org/archive/html/bug-gnu-emacs/2022-11/msg02149.html) to show the empty list item**. I mean, it's there, right? But still, it looks like an error, so I don't want to see it. This will require **modifying the browser's behavior**.

Fortunately, Emacs provides a mechanism to unobtrusively modify any behavior at all, namely **[advice](http://localhost:4000/2019/01/14/tetris.html)**. In short, we will define a new function that will attach itself to an existing function and do some extra stuff.

This could be done in lots of different ways. My idea was to modify the list item handler `shr-tag-li`, a function of one argument:

{% highlight emacs-lisp %}
(defun shr-tag-li (dom) ...)
{% endhighlight %}

We need to define a new function of two arguments to wrap this one. The two arguments will be the handler function and its argument, and the wrapping function will call the handler on its argument **only when the list item is non-empty**:

{% highlight emacs-lisp %}
(defun skip-empty-li (shrtagli dom)
  (when (cddr dom)
    (funcall shrtagli dom)))
{% endhighlight %}

The wrapper will be attached to the wrapped with `advice-add`:

{% highlight emacs-lisp %}
(advice-add
   'shr-tag-li :around
   #'skip-empty-li)
{% endhighlight %}

And that's it. **This fixes the problem**:

![img](/assets/wiktionary-advice/locus-eww-after.png)
