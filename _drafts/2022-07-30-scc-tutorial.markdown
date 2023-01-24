---
layout: post
title:  "Contract tests"
date:   2022-05-11 21:15:46 +0200
categories: scc contract test spring
---

# Why and when contract tests are usefull

When we have two applications interacting with each other, we often can say that one of them are providing some functionalify and other is consuming it (lets name them producer and consumer). How we can ensure that those applications will work with each other as we expect? There is common pattern for that - deploy those applications to separate environment and verify interactions with end to end (e2e) tests. If one of the application changes, then we are deploying new wersion A1v2 (App 1 version 2) to this test environment and run e2e tests again. If they are green then we can deploy new applicaion to production. What if in the same time second application changes and we want to deploy A2v2 (App 2 version 2) too? We are deploying it to the test environment. Then we need to verify them again. Let's suppose that e2e test are passing. And now, someone have found critical vulnerability in the A1V2. We can't deploy it on prod, we have to wait for fix and next tests. What with the deployment of the A2V2, which have green light to go? We can't deploy it to the production, because we don't know how it will work with A1V1 - maybe there is missing some feature and backward compability doesn't apply here?
The simply solution for that is having 3 test environment - one for testing app 1, one for testing app 2 and one for testing both new versions. So we would have:
A1V2 & A2V1  |  A1V1 & A2V2  |  A1V2 & A2V2
Having that we are sure that our applications will work properly on production after deployment.

Let's imagine having 10 applications interacting with each other. When we would like to take same strategy as for 2 applications, we are opening gates to hell. Peoples are dealing with that situations with some synchronization of deployments. Test environment is blocked after installation of the fresh applications. In that time only bugfixes can be delivered to that environment. After verification, this test environment is promoted to production environment. It works, but it is slowly. And it may slow down the whole deployment process. Imagine that application 1 deliver new urgent feature, application 2 has critical bug. We can rollback application 2 or wait for fix. The second app development team says they will fix that bug in a week. Manager of the second application says they can't wait another month for deployment on prod. Manager of the first app says that their feature is urgent and can't wait a day longer. Even after rollbacking the second app, we need to verify if everything works. If it not works, we are screwed.

Things go even more complicated in the microservices environment, where we have many applications developed separately. One of greatest advantage of having microservices is independent deployment. When implementing this `e2e environment` approach, we are losing this. Our microservice architecture collaps to distributed monolith. So this should be avoided.

We can solve this problem with 2 steps: 
 1. Proving that each application works fine in isolated environment, where all other necessary application are stubbed.
 2. Proving that subs used in step 1. are actual. They have to respond exactly how they would respond in production environment.

Step 1 may be achieved by writting proper integration tests and step 2 by using contract tests between integrated applications. This is verified and [well known approach](https://martinfowler.com/bliki/IntegrationTest.html).

# Contract tests - how to work with them?

While using [Spring Cluod Contract (SCC)](https://spring.io/projects/spring-cloud-contract) framework, the contract tests on the provider side are generated automatically. It also can generate stubs of you application based on those contracts (and push them to your maven repository). Consumer project can also use SCC framework to import those stubs and run them automatically. Having that, our CI/CD pipelines can guarantee that all those applications integrates together properly. New version of producer can't be deployed if they break any contract. New version of consumer can't be deployed if it works wrong with actual version of producer.

After successfull build of producer, it's new stubs are distributed. So, if we change some contract and adjust producer application to that change, it's CI/CD pipeline allows to deploy the new version, which may not integrate with actual versions of consumers. How we can prevent that? 

 - First of all (regardless if you use contract tests or not) your application has to be backward compatible to allow dependent applications to adjust to the changes. So, producer team should write the new contract and make the old one as deprecated. After all consumers adopt to the new contract, old one should be removed. I'd suggest not deleting deprecated functionality yet. Maybe someone haven't adjusted their appliation yet? This would break their CI/CD, but not affect production environment. For sure the missed team would ask producer team what is going on.
 - Next, let's answer the question: why does contract has to change? Obviously, it's because someone needs a change :D But wait, what with the others? Maybe they don't want to change anything here? How to ensure that anyone else uses given contract? SCC framework doesn't help here. Maintaining the list of consumers in the contract repo seems to be the simplest solution. Each team adds entry in contract about that they are using it. If the team don't want to use this contract anymore, they removes the entry from file. If somebody want to modify this contract, he has to involve all the teams listed in the contract file. 
   - If someone doesn't follow this rule and don't add his team into the contract file, then their application after the change won't pass tests in CI/CD pipeline. They will notice that something has changed :) and remember about the thing I have mentioned in previous point: don't delete deprecated code yet. Don't break production for those forgotting teams.
   - What if some team won't delete itself from contract file after stoping using it? I think it is easy: developer deletes some code and life goes on. Someone will ask them if they have something against applying some changes in the contract. They will have to check if they are using described functionality and how they use it. It's a waste of the time for all, and other peoples for sure will teach them what they should do :)

The great thing about those contract tests is the fact that developers can (and should!) execute them locally while writing code. They will have fast feedback that their changes won't screw anything. They will also be sure that their functionalities are going to work properly in real production environment.

How producer team developer can work on the new (or modified) contracted feature implementation? Contracts are the text files, and they should be stored in version control system (git is most popular). Those contract files can be stored as standalone repository or inside the provider project. Basically, developer creates new branch, apply approved change to the contract, and make the application fulfill this contract. Developer executes contract tests (as you remember, they are generated automatically) and write the code to make them green. Simple and easy, as everything should be :)

# Who should write contract and their code first?

We have two parties there, so we have three options: `producer first`,  `consumer first` and `both in the same time`. Don't google the last one, I've made it up now :)

`producer first` means that producer team creates the contract and implement functionalities fulfilling the contract. After this is done, consumer team can fetch new stubs and create their functionality based on the contract.

`consumer first` means that consumer team creates the contract and write code using it. When this is done, contract is distributed to the provider team and they write functionality fulfilling the contract.

`both in the same time` means that the contract is established before teams start writing the code.









You’ll find this post in your `_posts` directory. Go ahead and edit it and re-build the site to see your changes. You can rebuild the site in many different ways, but the most common way is to run `jekyll serve`, which launches a web server and auto-regenerates your site when a file is updated.

Jekyll requires blog post files to be named according to the following format:

`YEAR-MONTH-DAY-title.MARKUP`

Where `YEAR` is a four-digit number, `MONTH` and `DAY` are both two-digit numbers, and `MARKUP` is the file extension representing the format used in the file. After that, include the necessary front matter. Take a look at the source for this post to get an idea about how it works.

Jekyll also offers powerful support for code snippets:

{% highlight ruby %}
def print_hi(name)
  puts "Hi, #{name}"
end
print_hi('Tom')
#=> prints 'Hi, Tom' to STDOUT.
{% endhighlight %}

Check out the [Jekyll docs][jekyll-docs] for more info on how to get the most out of Jekyll. File all bugs/feature requests at [Jekyll’s GitHub repo][jekyll-gh]. If you have questions, you can ask them on [Jekyll Talk][jekyll-talk].

[jekyll-docs]: https://jekyllrb.com/docs/home
[jekyll-gh]:   https://github.com/jekyll/jekyll
[jekyll-talk]: https://talk.jekyllrb.com/
