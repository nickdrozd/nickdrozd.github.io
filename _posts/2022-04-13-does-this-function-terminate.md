---
title: "Does This Function Terminate?"
date: <span class="timestamp-wrapper"><span class="timestamp">&lt;2022-04-13 Wed&gt;</span></span>
layout: post
categories:
tags:
---
The function ***G*** is defined as follows:

{% highlight nil %}
G : ℕ × ℕ → ℕ

G(n, 0) = n

G(n, 1) = G(1, n + 3)

G(4k + 0, m) = G(7k +  7, m - 2)
G(4k + 1, m) = G(7k +  8, m - 1)
G(4k + 2, m) = G(7k +  8, m - 1)
G(4k + 3, m) = G(7k + 14, m - 2)
{% endhighlight %}

🛃 **Question** 🛃 Does *G(1, 1)* terminate?

🛄 **Answer** 🛄 Yes. *G(1, 1) = 2533&#x2026;2210 > 18<sup>7003</sup>*.

That was just a warmup. *G* is not the function referred to in the title of this post. What we really want to know about is ***H***:

{% highlight nil %}
H : ℕ × ℕ → ℕ

H(n, 0) = n

H(n, 1) = H(1, n + 3)

H(4k + 0, m) = H(7k + 14, m - 2)
H(4k + 1, m) = H(7k +  8, m - 1)
H(4k + 2, m) = H(7k + 15, m - 1)
H(4k + 3, m) = H(7k + 14, m - 2)
{% endhighlight %}

🛃 **Question** 🛃 Does *H(1, 1)* terminate?

🛄 **Answer** 🛄 **&#x2026; ¿ 🛐 ? &#x2026;**

*G(1, 1)* returns its answer after **28,833 iterations**. *H(1, 1)* does not return an answer after any **reasonable number** of iterations. There are two possibilities:

1.  *H(1, 1)* **never** returns an answer.
2.  *H(1, 1)* returns an answer after an **unreasonable number** of iterations.

**Practically speaking**, there is no difference &#x2013; we get no answer either way.

🛃 **Question** 🛃 Which possibility is more likely?

*G* and *H* are examples of **iterated Collatz-like functions**. The first argument accumulates the answer and the second argument counts how many times to apply the transformation. The countdown argument can get reset, giving these functions an **Ackermann** flavor.

Notice that we are *not* asking about whether *H* is **[total](https://nickdrozd.github.io/2022/04/01/total-partial-functions.html)**, and neither are we claiming that *G* is. Those would be ***very difficult claims to prove***. No, we are asking the *severely unambitiious* question of whether these functions terminate on ***just this one particular argument***. *G(1, 1)* terminates, but we can't answer for *H(1, 1)*.

One way to look at this is to say: *G* and *H* have quite similar definitions &#x2013; they differ at just two parameters. ***G(1, 1)* terminates, so why shouldn't *H(1, 1)*?** Maybe most functions similar to *G* terminate, and so we should assume that *H* does too.

On the other hand, **why exactly *does* *G(1, 1)* terminate?** There's no obvious reason why it should work. In fact, it seems **miraculous** that it terminates at all. Maybe most of these functions *don't* terminate, and *G* is a remarkable exception.

🛃 **Question** 🛃 Why are we talking about these weird functions?

🛄 **Answer** 🛄 In connection with the **[Beeping Busy Beaver](https://nickdrozd.github.io/2022/02/11/latest-beeping-busy-beaver-results.html)** problem, **Turing machine programs** have been discovered that implement these functions. The program that implements *G* is the current 5-state 2-color BBB champion, and the program that implements *H* is a contender. Both programs are "children" of the so-called **[Mother of Giants](https://www.sligocki.com/2022/04/03/mother-of-giants.html)** and were discovered by **[Shawn Ligocki](https://github.com/sligocki/busy-beaver/)**.

**Proving the true value of *BBB(5)* is at least as hard as determining the outcome of *H(1, 1)*.**
