---
layout: post
title:  "To microservice or to not microservice?"
date:   2023-05-21 13:00:00 +0200
tags: microservice monolith module architecture
---

Hi,

Recently I have read [an article](https://medium.com/@abhishekranjandev/the-amazon-prime-video-monolith-shift-dissecting-microservices-serverless-and-the-real-world-ec18e429ad6f#:~:text=The%20Amazon%20Prime%20Video%20team%E2%80%99s%20recent%20case%20study,in%20a%20significant%2090%25%20reduction%20in%20operating%20expenses.) written by Abhishek Ranjan on Medium about that Amazon has joined several microservices into the mononolith and reduced their operating expenses in 90%. It's great to read such news and because I'm thrifty I'm happy that less electricity is needed to run this service :)

Recently I had read a post on Linkedin about that, and many people shared their opinion that microservices are s***t. And monolith is the way (1). There were several people who shared words of wisdom that architecture should be carefully chosen to not stuck with something that is inefficient, complicated and hard to mantain. Basically that is true, but it's hard (2). 

These two things motivated me to write this post. I'd like to share with you my thoughts to unreveal some unspoken words and show you an another way.

Before we jump right into the fire, let's step back. Why we are even develop applications? For money :) but the right answer should be: to satisfy some business needs. To help people from business to do their job, to let them excel in what they do. 

Kiedy zapytasz się klienta, na kiedy chce aplikację, to odpowie, że na jutro, albo na wczoraj. Można niewiele myśląc po prostu naklepać jakkolwiek trochę kodu w jakiejś technologii, używająć jakichśtam bibliotek, spełniającą zadane wymagania funkcjonalne i niefunkcjonalne. Będzie szybko i biznes będzie zadowolony. A jutro przyjdzie ktoś i powie, że chcą jeszcze taką funkcję i taką, a to powinno być trochę inaczej działać. Albo będą się skarżyć, że coś działa zbyt wolno. I, oczywiście, trzeba to zrobić na już! O tym, jak szybko można wprowadzić nowe funkcjonalności i modyfikować istniejące ma dyży wpływ wykorzystana architektura i czystość kodu. Architekrura też ma duży wpływ na działania pozafunkcjonalne. 

Przed rozpoczęciem projektu można oczywiście zatrzymać się i zastanowić jaką architekturę wybrać. Tylko bez przesady z tym zastanawianiem się, bo ktoś czeka na ten program. Jak 

What could be a difference between two applications, which delivers exactly the same functionalities? I'll mention only a few of them: operational costs (like in the Amazon Prime Video case), the time that was needed to create the application, the time needed to deliver new functionalities to this application, the costs of maintanance (support, bugs, their fixes), the efficiency. These non-functional things are dependent of chosen architecture and how clean is the code.



Ad. (2). Of course, before the project is started, we can gather software engineers and think about the needs to propose the solution architecture. How valuable it be it depends of the experience, communication skills, understanding the problem domain of those people and the time. It's great approach, but we have to be carefull to not run into analysis paralize. 

If you'd ask people from business when they would like to get application they would say tomorrow (or yesterday!). If you have really experienced team, then they could predict proper architecture for the solution without spending a lot of time on the analisys. Both monolithic architecture and microservices architecture have their pros and cons. 

co chcę przekazać? że business value delivery time jest bardzo kluczowe.

