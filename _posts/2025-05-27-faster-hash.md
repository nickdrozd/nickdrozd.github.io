---
title: "What a Difference a Faster Hash Makes"
date: <span class="timestamp-wrapper"><span class="timestamp">&lt;2025-05-27 Tue&gt;</span></span>
layout: post
categories: 
tags: 
---

I have some Rust code that does a bunch of pure computation. A lot of it. To solve basically an [elaborate combinatorial problem](https://nickdrozd.github.io/2025/03/24/bbb-3-3.html).

Wanted to speed it up. Profiled with [`flamegraph`](https://www.ntietz.com/blog/profiling-rust-programs-the-easy-way/).

When you do performance profiling, what you really want to find are [**hot spots**](https://nickdrozd.github.io/2022/04/12/performance-hot-spots.html). Some low-hanging fruit. You want to look at the profile and see one big anomolous entry. "We're spending X% of total CPU time doing what now???". Look at the code and find there is some critical point where something infelicitous is being done. Then fix it for a big-time speed-up. That's the dream.

And lucky for me that's exactly what I found. According to the graph, I was spending 23.25% of total CPU time on the function `<std::hash::random::DefaultHasher as core::hash::Hasher>::write`. What? Yeah, that's just time spent going back and forth with `std::collections::{HashMap, HashSet}`. A really stupid amount of effort to spend on a basic administrative task.

Replaced the builtin hash collections with an external package, `ahash::{AHashMap, AHashSet}`. Boy oh boy, what a difference it made. The big computational task went from taking 67 minutes to 55 minutes. That's an 18% improvent for a diff of only a few lines. Hooray.

Why is `std::collections::HashMap` so much slower than `ahash::AHashMap`? Well, the first thing to note is that *ahash* is a really hard word to type. I have never typed it correctly on the first try. It always comes out as *ahahs* or *ashash*, etc. That doesn't have anything to do with speed, it's just something I wanted to complain about.

The builtin hash procedure is slower because it attempts to provide some security. It wants to make it as difficult as possible to guess a key from a value. That is a great feature for a web server or CLI tool. But it is totally useless for solving combinatorial problems. There is no need to make anything difficult to guess because there is no untrusted input. It is the computational equivalent of installing external locks on the internal doors in a home. Stop doing that and it goes a lot faster.

There are other hash collection implementations. Some of them are specialized for certain types of data. For example if the data is all numbers then you will want one hash procedure, but a different one if you are hashing compound objects.

A good way to make it easy to experiment with different hashers is to use ***import aliases***. What you want to avoid is having to modify every callsite. For example:

{% highlight rust %}
use std::collections::{HashMap, HashSet};

let mut a = HashMap::new();  // gotta change this
let mut b = HashMap::new();  // gotta change this
let mut c = HashSet::new();  // gotta change this
let mut d = HashSet::new();  // gotta change this
{% endhighlight %}

Instead, I like to refer to the collections by more generic names, like `Dict` and `Set`.

{% highlight rust %}
use std::collections::{HashMap as Dict, HashSet as Set};

let mut a = Dict::new();
let mut b = Dict::new();
let mut c = Set::new();
let mut d = Set::new();
{% endhighlight %}

Swapping in a different hasher is only a matter of changing the import to `use ahash::{AHashMap as Dict, AHashSet as Set}`.

This technique has the added benefit / drawback of making the code look more like Python.
