---
title: "Tetration"
date: <span class="timestamp-wrapper"><span class="timestamp">&lt;2023-09-25 Mon&gt;</span></span>
layout: post
categories: 
tags: 
---

Multiplication is repeated addition: *2 \* 5* is defined as *2 + 2 + 2 + 2 + 2*.

Exponentiation is repeated multiplication: *2<sup>5</sup>* is defined as *2 \* 2 \* 2 \* 2 \* 2*.

Repeated exponentiation is known as ***tetration***: *2 ↑↑ 5* is defined as *2<sup>(2<sup>(2<sup>(2<sup>2</sup>)</sup>)</sup>)</sup>*.

Exponential growth is difficult for people to reason about. The numbers are **surprising and overwhelming**. For example, if a plague spreads at an exponential rate and the infected population doubles every day, how long will it take for every person on the planet to be infected? The answer is: a lot sooner than most people would expect. The number of digits of a power of two is approximately one third of the power. If there are eight billion people, then that's ten digits, and three times that is thirty, so under these conditions everyone will be infected in about a month.

Well, tetration grows **a lot faster than that**. Here are the first few values of *2 ↑↑ n*:

|---|---|
| *n* | *2 ↑↑ n* |
|---|---|
| 0 | 1 |
| 1 | 2 |
| 2 | 4 |
| 3 | 16 |
| 4 | 65,536 |
| 5 | > 10<sup>19,729</sup> |
|---|---|

That is to say, *T = 2 ↑↑ 5* is a number with almost twenty thousand digits. *T* represents a **sweet spot for big numbers**. It is perhaps the smallest number that is easy to define, dramatically larger than any real-world number, and also ***physically obtainable***. By "physically obtainable" I mean that it can actually be displayed on a computer and witnessed in full, although this might take a little work.

First of all, some programming langauges represent numbers using **bit sequences of fixed length**. There are infinitely many numbers and only finitely many bit sequences of a given length, so it is only possible to deal with numbers within a certain bound. For example, the largest 64-bit number is *2<sup>64</sup> - 1 = 18,446,744,073,709,551,615*, a number with only twenty digits. Even on a platform with 65,536-bit numbers, *T* would be just a little too big to represent.

So bearing witness to *T* will require a language with unbounded numbers, like **Python**. But still there will be problems:

{% highlight python %}
>>> T = 2 ** 2 ** 2 ** 2 ** 2
>>> T
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
ValueError: Exceeds the limit (4300) for integer string conversion; use sys.set_int_max_str_digits() to increase the limit
{% endhighlight %}

By default Python won't display such a large number. To see *T*, the default must be overridden:

{% highlight python %}
>>> import sys
>>> sys.set_int_max_str_digits(20_000)
>>> T
{% endhighlight %}

Will that work? That depends on the local conditions. Up until just recently, trying to display *T* inside **Emacs** would cause it to freeze hard due to a long-standing and unbelievably annoying bug with long lines. So don't try this on Emacs version 28 or earlier. I haven't tried it on other platforms, but my guess is that it would cause problems elsewhere as well.

The first and last digits of *T* in base-10 are: *2003&#x2026;6736*. As expected, it is an even number.

The base-10 representation of *T* contains ***every single three-digit number sequence***. That is, it contains *000*, *001*, &#x2026;, and *999* as subsequences.

{% highlight python %}
T = 2 ** 2 ** 2 ** 2 ** 2
T_str = str(T)

seq_len = 3

for n in range(10 ** seq_len):
    assert str(n).zfill(seq_len) in T_str
{% endhighlight %}
