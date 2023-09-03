---
layout: post
title:  "Facade pattern"
date:   2023-09-03 13:00:00 +0200
tags: facade pattern
---

Hi,

As I mentioned in the [article about BDD]({% post_url /articles/2022-10-29-bdd %}), the entire module's code is hidden from the external world. The module communicates with the external world through adapters. It is a good practice to isolate the business logic code from the rest of the code responsible for infrastructure. There are numerous advantages, and to avoid boring you, I will mention just a few:

- Dealing with technological debt becomes easier. When changing or upgrading the libraries used by adapters, you won't have to touch the business logic code.
- You separate responsibilities - the business logic code does what it should, and the adapter layers do what they should. Everyone knows where to look.
- You can easily test the business logic without mocking requests, setting up databases, and so on.

During development, it's important to ensure that no business logic is implemented in the adapters. This is a good practice. From experience, I know that sooner or later, there will be someone who wants to violate this rule because it's more convenient for them. By enforcing good practices, we make it harder for such individuals to take shortcuts; instead, they'll do things the right way. In our discussed case, you can use the structural pattern called "Facade."

# Facade pattern

Facade is a layer of abstraction that separates the external world from what is hidden behind it. From the outside, you can only access the hidden code through the facade and only in a way that the facade allows.

Public methods of the facade cannot use any inner class that utilizes the hidden code (you'll thank me for this later). Complex method arguments can be passed through Data Transfer Objects (DTO) classes. Within the application, these objects are mapped to inner objects, or their properties are used as arguments for various operations.

The facade class, along with DTO classes, creates a public interface for the hidden code. It hides the complexity of the business logic. Adapter classes should use the facade class to perform business logic. This way, you separate the business logic from the infrastructure code.

When I define a module, I immediately create a facade class in it. I use it in unit tests and, following the Test-Driven Development (TDD) methodology, define the signatures of its methods.

I won't provide any example code since it's readily available on the internet and in many books :)

I highly recommend this approach, and best regards.