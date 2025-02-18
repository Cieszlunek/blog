---
layout: post
title:  "TDD lesson"
date:   2023-09-03 13:00:00 +0200
tags: tdd bdd
---

Hi,

Let's get our hands dirty to train basics of TDD. 

We'll develop yet another task manager application. But only a couple of classess, and lets focus on the approach. I'll show you something simple, but powerfull.

Let's define the application template. It will use Java, groovy, gradle, and Spock testing library. Here is how the `build.gradle` file looks like:
{% highlight groovy %}
def foo
  puts 'foo'
end
{% endhighlight %}

I think that it's good to learn on mistakes, so let's first make a mistake. Next, we will discuss what's wrong with it. And of course, we will implement it according to the art. 

## Example application definition

Let's assume that we're working in agile, and we have following tasks to do:

1. We want that our application allows adding and reading of tasks. A task has a summary and a creation date.
2. Application allows for closing the task. Closed tasks doesn't appear on the tasks list anymore.
3. A task can have subtasks. A subtask can belong to only one parent task. Closing a task closes it and all the child tasks.

In this example we don't take care here for writing the adapters, like HTTP REST API. We'll focus on different things.

## Wrongly implemented TDD

### 1. Created tasks can be read

So, because we're working with TDD approach, we will write tests first.

```groovy
package uk.samcz.tm

import spock.lang.Specification

class TaskManagingSpecification extends Specification {

    TaskRepository taskRepository = Mock(TaskRepository)
    TaskManagerFacade taskManagerFacade = new TaskManagerConfiguration().getTaskManagerFacade(taskRepository)

    def "creating a task"() {
        when: "I create a 'TODO' task"
        taskManagerFacade.createTask(new TaskCreateDTO("TODO"))

        then: "'TODO' task is created"
        1 * taskRepository.create(new Task(null, "TODO"))
    }

    def "reading tasks"() {
        given: "a 'TODO' and a 'FIXME' tasks exists"
        taskRepository.getAll() >> [new Task(1, "TODO"), new Task(2, "FIXME")]

        when: "I read all tasks"
        def tasks = taskManagerFacade.getTasks()

        then: "'TODO' and 'FIXME' tasks are returned"
        tasks == [new TaskReadDTO(1, "TODO"), new TaskReadDTO(2, "FIXME")]
    }
}
```

I saw this approach in many projects (and I was writting tests like that too) about: testing class methods and interactions with different classes.

We didn't written any production code yet. That's one of the TDD principle. Test first. Now, let this drive our code creation. 

Before we will create all specified classess, you deserve some explanation about them.

 - `TaskManagerFacade` is an entrypoint to our application. We will interact with the application using this class.
 - `TaskManagerConfiguration` is the utility class who creates an instance of `TaskManagerFacade`. If you use Spring, then this class will be `@Configuration` class.
 - `TaskRepository` - we want to persist somewhere our tasks, right? We won't implement it details. Nowadays, you can use Spring data for writing the code for you. So it will be only interface for us.

Ok, so let's write the code implementing them:

```java
package uk.samcz.tm.module;

import java.util.Objects;

public class Task {

    private final Long id;
    private final String summary;

    public Task(Long id, String summary) {
        this.id = id;
        this.summary = summary;
    }

    public long getId() {
        return id;
    }

    public String getSummary() {
        return summary;
    }
    // equals & hash code
}
```

```java
package uk.samcz.tm.module;

import java.util.List;

public interface TaskRepository {
    long create(Task task);
    List<Task> getAll();
}
```

```java
package uk.samcz.tm.dto;

public record TaskCreateDTO(String summary) {
}
```

```java
package uk.samcz.tm.dto;

public record TaskReadDTO(long id, String summary) {
}
```

```java
package uk.samcz.tm;

import uk.samcz.tm.module.TaskRepository;

public class TaskManagerConfiguration {
    public TaskManagerFacade getTaskManagerFacade(TaskRepository taskRepository) {
        return new TaskManagerFacade(taskRepository);
    }
}
```

```java
package uk.samcz.tm;

import uk.samcz.tm.dto.TaskCreateDTO;
import uk.samcz.tm.dto.TaskReadDTO;
import uk.samcz.tm.module.Task;
import uk.samcz.tm.module.TaskRepository;

import java.util.List;

public class TaskManagerFacade {
    private final TaskRepository taskRepository;

    TaskManagerFacade(TaskRepository taskRepository) {
        this.taskRepository = taskRepository;
    }

    public void createTask(TaskCreateDTO taskCreateDTO) {
        taskRepository.create(newTask(taskCreateDTO));
    }

    public List<TaskReadDTO> getTasks() {
        return taskRepository.getAll()
                .stream()
                .map(task -> new TaskReadDTO(task.getId(), task.getSummary()))
                .toList();
    }

    private Task newTask(TaskCreateDTO dto) {
        return new Task(null, dto.summary());
    }
}
```

### 2. Task closing

Again, let's write test first:

```groovy
class TaskManagingSpecification extends Specification {
    ...

    def "closing a task"() {
        when: "I close the 'TODO' task, which has id = 1"
        taskManagerFacade.closeTask(1)

        then: "'TODO' task is deleted"
        1 * taskRepository.delete(1)
    }
}
```

and implement the code

```java
public class TaskManagerFacade {
    ...

    void closeTask(Long taskId) {
        taskRepository.delete(taskId);
    }
}
```

```java
public interface TaskRepository {
    Long create(Task task);
    List<Task> getAll();

    Long delete(Long integer);
}
```

Nothing challenging so far. 

Później dodajemy metodę closeTask - wyszukuje zadanie po jego id. Jeżeli nie istnieje to wyrzuca wyjątek. Jeżeli istnieje to je usuwa.

Jaki refactor, który zmieni sygnatury metod?

### 3. Task can have subtasks

Test:

```groovy
class TaskManagingSpecification extends Specification {
    ...

    def "creating a subtask"() {
        given: "a 'TODO' task exists"
        taskRepository.findById(1) >> new Task(1, "TODO")

        when: "I add the 'FIXME' subtask to 'TODO' task"
        taskManagerFacade.createSubtask(new SubtaskCreateDTO(1, "FIXME"))

        then: "the 'TODO' task is saved with the new 'FIXME' subtask"
        1 * taskRepository.save(new Task(1, "TODO", List.of(new Task(null, "FIXME"))))
    }

    def "fetching a task with subtask"() {
        given: "'TODO' task has 'FIXME' subtask"
        taskRepository.findById(1) >> new Task(1, "TODO", List.of(new Task(2, "FIXME")))

        when: "I add the 'FIXME' subtask to 'TODO' task"
        taskManagerFacade.createSubtask(new SubtaskCreateDTO(1, "FIXME"))

        then: "the 'TODO' task is saved with the new 'FIXME' subtask"
        tasks == [new TaskReadDTO(1, "TODO", [new TaskReadDTO(2, "FIXME")])]
    }
}
```