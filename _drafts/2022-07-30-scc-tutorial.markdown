---
layout: post
title:  "SCC tutorial"
date:   2022-05-11 21:15:46 +0200
categories: scc contract test spring
---
When we have two applications interacting with each other, we often can say that one of them are providing some functionalify and other is consuming it (We name them producer and consumer). How we can ensure that those applications will work with each other as we expect? There is common pattern for that - deploy those applications to separate environment and verify interactions with end to end (e2e) tests. If one of the application changes, then we are deploying new wersion A1v2 (App 1 version 2) to this test environment and run e2e tests again. If they are green then we can deploy new applicaion to production. What if in the same time second application changes and we want to deploy A2v2 (App 2 version 2) too? We are deploying it to the test environment. Then we need to verify them again. Let's suppose that e2e test are passing. And now, someone have found critical vulnerability in the A1V2. We can't deploy it on prod, we have to wait for fix and next tests. What with the deployment of the A2V2, which have green light to go? We can't deploy it to the production, because we don't know how it will work with A1V1.
The simply solution for that is having 2 test environment - one for testing app 1, one for testing app 2 and one for testing both new versions. So we would have:
A1V2 & A2V1  |  A1V1 & A2V2  |  A1V2 & A2V2
Having that we are sure that our applications will work properly on production after deployment.

Let's imagine having 10 applications interacting with each other. When we would like to take same strategy as for 2 applications, we are opening gates to hell. Peoples are dealing with that situations with some synchronization of deployments. Test environment is blocked after installation of the fresh applications. In that time only bugfixes can be delivered to that environment. After verification, this test environment is promoted to production environment. It works, but it is slowly. And it may slow down the whole deployment process. Imagine that application 1 deliver new urgent feature, application 2 has critical bug. We can rollback application 2 or wait for fix. The second app development team says they will fix that bug in a week. Manager of the second application says they can't wait another month for deployment on prod. Manager of the first app says that thei feature is urgent and can't wait a day longer. Even after rollbacking the second app, we need to verify if everything works. If not, we are screwed.

Things go even more complicated in the microservices environment. We shouldn't delay their deployments, because it destroy the main advantage of using microservices - independent deployments.

We can solve this problem with 2 steps: 
 1. Proving that our application works fine in isolated environment, where all other necessary application are stubbed.
 2. Proving that subs used in step 1. are actual. They have to respond exactly how they would respond in production environment.

Step 1 may be achieved by writting proper integration tests and step 2 by using contract tests between integrating applications. This is verified and [well known approach](https://martinfowler.com/bliki/IntegrationTest.html). 






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
