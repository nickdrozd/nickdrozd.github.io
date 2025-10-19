---
title: "Recursive Type Definitions in Rust"
date: <span class="timestamp-wrapper"><span class="timestamp">&lt;2025-10-18 Sat&gt;</span></span>
layout: post
categories: 
tags: 
---

I am pleased to announce that I was able to **[add a new feature](https://github.com/rust-lang/rust-clippy/pull/15566)** to the **Rust Clippy linter**. Namely: the `use_self` lint will now notify that the **`Self` keyword** can be used in **recursive type definitions**. This feature is now officially available in the Nightly release. Hip hip hooray.

Recursive type definitions? `Self` keyword? Let's look at some examples. First, consider the humble linked list, the nodes of which contain some data and possibly also a link to another node:

{% highlight rust %}
struct LinkedList {
    data: u8,
    link: Option<Box<LinkedList>>,
}
{% endhighlight %}

The `link` field refers back to the object's own type, so this is a recursive type definition. In this case, the `data` field contains a `u8`. Except, actually, the requirements just changed. Now the `data` needs to be generic. Okay, just a little change to make:

{% highlight rust %}
struct LinkedList<T> {
    data: T,
    link: Option<Box<LinkedList<T>>>,
}
{% endhighlight %}

Obviously the `data` field was updated, and the struct had to be made generic accordingly. But on top of that, the recursive field also had to be updated. Kind of annoying, but it should be fine going forward. Except, no, wait, the requirements changed again. Now instead of an owned value, we're going to take a reference. Gotta update with a lifetime now:

{% highlight rust %}
struct LinkedList<'t, T> {
    data: &'t T,
    link: Option<Box<LinkedList<'t, T>>>,
}
{% endhighlight %}

Okay I am starting not to like this. Every time the struct gets updated, the recursive field gets updated too. Lifetime soup. There's gotta be a better way. Oh hey, there is. Clippy says:

{% highlight nil %}
error: unnecessary structure name repetition
  |
  |     link: Option<Box<LinkedList<'t, T>>>,
  |                      ^^^^^^^^^^^^^^^^^ help: use the applicable keyword: `Self`
{% endhighlight %}

Instead of explicitly referring to the object by name, the `Self` keyword can be used instead:

{% highlight rust %}
struct LinkedList<'t, T> {
    data: &'t T,
    link: Option<Box<Self>>,
}
{% endhighlight %}

Well would you look at that. Now the type definition can undergo further changes and the recursive field can be left undisturbed.

`Self` is not just for `struct`. It is also for `enum`. For example, the definition of a basic Lisp language:

{% highlight rust %}
enum Expr<NumType, SymType> {
    Number(NumType),
    Symbol(SymType),
    Define(SymType, Box<Self>),
    Call(Box<Self>, Vec<Self>),
    Lambda(Vec<SymType>, Box<Self>),
    If(Box<Self>, Box<Self>, Box<Self>),
}
{% endhighlight %}

[The Rust language reference](https://doc.rust-lang.org/reference/types.html#recursive-types) also says that `union` can be recursive. But unions are already unsafe, so I didn't implement this new feature for them. Recursive unions are not just unsafe, but exotically unsafe, and probably shouldn't be messed with.

It might be argued that using `Self` in type definitions is not idiomatic. Certainly it is not very common. But to me that just means it is a good language feature that is poorly publicized. I myself didn't learn about it until I had to update a recursive struct to be generic. I was annoyed that the `use_self` lint hadn't alread told me that `Self` could be used there. Hence the new feature.

But still, what if you have recursive type definitions and you enable the opt-in `use_self` lint and you really, really do not want to use `Self`? Well there is something for you too. Just add `recursive-self-in-type-definitions = false` to your Clippy configuration file and you won't have to hear about it.


# Discussion Questions

1.  Have you used `Self` in recursive type definitions?
2.  Were you aware that this is even possible?
3.  Have you used `Self` in `impl` blocks?
4.  Does the new check have any false negatives?
5.  Does the new check have any false positives?
6.  Are there any uses for recursive unions?
