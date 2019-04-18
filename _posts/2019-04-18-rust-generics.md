---
title: "Lispier Rust with Generics"
date: <span class="timestamp-wrapper"><span class="timestamp">&lt;2019-04-18 Thu&gt;</span></span>
layout: post
categories:
tags:
---
In **Lisp**, as in languages like Python, **there are no types**. No, wait, there is **just one type**, and everything is that type. No, that's not right either. Well, whatever the types really are, it certainly *feels* from the programmer's perspective like there are no types, because types are never or only rarely declared. **C** is not like this, because in C you're constantly declaring types and casting and so forth.

In the **[C core of Emacs](https://nickdrozd.github.io/2018/12/20/emacs-commit.html)**, an elaborate system of **macros** makes it possible to write C code that feels like writing Lisp, or at least some kind of dynamically typed language. **[Remacs](https://nickdrozd.github.io/2019/04/16/remacs-faq.html)** is an effort to rewrite the C core in **Rust**. Rust allows for **generic types**, which aren't available in C, and using these it's possible to make the low-level code **even more Lispier than ever**.

Here's some **concretely-typed** Rust<sup><a id="fnr.1" class="footref" href="#fn.1">1</a></sup>. `cons` is defined in C, and is exported to Rust as `Fcons`. `LispObject::cons` is a wrapper around the unsafe `Fcons`, and both functions take two `LispObjects` and return another one. `frame_position` is defined in Rust, where it takes a `LispFrameRef` as an argument and returns a `LispObject`. It is wrapped with the `lisp_fn` procedural macro, which will cause it to be exported as a function called `Fframe_position` which takes `LispObject` for its input and output.

{% highlight rust %}
extern "C" {
    pub fn Fcons(arg1: LispObject, arg2: LispObject) -> LispObject;
}

impl LispObject {
    pub fn cons(car: LispObject, cdr: LispObject) -> Self {
        unsafe { Fcons(car, cdr) }
    }
}

#[lisp_fn]
pub fn frame_position(frame: LispFrameRef) -> LispObject {
    LispObject::cons(
        LispObject::from(frame.left_pos),
        LispObject::from(frame.top_pos),
    )
}
{% endhighlight %}

`frame_position` just returns a cons pair containing two fields from the given frame. But those fields are numbers (`c_int`, specifically), and `LispObject::cons` requires `LispObjects`, and so the numbers must be cast before passing them along.

**Explicit type conversion** of this sort was happening all over the place in the Remacs Rust code, and it was **ugly and burdensome**. Wouldn't it be easier to just skip it? Well, generics make that possible.

Rather than forcing the **caller** to cast the arguments in preparation for consing, we can simply tell `LispObject::cons` to take care of the casting itself, **provided** that the arguments are of a type that can be converted to `LispObject`<sup><a id="fnr.2" class="footref" href="#fn.2">2</a></sup>:

{% highlight rust %}
impl LispObject {
    pub fn cons(car: impl Into<LispObject>, cdr: impl Into<LispObject>) -> Self {
        unsafe { Fcons(car.into(), cdr.into()) }
    }
}

#[lisp_fn]
pub fn frame_position(frame: LispFrameRef) -> LispObject {
    LispObject::cons(frame.left_pos, frame.top_pos)
}
{% endhighlight %}

Isn't that nice? Now `LispObject::cons` takes two arguments, each of which is something that can be converted to `LispObject`, and those arguments are converted before being passed along to `Fcons`. **The caller doesn't need to worry about types anymore!**

This is not bad, and the Rust `LispObject::cons(4, "abc")` looks a lot like the Lisp `(cons 4 "abc")`. But in Lisp it's also common to use **literal syntax** like `'(4 . "abc")`, without calling a function. Can this be done in Rust? Yes, by implimenting **tuple conversion** for `LispObject`:

{% highlight rust %}
impl<S, T> From<(S, T)> for LispObject
where
    S: Into<LispObject>,
    T: Into<LispObject>,
{
    fn from(t: (S, T)) -> Self {
        Self::cons(t.0, t.1)
    }
}

#[lisp_fn]
pub fn frame_position(frame: LispFrameRef) -> (c_int, c_int) {
    (frame.left_pos, frame.top_pos)
}
{% endhighlight %}

Now `frame_position` doesn't call `LispObject::cons` at all &#x2013; it just uses a **native Rust tuple**! And because it no longer returns a `LispObject`, its **return type** can be updated to the **more specific** `(c_int, c_int)`. Because a tuple of things that can be converted to `LispObject` can itself be converted to `LispObject`, the `lisp_fn` macro will ensure that this function is still properly exported as a Lisp function with `LispObject` inputs and outputs.

Note that because the `From` and `Into` traits are defined in terms of each other, the definition for tuple conversion is **recursive**, and so it can handle **arbitrarily nested tuple pairs** "for free".


# Exercise for the reader

It's possible to convert arbitrarily nested tuple pairs into a `LispObject`. Is it possible to **destructure** a `LispObject` into arbitrarily nested tuple pairs?


# Remacs PRs containing further commentary

-   [Make cons generic](https://github.com/remacs/remacs/pull/1182)
-   [impl From<(S, T)> for LispObject](https://github.com/remacs/remacs/pull/1213)
-   [Add tuple conversions](https://github.com/remacs/remacs/pull/1215)
-   [Use impl notation for generics](https://github.com/remacs/remacs/pull/1277)

# Footnotes

<sup><a id="fn.1" href="#fnr.1">1</a></sup> Irrelevant and boring details have been suppressed.

<sup><a id="fn.2" href="#fnr.2">2</a></sup> This implementation uses the [`impl Trait`](https://doc.rust-lang.org/nightly/edition-guide/rust-2018/trait-system/impl-trait-for-returning-complex-types-with-ease.html) syntax, new in **Rust 2018**. Without that notation, `LispObject::cons` would be more verbose:

{% highlight rust %}
impl LispObject {
    pub fn cons<A: Into<LispObject>, D: Into<LispObject>>(car: A, cdr: D) -> Self {
        unsafe { Fcons(car.into(), cdr.into()) }
    }
}
{% endhighlight %}

`impl Trait` is [unpopular with some](https://github.com/rust-lang/rfcs/pull/2444), but I love it. Why should I need to come up for names for the types when the names aren't used? We have anonymous functions, why not **anonymous types**?
