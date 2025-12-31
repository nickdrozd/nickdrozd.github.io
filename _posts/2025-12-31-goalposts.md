---
title: "Running out of places to move the goalposts to"
date: <span class="timestamp-wrapper"><span class="timestamp">&lt;2025-12-31 Wed&gt;</span></span>
layout: post
categories: 
tags: 
---

The history of artificial intelligence is full of **moved goalposts**. For example, **chess** was long thought to be a holy grail of intelligence. A solution to chess would be the solution to intelligence itself. But then chess got solved, and it didn't seem like intelligence had been achieved. It turned out that chess wasn't all that important after all, and intelligence was still out of reach. Goalposts moved.

Moving the goalposts is often an accusation. It is perceived as dishonest, or a form of cheating. But it is an important part of science. **Sometimes you find that the goalposts really are in the wrong place, and they need to be moved.**

**Where should the AI goalposts be moved now?** That is becoming an increasingly difficult question.

When ChatGPT came to prominence in 2023, it was clear that **the so-called "Turing test" had more or less been passed**, and so the goalposts needed to be moved again. LLM technology at that time had a lot of obvious shortcomings, so there were lots of places to move the goalposts to. Lots of comments of the form "LLMs can never be intelligent because they can't do X", where X is **some ad-hoc goal that has never been discussed before**.

Some of these ad-hoc goals became **popular memes**. Look, ChatGPT can't tell how many r's are in the word "strawberry", therefore it will never be truly intelligent. Some people thought this was a showstopper / mic drop / big deal. It wasn't a big deal though. First, because it was a goal that nobody had ever cared about before. Second, because ChatGPT soon became able to do it. Whoops. Time to move the goalposts again.

For a while I had **my own personal ad-hoc benchmark**. A complicated coding task related to the **Busy Beaver problem**. *[Warning: technical details ahead.]* Check out [the pseudocode from this paper](https://arxiv.org/pdf/2509.12337#subsection.4.4) for what is known as the "closed position set" method (CPS). Basically there is a `todo` pile and a `seen` pile; items from the `todo` pile are popped, processed, and added to `seen`; and when the `todo` pile is finished, the `seen` pile is recycled back into `todo`, repeating all this until nothing new is added to `seen`. This is all accomplished by nested `while` loops. If you hear that and think, that sounds like it will involve a catastrophic amount of deep data structure cloning, well, you're right. I implemented the algorithm as-is in Rust and it was indeed catastrophically slow. I wanted to change it to track what would need to be updated after an item was processed. But it's tricky to get it right, and a lot of work, and I never quite managed it.

**I failed at it, but I took some comfort in the fact that ChatGPT couldn't get it either.** Over and over I tried to goad it into giving me working code, and it never did. I returned to it as new models came out. Tried it with DeepSeek too, nothing ever got it right. It can never be truly intelligent if it can't figure this out.

**Except, recently it did get it right.** I think it was with "ChatGPT 5.1 Thinking". I said, here's some code, figure out how to eliminate the catastrophic cloning. And within a minute it came back with working code. Just like that. Substantially faster and totally correct according to my elaborate test suite. And then I pressed a little further and it came up with a bunch of other performance optimizations. Oh. Wow. Time to move the goalposts again. Uh, where to?

**All that's left is "AI can never come up with an original artistic / scientific idea". Except, this is not true anymore.** [AI-generated music is really starting to hit](https://nickdrozd.github.io/2025/10/07/beach-boys-beatles-ai.html), and of course original, compelling images have been old hat for a while now. What about original scientific ideas? Yes, that's starting to happen too.

I'll give another Busy Beaver example. The Busy Beaver problem is uncomputable, in the sense that there is no algorithm that can solve it outright. There is a variation known as the **Beeping Busy Beaver**. This problem is super-uncomputable, meaning that it would still be uncomputable even if there were a solution to the regular-uncomputable Busy Beaver. It is impossible to exaggerate how difficult this problem is from a theoretical perspective, and it is also incredibly difficult practically, even on small instances. There are various techniques for dealing with small instances of the Busy Beaver problem, and nobody has any idea how to get them to apply to the Beeping Busy Beaver.

Well, "ChatGPT 5.2 Thinking" was actually able to move the needle slightly. It proposed modifying the CPS method to maintain a state transition graph as the closed position set is constructed; then analyzing the graph afterwards to verify certain liveness conditions. TBH, I don't understand the details very well. But the code mostly works. It has a good true positive rate and a surprisingly low false positive rate. Not perfect, but it is literally the best idea I have ever heard for how to deal with this problem. It is certainly not something that is just regurgitated from the training set. **It is a full-blown original idea.**

**So given all this, where should the goalposts be moved to next?** I don't know if I'm competent to tell. AI seems to have caught up to my own intelligence even in those narrow domains where I have some expertise. What is there left that AI can't do that I would be able to verify? But even ignoring that, what is the point of trying to move the goalposts anymore? AI capabilities are improving at such an incredible pace that people don't even realize that the goalposts need to be moved again since the last time they moved them. **Perhaps the time has come to stop moving the goalposts and simply conclude that artificial intelligence really has been achieved.**
