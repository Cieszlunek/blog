---
layout: post
title:  "Contract tests"
date:   2023-04-22 13:00:00 +0200
categories: scc contract test spring
mermaid: true
---

# What are contract tests? Why and when are they useful?

When we have two applications interacting with each other, we can often say that one of them is providing some functionality and the other is consuming it (let's name them producer and consumer). How can we ensure that those applications will work with each other as we expect? There is a common pattern for that - deploy those applications to separate environments and verify interactions with end-to-end (e2e) tests. If one of the applications changes, then we deploy the new version A1v2 (App 1 version 2) to this test environment and run e2e tests again. If they pass, we can deploy the new application to production.

But what if the second application changes at the same time, and we want to deploy A2v2 (App 2 version 2) too? We deploy it to the test environment and verify it again. Suppose the e2e tests pass. But now someone has found a critical vulnerability in A1V2. We can't deploy it on prod, so we have to wait for a fix and re-run the tests. What about the deployment of A2V2, which has the green light to go? We can't deploy it to production because we don't know how it will work with A1V1 - maybe there is a missing feature, and backward compatibility doesn't apply here?

The simple solution is to have three test environments - one for testing app 1, one for testing app 2, and one for testing both new versions. So we would have: A1V2 & A2V1, A1V1 & A2V2, A1V2 & A2V2. This way, we are sure that our applications will work properly on production after deployment.

Let's imagine having 10 applications interacting with each other. When we would like to take the same strategy as for 2 applications, we are opening the gates to hell. People deal with such situations through some synchronization of deployments. The test environment is blocked after installation of fresh applications. During this time, only bug fixes can be delivered to that environment. After verification, this test environment is promoted to the production environment. It works, but it is slow, and it may slow down the whole deployment process.

Imagine that application 1 delivers a new urgent feature, but application 2 has a critical bug. We can rollback application 2 or wait for a fix. The second app development team says they will fix that bug in a week, but the manager of the second application says they can't wait another month for deployment on prod. The manager of the first app says that their feature is urgent and can't wait a day longer. Even after rolling back the second app, we need to verify if everything works. If it does not work, we are screwed.

Things become even more complicated in the microservices environment, where we have many applications developed separately. One of the greatest advantages of having microservices is independent deployment. When implementing this 'e2e environment' approach, we are losing this. Our microservice architecture collapses into a distributed monolith. So, this should be avoided.

We can solve this problem with two steps:

1. Proving that each application works fine in an isolated environment where all other necessary applications are stubbed.
2. Proving that the subs used in step 1 are actual. They have to respond exactly how they would respond in the production environment.

Step 1 may be achieved by writing proper integration tests, and step 2 by using contract tests between integrated applications. This is a verified and well-known approach ([Martin Fowler wrote about that](https://martinfowler.com/bliki/IntegrationTest.html)).

# How to work with contract tests?

When using the [Spring Cluod Contract (SCC)](https://spring.io/projects/spring-cloud-contract) framework, the contract tests on the provider side are generated automatically. You need to provide a base class for tests, which will set up your application. The framework can also generate stubs of your application based on those contracts (and push them to your Maven repository). The consumer project can also use the SCC framework to import those stubs and run them automatically. With this, our CI/CD pipelines can guarantee that all those applications integrate together properly. A new version of the producer can't be deployed if it breaks any contract. A new version of the consumer can't be deployed if it works incorrectly with the actual version of the producer.

After the successful build of the producer, its new stubs are distributed. If we change some contract and adjust the producer application to that change, its CI/CD pipeline allows us to deploy the new version, which may not integrate with actual versions of consumers. How can we prevent that?

 - First of all (regardless of whether you use contract tests or not), your application has to be backward compatible to allow dependent applications to adjust to the changes. The producer team should write the new contract and make the old one as deprecated. After all consumers adopt the new contract, the old one should be removed. I'd suggest not deleting deprecated functionality yet. Maybe someone hasn't adjusted their application yet? This would break their CI/CD, but not affect the production environment. For sure, the missed team would ask the producer team what is going on.
 - Next, let's answer the question: why does the contract have to change? Obviously, it's because someone needs a change :D But wait, what about the others? Maybe they don't want to change anything here? How to ensure that anyone else uses the given contract? The SCC framework doesn't help here. Maintaining the list of consumers in the contract repo seems to be the simplest solution. Each team adds an entry in the contract about that they are using it. If the team doesn't want to use this contract anymore, they remove the entry from the file. If somebody wants to modify this contract, they have to involve all the teams listed in the contract file.
 - If someone doesn't follow this rule and doesn't add their team into the contract file, then their application after the change won't pass tests in the CI/CD pipeline. They will notice that something has changed :) and remember the thing I have mentioned in the previous point: don't delete deprecated code yet. Don't break production for those forgetting teams.
 - What if some team won't delete itself from the contract file after stopping using it? I think it's easy: the developer deletes some code, and life goes on. Someone will ask them if they have something against applying some changes in the contract. They will have to check if they are using described functionality and how they use it. It's a waste of time for all, and other people will surely teach them what they should do :)

In the above consideration, we assumed that each consumer can get the same response. There is a common case when each consumer needs its own response. The SCC framework doesn't support modifying generated stubs' responses in the consumer application integration tests. How do Spring folks deal with that? They propose that every consumer should have its own contract for given functionality. The SCC stubs generator can then generate separate stubs per consumer. With this approach, the producer team has to be aware of all contracts for given functionality for all consumers. Let's look at an example:

One functionality is used by two consumers, each of which has its own contract defined. Suddenly, the first consumer wants a change in the functionality. Let's say the producer team forgot about the other consumer. They develop the functionality, which is backward compatible. When they finally want to remove the backward compatibility, they can't because the other contract test fails. They contact the forgotten consumer team about applying these changes to their application, and they say it is not possible. The producer team is then stuck with this backward compatibility patch forever. Is this bad? Yes and no. No, because it works. Yes, because code should be simple. Knowledge about the differences in the needs of both consumers could result in the producer team taking a different approach, such as preparing separate functionality or having both consumer teams negotiate about this functionality.

So, how can we avoid this situation? Of course, we can say that the producer team should remember to check different contracts. How can we make it easier? I would suggest tagging or categorizing contracts for a given functionality. A good idea is to keep all contracts for one functionality close together. What if there are ~100 or more consumers for one functionality and it needs to be changed? I won't give you a simple solution, but it's great that the producer team is aware that changing that functionality wouldn't be easy.

The great thing about these contract tests is that developers can (and should!) execute them locally while writing code. They will receive fast feedback that their changes won't affect anything. They will also be sure that their functionalities will work properly in the production environment.

How can a producer team developer work on implementing a new (or modified) contracted feature? Contracts are text files and should be stored in a version control system (Git is the most popular). These contract files can be stored as a standalone repository or inside the provider project. Basically, the developer creates a new branch, applies the approved change to the contract, and makes the application fulfill this contract. The developer executes contract tests (as you remember, they are generated automatically) and writes the code to make them pass. Simple and easy, as everything should be.

# Who should write contract and their code first?

People are currently discussing two approaches to team cooperation in feature implementation based on contract testing: `producer first` and `consumer first`. In addition to these, I'm introducing two more approaches: `both at the same` time and `ping pong`.

`Producer first` means that the producer team creates the contract and implements functionalities that fulfill the contract. After this is done, the consumer team can fetch new stubs and create their functionality based on the contract.

`Consumer first` means that the consumer team creates the contract and writes code using it. When this is done, the contract is distributed to the provider team, and they write functionality that fulfills the contract. Consumer code can't be deployed until the producer team delivers functionality implementation.

`Both at the same time` means that the contract is established before teams start writing the code. With that, both teams work in parallel. Consumer code can't be deployed until the producer team delivers functionality implementation.

`Ping pong` is a unique variation that combines elements of the three approaches mentioned above, but with some optimizations. This approach consists of three distinct phases:

1. Contract initialization phase. The contract snapshot is established before teams start writing the code.
2. Contract negotiation phase. One of the teams starts the implementation. They implement a POC (Proof Of Concept) to prove that the contract is valid. If the contract is not applicable, it is renegotiated. After renegotiation, the team modifies their POC. Then, the other team also implements a POC to prove that the contract is valid on their side. If it's invalid, both teams renegotiate the contract. The other team writes the POC to the end. If the contract was changed in this step, the first team applies changes to their POC. This cycle is repeated until both teams would have working POCs.
3. Contract implementation. At this point, we have a contract release candidate established. Teams can redefine their cooperation model to one of producer first, consumer first, both at the same time, or ping pong. It seems logical to take both at the same time now: both teams have implemented some code to prove that the contract wouldn't change. But sometimes, in huge legacy monoliths, where implementation impacts plenty of functionalities, it may not be enough. If teams decide on ping pong, then they are not writing POC anymore, they will write the implementation. Developers should have in the back of their minds that their implementation may change, so they should write code that would be easily changed.

Contract negotiation example:
<div class="mermaid" style="font-size: 1.7ex">
    sequenceDiagram
      
      participant 1 as First team
      participant 2 as Second team

      1->>2: POC done - contract is valid
      2->>1: POC failed - contract is invalid
      1->2: Contract renegotiation
      2->>1: POC done - contract is valid
      1->>2: POC failed - contract is invalid
      1->2: Contract renegotiation
      1->>2: POC done - contract is valid
      2->>1: POC done - contract is valid
</div>

Comparison in specific situations:

| Situation | Producer First | Consumer First | Both | Ping Pong |
| --------- | -------------- | -------------- | ---- | --------- |
| The contract is not applicable on the producer side | The producer team contacts the consumer team to discuss the issue. The consumer team has not written any code yet. | The consumer team renegotiates the contract with the producer team and modifies their solution. The consumer team must apply changes to their solution. | Chaos | Is optimized if the producer team is first. |
| The contract is not applicable on the consumer side | The consumer team contacts the producer team to change the contract. The producer team has already created an implementation and needs to apply changes. | The consumer team renegotiates the contract with the producer team. The consumer team re-implements their solution. The producer team has not started implementation yet. | Chaos | Is optimized if the consumer team is first. |
| The contract is trivial and is applicable on both sides without any changes. | The producer team delivers the feature and the consumer team delivers their feature. | The contract team implements the feature and waits for the producer team to deliver the feature on their side. Then the consumer team delivers the feature. | Both teams are developing in parallel. The consumer team can merge their feature after the producer team delivers their side. | Too much context switching. |

It's important to note that the contract may first be inapplicable on the consumer side, then the modified contract may become inapplicable on the producer side, and so on. Each option has its pros and cons, and there is no one-size-fits-all approach. Teams should communicate and choose the most optimal approach for their situation.
