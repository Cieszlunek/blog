---
layout: post
title:  "Hexagonal (or ports & adapters) architecture"
date:   2023-08-03 18:55:00 +0200
tags: hexagonal_architecture architecture ports_adapters
---

Hi,

In my previous post, I wrote that the hexagonal architecture allows for an easy transition from microservices to a modular monolith. This also works the other way around. This property stems from the fact that such a change does not require any modifications to the business logic of a given service.

# Hexagonal, or Ports and adapters architecture

The hexagonal architecture is also known as the Ports and Adapters architecture. The first term refers to how the environment is built with microservices based on this architecture, while the second term focuses more on explaining what a single hexagon looks like.

* Port - it is a plug along with a protocol, such as an HDMI plug and the protocol in which various data is transmitted.
* Adapter - is something that translates data from the protocol into the language of the business logic of the module and vice versa.

A port could be, for example, a REST protocol and the libraries that support it. In this case, the adapter is the application endpoint, using a framework that translates the parameters and values sent in the request into specific method calls in the application's business logic.

![Ports and adapters architecture](/images/posts/hexagonalArch.drawio.svg)

When a service wants to interact with another service, it must also do so through an adapter. This way, we separate the business logic of the application with a layer of adapters from the external world. Thus, we have two types of adapters: input adapters and output adapters.

Looking at it from a broader perspective, hexagons fit together well in shape. It's convenient to build large and complex systems with them.

![Ports and adapters architecture](/images/posts/multiHexagonalArch.drawio.svg)

Personally, I really like this architecture because it is very flexible. By using the `facade` pattern, you have beautifully separated the business logic code from the adapter code. And now, when you apply [BDD]({% post_url /articles/2022-10-29-bdd %}) to test your business logic, you have a module that makes working with it a pure pleasure. You're welcome :)

# Hexagonal Architecture Supports Merging Microservices into a Monolith or the Other Way Around.

When we want to merge two services that communicate through, for instance, the REST protocol, we can actually put them together in one project; they will compile and deploy together, and everything will work. Now, these two services run in the same process, and it would be a waste not to take advantage of it. Communication within the process does not require data conversion, authentication, or thread blocking. A good step is to exchange the REST protocol for an inter-process communication protocol. This will require writing adapters that will replace the REST adapters. You need to switch the plug.

The same goes if you want to extract a service from a modular monolith into a microservice. You add a new port, write the adapters, and extract the service for a separate deployment. In this case, remember to write appropriate [Contract Tests]({% post_url /articles/2023-04-22-contract-tests %}) that will verify the correctness of communication between your services.

As you probably noticed, such migration can be carried out in a way that guarantees continuous availability of the modified services.




