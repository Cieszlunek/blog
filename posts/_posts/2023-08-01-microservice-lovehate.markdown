---
layout: post
title:  "To microservice or to not microservice?"
date:   2023-08-01 19:40:00 +0200
tags: microservice modular_monolith monolith module architecture agile
---

Hi,

Recently, I read [an article](https://medium.com/@abhishekranjandev/the-amazon-prime-video-monolith-shift-dissecting-microservices-serverless-and-the-real-world-ec18e429ad6f#:~:text=The%20Amazon%20Prime%20Video%20team%E2%80%99s%20recent%20case%20study,in%20a%20significant%2090%25%20reduction%20in%20operating%20expenses.) written by Abhishek Ranjan on Medium about Amazon's decision to merge several microservices into a monolith, resulting in a significant 90% reduction in operating expenses. It's great to read such news, and as someone who values frugality, I'm happy to know that less electricity is needed to run this service.

I also came across a post on Linkedin where many people shared their negative opinions about microservices, advocating for monolith as the better approach. Some shared wise words, emphasizing the importance of choosing an architecture that is efficient, uncomplicated, and easy to maintain.

In response, I believe that the default approach should be the modular monolith architecture, which was named "[Monolith First](https://www.martinfowler.com/bliki/MonolithFirst.html)" by Martin Fowler in 2015. I'd like to add a few points to Mr. Martin's words:

It can be challenging to find experienced individuals who can design well-defined service bounded contexts. With a monolith, if the boundaries change, it's easier to update them in one project without worrying about backward compatibility between modules. Embracing Agile principles, we should welcome changing requirements even late in development, as the best models evolve over time according to Eric Evans and his DDD book.

Aligning with the [Agile Manifesto](https://agilemanifesto.org/principles.html), our highest priority should be to satisfy the customer through early and continuous delivery of valuable software. A monolith allows for simpler CI/CD pipeline setup and participation in projects that already have one. It enables almost instant initial delivery, allowing us to focus on delivering business functionalities and gathering early feedback.

If the need arises to migrate a module to a microservice, it's straightforward because a well-designed module makes for an excellent candidate for microservice architecture. (If this idea doesn't resonate with you, you can check my [BDD article]({% post_url /articles/2022-10-29-bdd %}) for more insights).

Should you always pick the modular monolith architecture from the start? Not necessarily. If you have compelling reasons to opt for microservices architecture and you know precisely what you're doing, go ahead. However, keep in mind that in the future, you may need to consolidate several microservices into a modular monolith, as Amazon did. Therefore, it's wise to select an architecture that facilitates this transition easily, such as the hexagonal architecture.

